/*
* This Class is used to test UnitInspectionEmailFormController
*/
@isTest
public class UnitInspectionEmailFormControllerTest {
	   /*
       * This Method is used to Create Test Data
	   */
     @testSetup 
    
    private static void createTestdata(){
        Contact NewContact = new Contact();
        NewContact.LastName='Test Conatact';
        NewContact.Email = 'test@kizzy.com';
        NewContact.Primary_Contact__c = true;
        NewContact.Can_Inspect_Machines__c = true;
        //NewContact.AccountID = NewAccount.Id;
        insert NewContact;
        
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,'company');
        for(account eachAccount : lstAccount){
            eachAccount.primary_contact__c=NewContact.Id;
            eachAccount.Client_Type__c = 'Shipping/Logistics';
        }
        insert lstAccount;
        
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , lstAccount[0].id);
        insert lstUnit;
        list<Unit_Inspection__c> lstUnitInspection = TestDataFactory.createUnitInspection(2 ,lstUnit[0].id , NewContact.id,lstAccount[0].id);
        
        insert lstUnitInspection;
        
      
    }
     
    /*
     * This Method is used to testGetInitialData
	 */
    @isTest
    static void testGetInitialFreightData() {
        // Create a mock wrapper object with required fields
        Unit_Inspection__c eachUnitInspection = [SELECT Id FROM Unit_Inspection__c Order By CreatedDate DESC LIMIT 1 ];
        String testKey = '01tD4000004SKytestId';
        UnitInspectionEmailFormController.AuraResponse result0= UnitInspectionEmailFormController.createIntialData(eachUnitInspection.Id); 
        UnitInspectionEmailFormController.AuraResponse result1= UnitInspectionEmailFormController.createIntialData(null);
        UnitInspectionEmailFormController.AuraResponse result2= UnitInspectionEmailFormController.createIntialData(testKey);
        // Assert the result
        System.assertEquals(true, result0.isSuccess);
        System.assertEquals('SUCCESS', result0.message);
        System.assertEquals(false, result1.isSuccess);
        System.assertEquals('ERROR', result1.message);
        System.assertEquals(false, result2.isSuccess);
        System.assertEquals('ERROR', result2.message);
    }
    
      /*
     * This Method is used to test update Inspection Data
	 */
     @isTest
    static void testUpdateFreightData() {
        // Create a mock wrapper object with required fields
        Unit_Inspection__c eachUnitInspection = [SELECT Id FROM Unit_Inspection__c Order By CreatedDate DESC LIMIT 1 ];
        String testKey = '01tD4000004SKytestId';
        UnitInspectionEmailFormController.AuraResponse result0= UnitInspectionEmailFormController.createIntialData(eachUnitInspection.Id); 
        
        UnitInspectionEmailFormController.AuraResponse result1= UnitInspectionEmailFormController.updateFreightData(result0.response);
        
        UnitInspectionEmailFormController.AuraResponse result2= UnitInspectionEmailFormController.updateFreightData(null);
         // Assert the result
        System.assertEquals(true, result1.isSuccess);
        System.assertEquals('SUCCESS', result1.message);
        System.assertEquals(false, result2.isSuccess);
        System.assertEquals('ERROR', result2.message);
    }

}