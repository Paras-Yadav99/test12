public class MLSCallout {
    public static final String MLS_KEY = 'MLS';

    public static void getListInventoryItems(){
        Map<String, Call_Out_Setting__mdt> calloutMap = new Map<String, Call_Out_Setting__mdt>();

        for(Call_Out_Setting__mdt setting : Call_Out_Setting__mdt.getAll().values()){
            calloutMap.put(setting.DeveloperName , setting);
        }
        String endpoint = calloutMap.get(MLS_KEY).endpoint__c;
        String authorization = calloutMap.get(MLS_KEY).Authorization__c;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        request.setHeader('Authorization', authorization);
        request.setTimeout(120000);
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            MLSCalloutHelper.Listings responseBody = (MLSCalloutHelper.Listings)
            JSON.deserialize(response.getBody(), MLSCalloutHelper.Listings.class);
            System.debug(responseBody);
        }
    }

    public static void getInventoryInfo(Integer listingId){
        Map<String, Call_Out_Setting__mdt> calloutMap = new Map<String, Call_Out_Setting__mdt>();

        for(Call_Out_Setting__mdt setting : Call_Out_Setting__mdt.getAll().values()){
            calloutMap.put(setting.DeveloperName , setting);
        }
        String endpoint = calloutMap.get(MLS_KEY).endpoint__c;
        String authorization = calloutMap.get(MLS_KEY).Authorization__c;
        if(listingId != null){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            request.setEndpoint(endpoint+'/'+String.valueOf(listingId));
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Authorization', authorization);
            request.setTimeout(120000);
            
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                MLSCalloutWrapper responseBody = (MLSCalloutWrapper)
                JSON.deserialize(response.getBody(), MLSCalloutWrapper.class);
                System.debug(responseBody);
            }
        }
    }

    public static void deleteInventoryItem(List<Integer> listingIds){
        List<Product2> unitsToUpdate = [SELECT Id, MLS_Number__c, My_Little_Salesman_Listing__c 
            FROM Product2 WHERE MLS_Number__c IN :listingIds];
        Map<String, Call_Out_Setting__mdt> calloutMap = new Map<String, Call_Out_Setting__mdt>();

        for(Call_Out_Setting__mdt setting : Call_Out_Setting__mdt.getAll().values()){
            calloutMap.put(setting.DeveloperName , setting);
        }
        String endpoint = calloutMap.get(MLS_KEY).endpoint__c;
        String authorization = calloutMap.get(MLS_KEY).Authorization__c;
        for(Product2 unit : unitsToUpdate){
            if(unit.MLS_Number__c != null){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint+'/'+String.valueOf(Integer.valueOf(unit.MLS_Number__c)));
                request.setMethod('DELETE');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setHeader('Authorization', authorization);
                request.setTimeout(120000);
                
                HttpResponse response = http.send(request);
                if(response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                } else {
                    System.debug(response.getBody());
                    unit.MLS_Number__c = null;
                    unit.Is_Listed_On_MLS__c = false;
                }
            }
        }

        if(unitsToUpdate != null && unitsToUpdate.size() > 0){
            update unitsToUpdate;
        }
    }

    public static void addInventory(Set<Id> unitIds){
       new MLSCalloutHelper(unitIds)
       .addInventoryItem();

    }

    public static void updateInventory(Set<Id> unitIds){
        new MLSCalloutHelper(unitIds)
        .updateInventoryItem();
    }

    private static void updateUnitAfterDelete(Integer listingId){

    }
}