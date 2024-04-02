@isTest
private class SendIronDemandEmailPageController_Test {
    
    static testMethod void testIronDemandSendEmail(){
        Model__c model = TestDataFactory.createModel(true);
        Equipment__c equip = TestDataFactory.createEquipment(true, model.Id);
        Contact con = TestDataFactory.createContact(true);
        Product2 pro = TestDataFactory.createUnit(true, model.id, equip.id);
        Iron_Demand__c iron = TestDataFactory.createIronDemand(true, equip.id, con.id);
        Iron_Demand_Unit__c unit = TestDataFactory.createUnits(true, pro.id, iron.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(iron);
        SendIronDemandEmailPageController controller = new SendIronDemandEmailPageController(sc);
        List < WrapperClass > wrapList = new List < WrapperClass >{new WrapperClass(unit,true)};
            controller.wrapperList = wrapList;
        controller.sendEmail();
        PageReference pageRef = Page.SendIronDemandEmailPage;
        Test.setCurrentPage(pageRef);
        
    }
}