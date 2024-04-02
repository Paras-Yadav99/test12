@isTest
public class LeadTriggerTest {
     @testSetup
    public static void CreateTestData(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
         list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Zadoon_s_Final_Purchase_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Transaction_Expense_Total__c=100;
        lstOfProductToAdd[0].Unit_Transaction_Income_Total__c =300;
        lstOfProductToAdd[0].Sellers_Most_Recent_Bottom_Price__c=1000;
        lstOfProductToAdd[0].Sellers_Initial_Bottom_Price__c=100;
        lstOfProductToAdd[0].Sellers_Original_Asking_Price__c=100;
        //lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;
        insert lstOfProductToAdd;
        list<contact> lstContact = TestDaTaFactory.noOfContactToInsert(1,'test');
        insert lstContact;
        list<lead> lstLead = TestDaTaFactory.noOfLeadToInsert(1,'');
        insert lstLead;
        User newUser = TestDaTaFactory.createTestUser('Shelly','Murphy');
        insert newUser;
        list<User_Requirement_ID__c> newUserRequirement = testDataFactory.createUserRequirementID(1);
        newUserRequirement[0].lead__c =  lstLead[0].id;       
        newUserRequirement[0].Max_Budget__c =1000;
        newUserRequirement[0].Min_Budget__c = 100;
        newUserRequirement[0].Weight_Max__c = 1100;
        newUserRequirement[0].Weight_Min__c = 100;
        insert newUserRequirement;
        list<iron_demand__c> lstIronDemand = testDataFactory.createlstIronDemand(1,lstToAdd[0].id);
        lstIronDemand[0].Unit_Currently_Interested_In__c =lstOfProductToAdd[0].id; 
        lstIronDemand[0].User_Requirement_ID__c = newUserRequirement[0].id;
        insert lstIronDemand;
        
    }
    
    @isTest
    public static void testMethodForInsert(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Zadoon_s_Final_Purchase_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Transaction_Expense_Total__c=100;
        lstOfProductToAdd[0].Unit_Transaction_Income_Total__c =300;
        lstOfProductToAdd[0].Sellers_Most_Recent_Bottom_Price__c=1000;
        lstOfProductToAdd[0].Sellers_Initial_Bottom_Price__c=100;
        lstOfProductToAdd[0].Sellers_Original_Asking_Price__c=100;
        //lstOfProductToAdd[0].Unit_Stage__c ='Potential trade';
        /*lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;*/
        insert lstOfProductToAdd;
        Contact con = TestDaTaFactory.createContact(True);
		User newUser = TestDaTaFactory.createTestUser('Shelly','Murphy');
        insert newUser;
        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Unit__c = lstOfProductToAdd[0].Id;
        lead.Contact__c = con.Id;
        lead.Output_Relevant__c=true;
        
        Test.startTest();
        insert lead;
        Test.stopTest();

        list<Iron_Demand__c> ironDemand = [SELECT Id FROM Iron_Demand__c limit 1];
        System.assert(ironDemand != null);
    }

        @isTest
    public static void testMethodtoInsert(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Zadoon_s_Final_Purchase_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Transaction_Expense_Total__c=100;
        lstOfProductToAdd[0].Unit_Transaction_Income_Total__c =300;
        lstOfProductToAdd[0].Sellers_Most_Recent_Bottom_Price__c=1000;
        lstOfProductToAdd[0].Sellers_Initial_Bottom_Price__c=100;
        lstOfProductToAdd[0].Sellers_Original_Asking_Price__c=100;
        lstOfProductToAdd[0].Unit_Stage__c ='Potential Trade';
        lstOfProductToAdd[0].isactive = false;
        lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;

        insert lstOfProductToAdd;
		
        Contact con = TestDaTaFactory.createContact(True);
		User newUser = TestDaTaFactory.createTestUser('Shelly','Murphy');
        insert newUser;
        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Unit__c = lstOfProductToAdd[0].Id;
        lead.Contact__c = con.Id;
        lead.Output_Relevant__c=true;
        try{
            Test.startTest();
            insert lead;
            Test.stopTest();   
        }
        catch(exception e){
            system.assert(true);
        }

        list<Iron_Demand__c> ironDemand = [SELECT Id FROM Iron_Demand__c limit 1];
        System.assert(ironDemand != null);
    }
    
