@isTest
private class AdhocEmailContactController_Test {
    
    static testMethod void testContactAdhocEmail(){
        Contact con = TestDataFactory.createContact(true);
        Model__c model = TestDataFactory.createModel(true);
        Equipment__c equipment = TestDataFactory.createEquipment(true, model.Id);
        Product2 unit = TestDataFactory.createUnit(true, model.Id, equipment.id);
        Iron_Demand__c iron = TestDataFactory.createIronDemand(true, equipment.id, con.id);
        
        List< Contact > conList = new List< Contact >{con};
            test.startTest();
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(conList);
        stdSetController.setSelected(conList);
        AdhocEmailContactController controller = new AdhocEmailContactController(stdSetController);
        controller.selectedPage_Size = '10';
        controller.selectedCategory = 'Motor Grader';
        controller.minYear = '2012';
        controller.maxYear = '2019';
        controller.make = 'Caterpillar';
        controller.model = model.Name;
        controller.minPrice = 250000;
        controller.maxPrice = 250000;
        controller.minWeight = 5000;
        controller.maxWeight = 5000;
        controller.maxHour = 3000;
        controller.minHour = 3000;
        controller.unitCode = '2500S Cone Crusher ZID-130163';
        List < WrapperClass > wrapList = new List < WrapperClass >{new WrapperClass(unit,true)};
            controller.wrapperRecordList = wrapList;
        controller.search();
        controller.next();
        controller.first();
        controller.last();
        controller.previous();
        controller.refreshPageSize();
        controller.sendEmail();
        Test.setCurrentPage(Page.AdhocEmailContactPage);
        Test.stopTest();
    }
}