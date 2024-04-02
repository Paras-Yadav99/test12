@istest
public class OpportunityTriggerTest {
    @testSetup
    public static void CreateTestData(){
        user newuser = testDataFactory.createTestUser('Test','name');
        insert newuser;
        list<contact> lstContact = testDataFactory.noOfContactToInsert(1,'test');
        lstContact[0].MobilePhone = '1234567891';
        lstContact[0].Phone = '1234567890';
        insert lstContact;
         list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        lstAccount[0].Primary_Contact__c = lstContact[0].id;
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        lstEquipment[0].Manufacturer__c ='Stellar';
        lstEquipment[0].On_Off_Highway__c = 'Off Highway';
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
        //lstProduct[0].Primary_Contact__c = lstContact[0].id;
        lstProduct[0].Hour__c  = 100;
        lstProduct[0].Year__c = '2022';
        lstProduct[0].Serial_Number__c ='1000';
        lstProduct[0].Site_Contact__c = lstContact[0].id;
        lstProduct[0].Storage_Address__c = 'test';
        lstProduct[0].Storage_City__c = 'test';
        lstProduct[0].Storage_Country__c ='test'; 
        lstProduct[0].Storage_State__c = 'test';
        lstProduct[0].Storage_Zip_Code__c = '131001';
         lstProduct[0].Unit_Owner__c = newuser.id;
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
       
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
        lstOpportunity[0].WTB_Date__c = Date.newInstance(2022, 12, 9);
        lstOpportunity[0].Invoice_Details__c = false;
        insert lstOpportunity;
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
    }
    
