/*
* This Class is used to test FreightProcessFormController
*/
@isTest
public class FreightProcessFormControllerTest {
    
      /*
       * This Method is used to Create Test Data
	   */
     @testSetup 
    
    public static void createTestdata(){
        Contact NewContact = new Contact();
        NewContact.LastName='Test Conatact';
        NewContact.Email = 'test@kizzy.com';
        NewContact.Primary_Contact__c = true;
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
        list<Freight_Company_Unit__c> lstFreight_Company_Unit = TestDataFactory.Createfreight_company_unitObj(1 ,lstUnit[0].id , NewContact.id,lstAccount[0].id);
        
        insert lstFreight_Company_Unit;
        
      
    }
    
    /*
     * This Method is used to testGetInitialData
	 */
    @isTest
    static void testGetInitialFreightData() {
        // Create a mock wrapper object with required fields
        Freight_Company_Unit__c eachFreight_Company_Unit = [SELECT Id FROM Freight_Company_Unit__c Order By CreatedDate DESC LIMIT 1 ];
        String testKey = '01tD4000004SKytestId';
        FreightProcessFormController.AuraResponse result0= FreightProcessFormController.createIntialData(eachFreight_Company_Unit.Id); 
        FreightProcessFormController.AuraResponse result1= FreightProcessFormController.createIntialData(null);
        FreightProcessFormController.AuraResponse result2= FreightProcessFormController.createIntialData(testKey);
        // Assert the result
        System.assertEquals(true, result0.isSuccess);
        System.assertEquals('SUCCESS', result0.message);
        System.assertEquals(false, result1.isSuccess);
        System.assertEquals('ERROR', result1.message);
        System.assertEquals(false, result2.isSuccess);
        System.assertEquals('ERROR', result2.message);
    }
    
    /*
     * This Method is used to test update Freight Data
	 */
     @isTest
    static void testUpdateFreightData() {
        // Create a mock wrapper object with required fields
        Freight_Company_Unit__c eachFreight_Company_Unit = [SELECT Id FROM Freight_Company_Unit__c Order By CreatedDate DESC LIMIT 1 ];
        String testKey = '01tD4000004SKytestId';
        FreightProcessFormController.AuraResponse result0= FreightProcessFormController.createIntialData(eachFreight_Company_Unit.Id); 
        
        FreightProcessFormController.AuraResponse result1= FreightProcessFormController.updateFreightData(result0.response);
        
        FreightProcessFormController.AuraResponse result2= FreightProcessFormController.updateFreightData(null);
         // Assert the result
        System.assertEquals(true, result1.isSuccess);
        System.assertEquals('SUCCESS', result1.message);
        System.assertEquals(false, result2.isSuccess);
        System.assertEquals('ERROR', result2.message);
    }

}