@isTest (seeAllData=true)
private class EquipmentRelatedListBaseMatchesTest {

    static testMethod void EquipmentRelatedListBaseMatchesTest() 
    {

        Test.startTest();
        
        // Create Account 
        Account account = new Account(Name='Test Account');
        insert account;
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', Base_New__c = 'Darryl Test Model', Name = 'Test Equipment', MT_Inventory_Type__c = 'Trailers');
        insert equipment;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(equipment);

        
        EquipmentRelatedListBaseMatches sch1 = new EquipmentRelatedListBaseMatches(sc);
                
        Test.stopTest();
        
    }

}