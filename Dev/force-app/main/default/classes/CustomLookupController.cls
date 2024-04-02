public with sharing class CustomLookupController {

    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query;
            if(objectName == 'Equipment__c'){
                query = 'SELECT Id, On_Off_Highway__c, Name, ' + filterField + ' FROM '+objectName;
            }else if(objectName == 'Account'){
                query = 'SELECT Id, Do_NOT_List_any_Units_on_MT__c, Do_not_market_Construction_Equip_Guide__c, Do_not_market_Craigslist__c, '+ 
                'Do_not_market_Facebook__c, Do_not_market_FB_Marketplace__c, Do_Not_Market_Fleet_Up_Marketplace__c, Do_not_market_GearFlow__c, '+ 
                'Do_not_market_Instagram__c, Do_not_market_LinkedIn__c, Do_not_market_Machinio__c, Do_not_market_Mascus__c, Do_not_market_MT_incl_Crane_Truck__c, '+
                'Do_not_market_MyLittleSalesman__c, Do_not_market_Terrapoint__c, Do_not_market_TradeMachines__c, Do_not_market_Used_Equip_Guide__c, Do_not_market_Zonapesada__c, '
                +filterField + ' FROM '+objectName;
            }else if(objectName == 'Contact'){
                query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
                query += ' WHERE ('+filterField+
                            ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim())+ '%\''+
                            ' OR Name'+ ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim())+
                            '%\' )';
                if(String.isNotBlank(value) && value != null ) {
                 query += ' AND AccountId = \''+ value + '\' LIMIT 49999';
                }
            }
            else{
                query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            }
            System.debug(query);
            if(objectName != 'Contact'){
                if(String.isNotBlank(value) && value != null ) {
                    query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                            ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim())+ '%\''+
                            ' OR Name'+ ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim())+
                            '%\' LIMIT 49999';
                }
            }
            
            System.debug(query);
	        for(SObject s : Database.query(query)) {
                if(objectName == 'Equipment__c'){
                    List<String> fields = filterField.split(',');
                    RecordsData recordData = new RecordsData();
                    recordData.label = (String)s.get('Name');
                    recordData.onOffHighway = (String)s.get('On_Off_Highway__c');
                    recordData.value = (String)s.get('id');
                    recordsDataList.add( recordData);
                }
                else if(objectName == 'Contact'){
                    List<String> fields = filterField.split(',');
                    RecordsData recordData = new RecordsData();
                    recordData.label = (String)s.get('Name');
                    recordData.value = (String)s.get('id');
                    recordsDataList.add( recordData);
                }else{
                    RecordsData recordData = new RecordsData();
                    recordData.label = (String)s.get(filterField);
                    recordData.value = (String)s.get('id');
                    recordData.listMT = getListingStatus(s.get('Do_NOT_List_any_Units_on_MT__c'));
                    recordData.listconstruction = getListingStatus(s.get('Do_not_market_Construction_Equip_Guide__c'));
                    recordData.listCraigslist = getListingStatus(s.get('Do_not_market_Craigslist__c'));
                    recordData.listFacebook = getListingStatus(s.get('Do_not_market_Facebook__c'));
                    recordData.listFBMarketplace = getListingStatus(s.get('Do_not_market_FB_Marketplace__c'));
                    recordData.listFleetUpMarketplace = getListingStatus(s.get('Do_Not_Market_Fleet_Up_Marketplace__c'));
                    recordData.listGearFlow = getListingStatus(s.get('Do_not_market_GearFlow__c'));
                    recordData.listInstagram = getListingStatus(s.get('Do_not_market_Instagram__c'));
                    recordData.listLinkedIn = getListingStatus(s.get('Do_not_market_LinkedIn__c'));
                    recordData.listMachinio = getListingStatus(s.get('Do_not_market_Machinio__c'));
                    recordData.listMascus = getListingStatus(s.get('Do_not_market_Mascus__c'));
                    recordData.listMT2 = getListingStatus(s.get('Do_not_market_MT_incl_Crane_Truck__c'));
                    recordData.listMLS = getListingStatus(s.get('Do_not_market_MyLittleSalesman__c'));
                    recordData.listTerrapoint = getListingStatus(s.get('Do_not_market_Terrapoint__c'));
                    recordData.listTradeMachines = getListingStatus(s.get('Do_not_market_TradeMachines__c'));
                    recordData.listUsedEquipGuide = getListingStatus(s.get('Do_not_market_Used_Equip_Guide__c'));
                    recordData.listZonapesada = getListingStatus(s.get('Do_not_market_Zonapesada__c'));
                    recordsDataList.add( recordData );
                }
	        }
            return recordsDataList;
	    } catch (Exception err) {
	    	if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
	    }
    }

    private static String getListingStatus(Object donotList){
        return Boolean.valueOf(donotList) ? 'Do not Advertise' : 'Advertise';
    }

    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String onOffHighway;
        @AuraEnabled public String listMT;
        @AuraEnabled public String listconstruction;
        @AuraEnabled public String listCraigslist;
        @AuraEnabled public String listFacebook;
        @AuraEnabled public String listFBMarketplace;
        @AuraEnabled public String listInstagram;
        @AuraEnabled public String listFleetUpMarketplace;
        @AuraEnabled public String listGearFlow;
        @AuraEnabled public String listLinkedIn;
        @AuraEnabled public String listMachinio;
        @AuraEnabled public String listMascus;
        @AuraEnabled public String listMLS;
        @AuraEnabled public String listMT2;
        @AuraEnabled public String listTerrapoint;
        @AuraEnabled public String listTradeMachines;
        @AuraEnabled public String listUsedEquipGuide;
        @AuraEnabled public String listZonapesada;
    }
}