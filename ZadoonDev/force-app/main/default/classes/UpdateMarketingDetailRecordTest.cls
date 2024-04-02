@isTest public class UpdateMarketingDetailRecordTest {
    @isTest public static void testUpdateMarketingDetailRecord (){
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1, 'company');
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id ,lstAccount[0].id );
        insert lstUnit;
        
        
        
        test.startTest();
        
        UpdateMarketingDetailRecord newinstance = new UpdateMarketingDetailRecord();
        Database.executeBatch(newinstance);
        test.stopTest();
    }
}