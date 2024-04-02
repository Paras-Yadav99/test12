@isTest (seeAllData=true)
private class DailyIronDemandMatchingEmailTest {
/* 
    static testMethod void DailyIronDemandMatchingEmailTest() 
    {

        Test.startTest();
        
        // Create Account 
        Account account = new Account(Name='Test Account');
        insert account;
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', Base__c = 'Darryl Test Model', Name = 'Test Equipment');
        insert equipment;
        
        // Create Unit 
        Product2 ZIDs = new Product2(name='test product', equipment__c = equipment.Id, account__c =account.id, CreatedAt__c = Date.today().addDays(-30));
        insert ZIDs;
 
        // Create Contact 
        Contact clist = new Contact(LastName='ContTest1', email='djung@atlassoftwaregroup.com', AccountId = account.Id, Primary_Contact__c = true);
        insert clist;
        
        // Create account relation 
        // AccountContactRelation AccountContact = new AccountContactRelation(AccountId = account.Id, ContactId = clist.Id);
        // insert AccountContact;
        
        String sch = '0 0 1 * * ?';
        
        DailyIronDemandMatchingEmail sch1 = new DailyIronDemandMatchingEmail();
        
        system.schedule('Daily ID Matching Email', sch, sch1 );
        
        sch1.GetDailyIDMatchingEmail();
        sch1.GetRecordPage();
        
        Test.stopTest();
        
    }
*/
}