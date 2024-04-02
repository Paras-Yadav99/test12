public class UpdateVagueCityBatch implements database.Batchable<sObject>{
    public database.QueryLocator start(database.BatchableContext bc){
        return Database.getQueryLocator(
            [
                SELECT Id, IsActive, MT_Vague_Display_Location_Name__c, Inventory_Status__c, Storage_City__c, Storage_State__c
                FROM Product2 
                WHERE (MT_Vague_Display_Location_Name__c = null OR MT_Vague_Display_Location_Name__c = '' )
                AND
                IsActive = true
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Product2> scope){
        List<Product2> unitsToUpdate = new List<Product2>();
        PopulateVagueCityHelper helper = new PopulateVagueCityHelper();
        for(Product2 unit : scope){
            unit.MT_Vague_Display_Location_Name__c = helper.getCity(unit);
            unitsToUpdate.add(unit);
        }

        update unitsToUpdate;
    }

    public void finish(Database.BatchableContext bc){
        
    }
}