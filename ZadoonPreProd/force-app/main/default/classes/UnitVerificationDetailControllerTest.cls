@isTest
public class UnitVerificationDetailControllerTest {
    @testSetup static void createTestdata(){
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,'company');
        insert lstAccount;
        list<Account> lstAccount1 = TestDataFactory.noOfAccountToInsert(1,'comdefhsdjpany');
        insert lstAccount1;
        
        list<Equipment__c> lstEquipment = TestDataFactory.noOfEquipment(1);                    
        insert lstEquipment;                                                                                            
        list<Product2> lstProduct2 = TestDataFactory.noOfUnitsToCreate(1,lstEquipment[0].id) ;
        lstProduct2[0].Inventory_status__c='Owned';
        insert lstProduct2;
        
        List<Marketing_Detail__c>lstMarketing_Detail= TestDataFactory.createMarketingDetails(1,lstAccount1[0].Id,null);
        insert lstMarketing_Detail;
        
        Unit_Verification__c unit_verificationObj = new Unit_Verification__c(
            Name = 'TEST UNIT VERIFICATION A',
            Marketing_Detail__c = lstMarketing_Detail[0].Id,
            unit__c = lstProduct2[0].id
        );
        insert unit_verificationObj;
        
        List<Unit_Verification_line_item__c>lstUnit_Verification_line_item = new List<Unit_Verification_line_item__c>();
        for(integer num = 0; num< 4; num++){
            Unit_Verification_line_item__c testLineItem = new Unit_Verification_line_item__c(
                Name = 'Test Line Item'+num,
                Is_Active__c= true,
                Unit_Verification__c = unit_verificationObj.Id);
            lstUnit_Verification_line_item.Add(testLineItem);
        }
        insert lstUnit_Verification_line_item;
        
        
    }

    @isTest
    static void testGetUnitVerificationLineItemsSuccess() {
     	Unit_Verification__c testLineItem = [SELECT Id, Name FROM Unit_Verification__c WHERE Name = 'TEST UNIT VERIFICATION A' LIMIT 1];
        // Call the method
        UnitVerificationDetailController.AuraResponse result = UnitVerificationDetailController.getUnitVerificationLineItems(testLineItem.Id);

        // Assert the result
        System.assertEquals(true, result.isSuccess);
        System.assertEquals('SUCCESS', result.message);
        // Add more assertions as needed to check the returned data
    }

    @isTest
    static void testGetUnitVerificationLineItemsError() {
        // Call the method with blank recordId
        UnitVerificationDetailController.AuraResponse result = UnitVerificationDetailController.getUnitVerificationLineItems(null);

        // Assert the result
        System.assertEquals(false, result.isSuccess);
        System.assertEquals('ERROR', result.message);
        System.assertEquals('RecordId Not found!', result.response);
    }
    
    @isTest
    static void testGetUnitVerificationLineItemsCatch() {
        // Call the method with blank recordId
        String recordId = 'TEST012D4000001TESTKIZZY';
        UnitVerificationDetailController.AuraResponse result = UnitVerificationDetailController.getUnitVerificationLineItems(recordId);
        
        // Assert the result
        System.assertEquals(false, result.isSuccess);
        System.assertEquals('ERROR', result.message);
    }

    @isTest
    static void testSaveUpdatedLineItemsSuccess() {
        // Create test data
		
     	Unit_Verification__c testLineItem = [SELECT Id, Name FROM Unit_Verification__c WHERE Name = 'TEST UNIT VERIFICATION A' LIMIT 1];
        UnitVerificationDetailController.AuraResponse result0 = UnitVerificationDetailController.getUnitVerificationLineItems(testLineItem.Id);
        
       
        // Convert the wrapper to JSON
        String testWrapperJson =JSON.serialize(result0.Response);

        // Call the method
        UnitVerificationDetailController.AuraResponse result1 = UnitVerificationDetailController.saveUpdatedLineItems(result0.Response);
        
        UnitVerificationDetailController.AuraResponse result2 = UnitVerificationDetailController.saveUpdatedLineItems(testWrapperJson);
		  
        // Assert the result
        System.assertEquals(false, result1.isSuccess);
    }
      @isTest
    static void testSaveUpdatedLineItemsCatch() {
        // Create test data
		
     	Unit_Verification__c testLineItem = [SELECT Id, Name FROM Unit_Verification__c WHERE Name = 'TEST UNIT VERIFICATION A' LIMIT 1];
        UnitVerificationDetailController.AuraResponse result0 = UnitVerificationDetailController.getUnitVerificationLineItems(testLineItem.Id);
        
       ////JSON.serialize(new List<UnitVerificationDetailController.Wrapper>{testWrapper});
      // ParentWrapper
          UnitVerificationDetailController.ParentWrapper wrappedTestData =(UnitVerificationDetailController.ParentWrapper)JSON.deserialize(result0.Response, UnitVerificationDetailController.ParentWrapper.Class); 
        // Convert the wrapper to JSON
        String testWrapperJson =JSON.serialize(wrappedTestData.UnitVerificationWrapperData);

        // Call the method
        //UnitVerificationDetailController.AuraResponse result1 = UnitVerificationDetailController.saveUpdatedLineItems(result0.Response);
        
        UnitVerificationDetailController.AuraResponse result2 = UnitVerificationDetailController.saveUpdatedLineItems(testWrapperJson);
		  
        // Assert the result
        System.assertEquals(true, result2.isSuccess);
        System.assertEquals('SUCCESS', result2.message);
        // Add more assertions as needed to check the updated data
    }

    @isTest
    static void testSaveUpdatedLineItemsError() {
        // Call the method with blank wrapperData
        UnitVerificationDetailController.AuraResponse result = UnitVerificationDetailController.saveUpdatedLineItems('');

        // Assert the result
        System.assertEquals(false, result.isSuccess);
        System.assertEquals('ERROR', result.message);
        System.assertEquals('Unit Verification line item(s) are not found(s) to update.', result.response);
    }


}