@isTest (seeAllData=true)
private class AdhocEmailerTest {

    static testMethod void AdhocEmailerTest() 
    {

        Test.startTest();
        
        // Create Account 
        Account account = new Account(Name='Test Account',  Client_Type__c = 'Other', Client_Region__c = 'Africa');
        insert account;
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', Base_New__c = 'Darryl Test Model', Name = 'Test Equipment', MT_Inventory_Type__c = 'Trailers', On_Off_Highway__c = 'On Highway');
        insert equipment;
        
        // Create Unit 
        Product2 ZIDs = new Product2(name='test product', equipment__c = equipment.Id, account__c =account.id, CreatedAt__c = Date.today().addDays(-30));
        insert ZIDs;
 
        // Create Contact 
        Contact clist = new Contact(LastName='ContTest1', email='djung@atlassoftwaregroup.com', AccountId = account.Id, Primary_Contact__c = true);
        insert clist;
        
        AdhocEmailer sch1 = new AdhocEmailer();
        
        // contact darryl jung test should be Other Africa 
        sch1.ClientTypes = 'Other';
        sch1.Regions = 'Africa';
        sch1.Zid = '114000';
        sch1.MassEmailEquipmentNeedBodyHidden = 'hidden body';
        sch1.MassEmailEquipmentNeedTitleHidden = 'hidden title';
        sch1.EquipmentNeed = equipment.Id;
        sch1.unitTestFlag = true;

        
        sch1.getListOfRegions();
        sch1.getListOfClientTypes();
        sch1.getListOfEquipment();
        sch1.getListOfEquipmentNeed();
        sch1.getListOfManufacturers();
        sch1.getListOfCategories();
        sch1.getListOfIndustries();
        sch1.getListOfAccountIndustries();
        sch1.getListOfAccountCategories();
        sch1.getListOfAccountDealers();
        
        sch1.AccountIndustry = '[]';
        sch1.AccountCategory = '[]';
        sch1.AccountDealer = '[]';
        
        
        sch1.GetAdhocEmailer();
        sch1.GetRecordPage();
        sch1.SendEmail();
     
        
    }
    
}