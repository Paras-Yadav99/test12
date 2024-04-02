@isTest (seeAllData=true)
private class emailMatchingUnitstoContactsTest {
/* 
    static testMethod void emailMatchingUnitstoContactsTest() 
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
        
        emailMatchingUnitstoContacts sch1 = new emailMatchingUnitstoContacts();
        
        system.schedule('Daily Email Stale Unit Contacts', sch, sch1 );
        
        emailMatchingUnitstoContacts.EmailMethodUnitIDContacts();
        
        Test.stopTest();
        
    }
    */
}