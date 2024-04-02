/**
 * This Class is used to test BatchToSendInspectionEmailOnInspection, BatchToSendInsEmailOnInsDayCtrl and ScheduleBatchToSendInsEmailOnInsDay
 */
@isTest
public class BatchToSendInspectionEmailOnInsTest {
	  /**
       * This Method is used to Create Test Data
	   */
     @testSetup 
    
    private static void createTestdata(){
        Contact NewContact = new Contact();
        NewContact.LastName='Test Conatact';
        NewContact.Email = 'test@kizzy.com';
        NewContact.Primary_Contact__c = true;
        NewContact.Can_Inspect_Machines__c = true;
        newContact.MailingCountry = 'United States';
        newContact.MailingStreet = '123 Main Street';
        newContact.MailingCity = 'San Francisco';
        newContact.MailingState = 'California';
        newContact.MailingPostalCode = '94101'; 
       // NewContact.MailingAddress='test';
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
        for(Product2 eachProduct: lstUnit){
            eachProduct.Storage_Address__c='test';
            eachProduct.Storage_City__c='test';
            eachProduct.Storage_Zip_Code__c='test';
            eachProduct.Storage_State__c='test';
            eachProduct.Storage_Country__c='test';
            eachProduct.Year__c = '2023'; 
            eachProduct.Make__c = '94101'; 
            
        }
        insert lstUnit;
        list<Unit_Inspection__c> lstUnitInspection = TestDataFactory.createUnitInspection(2 ,lstUnit[0].id , NewContact.id,lstAccount[0].id);
       
        insert lstUnitInspection;
        
      
    }
    
        /*
     * This Method is used to test Batch Data
	 */
    @isTest
    static void testBatch() {
       /* // Create a mock wrapper object with required fields
        Product2 eachUnit = [SELECT Id FROM Product2 Order By CreatedDate DESC LIMIT 1 ];
        String testKey = '01tD4000004SKytestId';
        UnitInspectionEmailCmpController.AuraResponse result0= UnitInspectionEmailCmpController.getIntialdata(eachUnit.Id); 
        UnitInspectionEmailCmpController.AuraResponse result1= UnitInspectionEmailCmpController.getIntialdata(null);
        UnitInspectionEmailCmpController.AuraResponse result2= UnitInspectionEmailCmpController.getIntialdata(testKey);
        // Assert the result
        System.assertEquals(true, result0.isSuccess);
        System.assertEquals('SUCCESS', result0.message);
        System.assertEquals(false, result1.isSuccess);
        System.assertEquals('ERROR', result1.message);
        System.assertEquals(false, result2.isSuccess);
        System.assertEquals('ERROR', result2.message);*/
         BatchToSendInspectionEmailOnInspection batchInstance = NEW BatchToSendInspectionEmailOnInspection();
        id BatchId = DataBase.executeBatch(batchInstance, 200);
    }
    
      @isTest
    public static void testSchedulableContext(){
        System.Test.startTest();
        ScheduleBatchToSendInsEmailOnInsDay instScheduleClass = new ScheduleBatchToSendInsEmailOnInsDay();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, instScheduleClass); 
        System.Test.stopTest();
    }
    
    
}