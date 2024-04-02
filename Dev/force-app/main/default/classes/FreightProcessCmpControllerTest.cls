/*
 * This Test Class is used to test FreightProcessCmpController.
 */

@isTest
public class FreightProcessCmpControllerTest {
    /*
 	 * This Method is used to create Test Data
	 */
	 @testSetup static void createTestdata(){
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
         for(Equipment__c eachEquipment : lstEquipment){
             eachEquipment.Machine_Specalog__c = 'TEst';
         }
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , lstAccount[0].id);
         for(Product2 eachProduct2 : lstUnit){
             eachProduct2.Storage_City__c = 'Rewari';
             eachProduct2.Storage_State__c = 'Rewari';
         }
         insert lstUnit;
        
        
      
    }
    
     /*
 	 * This Method is used to Test Get Contact Data
	 */    
    @isTest
    static void testGetContactData() {
        // Create a mock wrapper object with required fields
        Map<String, Object> wrapperData = new Map<String, Object>{
            'ClientType' => 'Shipping/Logistics',
                'searchKey'=>'Test'
                };
       	
                    
        FreightProcessCmpController.AuraResponse result0= FreightProcessCmpController.getContactData(JSON.serialize(wrapperData));
        // Assert the result
        System.assertEquals(true, result0.isSuccess);
        System.assertEquals('SUCCESS', result0.message);
    }
    
     /*
 	 * This Method is used to Test Get Initial Freight Data
	 */ 
    
    @isTest
    static void testGetInitialFreightData() {
        // Create a mock wrapper object with required fields
       Product2 eachUnit = [SELECT Id FROM Product2 Order By CreatedDate DESC LIMIT 1 ];
       	String testKey = '01tD4000004SKytestId';
                   
        FreightProcessCmpController.AuraResponse result0= FreightProcessCmpController.getInitialFreightData(eachUnit.Id); 
        FreightProcessCmpController.AuraResponse result1= FreightProcessCmpController.GetInitialFreightData(null);
        FreightProcessCmpController.AuraResponse result2= FreightProcessCmpController.GetInitialFreightData(testKey);
        // Assert the result
        System.assertEquals(true, result0.isSuccess);
        System.assertEquals('SUCCESS', result0.message);
        System.assertEquals(false, result1.isSuccess);
        System.assertEquals('ERROR', result1.message);
        System.assertEquals(false, result2.isSuccess);
        System.assertEquals('ERROR', result2.message);
    }
    
     /*
 	 * This Method is used to Test Send Freight Emails
	 */ 
     @isTest
    static void testSendFreightEmails() {
        Product2 eachUnit = [SELECT Id FROM Product2 Order By CreatedDate DESC LIMIT 1 ];
        Account eachAccount = [SELECT Id FROM Account Order By CreatedDate DESC LIMIT 1 ];
        
         Map<String, Object> wrapperData = new Map<String, Object>{
            'ClientType' => 'Shipping/Logistics',
                'searchKey'=>'Test'
                };
       	
                    
        FreightProcessCmpController.AuraResponse result0= FreightProcessCmpController.getContactData(JSON.serialize(wrapperData));
        FreightProcessCmpController.AuraResponse result1= FreightProcessCmpController.getInitialFreightData(eachUnit.Id); 
        
        FreightProcessCmpController.AuraResponse result2= FreightProcessCmpController.SendFreightEmails(result1.response,new list<String>{eachAccount.Id},result0.response,eachUnit.Id); 
    }
    

}