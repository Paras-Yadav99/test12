public class sendMachineEmailController {
@AuraEnabled
    public static AuraResponse returnRecord(String recordId){
        AuraResponse AuraResponse;
        
        try{
            if(string.isNotBlank(recordId)){
                AuraResponse = handleUpdateFreightData(recordId);
            }else{
                AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                           'RecordId is not there!');
            }
            
            //Check for input Value
           /* AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                            handleUpdateFreightData(wrapperKey));*/
            
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        
        // Returning Aura-Response to LWC
        return AuraResponse;
    }
    
    public static AuraResponse handleUpdateFreightData(String wrapperKey){
        String objectName = getObjectNameFromRecordId(wrapperKey);
        AuraResponse AuraResponse;
        wrapperData newWrapperData = new wrapperData();
        system.debug('objectName:::'+objectName);
        if(string.isNotBlank(objectName) && objectName == 'Lead' ){
            Lead newLead = [SELECT id, name,Unit__c, Email,Contact__c	 FROM Lead WHERE id =: wrapperKey LIMIT 1];
            if((string.isNotBlank(newLead.Email)|| newLead.Contact__c!=null) && newLead.Unit__c!=null){
                newWrapperData.RecordId = newLead.id;
                newWrapperData.unitID = newLead.Unit__c;
                //JSON.serialize(newWrapperData0)
                AuraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(newWrapperData));
            }else if((string.isNotBlank(newLead.Email)|| newLead.Contact__c!=null) && newLead.Unit__c==null){
                AuraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'Unit is not there on the lead');
            }else if((string.isBlank(newLead.Email)&& newLead.Contact__c==null) && newLead.Unit__c!=null){
                AuraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'Contact and Email is not there on the lead');
            }else{
                AuraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'Contact, Email and Unit are not there on the lead');
            }
            
            
        }else if(string.isNotBlank(objectName) && objectName == 'Opportunity'){
            Opportunity newOpportunity = [SELECT id, name,Product__c FROM Opportunity WHERE id =: wrapperKey LIMIT 1];
            if( newOpportunity.Product__c!=null){
                newWrapperData.RecordId = newOpportunity.id;
                newWrapperData.unitID = newOpportunity.Product__c;
                //JSON.serialize(newWrapperData0)
                AuraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(newWrapperData));
            }else {
                AuraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'Unit is not there on the Opportunity');
            }
        }
        return AuraResponse;
    }
     public class wrapperData{
        @AuraEnabled 
        public String RecordId{get;set;}
        @AuraEnabled 
        public String unitId{get;set;}
         wrapperData(){
            
        }
        
        wrapperData(String RecordID,
                    String unitId){
                        this.RecordID = RecordID;
                        this.unitId = unitId;
                    }
     }
    // Aura-Response 
    Public class AuraResponse{
        @AuraEnabled 
        public Boolean isSuccess{get;set;}
        @AuraEnabled 
        public string message{get;set;}
        @AuraEnabled 
        public string response{get;set;}
        
        AuraResponse(Boolean isSuccess,
                     String message,
                     String response) {
                         
                         this.isSuccess = isSuccess;
                         this.message = message;
                         this.response = response;
                     }
    }
    // Method to get object name from Record Id
    public static String getObjectNameFromRecordId(Id recordId) {
        // Get the prefix of the Record Id
        String recordPrefix = recordId.getSObjectType().getDescribe().getKeyPrefix();

        // Query for object names with the obtained prefix
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for (String s : gd.keySet()) {
            Schema.SObjectType objType = gd.get(s);
            String prefix = objType.getDescribe().getKeyPrefix();
            if (prefix == recordPrefix) {
                return objType.getDescribe().getName();
            }
        }
        return null; // Return null if object name not found
    }
    
}