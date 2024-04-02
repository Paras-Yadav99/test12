public class CustomChildFieldController {
    
    @AuraEnabled
    
    public static AuraResponse picklistOptionResponse(string ObjectApi_name , String Field_name){ //Aura Method 
        
        
        AuraResponse AuraResponse;
        
        try{
            
            if(string.isNotEmpty(ObjectApi_name) && string.isNotEmpty(Field_name)){  			 // try method
                AuraResponse = new AuraResponse(true ,
                                                'Success',
                                                JSON.serialize(getPicklistValues(ObjectApi_name , Field_name)));         
            }
            
            else {
                AuraResponse = new AuraResponse(false ,
                                                'error',
                                                'ObjectName and FieldName is not Found');   
            }
            
        }
        catch (exception ex){				//catch method
            
            AuraResponse = new AuraResponse(false ,
                                            'Error',
                                            ex.getMessage());
            
        }
        
        return AuraResponse;
        
    } 

    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
            } else {
                query += ' WHERE '+filterField+
                    ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
            }
            for(SObject s : Database.query(query)) {
                recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
            }
            return recordsDataList;
        } catch (Exception err) {
            if ( String.isNotBlank(err.getMessage()) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    @AuraEnabled
    public static List<RecordsData> getPicklistValues(String ObjectApi_name,String Field_name){  
        List<RecordsData> lstPickvals = new List<RecordsData>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(new RecordsData(a.getLabel(),a.getValue()));//add the value  to our final list
        }
        return lstPickvals;
    }
    
    public class AuraResponse{
        
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public string message;
        @AuraEnabled public string response;
        
        AuraResponse(Boolean isSuccess,
                     String message,
                     string response){
                         
                         this.isSuccess = isSuccess;
                         this.message = message;
                         this.response = response;
                     }
    }
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
}