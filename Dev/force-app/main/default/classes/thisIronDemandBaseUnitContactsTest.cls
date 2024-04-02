@isTest
private class thisIronDemandBaseUnitContactsTest {

    static testMethod void thisIronDemandBaseUnitContactsTest() 
    {

        Test.startTest();
        
        // Create Account 
        Account account = new Account(Name='Test Account');
        insert account;
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', Base_New__c = 'Darryl Test Model', Name = 'Test Equipment', On_Off_Highway__c = 'On Highway', MT_Inventory_Type__c = 'Trucks');
        insert equipment;
        
        // Create Unit 
        //Product2 ZIDs = new Product2(name='test product', equipment__c = equipment.Id, account__c =account.id, CreatedAt__c = Date.today().addDays(-30));
       // insert ZIDs;
 
        // Create Contact 
        Contact clist = new Contact(LastName='ContTest1', email='djung@atlassoftwaregroup.com', AccountId = account.Id, Primary_Contact__c = true);
        insert clist;
        
        //WHERE IronDemand_Contact__c = :thisContactId AND IsActive__c = true
        // Create account relation 
        /* AccountContactRelation AccountContact = new AccountContactRelation(AccountId = account.Id, ContactId = clist.Id);
        insert AccountContact; */
        Iron_Demand__c newIronDemand = new Iron_Demand__c();
        newIronDemand.IronDemand_Contact__c = clist.id;
       	newIronDemand.IronDemand_Iron__c = equipment.id;
        newIronDemand.IsActive__c = true;
        insert newIronDemand;
        
        
        thisIronDemandBaseUnitContacts IDUnitContacts = new thisIronDemandBaseUnitContacts();
        
        IDUnitContacts.thisContactId = clist.id;
        
        IDUnitContacts.getThisContactZids();
        
        
        Test.stopTest();
        
    }
    
 
}