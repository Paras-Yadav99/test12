@isTest
private class AdhocEmailUnitController_Test {
    
    static testMethod void testContactAdhoc() {
        Contact con = TestDataFactory.createContact(true);
        Model__c model = TestDataFactory.createModel(true);
        Equipment__c equipment = TestDataFactory.createEquipment(true, model.Id);
        Product2 unit = TestDataFactory.createUnit(true, model.Id, equipment.id);
        Iron_Demand__c iron = TestDataFactory.createIronDemand(true, equipment.id, con.id);
        
        List<Product2> unitList = new List<Product2>{unit};
            
            Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(unitList);
        stdSetController.setSelected(unitList);
        AdhocEmailUnitController controller = new AdhocEmailUnitController(stdSetController);
        controller.selectedPage_Size = '10';
        controller.firstName = con.FirstName; 
        controller.lastName = con.LastName;
        controller.email = con.Email;
        controller.phone = con.Phone;
        List < WrapperClass > wrapList = new List < WrapperClass >{new WrapperClass(con,true)};
            controller.wrapperList = wrapList;
        controller.search();
        controller.next();
        controller.first();
        controller.last();
        controller.previous();
        controller.refreshPageSize();
        controller.sendEmail();
        Test.setCurrentPage(Page.AdhocEmailEquipmentPage);
        Test.stopTest();
    }
}