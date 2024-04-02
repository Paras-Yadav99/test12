@isTest (seeAllData=true)
private class thisMassEmailEquipmentListTest {
/* 
    static testMethod void thisMassEmailEquipmentListTest() 
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
        
        account.Primary_Contact__c = clist.id;
        update account;

        thisMassEmailEquipmentList var = new thisMassEmailEquipmentList();
        var.thisEquipment = 'a006A000002GwLe';
        
        var.getthisEquipmentZids();  

                  
        Test.stopTest();
        
    }
 */
}