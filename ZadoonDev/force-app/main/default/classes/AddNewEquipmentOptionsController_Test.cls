@isTest
public class AddNewEquipmentOptionsController_Test {
    @isTest static void testUpdateParentId() {
        Equipment__c eq = new Equipment__c();
        eq.On_Off_Highway__c = 'On Highway';
        eq.MT_Inventory_Type__c = 'Trucks';
        insert eq;
        
        Equipment_Options__c eo = new Equipment_Options__c();
        eo.name = 'Test';
        insert eo;
        
        Product2 unit = new Product2();
        unit.name = 'Test';
        unit.equipment__c = eq.Id;
        insert unit;
        Test.startTest();    
        AddNewEquipmentOptionsController.updateParentId(eo.Id, unit.Id);
        Test.stopTest();
    }
    @isTest static void testGetRequiredValues() {
        Equipment__c eq = new Equipment__c();
        eq.On_Off_Highway__c = 'On Highway';
        eq.MT_Inventory_Type__c = 'Trucks';
        insert eq;
        
        Product2 unit = new Product2();
        unit.name = 'Test';
        unit.equipment__c = eq.Id;
        insert unit;

        Test.startTest();    
        AddNewEquipmentOptionsController.getRequiredValues(unit.Id);
        Test.stopTest();
    }
}