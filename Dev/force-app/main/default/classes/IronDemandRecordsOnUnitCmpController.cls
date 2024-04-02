public class IronDemandRecordsOnUnitCmpController {
@AuraEnabled(cacheable=true)
    public static AuraResponse getIronDemandRecords(string recordId) { 
        AuraResponse auraResponse;
        list<Equipment__c> lstEquipment = new list<Equipment__c>();
        list<IronDemandWrapper> lstIronDemandWrapper = new list<IronDemandWrapper>();
        /* product2 newProduct = [SELECT id,equipment__c
			FROM product2
			WHERE ID =:recordId LIMIT 1];*/
        try{
            if(string.isnotBlank(recordId)){
                lstEquipment = [SELECT id,(SELECT id,IronDemand_Iron__c,Name,Make__c,Model__c,IsActive__c,IronDemand_Iron__r.Name
                                           FROM Iron_Demands__r) 
                                FROM Equipment__c
                                WHERE id In(SELECT equipment__c
                                             FROM product2
                                             WHERE ID =:recordId)];
                system.debug('lstEquipment::'+lstEquipment);
            }
            if(lstEquipment != null && !lstEquipment.isEmpty() ){
                for(Equipment__c eachEquipment : lstEquipment){
                    for(Iron_Demand__c eachIron_Demand : eachEquipment.Iron_Demands__r){
                        IronDemandWrapper newIronDemandWrapper = new IronDemandWrapper();
                        newIronDemandWrapper.Id = eachIron_Demand.Id;
                        newIronDemandWrapper.Name = eachIron_Demand.Name;
                        newIronDemandWrapper.Equipment = eachIron_Demand.IronDemand_Iron__r.Name;
                        newIronDemandWrapper.Make = eachIron_Demand.Make__c;
                        newIronDemandWrapper.Model = eachIron_Demand.Model__c;
                        newIronDemandWrapper.IsActive = eachIron_Demand.IsActive__c;
                        lstIronDemandWrapper.add(newIronDemandWrapper);
                    }
                }
            }
            if(lstIronDemandWrapper != null && !lstIronDemandWrapper.isEmpty()){
                auraResponse = new AuraResponse();
                auraResponse.isSuccess = true;
                auraResponse.message = 'IronDemand Records';
                auraResponse.lstIronDemand = lstIronDemandWrapper;
                return auraResponse;
            }
            else{
                auraResponse = new AuraResponse();
                auraResponse.isSuccess = false;
                auraResponse.message = 'Records not found';
                return auraResponse;
            }
        }catch(exception ex){
             auraResponse = new AuraResponse();
            auraResponse.isSuccess = false;
            auraResponse.message = ex.getmessage();
        }
        return auraResponse;
        
    }
    
    public class AuraResponse {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
        @AuraEnabled public String response;
        @AuraEnabled public list<IronDemandWrapper> lstIronDemand;
    }
    public class IronDemandWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Equipment;
        @AuraEnabled public string Make;
        @AuraEnabled public string Model;
        @AuraEnabled public boolean IsActive;
    }
}