/**
 * This Class is used to test BatchForFreightRecTaskCreation and ScheduleBatchForFreightRecTaskCreation
 */
@isTest
public class BatchForFreightRecTaskCreationTest {
	  /**
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
        
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstUnit[0].id);
        insert lstOpportunity;
        list<Freight_Company_Unit__c> lstFreight_Company_Unit = TestDataFactory.Createfreight_company_unitObj(1 ,lstUnit[0].id , NewContact.id,lstAccount[0].id);
        for(Freight_Company_Unit__c eachFCU :lstFreight_Company_Unit){
            eachFCU.Freight_Requestor__c = System.UserInfo.getUserId();
            eachFCU.Associated_sales_procurement_opp__c = lstOpportunity[0].Id;
            eachFCU.Freight_Estimated_Pickup_Date__c = SYSTEM.TODAY();
            eachFCU.Freight_Pickup_Date__c = SYSTEM.TODAY().addDays(-3);
            eachFCU.Freight_Quoted_Amount__c = 11000;
        }
        insert lstFreight_Company_Unit;
        
        for(Freight_Company_Unit__c eachFCU :lstFreight_Company_Unit){
            eachFCU.Freight_Status__c = 'Vendor Acquired';
        }
        update lstFreight_Company_Unit;
        
        for(Freight_Company_Unit__c eachFCU :lstFreight_Company_Unit){
            eachFCU.Freight_Status__c = 'Machine Loaded';
        }
        update lstFreight_Company_Unit;
        for(Freight_Company_Unit__c eachFCU :lstFreight_Company_Unit){            
            eachFCU.Freight_Pickup_Date__c = SYSTEM.TODAY().addDays(-3);
        }
        update lstFreight_Company_Unit;
    }
    
    /*
     * This Method is used to test Batch Data
	 */
    @isTest
    static void testBatch() {
       
         BatchForFreightRecTaskCreation batchInstance = NEW BatchForFreightRecTaskCreation();
        id BatchId = DataBase.executeBatch(batchInstance, 200);
    }
    
      @isTest
    public static void testSchedulableContext(){
        System.Test.startTest();
        ScheduleBatchForFreightRecTaskCreation instScheduleClass = new ScheduleBatchForFreightRecTaskCreation();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, instScheduleClass); 
        System.Test.stopTest();
    }
    
    
}