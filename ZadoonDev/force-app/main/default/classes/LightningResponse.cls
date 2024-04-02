public with sharing class LightningResponse {
    @AuraEnabled public boolean bIsSuccess{get;set;}
    @AuraEnabled public Map<String,Object> mapResponse{get;set;}
    public LightningResponse(){
        mapResponse = new Map<String,Object>();
    }
    public void put(String skey, Object objValue){
        mapResponse.put(skey,objValue);
    }
    
}