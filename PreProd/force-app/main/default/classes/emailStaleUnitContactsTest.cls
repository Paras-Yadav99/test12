@isTest
private class emailStaleUnitContactsTest {

    static testMethod void emailStaleUnitScheduleTest() 
    {

        Test.startTest();
        Contact con = TestDataFactory.createContact(true);
        
        // Create Account 
        Account account = new Account(Name='Test Account',CL_Listing_Status_Last_Checked__c=date.today().addDays(-21),
                                     Do_not_send_equipment_status_emails__c=false,
                                     Not_A_Client_We_Want_To_Do_Business_With__c=false,
                                     Primary_Contact__c=con.id);
        insert account;
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', On_Off_Highway__c = 'On Highway',  Base_New__c = 'Darryl Test Model', Name = 'Test Equipment', MT_Inventory_Type__c = 'Trucks');
        insert equipment;
        
        // Create Unit 
        Product2 ZIDs = new Product2(name='test product', equipment__c = equipment.Id, account__c =account.id,
                                     CreatedAt__c = Date.today().addDays(-7),Unit_Stage__c='Imported', isActive=true,
                                    Inventory_Status__c='Owned',Last_Equipment_Status_Confirmation__c=Date.today().addDays(-7));
        insert ZIDs;
 
        // Create Contact 
        Contact clist = new Contact(LastName='ContTest1', email='djung@atlassoftwaregroup.com', AccountId = account.Id, Primary_Contact__c = true);
        insert clist;
        
        // Create account relation
        // AccountContactRelation AccountContact = new AccountContactRelation(AccountId = account.Id, ContactId = clist.Id);
        // insert AccountContact;
        
        String sch = '0 0 1 * * ?';
        
        emailStaleUnitContacts sch1 = new emailStaleUnitContacts();
        
        system.schedule('Daily Email Stale Unit Contacts', sch, sch1 );
        
        sch1.GetEmailMethod();
        sch1.GetRecordPage();
        
        
        Test.stopTest();
        
    }

}