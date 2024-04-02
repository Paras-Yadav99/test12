/*
 * This Class is used to all the Events required for Freight Company Unit Trigger
 */
@isTest
public class FreightCompanyUnitTriggerTest {
    /*
 	 * This Method is used to create Test Data
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
        
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstUnit[0].id);
        insert lstOpportunity;
        list<Freight_Company_Unit__c> lstFreight_Company_Unit = TestDataFactory.Createfreight_company_unitObj(2 ,lstUnit[0].id , NewContact.id,lstAccount[0].id);
        for(Freight_Company_Unit__c eachFCU :lstFreight_Company_Unit){
            eachFCU.Freight_Requestor__c = System.UserInfo.getUserId();
            eachFCU.Associated_sales_procurement_opp__c = lstOpportunity[0].Id;
            eachFCU.Freight_Estimated_Pickup_Date__c = SYSTEM.TODAY();
			eachFCU.Freight_Pickup_Date__c = SYSTEM.TODAY();
             eachFCU.Freight_Quoted_Amount__c = 11000;
        }
        insert lstFreight_Company_Unit;
        
        
    }
    // Freight_Status__c = 'Requested',
    @isTest
    static void testAfterUpdate() {
        // Create a mock wrapper object with required fields
        Freight_Company_Unit__c eachFreight_Company_Unit = [SELECT Id,Freight_Status__c ,Freight_Quoted_Amount__c FROM Freight_Company_Unit__c Order By CreatedDate DESC LIMIT 1 ];
        eachFreight_Company_Unit.Freight_Status__c = 'Vendor Acquired';
        System.test.startTest();
        Database.SaveResult result = Database.update(eachFreight_Company_Unit, false);
        System.test.stopTest();
        // Assert the result
        System.assertEquals(true, result.isSuccess());
    }
     // Freight_Status__c = 'Requested',
    @isTest
    static void testBeforUpdateVendorAcquired() {
        // Create a mock wrapper object with required fields
        List<Freight_Company_Unit__c> lstFreight_Company_Unit = [SELECT Id,Freight_Status__c ,Freight_Quoted_Amount__c FROM Freight_Company_Unit__c Order By CreatedDate DESC LIMIT 2 ];
        for(Freight_Company_Unit__c eachFreight_Company_Unit: lstFreight_Company_Unit){
        eachFreight_Company_Unit.Freight_Status__c = 'Vendor Acquired';
        }
       
        Test.startTest();
        // Update the records
        Database.SaveResult[] results = Database.update(lstFreight_Company_Unit, false);
        Test.stopTest();
        // Assert the results
        for (Database.SaveResult result : results) {
            // Assert that the update failed for each record
            System.assertEquals(false, result.isSuccess());
        }
    }
    
      // Freight_Quoted_Amount__c = '120000',
    @isTest
    static void testAfterUpdateFreightQuotedAmount() {
        // Create a mock wrapper object with required fields
        Freight_Company_Unit__c eachFreight_Company_Unit = [SELECT Id,Freight_Status__c FROM Freight_Company_Unit__c Order By CreatedDate DESC LIMIT 1 ];
        eachFreight_Company_Unit.Freight_Estimated_Pickup_Date__c = SYSTEM.TODAY();
        eachFreight_Company_Unit.Freight_Quoted_Amount__c = 120000;
        System.test.startTest();
        Database.SaveResult result = Database.update(eachFreight_Company_Unit, false);
        System.test.stopTest();
        // Assert the result
        System.assertEquals(true, result.isSuccess());
    }
    
      // Freight_Status__c = 'Completed',
    @isTest
    static void testAfterUpdateCompleteStatus() {
        // Create a mock wrapper object with required fields
        Freight_Company_Unit__c eachFreight_Company_Unit = [SELECT Id,Freight_Status__c FROM Freight_Company_Unit__c Order By CreatedDate DESC LIMIT 1 ];
        eachFreight_Company_Unit.Freight_Status__c = 'Vendor Acquired';
        update eachFreight_Company_Unit;
        eachFreight_Company_Unit.Freight_Status__c = 'Completed';
        // eachFreight_Company_Unit.Freight_Quoted_Amount__c = 120000;
        System.test.startTest();
        Database.SaveResult result = Database.update(eachFreight_Company_Unit, false);
        System.test.stopTest();
        // Assert the result
        System.assertEquals(true, result.isSuccess());
    }
      // Freight_Status__c = 'Completed',
    @isTest
    static void testAfterUpdateMLoadedStatus() {
        // Create a mock wrapper object with required fields
        Freight_Company_Unit__c eachFreight_Company_Unit = [SELECT Id,Freight_Status__c FROM Freight_Company_Unit__c Order By CreatedDate DESC LIMIT 1 ];
        eachFreight_Company_Unit.Freight_Status__c = 'Vendor Acquired';
        update eachFreight_Company_Unit;
        eachFreight_Company_Unit.Freight_Status__c = 'Machine Loaded';
        // eachFreight_Company_Unit.Freight_Quoted_Amount__c = 120000;
        System.test.startTest();
        Database.SaveResult result = Database.update(eachFreight_Company_Unit, false);
        System.test.stopTest();
        // Assert the result
        System.assertEquals(true, result.isSuccess());
    }
}