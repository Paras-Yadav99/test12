@isTest
public class UpdateVagueCityBatchTest {
    @isTest
    static void testMethod2(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;

        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].MT_Vague_Display_Location_Name__c = null;
        lstOfProductToAdd[0].IsActive = true;
        insert lstOfProductToAdd;

        Test.startTest();
        UpdateVagueCityBatch obj = new UpdateVagueCityBatch();
        Database.executeBatch(obj);
        Test.stopTest();
    }


}