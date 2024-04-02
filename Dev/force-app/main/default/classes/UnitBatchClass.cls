public class UnitBatchClass implements Database.Batchable<sobject> {
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Name,equipment__c,IsActive,Category__c FROM Product2 WHERE equipment__c != null AND IsActive =true ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Product2> lstProduct) {
        list<Unit_Category_Details__c> lstUnitCategoryDetails = new list<Unit_Category_Details__c>();
        Id unitCategoryDetailsRecordType = Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId();
        if(lstProduct != null && !lstProduct.isEmpty()){
            for(product2 eachProduct : lstProduct){
                if( string.isnotblank(UnitCategoryDetailsRecordType) ){
                    Unit_Category_Details__c newUnitCategoryDetails = new Unit_Category_Details__c();
                    newUnitCategoryDetails.name = 'Unit - '+eachProduct.name;
                    newUnitCategoryDetails.Unit__c = eachProduct.id;
                    newUnitCategoryDetails.Category_Details__c = eachProduct.Category__c;
                    newUnitCategoryDetails.RecordTypeId = UnitCategoryDetailsRecordType;
                    //newUnitCategoryDetails.Equipment__c = eachProduct.equipment__c; 
                    lstUnitCategoryDetails.add(newUnitCategoryDetails);
                }
            }
        }
        if(lstUnitCategoryDetails!=null && !lstUnitCategoryDetails.isEmpty()){
            system.debug('lstUnitCategoryDetails:::'+lstUnitCategoryDetails);
            insert lstUnitCategoryDetails;
            system.debug('lstUnitCategoryDetails:::'+lstUnitCategoryDetails);
        }
        
    }

    public void finish(Database.BatchableContext context) {
      system.debug('batch Executed::');  
    }
}