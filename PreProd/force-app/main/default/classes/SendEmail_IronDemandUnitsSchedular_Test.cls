@isTest
private class SendEmail_IronDemandUnitsSchedular_Test {
    
    static testMethod void SendEmail_IronDemandUnitBatchTest(){
        Model__c model = TestDataFactory.createModel(true);
        Equipment__c equipment = TestDataFactory.createEquipment(true, model.Id);
        Contact con = TestDataFactory.createContact(true);
        Iron_Demand__c iron = TestDataFactory.createIronDemand(true, equipment.id, con.id);
        Product2 unit = TestDataFactory.createUnit(true, model.id, equipment.id);
        Iron_Demand_Unit__c ironUnit = TestDataFactory.createUnits(false, unit.Id, iron.Id);
        ironUnit.CreatedDate = system.now().addHours(-24);
        insert ironUnit;
        
        Test.StartTest();
        String crnExpr = '0 0 9 1/1 * ? *';
        system.schedule('SendEmail_IronDemandUnit Batch', crnExpr,  new SendEmail_IronDemandUnitsSchedular()); 
        Test.stopTest();
        //insert ironUnit;
    }
}