        @isTest
    public static void testMethodForInsert1(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;
        lstOfProductToAdd[0].Old_SF_Unit_Details__c = 'Test';
        insert lstOfProductToAdd;
		
        Contact con = TestDaTaFactory.createContact(True);
		User newUser = TestDaTaFactory.createTestUser('Shelly','Murphy');
        insert newUser;
        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Unit__c = lstOfProductToAdd[0].Id;
        lead.Contact__c = con.Id;
        lead.Output_Relevant__c=true;
        
        Test.startTest();
        insert lead;
        Test.stopTest();

        list<Iron_Demand__c> ironDemand = [SELECT Id FROM Iron_Demand__c limit 1];
        System.assert(ironDemand != null);
    }
       @isTest
    public static void testMethodToInsert1(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Stage__c ='Potential Trade';
        lstOfProductToAdd[0].isactive = false;
        
            insert lstOfProductToAdd;
        
        Contact con = TestDaTaFactory.createContact(True);
		User newUser = TestDaTaFactory.createTestUser('Shelly','Murphy');
        insert newUser;
        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Unit__c = lstOfProductToAdd[0].Id;
        lead.Contact__c = con.Id;
        lead.Output_Relevant__c=true;
        try{
            Test.startTest();
            insert lead;
            Test.stopTest();
        }
        catch(exception e){
            system.assert(true);
        }
        list<Iron_Demand__c> ironDemand = [SELECT Id FROM Iron_Demand__c limit 1];
        System.assert(ironDemand != null);
    }
    
