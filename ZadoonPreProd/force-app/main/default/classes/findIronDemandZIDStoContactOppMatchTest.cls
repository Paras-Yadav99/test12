@isTest (seeAllData=true)
private class findIronDemandZIDStoContactOppMatchTest  {

    static testMethod void findIronDemandZIDStoContactOppMatchTest() 
    {

        Test.startTest();
        
        // Create Account 
        Account account = new Account(Name='Test Account');
        insert account;
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', MT_Inventory_Type__c = 'Trucks', Base_New__c = 'Darryl Test Model', On_Off_Highway__c = 'On Highway', Name = 'Test Equipment');
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
        
        
        
        findIronDemandZIDStoContactOppMatch IDUnitContacts = new findIronDemandZIDStoContactOppMatch();
        
        IDUnitContacts.thisContactId = '0036A00000Bxwz4';
        IDUnitContacts.thisAccountId = '0016A000005eK43';
        
        IDUnitContacts.getThisContactZids();
        
        
        Test.stopTest();
        
    }
    
}