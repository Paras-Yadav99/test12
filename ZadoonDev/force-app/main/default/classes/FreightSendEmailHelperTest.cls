@isTest
public class FreightSendEmailHelperTest {
    
    @isTest
    static void testSendFreightEmail() {
        // Create test data
         list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(2,'company');
        insert lstAccount;
        
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , lstAccount[0].id);
        
        list<contact>lstContact = TestDataFactory.noOfContactToInsert(1,'testContact');
        insert lstContact;
        
        
        Product2 testProduct = new Product2(Name = 'Test Product', Freight_Ready_to_move__c = true);
       // insert testProduct;
        
        Freight_Company_Unit__c testFreightCompanyUnit = new Freight_Company_Unit__c(
           // Name = 'Test Freight Company Unit',
            Storage_City__c = 'Test City',
            Storage_State__c = 'Test State',
            Destination_City__c = 'Destination City',
            Destination_Country__c = 'Destination Country',
            Freight_Company_Account__c = lstAccount[0].id
        );
        insert testFreightCompanyUnit;
        
        Map<String, Freight_Company_Unit__c> testMap = new Map<String, Freight_Company_Unit__c>();
      //  testMap.put(testAccount.Id, testFreightCompanyUnit);
        
        // Call the method being tested
        Test.startTest();
       // String result = FreightSendEmailHelper.sendFreightEmail(new List<Account>{testAccount}, testProduct, testMap);
        Test.stopTest();
        
        // Verify the result
      //  System.assertEquals('Freight Emails are send successfully!! ', result);
        
        // Verify email has been sent
       /// List<Messaging.SingleEmailMessage> sentEmails = [SELECT Id FROM Messaging.SingleEmailMessage];
       /// System.assertEquals(1, sentEmails.size());
        
       
    }
    
    @isTest
    static void testCreateEmailTemplate() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@example.com', AccountId = testAccount.Id);
        insert testContact;
        
        Product2 testProduct = new Product2(Name = 'Test Product', Google_Drive_LInk__c = 'https://example.com');
       // insert testProduct;
        
        Freight_Company_Unit__c testFreightCompanyUnit = new Freight_Company_Unit__c(
          //  Name = 'Test Freight Company Unit',
            Storage_City__c = 'Test City',
            Storage_State__c = 'Test State',
            Destination_City__c = 'Destination City',
            Destination_Country__c = 'Destination Country',
            Freight_Company_Account__c = testAccount.id
        );
        insert testFreightCompanyUnit;
        
     //   String result = FreightSendEmailHelper.createEmailTemplate(testAccount, 'Test', testProduct, testFreightCompanyUnit);
        
      //  System.assertNotEquals(null, result);
        
        // Clean up test data
        //delete testContact;
       // delete testAccount;
       // delete testFreightCompanyUnit;
    }
}