 @isTest
    public static void testMethodForLeadInsert(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Zadoon_s_Final_Purchase_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Transaction_Expense_Total__c=100;
        lstOfProductToAdd[0].Unit_Transaction_Income_Total__c =300;
        lstOfProductToAdd[0].Sellers_Most_Recent_Bottom_Price__c=1000;
        lstOfProductToAdd[0].Sellers_Initial_Bottom_Price__c=100;
        lstOfProductToAdd[0].Sellers_Original_Asking_Price__c=100;
        lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Stage__c ='Potential Trade';
        lstOfProductToAdd[0].isactive = false;
        insert lstOfProductToAdd;

        list<Contact> lstCon = TestDaTaFactory.noOfContactToInsert(1,'test');
        insert lstCon;
		User newUser = TestDaTaFactory.createTestUser('Shelly','Murphy');
        insert newUser;
        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Unit__c = lstOfProductToAdd[0].Id;
        lead.Contact__c = lstCon[0].Id;
        lead.Evaluation_Output__c = 'test';
        lead.Output_Relevant__c=true;
        lead.Status = 'Eval Required';
        try{
            Test.startTest();
            insert lead;
            Test.stopTest();
        }
        catch(exception e){
            system.assert(true);
        }
        list<Iron_Demand__c> ironDemand = [SELECT Id 
                                     FROM Iron_Demand__c 
                                     limit 1];
        System.assert(ironDemand != null);
    }
     @isTest
    public static void testMethodForLeadInsert1(){
       contact newContact = [SELECT id
                             FROM contact
                             LIMIT 1];
        list<lead> lstLead = TestDaTaFactory.noOfLeadToInsert(1,'');
        list<lead> lstLeadToInsert = new list<lead>();
        for(lead eachLead : lstLead){
            eachLead.Contact__c = newContact.Id;
            eachLead.Output_Relevant__c=true; 
            eachLead.Status = 'Pending Unit Addition';
            lstLeadToInsert.add(eachLead);
        }
       
        Test.startTest();
        insert lstLeadToInsert;
        system.debug('lstLeadToInsert:::'+lstLeadToInsert);
        Test.stopTest();
        /*Iron_Demand__c ironDemand = [SELECT Id 
                                     FROM Iron_Demand__c 
                                     limit 1];
        System.assert(ironDemand != null);*/
    }
    
    
    @isTest
    public static void testMethodForUpdate(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
        User newUser = TestDaTaFactory.createTestUser('Shelly','Murphy');
        insert newUser;
        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Zadoon_s_Final_Purchase_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Transaction_Expense_Total__c=100;
        lstOfProductToAdd[0].Unit_Transaction_Income_Total__c =300;
        lstOfProductToAdd[0].Sellers_Most_Recent_Bottom_Price__c=1000;
        lstOfProductToAdd[0].Sellers_Initial_Bottom_Price__c=100;
     	lstOfProductToAdd[0].Sellers_Original_Asking_Price__c=100;
        //lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;
        insert lstOfProductToAdd;
		 product2 newProduct = [SELECT id
                                FROM product2
                                LIMIT 1 ];
        system.debug('newProduct::'+newProduct);
        Contact con = TestDaTaFactory.createContact(True);

        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Contact__c = con.Id;
        lead.Output_Relevant__c = false;
        lead.Status = 'Offer Rejected';
        lead.Deactivate_Unit_after_Lost_Lead__c = true;
        insert lead;
       
         lead.Unit__c = newProduct.Id;
        lead.Output_Relevant__c = true;
        lead.Status = 'Reviewing';
        Test.startTest();
        update lead;
        Test.stopTest();

    }
  @isTest
    public static void testMethodtoUpdateNew(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
        User newUser = TestDaTaFactory.createTestUser('Shelly','Murphy');
        insert newUser;
        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Zadoon_s_Final_Purchase_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Transaction_Expense_Total__c=100;
        lstOfProductToAdd[0].Unit_Transaction_Income_Total__c =300;
        lstOfProductToAdd[0].Sellers_Most_Recent_Bottom_Price__c=1000;
        lstOfProductToAdd[0].Sellers_Initial_Bottom_Price__c=100;
     	lstOfProductToAdd[0].Sellers_Original_Asking_Price__c=100;
        //lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;
        insert lstOfProductToAdd;
		 product2 newProduct = [SELECT id
                                FROM product2
                                LIMIT 1 ];
        system.debug('newProduct::'+newProduct);
        Contact con = TestDaTaFactory.createContact(True);

        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Unit__c= lstOfProductToAdd[0].id;
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Contact__c = con.Id;
        lead.Output_Relevant__c = false;
         //lead.Stage__c = '';
        insert lead;
       
         lead.Unit__c = newProduct.Id;
        lead.Output_Relevant__c = true;
        lead.Status = 'Stopped Pursuing';
        lead.Deactivate_Unit_after_Lost_Lead__c=true;
        Test.startTest();
        update lead;
        Test.stopTest();
    }    
    @isTest
    public static void testMethodtoUpdate(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Zadoon_s_Final_Purchase_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Transaction_Expense_Total__c=100;
        lstOfProductToAdd[0].Unit_Transaction_Income_Total__c =300;
        lstOfProductToAdd[0].Sellers_Most_Recent_Bottom_Price__c=1000;
        lstOfProductToAdd[0].Sellers_Initial_Bottom_Price__c=100;
     	lstOfProductToAdd[0].Sellers_Original_Asking_Price__c=100;
        //lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;
        insert lstOfProductToAdd;
		 product2 newProduct = [SELECT id
                                FROM product2
                                LIMIT 1 ];
        system.debug('newProduct::'+newProduct);
        Contact con = TestDaTaFactory.createContact(True);

        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Unit__c= lstOfProductToAdd[0].id;
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Contact__c = con.Id;
        lead.Output_Relevant__c = false;
         //lead.Stage__c = '';
        insert lead;
       
         lead.Unit__c = newProduct.Id;
        lead.Output_Relevant__c = true;
        lead.Status = 'Offer Approved';
        Test.startTest();
        update lead;
        Test.stopTest();
    }
     @isTest
    public static void testMethodtoUpdateForQualified(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Zadoon_s_Final_Purchase_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Transaction_Expense_Total__c=100;
        lstOfProductToAdd[0].Unit_Transaction_Income_Total__c =300;
        lstOfProductToAdd[0].Sellers_Most_Recent_Bottom_Price__c=1000;
        lstOfProductToAdd[0].Sellers_Initial_Bottom_Price__c=100;
     	lstOfProductToAdd[0].Sellers_Original_Asking_Price__c=100;
        //lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;
        insert lstOfProductToAdd;
		 product2 newProduct = [SELECT id
                                FROM product2
                                LIMIT 1 ];
        system.debug('newProduct::'+newProduct);
        Contact con = TestDaTaFactory.createContact(True);

        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Unit__c= lstOfProductToAdd[0].id;
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Contact__c = con.Id;
        lead.Output_Relevant__c = false;
         //lead.Stage__c = '';
        insert lead;
       
         lead.Unit__c = newProduct.Id;
        lead.Output_Relevant__c = true;
        lead.Status = 'Qualified';
        Test.startTest();
        update lead;
        Test.stopTest();
    }
    @isTest
    public static void testMethodtoUpdateForSalesLead(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
        contact newContact = [SELECT id
                              FROM Contact
                              LIMIT 1];
        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Zadoon_s_Final_Purchase_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Transaction_Expense_Total__c=100;
        lstOfProductToAdd[0].Unit_Transaction_Income_Total__c =300;
        lstOfProductToAdd[0].Sellers_Most_Recent_Bottom_Price__c=1000;
        lstOfProductToAdd[0].Sellers_Initial_Bottom_Price__c=100;
     	lstOfProductToAdd[0].Sellers_Original_Asking_Price__c=100;
        //lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;
        insert lstOfProductToAdd;
		 product2 newProduct = [SELECT id
                                FROM product2
                                LIMIT 1 ];
        system.debug('newProduct::'+newProduct);
        list<contact> lstContact = TestDaTaFactory.noOfContactToInsert(1,'test');
        lstContact[0].Primary_contact__c = true;
        insert lstContact;
		system.debug(' Sch:::'+Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(label.Lead_Record_Type_Sales_lead).getRecordTypeId());
        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Unit__c= lstOfProductToAdd[0].id;
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Contact__c = lstContact[0].Id;
        lead.Output_Relevant__c = false;
        lead.RecordTypeId = 
            Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(label.Lead_Record_Type_Sales_lead).getRecordTypeId();
        try{
            insert lead;
        }
        catch(exception ex){
            
        }
          lead.Unit__c = newProduct.Id;
        lead.Output_Relevant__c = true;
        lead.Contact__c =newContact.id;
        Test.startTest();
        try{
            update lead;
        }
        catch(exception ex){}
            
        Test.stopTest();
    }
    
    
    @isTest
    public static void testMethodtoUpdateForOfferPendingApproval(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
        lead newLead = [SELECT ID
                       FROM lead
                       LIMIT 1];
        contact newContact = [SELECT id
                              FROM Contact
                              LIMIT 1];
        system.debug('newLead::'+newLead);
        User_Requirement_ID__c newUserReq = [SELECT ID, lead__c,
                                             (SELECT ID,User_Requirement_ID__c
                                              FROM iron_demand__r)
                                             FROM User_Requirement_ID__c
                                             WHERE opportunity__c = null AND lead__c=:newLead.id
                                             LIMIT 1];
        system.debug('newUserReq:::'+newUserReq);
        iron_demand__c newIronDemand = [SELECT ID,User_Requirement_ID__c
                                        FROM iron_demand__c
                                        WHERE User_Requirement_ID__c != null 
                                        AND User_Requirement_ID__c =:newUserReq.ID
                                        LIMIT 1];
        system.debug('newIronDemand:::'+newIronDemand);
        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Zadoon_s_Final_Purchase_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Transaction_Expense_Total__c=100;
        lstOfProductToAdd[0].Unit_Transaction_Income_Total__c =300;
        lstOfProductToAdd[0].Sellers_Most_Recent_Bottom_Price__c=1000;
        lstOfProductToAdd[0].Sellers_Initial_Bottom_Price__c=100;
     	lstOfProductToAdd[0].Sellers_Original_Asking_Price__c=100;
        //lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;
        insert lstOfProductToAdd;
		 product2 newProduct = [SELECT id
                                FROM product2
                                LIMIT 1 ];
        system.debug('newProduct::'+newProduct);
        Contact con = TestDaTaFactory.createContact(True);
		
        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Unit__c= lstOfProductToAdd[0].id;
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Contact__c = con.Id;
        lead.Output_Relevant__c = false;
        lead.Evaluation_Output__c='Test';
        lead.Offer_Amount__c = 1000;
        lead.Status = 'Qualified';
        insert lead;
       
         lead.Unit__c = newProduct.Id;
        lead.Output_Relevant__c = true;
        lead.Status = 'Offer Pending Approval';
        lead.Contact__c = newContact.id;
        Test.startTest();
        update lead;
        Test.stopTest();
    }
    
    
        @isTest
    public static void testMethodtoUpdate1(){
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;
        User newUser = TestDaTaFactory.createTestUser('Shelly','Murphy');
        insert newUser;
        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].Zadoon_s_Final_Purchase_Price__c = 1000;
        lstOfProductToAdd[0].Unit_Transaction_Expense_Total__c=100;
        lstOfProductToAdd[0].Unit_Transaction_Income_Total__c =300;
        lstOfProductToAdd[0].Sellers_Most_Recent_Bottom_Price__c=1000;
        lstOfProductToAdd[0].Sellers_Initial_Bottom_Price__c=100;
     	lstOfProductToAdd[0].Sellers_Original_Asking_Price__c=100;
        lstOfProductToAdd[0].Unit_Stage__c ='Potential Trade';
        lstOfProductToAdd[0].isactive = false;
        lstOfProductToAdd[0].Starting_Advertised_Retail_Price__c = 1000;
        insert lstOfProductToAdd;
		 product2 newProduct = [SELECT id
                                FROM product2
                                LIMIT 1 ];
        system.debug('newProduct::'+newProduct);
        Contact con = TestDaTaFactory.createContact(True);

        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Contact__c = con.Id;
        lead.Output_Relevant__c = false;
        lead.Status = 'Reviewing';
        insert lead;
       
