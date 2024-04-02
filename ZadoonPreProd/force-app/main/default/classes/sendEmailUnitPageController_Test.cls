@isTest
public class sendEmailUnitPageController_Test {
    
    static testMethod void testEmailFromUnit(){
        Contact con = TestDataFactory.createContact(true);
        Model__c model = TestDataFactory.createModel(true);
        Equipment__c equipment = TestDataFactory.createEquipment(true, model.Id);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id limit 1];
        System.assertEquals(true, standardPricebook.IsStandard);
 
        Product2 unit = TestDataFactory.createUnit(true, model.Id, equipment.id);
        Iron_Demand__c iron = TestDataFactory.createIronDemand(true, equipment.id, con.id);
      
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(unit);
        sendEmailUnitPageController controller = new sendEmailUnitPageController(sc);
        List < WrapperClass > wrapList = new List < WrapperClass >{new WrapperClass(con,true)};
            controller.wrapperList = wrapList;
        controller.sendEmail();
        test.stopTest();
    }
}