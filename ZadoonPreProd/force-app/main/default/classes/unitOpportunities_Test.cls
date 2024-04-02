@isTest
private class unitOpportunities_Test {
    
    static testMethod void unitOpportunitiesTest() {
        
        Test.startTest();
        Model__c model = TestDataFactory.createModel(true);
        Equipment__c equipment = TestDataFactory.createEquipment(true, model.Id);
        Product2 ZIDs = TestDataFactory.createUnit(true, model.Id, equipment.id);
        
        PageReference pageRef = Page.Unit_Creation_Edit_Form;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', ZIDS.Id);
        pageRef.getParameters().put('CF00N6A000003fVIc_lkid',equipment.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ZIDs);
        unitOpportunities controller = new unitOpportunities(sc);
        controller.sendEmail();
        controller.cloneApex();
        Test.stopTest();
    }
    
     static testMethod void unitOpportunitiesTest1() {
        
        Test.startTest();
        Model__c model = TestDataFactory.createModel(true);
        Equipment__c equipment = TestDataFactory.createEquipment(true, model.Id);
        Product2 ZIDs = TestDataFactory.createUnit(true, model.Id, equipment.id);
        
        PageReference pageRef = Page.Unit_Creation_Edit_Form;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', ZIDS.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ZIDs);
        unitOpportunities controller = new unitOpportunities(sc);
        Test.stopTest();
    }
}