    @isTest  public static void opportunityTriggerHandlerTest() {
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
    
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
        string procuretmentRecordType = label.Opp_Rec_type_Dev_Name_procurement_opp ;
        list<recordType> lstRecordType ;
        if(string.isNotBlank(ProcuretmentRecordType)){
             lstRecordType = [SELECT Id,DeveloperName From RecordType Where DeveloperName =: ProcuretmentRecordType];
        }
       system.debug('lstRecordType'+lstRecordType);
        
        for(Opportunity eachOpportunity : lstOpportunity){
            if(lstRecordType !=null && !lstRecordType.isEmpty()){
                eachOpportunity.RecordTypeId = lstRecordType[0].id;
				eachOpportunity.Inspection_Status__c = 'Completed';
                eachOpportunity.Send_machine_to_on_brand_dealers__c = true;
                eachOpportunity.Call_previous_won_lost_opps__c = true;
            }
            
        }
        test.startTest();
        
        try{
            insert lstOpportunity;
        }catch(exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('inspection status can\'t be changed to') ? true : false;
           // System.AssertEquals(expectedExceptionThrown, true);
        }
        //update lstOpportunityUpdate;
        test.stopTest();
    }
    @isTest  public static void opportunityTriggerAfterUpdateTest() { 
        list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c
                                    FROM opportunity];
        lstOpp[0].WTB_Date__c = Date.newInstance(2021, 12, 9);
        lstOpp[0].WTB_Priority__c ='High (immediate WTB email)';
        test.startTest();
        update lstOpp;
        test.stopTest();
    }
     @isTest  public static void opportunityTriggerAfterUpdateTest1() { 
         list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,product__c
                                     FROM opportunity WHERE product__c != null  ];
         lstOpp[0].WTB_Date__c = Date.newInstance(2021, 12, 9);
         lstOpp[0].WTB_Priority__c ='Medium (include w/ weekly WTB)';
         test.startTest();
         update lstOpp;
         test.stopTest();
    }
    
      @isTest  public static void opportunityTriggerWtbStatusAfterUpdateTest() { 
          list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c
                                      FROM opportunity];
          lstOpp[0].WTB_Status__c = 'WTB In Process';
          update lstOpp;
          lstOpp[0].WTB_Status__c = 'WTB Requested';
          test.startTest();
          update lstOpp;
          test.stopTest();
    }
    
        @isTest  public static void opportunityTriggerWtbStatusAfterUpdateTest1() { 
            opportunity newOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c,Call_previous_won_lost_opps__c,Send_machine_to_on_brand_dealers__c
                                  FROM opportunity LIMIT 1];
            newOpp.WTB_Status__c = 'WTB In Process';
            update newOpp;
            newOpp.WTB_Status__c = 'WTB Completed';
            newOpp.Call_previous_won_lost_opps__c = true;
            newOpp.Send_machine_to_on_brand_dealers__c = true;
           newOpp.StageName = 'Offer Made';
            
            test.startTest();
            update newOpp;
            test.stopTest();
    }
       @isTest  public static void opportunityTriggerStageAfterUpdateTest() { 
          list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c,stageName
                                      FROM opportunity];
          lstOpp[0].stageName = 'Needs Analysis';
          update lstOpp;
           
          lstOpp[0].stageName = 'Waiting for Buyer\'s Wire';
          test.startTest();
          update lstOpp;
           test.stopTest();
       }
    @isTest  public static void opportunityTriggerOppStageAfterUpdateTest() {
        Account newAccount = [SELECT ID
                              FROM Account
                              LIMIT 1];
        Equipment__c newEquipment = [SELECT id,category__c 
                                     FROM Equipment__c 
                                     LIMIT 1];
        try{
          newEquipment.Category__c = 'Dozer';
        update newEquipment;  
        }
        catch(exception e){
            system.assert(true);
        }
        
        contact newContact = [SELECT ID
                              FROM contact
                              LIMIT 1];
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, newEquipment.id, newAccount.id);
        lstProduct[0].Site_Contact__c = newContact.id;
        lstProduct[0].Storage_Address__c = 'test';
        lstProduct[0].Storage_City__c = 'test';
        lstProduct[0].Storage_Country__c ='test'; 
        lstProduct[0].Storage_State__c = 'test';
        lstProduct[0].Storage_Zip_Code__c = '131001';
        insert lstProduct;
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, newAccount.id, lstProduct[0].id);
        lstOpportunity[0].recordtypeid =
            Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
        lstOpportunity[0].Inspector_Type__c = 'Other';
        insert lstOpportunity;
        lstOpportunity[0].stageName = 'offer Accepted';
        
        test.startTest();
        update lstOpportunity;
        test.stopTest();        
      
    }
    
           @isTest  public static void oppTriggerStageAfterUpdateTest() { 
          list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c,stageName
                                      FROM opportunity];
          lstOpp[0].stageName = 'Needs Analysis';
          update lstOpp;
           
          lstOpp[0].stageName = 'Waiting for Buyer\'s Wire';
          test.startTest();
          update lstOpp;
           test.stopTest();
       }
    @isTest  public static void opportunityTriggerOppStageAfterUpdateTest3(){
        Account newAccount = [SELECT ID,Primary_Contact__c
                              FROM Account
                              LIMIT 1];
       
        Equipment__c newEquipment = [SELECT id,category__c 
                                     FROM Equipment__c 
                                     LIMIT 1]; 
        try{
            newEquipment.Category__c = 'Wheel loader';
            update newEquipment; 
        }
        catch(exception e){
            system.assert(true);
        }
        
        contact newContact = [SELECT ID
                              FROM contact
                              LIMIT 1];
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, newEquipment.id, newAccount.id);
        lstProduct[0].Site_Contact__c = newContact.id;
        lstProduct[0].Storage_Address__c = 'test';
        lstProduct[0].Storage_City__c = 'test';
        lstProduct[0].Storage_Country__c ='test'; 
        lstProduct[0].Storage_State__c = 'test';
        lstProduct[0].Storage_Zip_Code__c = '131001';
        lstProduct[0].account__c = newAccount.id;
        
        insert lstProduct;
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, newAccount.id, lstProduct[0].id);
        lstOpportunity[0].recordtypeid =
            Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
        lstOpportunity[0].Inspector_Type__c = 'Other';
        lstOpportunity[0].Approved__c = true;
        insert lstOpportunity;
        lstOpportunity[0].stageName = 'Invoice approved';
        lstOpportunity[0].Approved__c = true;
        
        test.startTest();
        update lstOpportunity;
        test.stopTest();        
      
    }
    
    
    
    
    
    
    
    
   @isTest  public static void opportunityTriggerStageAfterUpdateTest6() { 
        list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c,stageName
                                    FROM opportunity];
        
        lstOpp[0].RecordTypeId = 
            Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
       lstOpp[0].StageName ='Client Inspection Requested';
       lstOpp[0].recordtypeId = 
           Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_Type_Inventory_Sell).getRecordTypeId();
       lstOpp[0].Inspector_Type__c = 'Other';
       test.startTest();
        update lstOpp;
        test.stopTest();
    }
    
     @isTest  public static void opportunityTriggerStageAfterUpdateTest7() { 
        list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c,stageName
                                    FROM opportunity];
        
        lstOpp[0].RecordTypeId = 
            Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
       lstOpp[0].StageName ='Received Buyers Wire';
       lstOpp[0].recordtypeId = 
               Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_Type_Broker_Sell).getRecordTypeId();
       lstOpp[0].Inspector_Type__c = 'Other';
       test.startTest();
        update lstOpp;
        test.stopTest();
    }
    @isTest  public static void opportunityTriggerStageAfterUpdateTest2() { 
        list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c,stageName
                                    FROM opportunity];
        
        lstOpp[0].stageName = 'Pro Forma Signed';
        test.startTest();
        update lstOpp;
        test.stopTest();
    }
    @isTest  public static void opportunityTriggerInvoiceDetailAfterUpdateTest2() { 
        
        list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c,stageName,Invoice_Details__c,Primary_Contact__c
                                    FROM opportunity WHERE Invoice_Details__c =false AND Primary_Contact__c !=null];
        contact newContact = [SELECT ID FROM contact LIMIT 1];
        //lstOpp[0].stageName = 'Pro Forma Signed';

        lstOpp[0].Invoice_Details__c = true;
        lstOpp[0].stageName = 'offer Accepted';
        test.startTest();
        update lstOpp;
        test.stopTest();
    }
         @isTest  public static void opportunityTriggerStageAfterUpdateTest1() { 
          list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c,stageName
                                      FROM opportunity];
          lstOpp[0].stageName = 'Needs Analysis';
          update lstOpp;
          lstOpp[0].stageName = 'Received Buyers Wire';
          test.startTest();
          update lstOpp;
          test.stopTest();
    }
    @isTest  public static void opportunityTriggerStageAfterUpdateTest3() { 
        list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c,stageName,RecordTypeId
                                    FROM opportunity];
        lstOpp[0].stageName = 'Document Review';
        lstOpp[0].Inspection_Status__c = 'Completed'; 
        lstOpp[0].Inspection_Conversation_Notes_from_Owner__c = 'Test';
        lstOpp[0].RecordTypeId = 
        Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
        test.startTest();
        update lstOpp;
        test.stopTest();
    }
    
    @isTest  public static void opportunityTriggerStageAfterUpdateTest4() { 
        list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c,stageName
                                    FROM opportunity];
        lstOpp[0].stageName = 'Won - Purchased';
         lstOpp[0].Inspection_Conversation_Notes_from_Owner__c = 'Test';
        lstOpp[0].Inspection_Status__c = 'Completed'; 
        lstOpp[0].Offer_Amount__c = 1000;
        lstOpp[0].Mailchimp_Email__c ='Advertised';
        lstOpp[0].RecordTypeId = 
            Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
        test.startTest();
        update lstOpp;
        test.stopTest();
    }
    
    @isTest  public static void opportunityTriggerStageAfterUpdateTest5() { 
        list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c,stageName
                                    FROM opportunity];
        
        lstOpp[0].RecordTypeId = 
            Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
        lstOpp[0].StageName ='Offer Accepted';
        lstOpp[0].Inspector_Type__c = 'Other';
        test.startTest();
        update lstOpp;
        test.stopTest();
    }
    
       @isTest  public static void opportunityTriggerCategoryAfterUpdateTest() { 
          list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c,WTB_Status__c,ForecastCategoryName
                                      FROM opportunity];
          lstOpp[0].ForecastCategoryName = 'Pipeline';
          update lstOpp;
           
          lstOpp[0].ForecastCategoryName = 'Closed';
          test.startTest();
          update lstOpp;
          test.stopTest();
    }
    
      @isTest  public static void opportunityTriggerAfterUpdateTest3() { 
        list<opportunity> lstOpp = [SELECT Id,WTB_Date__c,name,WTB_Priority__c
                                    FROM opportunity];
        lstOpp[0].WTB_Date__c = Date.newInstance(2021, 12, 9);
         lstOpp[0].WTB_Priority__c ='Low (Post on iron sites only)';
         test.startTest();
        update lstOpp;
         test.stopTest();
    }
    @isTest  public static void oppTriggerAfterUpdateTest() {
        //lstContact[0].MobilePhone = '9999999999';
        //lstContact[0].Phone = '9999999999';
        Account newAcc = [SELECT ID,Primary_Contact__c
                          FROM Account
                          LIMIT 1];
        contact newContact = [SELECT id,MobilePhone,Phone
                              FROM contact 
                              LIMIT 1 ];
        equipment__c newEquipment = [SELECT ID from equipment__c LIMIT 1];
        newContact.MobilePhone = '9999999999';
        newContact.Phone = '9999999999';
        update newContact;
        newAcc.Primary_Contact__c = newContact.Id;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, newEquipment.id, newAcc.id);
        //lstProduct[0].Primary_Contact__c = newContact.Id;
        insert lstProduct;
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, newAcc.id, lstProduct[0].id);
        insert lstOpportunity;
        
    }
    
    
    
    @isTest  public static void opportunityTriggerAfterUpdateTest2() { 
        product2 newProduct = [SELECT ID 
                               FROM product2 
                               LIMIT 1];
        Account newAccount = [SELECT ID 
                              FROM Account
                              LIMIT 1];
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, newAccount.id, newProduct.id);
        lstOpportunity[0].StageName = 'Reviewing';
        test.startTest();
        insert lstOpportunity;
        test.stopTest();
    }
    @isTest  public static void OpportunityTriggerHandlerBeforeTest2() {
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate(1, lstEquipment[0].id);
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
    
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
        string ProcuretmentRecordType = label.Opp_Rec_type_Dev_Name_procurement_opp ;
        list<recordType> lstRecordType ;
        if(string.isNotBlank(ProcuretmentRecordType)){
             lstRecordType = [SELECT Id,DeveloperName From RecordType Where DeveloperName =: ProcuretmentRecordType];
        }
       system.debug('lstRecordType'+lstRecordType);
        
        for(Opportunity eachOpportunity : lstOpportunity){
            if(lstRecordType !=null && !lstRecordType.isEmpty()){
                eachOpportunity.RecordTypeId = lstRecordType[0].id;
				eachOpportunity.StageName = 'Offer Accepted';
				eachOpportunity.Inspection_Status__c = 'Scheduled';
            }
            
        }
        test.startTest();
        try{
            insert lstOpportunity;
        }catch(exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Can not be changed to "Offer Accepted "') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }
        //update lstOpportunityUpdate;
        test.stopTest();
    }
    @isTest  public static void OpportunityTriggerHandlerTestonBeforeUpdate() {
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate(1, lstEquipment[0].id);
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        list<Opportunity> lstOpportunityUpdate = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
        insert lstOpportunityUpdate;
        
        for(Opportunity eachOpportunity : lstOpportunityUpdate){
            eachOpportunity.Financials_complete__c = true;
            
        }
        try{
            update lstOpportunityUpdate;
        }catch(exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('You can not mark the checkbox Financials Complete') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
       
    }
    @isTest  public static void OpportunityTriggerHandlerTestonBeforeInsert1() {
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        for(account eachAccount : lstAccount){
            eachAccount.BillingCountry ='India';
            eachAccount.BillingState ='Haryana';
            eachAccount.BillingCity='Rewari';
            eachAccount.BillingStreet='rewari';
            eachAccount.BillingPostalCode='2133';
            
        }
        insert lstAccount;
        system.debug('lstAccount::'+lstAccount);
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate(1, lstEquipment[0].id);
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        RecordType procurementOppRecordType = [SELECT Id FROM RecordType 
                                               where DeveloperName =: System.Label.Opp_Rec_type_Dev_Name_procurement_opp LIMIT 1 ];
        
        list<Opportunity> lstOpportunityInsert1 = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
       	for(Opportunity eachOpportunity : lstOpportunityInsert1){
            eachOpportunity.RecordTypeId = procurementOppRecordType.id;
        }
        insert lstOpportunityInsert1;
        
        list<Opportunity> lstOpportunityInsert = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
		
        for(Opportunity eachOpportunity : lstOpportunityInsert){
            eachOpportunity.RecordTypeId = procurementOppRecordType.id;
        }
        
        
        
        try{
            insert lstOpportunityInsert;
        }catch(exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Procurement Opportunity for this Unit') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
    }
    
    @isTest  public static void OpportunityTriggerHandlerTestonBeforeUpdate1() {
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        for(account eachAccount : lstAccount){
            eachAccount.BillingCountry ='India';
            eachAccount.BillingState ='Haryana';
            eachAccount.BillingCity='Rewari';
            eachAccount.BillingStreet='rewari';
            eachAccount.BillingPostalCode='2133';
            
        }
        insert lstAccount;
        system.debug('lstAccount::'+lstAccount);
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate(1, lstEquipment[0].id);
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        RecordType procurementOppRecordType = [SELECT Id FROM RecordType 
                                               where DeveloperName =: System.Label.Opp_Rec_type_Dev_Name_procurement_opp LIMIT 1 ];
        
        list<Opportunity> lstOpportunityInsert1 = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
       	for(Opportunity eachOpportunity : lstOpportunityInsert1){
            eachOpportunity.RecordTypeId = procurementOppRecordType.id;
        }
        insert lstOpportunityInsert1;
        
        list<Opportunity> lstOpportunityInsert = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
		insert lstOpportunityInsert;
        for(Opportunity eachOpportunity : lstOpportunityInsert){
            eachOpportunity.RecordTypeId = procurementOppRecordType.id;
        }
        
        
        
        try{
            update lstOpportunityInsert;
        }catch(exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Opportunity RecordType is not') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
    }
    @isTest  public static void OpportunityTriggerHandlerBeforeUpdateTest2() {
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate(1, lstEquipment[0].id);
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
    
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
        string ProcuretmentRecordType = label.Opp_Rec_type_Dev_Name_procurement_opp ;
        list<recordType> lstRecordType ;
        if(string.isNotBlank(ProcuretmentRecordType)){
             lstRecordType = [SELECT Id,DeveloperName From RecordType Where DeveloperName =: ProcuretmentRecordType];
        }
       system.debug('lstRecordType'+lstRecordType);
        insert lstOpportunity;
        for(Opportunity eachOpportunity : lstOpportunity){
            if(lstRecordType !=null && !lstRecordType.isEmpty()){
                eachOpportunity.RecordTypeId = lstRecordType[0].id;
				eachOpportunity.StageName = 'Offer Accepted';
				eachOpportunity.Inspection_Status__c = 'Scheduled';
            }
            
        }
        test.startTest();
        try{
            update lstOpportunity;
        }catch(exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Can not be changed to "Offer Accepted "') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }
        //update lstOpportunityUpdate;
        test.stopTest();
    }
    
     @isTest  public static void OpportunityTriggerHandlerAfterUpdate() {
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(2,'company');
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , lstAccount[0].id);
        insert lstUnit;
        list<Opportunity> lstOpportunity = TestDataFactory.createOpportunity(1, lstAccount[0].id, lstUnit[0].id);
        string procurementOpp = System.Label.Opp_Rec_type_Dev_Name_procurement_opp;
            RecordType procurementOppRecordType = [SELECT Id FROM RecordType where DeveloperName =: procurementOpp LIMIT 1 ];
        lstOpportunity[0].RecordTypeId =procurementOppRecordType.id; 
        insert lstOpportunity; 
         Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
         for(Opportunity eachOpportunity : lstOpportunity){
              eachOpportunity.StageName = 'Closed Lost';
         }
         system.debug('lstOpportunity'+lstOpportunity);
         test.startTest();
         update lstOpportunity;
         test.stopTest();
     }
    @isTest  public static void OpportunityTriggerHandlerAfterDeleteTest() {
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
    
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
        string ProcuretmentRecordType = label.Opp_Rec_type_Dev_Name_procurement_opp ;
        list<recordType> lstRecordType ;
        if(string.isNotBlank(ProcuretmentRecordType)){
             lstRecordType = [SELECT Id,DeveloperName From RecordType Where DeveloperName =: ProcuretmentRecordType];
        }
       system.debug('lstRecordType'+lstRecordType);
        
        for(Opportunity eachOpportunity : lstOpportunity){
            if(lstRecordType !=null && !lstRecordType.isEmpty()){
                eachOpportunity.RecordTypeId = lstRecordType[0].id;
            }
            
        }
        insert lstOpportunity;
        test.startTest();
        delete lstOpportunity;
        //update lstOpportunityUpdate;
        test.stopTest();
    }
    //test class to create task in unit
    @isTest  public static void testOpportunityTriggerHandlerAfterUpdate() {
        user newUser = TestDataFactory.createTestUser('user','test');
        insert  newUser;
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,'company');
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , lstAccount[0].id);
        lstUnit[0].Unit_Owner__c=newUser.id;
        insert lstUnit;
        system.debug('lstAccount::'+lstAccount);
        system.debug('lstUnit::'+lstUnit);
        string ProcuretmentRecordType = label.Opp_Rec_type_Dev_Name_procurement_opp ;
        list<recordType> lstRecordType ;
        if(string.isNotBlank(ProcuretmentRecordType)){
             lstRecordType = [SELECT Id,DeveloperName From RecordType Where DeveloperName =: ProcuretmentRecordType];
        }
        list<Opportunity> lstOpportunity = TestDataFactory.createOpportunity1(1, lstAccount[0].id, lstUnit[0].id);
        //lstOpportunity[0].Market_on_FB__c=true;
        //lstOpportunity[0].StageName='Proactive Brokerage';
        lstOpportunity[0].RecordTypeId = lstRecordType[0].id;
        insert lstOpportunity;
        system.debug('lstOpportunity::'+lstOpportunity);
        list<Opportunity> lstNewOpportunity = new list<Opportunity>();
        for(Opportunity eachOpp : lstOpportunity){
            //eachOpp.RecordTypeId = lstRecordType[0].id;
            eachOpp.StageName='Proactive Brokerage';
            lstNewOpportunity.add(eachOpp);
        }
        test.startTest();
        update lstNewOpportunity;
        system.debug('lstNewOpportunity:'+lstNewOpportunity);
        test.stopTest();
        system.debug('lstNewOpportunity:'+lstNewOpportunity);
        system.debug('lstOpportunity:'+lstOpportunity);
    }
        @isTest  public static void testOpportunityTriggerHandlerAfterUpdate1() {
        user newUser = TestDataFactory.createTestUser('Kevin','Vellek');//Kevin Vellek
        insert  newUser;
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,'company');
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , lstAccount[0].id);
        lstUnit[0].Unit_Owner__c=newUser.id;
        insert lstUnit;
        string ProcuretmentRecordType = label.Opp_Rec_type_Dev_Name_procurement_opp ;
        list<recordType> lstRecordType ;
        if(string.isNotBlank(ProcuretmentRecordType)){
             lstRecordType = [SELECT Id,DeveloperName From RecordType Where DeveloperName =: ProcuretmentRecordType];
        }
        list<Opportunity> lstOpportunity = TestDataFactory.createOpportunity1(1, lstAccount[0].id, lstUnit[0].id);
        //lstOpportunity[0].Market_on_FB__c=true;
        lstOpportunity[0].RecordTypeId = lstRecordType[0].id;
        insert lstOpportunity;
        list<Opportunity> lstNewOpportunity = new list<Opportunity>();
        for(Opportunity eachOpp : lstOpportunity){
            eachOpp.RecordTypeId = lstRecordType[0].id;
            //eachOpp.Market_on_FB__c = true;
            eachOpp.StageName='Proactive Brokerage';
            lstNewOpportunity.add(eachOpp);
        }
        test.startTest();
        update lstNewOpportunity;
        test.stopTest();
        system.debug('lstNewOpportunity:'+lstNewOpportunity);
        system.debug('lstOpportunity:'+lstOpportunity);
    }
    
    @isTest  public static void OpportunityTriggerHandlerAfterUnDeleteTest() {
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
    
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
        string ProcuretmentRecordType = label.Opp_Rec_type_Dev_Name_procurement_opp ;
        list<recordType> lstRecordType ;
        if(string.isNotBlank(ProcuretmentRecordType)){
             lstRecordType = [SELECT Id,DeveloperName From RecordType Where DeveloperName =: ProcuretmentRecordType];
        }
       system.debug('lstRecordType'+lstRecordType);
        
        for(Opportunity eachOpportunity : lstOpportunity){
            if(lstRecordType !=null && !lstRecordType.isEmpty()){
                eachOpportunity.RecordTypeId = lstRecordType[0].id;
            }
            
        }
        insert lstOpportunity;
        delete lstOpportunity;
        test.startTest();
        undelete lstOpportunity;
        //update lstOpportunityUpdate;
        test.stopTest();
    }
    
}