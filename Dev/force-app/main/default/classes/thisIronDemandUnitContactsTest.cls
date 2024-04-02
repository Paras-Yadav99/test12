@isTest 
private class thisIronDemandUnitContactsTest {

    static testMethod void thisIronDemandUnitContactsTest() 
    {
         // Create Account 
        Account account = new Account(Name='Test Account');
        insert account;
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', Base_New__c = 'Darryl Test Model', Name = 'Test Equipment', MT_Inventory_Type__c = 'Trucks',On_Off_Highway__c='On Highway');
        insert equipment;
        
		Product2 ZIDs = new Product2(name='test product',Unit_Stage__c='Reviewing',	 IsActive=false, equipment__c = equipment.Id, account__c =account.id, CreatedAt__c = Date.today().addDays(-30));
        insert ZIDs;
        
        Test.startTest();
        
       
        
        
         //Update Unit 
     	 Product2 newZIDs = new Product2();
         newZIDs.id = ZIDs.id;
         newZIDs.Unit_Stage__c='Keep Only for Iron Demand';
		 Update newZIDs;
        // Create Contact 
        Contact clist = new Contact(LastName='ContTest1', email='djung@atlassoftwaregroup.com', AccountId = account.Id, Primary_Contact__c = true);
        insert clist;
        
        // Create account relation 
        // AccountContactRelation AccountContact = new AccountContactRelation(AccountId = account.Id, ContactId = clist.Id);
        // insert AccountContact;
        //Create Iron Demant
        Iron_Demand__c newIronDemand = new Iron_Demand__c();
        newIronDemand.IronDemand_Contact__c = clist.id;
       	newIronDemand.IronDemand_Iron__c = equipment.id;
        newIronDemand.IsActive__c = true;
        insert newIronDemand;
        Product2history newProduct2history = new Product2history(Product2Id = newZIDs.id, Field = 'Unit_Stage__c'); 
        insert newProduct2history;
        
        thisIronDemandUnitContacts IDUnitContacts = new thisIronDemandUnitContacts();
        
        IDUnitContacts.thisContactId = clist.id;
        
        IDUnitContacts.getThisContactZids();
        
        
        Test.stopTest();
        
    }

}