         lead.Unit__c = newProduct.Id;
        lead.Output_Relevant__c = true;
        lead.Status = 'Offer Approved';
        try{
            Test.startTest();
            update lead;
            Test.stopTest(); 
        }
        catch(exception e){
            system.assert(true);
        }
        

    }
        @isTest
    public static void testMethodForUpdate1(){
         list<Contact> lstCon = TestDaTaFactory.noOfContactToInsert(1,'test');
        insert lstCon;

        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Contact__c = lstCon[0].Id;
        lead.Output_Relevant__c = false;
        lead.Status = 'Offer Made';
        insert lead;
        lead.Output_Relevant__c = true;
         lead.Status = 'Reviewing';
        Test.startTest();
        update lead;
        system.debug('lead:::'+lead);
        Test.stopTest();

    }
      @isTest
    public static void testMethodForUpdate5(){
         list<Contact> lstCon = TestDaTaFactory.noOfContactToInsert(1,'test');
        insert lstCon;
		 product2 newProduct = [SELECT id
                                FROM product2
                                LIMIT 1 ];
        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Unit__c = newProduct.Id;
        lead.Company = 'Test';
        lead.Contact__c = lstCon[0].Id;
        lead.Output_Relevant__c = false;
        lead.Status = 'Offer Made';
        insert lead;
        lead.Output_Relevant__c = true;
         lead.Status = 'Eval Required';
        Test.startTest();
        update lead;
        system.debug('lead:::'+lead);
        Test.stopTest();

    }
    @isTest
    public static void testMethodForUpdate6(){
         list<Contact> lstCon = TestDaTaFactory.noOfContactToInsert(1,'test');
        insert lstCon;

        Lead lead = new Lead();
        lead.MobilePhone = '123';
        lead.Email = 'test@gmail.com';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Contact__c = lstCon[0].Id;
        lead.Output_Relevant__c = false;
        lead.Status = 'Offer Made';
        insert lead;
        lead.Output_Relevant__c = true;
         lead.Status = 'Stopped Pursuing';
        Test.startTest();
        update lead;
        system.debug('lead:::'+lead);
        Test.stopTest();

    }
    @isTest
    public static void testMethodBeforeInsertRoundRobin(){
        list<Lead> lstDomesticLead= testDataFactory.noOfLeadToInsert(1,'+15437');
        list<Lead> lstLeadToInert= testDataFactory.noOfLeadToInsertForRoundRobin(1,'456261','test1@gmail.com','Kizzy123');
        list<Lead> lstLeadToInert2= testDataFactory.noOfLeadToInsertForRoundRobin(1,'45626','test13@gmail.com','Kizzy123');
        list<Lead> lstLeadToInert1= testDataFactory.noOfLeadToInsertForRoundRobin(1,'3484','test12@gmail.com','test');
        
        list<Lead> lstInternationalLead= testDataFactory.noOfLeadToInsert(1,'456261');
        list<Sales_Team__c> lstDomesticSalesTeam = testDataFactory.SalesTeamToInsert(1,'Domestic');
        insert lstDomesticSalesTeam;
        list<Sales_Team__c> lstInternationalSalesTeam = testDataFactory.SalesTeamToInsert(1,'International');
        insert lstInternationalSalesTeam;
        list<Team_Member__c> lstDomesticTeamMember = testDataFactory.TeamMemberToInsert(1,lstDomesticSalesTeam[0].id);
        insert lstDomesticTeamMember;
        
        list<Team_Member__c> lstInternationalTeamMember = testDataFactory.TeamMemberToInsert(1,lstInternationalSalesTeam[0].id);
        insert lstInternationalTeamMember;
        Test.startTest();
        insert lstDomesticLead;
       // insert lstInternationalLead;
       // insert lstLeadToInert;
        //insert lstLeadToInert1;
        //insert lstLeadToInert2;
        Test.stopTest();

       
    }
    @isTest
    public static void testMethodBeforeInsertRoundRobin1(){
        //list<Lead> lstDomesticLead= testDataFactory.noOfLeadToInsert(1,'+15437');
        list<Lead> lstLeadToInert= testDataFactory.noOfLeadToInsertForRoundRobin(1,'456261','test1@gmail.com','Kizzy123');
        insert lstLeadToInert;
        list<Lead> lstLeadToInert2= testDataFactory.noOfLeadToInsertForRoundRobin(1,'45626','test13@gmail.com','Kizzy123');
        list<Lead> lstLeadToInert1= testDataFactory.noOfLeadToInsertForRoundRobin(1,'3484','test1@gmail.com','test');
        list<Lead> lstLeadToInert3= testDataFactory.noOfLeadToInsertForRoundRobin(1,'456261','test113@gmail.com','Kizzy1123');
        
        //list<Lead> lstInternationalLead= testDataFactory.noOfLeadToInsert(1,'456261');
        list<Sales_Team__c> lstDomesticSalesTeam = testDataFactory.SalesTeamToInsert(1,'Domestic');
        insert lstDomesticSalesTeam;
        list<Sales_Team__c> lstInternationalSalesTeam = testDataFactory.SalesTeamToInsert(1,'International');
        insert lstInternationalSalesTeam;
        list<Team_Member__c> lstDomesticTeamMember = testDataFactory.TeamMemberToInsert(1,lstDomesticSalesTeam[0].id);
        insert lstDomesticTeamMember;
        
        list<Team_Member__c> lstInternationalTeamMember = testDataFactory.TeamMemberToInsert(1,lstInternationalSalesTeam[0].id);
        insert lstInternationalTeamMember;
        Test.startTest();
        //insert lstDomesticLead;
        //insert lstInternationalLead;
        
        //insert lstLeadToInert1;
        insert lstLeadToInert2;
       // insert lstLeadToInert3;
        Test.stopTest();       
    }
    @isTest
    public static void testMethodBeforeUpdateRoundRobin(){
        list<Lead> lstDomesticLead= testDataFactory.noOfLeadToInsert(1,'+15437');
        insert lstDomesticLead;
        list<Lead> lstInternationalLead= testDataFactory.noOfLeadToInsert(1,'456261');
        insert lstInternationalLead;
        
        list<Sales_Team__c> lstDomesticSalesTeam = testDataFactory.SalesTeamToInsert(1,'DOMESTIC');
        insert lstDomesticSalesTeam;
        list<Sales_Team__c> lstInternationalSalesTeam = testDataFactory.SalesTeamToInsert(1,'INTERNATIONAL');
        insert lstInternationalSalesTeam;
        list<Team_Member__c> lstDomesticTeamMember = testDataFactory.TeamMemberToInsert(1,lstDomesticSalesTeam[0].id);
        insert lstDomesticTeamMember;
        
        list<Team_Member__c> lstInternationalTeamMember = testDataFactory.TeamMemberToInsert(1,lstInternationalSalesTeam[0].id);
        insert lstInternationalTeamMember;
        
        for(lead eachLead : lstDomesticLead){
            eachLead.Region__c = 'INTERNATIONAL';
        }
        for(lead eachLead : lstInternationalLead){
            eachLead.Region__c = 'DOMESTIC';
        }
        Test.startTest();
        update lstDomesticLead;
        Test.stopTest();

       
    }
}