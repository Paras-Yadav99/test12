public class BatchToUpdateUnitInventoryStage implements database.Batchable<sObject>{
    public Database.QueryLocator Start(DataBase.BatchableContext bc){
		String query = 'SELECT Id, Inventory_Status__c ';
         query += '    FROM Product2 WHERE Inventory_Status__c =\'Brokered\' OR Inventory_Status__c =\'Reviewing\'';
        return Database.getQueryLocator(query);
    }
    public void Execute (Database.BatchableContext dbc , list<Product2>lstUnit){
        list<Product2>lstProduct2 = new list<Product2>();
        system.debug('lstUnit:'+lstUnit);
        if(lstUnit!=null && !lstUnit.isEmpty()){
            for(Product2 eachUnit : lstUnit){
                eachUnit.Inventory_Status__c = 'Brokerage';
                lstProduct2.add(eachUnit);
            }
            if(lstProduct2!=null && !lstProduct2.isEmpty()){
                 update lstProduct2;
            }
           
        }
    }
    public void finish(Database.BatchableContext dbc){
        system.debug('Success : Task Creation Success');
    }
}