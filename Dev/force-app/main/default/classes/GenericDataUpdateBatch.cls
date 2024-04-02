public class GenericDataUpdateBatch implements database.Batchable<sObject>{
    public database.QueryLocator start(database.BatchableContext bc){
        return Database.getQueryLocator(
            [
                SELECT Id, Is_Listed_On_MLS__c FROM Product2 WHERE Is_Listed_On_MLS__c = false ORDER BY CreatedDate
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Product2> scope){
        for(Product2 unit : scope){
            unit.Is_Listed_On_MLS__c = true;
        }
        update scope;
        
    }

    public void finish(Database.BatchableContext bc){
        
    }
}