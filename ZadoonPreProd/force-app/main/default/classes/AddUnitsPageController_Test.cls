@isTest
public with sharing class AddUnitsPageController_Test {
    
    static testMethod void testAddUnits() {
        Model__c model = TestDataFactory.createModel(true);
        Equipment__c equip = TestDataFactory.createEquipment(true, model.Id);
        Contact con = TestDataFactory.createContact(true);
        Product2 pro = TestDataFactory.createUnit(true, model.id, equip.id);
        Iron_Demand__c iron = TestDataFactory.createIronDemand(true, equip.id, con.id);
        Iron_Demand_Unit__c unit = TestDataFactory.createUnits(true, pro.id, iron.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(iron);
        AddUnitsPageController controller = new AddUnitsPageController(sc);
        controller.selectedPage_Size = '10';
        controller.minPrice = 250000;
        controller.maxPrice = 250000;
        controller.minWeight = 5000;
        controller.maxWeight = 5000;
        controller.maxHour = 3000;
        controller.minHour = 3000;
        controller.unitCode = '2500S Cone Crusher ZID-130163';
        controller.countryOrState = 'Texas';
        controller.countryOrState = 'United States';
        List < WrapperClass > wrapList = new List < WrapperClass >{new WrapperClass(pro,true)};
            controller.wrapperRecordList = wrapList;
        controller.addSelectedProduct();
        controller.search();
        controller.next();
        controller.previous();
        controller.first();
        controller.last();
        controller.refreshPageSize();
        controller.deleteSelectedUnits();
        PageReference pageRef = Page.AddUnitsPage;
        Test.setCurrentPage(pageRef);
    } 
}