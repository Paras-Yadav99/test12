public class CreateTasksForUnitBatch implements database.Batchable<sObject>{
    public database.QueryLocator start(database.BatchableContext bc){
        return Database.getQueryLocator(
            [
                SELECT ID, IsActive, Inventory_Status__c, Unit_Owner__c, Unit_Confirmation_Age__c, Unit_Purchase_Age__c
                FROM Product2
                WHERE IsActive = True AND 
                (
                    (Unit_Confirmation_Age__c IN :CreateTasksForUnitBatchHelper.unitConfirmationAgeSet 
                        AND Inventory_Status__c != 'Owned'
                    ) 
                    OR 
                    Unit_Purchase_Age__c IN :CreateTasksForUnitBatchHelper.unitPurchaseAgeSet_priceDrop
                    OR 
                    Unit_Purchase_Age__c IN :CreateTasksForUnitBatchHelper.unitPurchaseAgeSet_valutaion
                )
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Product2> scope){
        CreateTasksForUnitBatchHelper.run(scope);
    }

    public void finish(Database.BatchableContext bc){
        
    }
}