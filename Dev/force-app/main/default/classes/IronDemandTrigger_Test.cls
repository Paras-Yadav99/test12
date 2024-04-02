@isTest
private class IronDemandTrigger_Test {
    
    @testSetup static void setup() {
        Model__c model = TestDataFactory.createModel(true);
        Contact con = TestDataFactory.createContact(true);
        Equipment__c equipment = TestDataFactory.createEquipment(true, model.Id);
        Product2 unit = TestDataFactory.createUnit(true, model.Id, equipment.id);
        Iron_Demand__c iron = TestDataFactory.createIronDemand(false, equipment.id, con.id);
        iron.Max_Year__c = unit.Year__c;
        iron.Max_Price__c = unit.Starting_Advertised_Retail_Price__c;
        iron.Min_Year__c = unit.Year__c;
        iron.Max_Year__c = unit.Year__c;
        insert iron;
        
    }
    
    static testMethod void testIronDemandTrigger(){
        Iron_Demand__c iron = [select id from Iron_Demand__c where isActive__c=true Limit 1];
        update iron;
    }
}