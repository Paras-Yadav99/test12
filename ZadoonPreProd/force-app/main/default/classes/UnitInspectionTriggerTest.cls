/*
* This Class is used to test UnitInspectionTrigger and UnitInspectionTriggerHandler
*/
@isTest
public class UnitInspectionTriggerTest {
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
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(2 ,lstEquipment[0].id , lstAccount[0].id);
        for(Product2 eachProduct: lstUnit){
            eachProduct.Storage_Address__c='test';
            eachProduct.Storage_City__c='test';
            eachProduct.Storage_Zip_Code__c='test';
            eachProduct.Storage_State__c='test';
            eachProduct.Storage_Country__c='test';
            eachProduct.Site_Contact__c = NewContact.Id;
        }
        
        insert lstUnit;
        lstUnit[1].Name = 'Test1';
        update lstUnit;
          //Opp_Rec_Type_Broker_Sell
            String Opp_Rec_Type_Broker_Sell_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_Type_Broker_Sell).getRecordTypeId();
            //Opp_Rec_Type_Inventory_Sell
            String Opp_Rec_Type_Inventory_Sell_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_Type_Inventory_Sell).getRecordTypeId();
            //Opp_Rec_type_Dev_Name_procurement_opp
            String Opp_Rec_type_Dev_Name_procurement_opp_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
            
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(7, lstAccount[0].id, lstUnit[0].id);
        integer i=0;
        for(Opportunity eachOpp: lstOpportunity){
            eachOpp.Inspector_Type__c='On-brand Dealer';
            if(i==0){
                eachOpp.recordTypeId = Opp_Rec_type_Dev_Name_procurement_opp_Id;
                eachOpp.stageName = 'offer accepted';
                //eachOpp.Inspector_Type__c=lstUnit[1].Id;
             }
            else If(i==1){
                eachOpp.recordTypeId = Opp_Rec_Type_Broker_Sell_Id;
                eachOpp.stageName = 'Client inspection requested';
                eachOpp.Product__c=lstUnit[1].Id;
            }
            else If(i==2){
                eachOpp.recordTypeId = Opp_Rec_Type_Broker_Sell_Id;
                eachOpp.stageName = 'Pro Forma Sent';
            }
             else If(i==3){
                eachOpp.recordTypeId = Opp_Rec_Type_Inventory_Sell_Id;
                eachOpp.stageName = 'Client inspection scheduled';
                eachOpp.Product__c=lstUnit[1].Id;
            }
            else If(i==4){
                eachOpp.recordTypeId = Opp_Rec_type_Dev_Name_procurement_opp_Id;
                eachOpp.stageName = 'Inspection Pending';
            }
            else If(i==5){
                eachOpp.recordTypeId = Opp_Rec_type_Dev_Name_procurement_opp_Id;
                eachOpp.stageName = 'Inspection Scheduled';
            }

           i=i+1; 
        }
        
        insert lstOpportunity;
        list<Unit_Inspection__c> lstUnitInspection = TestDataFactory.createUnitInspection(4 ,lstUnit[0].id , NewContact.id,lstAccount[0].id);
        
        insert lstUnitInspection;
        
      
    }
    
    /**
     * This Method is used to handle Update 
     */
      @isTest
    static void testUnitInspectionUpdateToIA() {
        
        Product2 eachUnit = [SELECT Id FROM Product2  Order By CreatedDate ASC LIMIT 1 ];
        List<Unit_Inspection__c> lstUnitInspection = [SELECT Id,Unit__c,Inspecion_Status__c FROM Unit_Inspection__c Order By CreatedDate DESC LIMIT 2 ];
        lstUnitInspection[0].Unit__c = eachUnit.Id;
            for(Unit_Inspection__c eachUnitIns: lstUnitInspection){
                eachUnitIns.Inspecion_Status__c = 'Inspector Acquired';
            }
        
        Test.startTest();
        // Update the records
        Database.SaveResult[] results = Database.update(lstUnitInspection, false);
        Test.stopTest();
        // Assert the results
        for (Database.SaveResult result : results) {
            // Assert that the update failed for each record
            System.assertEquals(false, result.isSuccess());
        }
    }
    
    /**
     * This Method is used to handle Update 
     */
      @isTest
    static void testUnitInspectionUpdateToIAwithOpp() {
        
        Opportunity eachOpportunity = [SELECT Id FROM Opportunity WHERE StageName ='offer accepted' Order By CreatedDate ASC LIMIT 1 ];
        
        Opportunity eachOpportunity1 = [SELECT Id FROM Opportunity WHERE StageName ='Pro Forma Sent' Order By CreatedDate ASC LIMIT 1 ];
        Product2 eachUnit = [SELECT Id FROM Product2  Order By CreatedDate ASC LIMIT 1 ];
        List<Unit_Inspection__c> lstUnitInspection = [SELECT Id,Unit__c,Inspecion_Status__c FROM Unit_Inspection__c Order By CreatedDate DESC LIMIT 2 ];
       
            for(Unit_Inspection__c eachUnitIns: lstUnitInspection){
                eachUnitIns.Inspecion_Status__c = 'Quotes Received';
            eachUnitIns.Associated_Opportunity__c = eachOpportunity.Id;
            }
         lstUnitInspection[0].Unit__c = eachUnit.Id;
        lstUnitInspection[0].Associated_Opportunity__c = eachOpportunity1.Id;
        
        Test.startTest();
        // Update the records
        Database.SaveResult[] results = Database.update(lstUnitInspection, false);
        Test.stopTest();
        // Assert the results
        for (Database.SaveResult result : results) {
            // Assert that the update failed for each record
            System.assertEquals(true, result.isSuccess());
        }
    }
    
     /**
     * This Method is used to handle Update 
     */
    @isTest
    static void testUnitInspectionUpdateToIAError() {
        Unit_Inspection__c eachFreight_Company_Unit = [SELECT Id FROM Unit_Inspection__c Order By CreatedDate ASC LIMIT 1 ];
        Unit_Inspection__c newFCU = new Unit_Inspection__c();
        newFCU.Id = eachFreight_Company_Unit.Id;
        newFCU.Inspecion_Status__c = 'Inspector Acquired';
        newFCU.Quote_Amount__c = 1151;
        update newFCU;
        
       // Opportunity eachOpportunity = [SELECT Id FROM Opportunity WHERE StageName ='Inspection Pending' Order By CreatedDate ASC LIMIT 1 ];
        List<Unit_Inspection__c> lstUnitInspection = [SELECT Id,Inspecion_Status__c FROM Unit_Inspection__c Order By CreatedDate DESC LIMIT 1 ];
        
        for(Unit_Inspection__c eachUnitIns: lstUnitInspection){
            eachUnitIns.Inspecion_Status__c = 'Inspector Acquired';
         //   eachUnitIns.Associated_Opportunity__c = eachOpportunity.Id;
        }
        
        Test.startTest();
        // Update the records
        Database.SaveResult[] results = Database.update(lstUnitInspection, false);
        Test.stopTest();
        // Assert the results
        for (Database.SaveResult result : results) {
            // Assert that the update failed for each record
            System.assertEquals(true, result.isSuccess());
        }
        
    }
    
     /**
     * This Method is used to handle Update to 
     */
      @isTest
    static void testUnitInspectionUpdateToComplete() {
    	
        Opportunity eachOpportunity = [SELECT Id FROM Opportunity WHERE StageName ='Inspection Scheduled' Order By CreatedDate ASC LIMIT 1 ];
        Product2 eachUnit = [SELECT Id FROM Product2  Order By CreatedDate ASC LIMIT 1 ];
        List<Unit_Inspection__c> lstUnitInspection = [SELECT Id,Unit__c,Inspecion_Status__c FROM Unit_Inspection__c Order By CreatedDate DESC LIMIT 1 ];
         List<Unit_Inspection__c> lstUnitInspection1 = new  List<Unit_Inspection__c>();
        lstUnitInspection[0].Unit__c = null;
        for(Unit_Inspection__c eachUnitIns: lstUnitInspection){
            eachUnitIns.Inspecion_Status__c = 'Inspector Acquired';
            eachUnitIns.Quote_Amount__c = 1000;
            //eachUnitIns.Associated_Opportunity__c = eachOpportunity.Id;
        }
        
        update lstUnitInspection;
        for(Unit_Inspection__c eachUnitIns: lstUnitInspection){
            eachUnitIns.Inspecion_Status__c = 'Completed';
            eachUnitIns.Quote_Amount__c = 1000;
            eachUnitIns.Associated_Opportunity__c = eachOpportunity.Id;
            
            lstUnitInspection[0].Unit__c = eachUnit.Id;
            lstUnitInspection1.add(eachUnitIns);
        }
        Test.startTest();
        // Update the records
        Database.SaveResult[] results = Database.update(lstUnitInspection1, false);
        Test.stopTest();
        // Assert the results
        for (Database.SaveResult result : results) {
            // Assert that the update failed for each record
            System.assertEquals(true, result.isSuccess());
        }
    }
    
     /**
     * This Method is used to handle Update to Quotes Received
     */
      @isTest
    static void testUnitInspectionUpdateToQR() {
       
        Product2 eachUnit = [SELECT Id FROM Product2 Order By CreatedDate ASC LIMIT 1 ];
        List<Unit_Inspection__c> lstUnitInspection = [SELECT Id,Unit__c,Inspecion_Status__c FROM Unit_Inspection__c Order By CreatedDate DESC LIMIT 2 ];
       
            for(Unit_Inspection__c eachUnitIns: lstUnitInspection){
                eachUnitIns.Inspecion_Status__c = 'Quotes Received';
            }
         lstUnitInspection[0].Unit__c = eachUnit.Id;
        Test.startTest();
        // Update the records
        Database.SaveResult[] results = Database.update(lstUnitInspection, false);
        Test.stopTest();
        // Assert the results
        for (Database.SaveResult result : results) {
            // Assert that the update failed for each record
            System.assertEquals(true, result.isSuccess());
        }
    }
    
    
}