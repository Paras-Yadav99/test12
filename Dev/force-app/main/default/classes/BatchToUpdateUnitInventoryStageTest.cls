@isTest
public class BatchToUpdateUnitInventoryStageTest {
	@isTest
    public static void testBatchToUpdateUnit(){
    	//list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1, 'company');
       // insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        Model__c model = TestDataFactory.createModel(true);
		 Product2 unit = TestDataFactory.createUnit(false, model.Id, lstEquipment[0].id);
        //unit.Account__c=lstAccount[0].id;
        unit.Inventory_Status__c ='Reviewing'; 
         insert unit;
        BatchToUpdateUnitInventoryStage newInstance = new BatchToUpdateUnitInventoryStage();
       //list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id ,lstAccount[0].id,model.Id);
        test.startTest();
       	
        database.executeBatch(newInstance);
        test.stopTest();    
    }
}