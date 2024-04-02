@isTest
private class emailStaleUnitLeads_Test {
    
    static testMethod void emailStaleUnitScheduleTest() 
    {
        
        Test.startTest();
        
        Lead l = new Lead(Status = 'New', LastName = 'Jung', Company = 'J Test', CL_Listing_Status_Last_Checked__c=date.today().addDays(-14),
                          Email='test@gmail.com');
        insert l;
        // Create Account
        Account account = new Account(Name='Test Account');
        insert account;
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', MT_Inventory_Type__c = 'Trucks', On_Off_Highway__c = 'On Highway', Base_New__c = 'Darryl Test Model', Name = 'Test Equipment');
        insert equipment;
        
        // Create Unit 
        Product2 ZIDs = new Product2(name='test product', equipment__c = equipment.Id, account__c =account.id, 
                                     CreatedAt__c = Date.today().addDays(-7),Inventory_Status__c = 'Owned',isActive = true,
                                     Unit_Stage__c = 'Imported',Last_Equipment_Status_Confirmation__c=Date.today().addDays(-7),
                                     Lead_Unit_Owner__c=l.id);
        insert ZIDs;
        
        /* Create Contact */ 
        Contact clist = new Contact(LastName='ContTest1', email='djung@atlassoftwaregroup.com', AccountId = account.Id, Primary_Contact__c = true);
        insert clist;
        
        // Create account relation 
        // AccountContactRelation AccountContact = new AccountContactRelation(AccountId = account.Id, ContactId = clist.Id);
        // insert AccountContact;
        
        String sch = '0 0 1 * * ?';
        
        emailStaleUnitLeads sch1 = new emailStaleUnitLeads();
        
        system.schedule('Daily Email Stale Unit Leads', sch, sch1 );
        
        sch1.GetEmailMethod();
        sch1.GetRecordPage();
        
        
        Test.stopTest();
        
    }   
}