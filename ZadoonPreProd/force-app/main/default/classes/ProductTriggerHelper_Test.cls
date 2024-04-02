@isTest
private class ProductTriggerHelper_Test {
    
    @testSetup static void setup() {
        Model__c model = TestDataFactory.createModel(true);
        Contact con = TestDataFactory.createContact(true);
        Equipment__c equipment = TestDataFactory.createEquipment(true, model.Id);
        Product2 unit = TestDataFactory.createUnit(true, model.Id, equipment.id);
        Iron_Demand__c iron = TestDataFactory.createIronDemand(false, equipment.id, con.id);
        iron.Max_Year__c = unit.Year__c;
        insert iron;

    }
    
    static testMethod void testProductTriggerUpdate() {
        Product2 unit = [Select isActive from Product2 where productCode ='ZID-130163' AND Name ='2500S Cone Crusher ZID-130163' Limit 1];
        update unit;
    }
    
    static testMethod void testProductTriggerUpdate1() {
        Product2 unit = [Select isActive from Product2 where productCode ='ZID-130163' AND Name ='2500S Cone Crusher ZID-130163' Limit 1];
        unit.Year__c = '2010';
        unit.IsActive = false;
        update unit;
    }
}