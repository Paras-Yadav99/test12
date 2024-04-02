@istest
public class AccountTriggerTest {
    @isTest public static void handleAfterInsert(){
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(2,'company');
        
        test.startTest();
        insert lstAccount;
        test.stopTest();
    }
    @isTest public static void handleAfterUpdate(){
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(2,'company');
        insert lstAccount;
        for(Account eachAccount : lstAccount){
            eachAccount.Client_Type__c = 'Manufacturer Dealer';
        }        
        test.startTest();
        update lstAccount;
        test.stopTest();
    }
    @isTest public static void testCreateTaskAfterUpdate(){
        user newUser = TestDataFactory.createTestUser('test','user');
        insert  newUser;  
         list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,'company');
         //lstAccount[0].Do_not_market_FB_Marketplace__c =true; 
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , lstAccount[0].id);
        lstUnit[0].Unit_Owner__c =newUser.Id;
        lstUnit[0].Inventory_Status__c='Owned';
        insert lstUnit;
        //lstAccount[0].Do_not_market_FB_Marketplace__c=false;
        test.startTest();
        update lstAccount;
        test.stopTest();
    }
}