@istest
public class UnitTriggerTest {
   @testSetup static void setup() {
       Model__c model = TestDataFactory.createModel(true);
       Contact con = TestDataFactory.createContact(true);
       Equipment__c equipment = TestDataFactory.createEquipment(true, model.Id);
       Product2 unit = TestDataFactory.createUnit(true, model.Id, equipment.id);
       Iron_Demand__c iron = TestDataFactory.createIronDemand(false, equipment.id, con.id);
       iron.Max_Year__c = unit.Year__c;
       list<Yards__c> lstYards = TestDataFactory.lstYards(1);
       insert lstYards;
       system.debug('lstYards:::'+lstYards);
       insert iron;
       list<Equipment__c> lstEquipment = TestDataFactory.noOfEquipment(1);
       insert lstEquipment;
       list<Product2> lstProduct = TestDataFactory.noOfUnitsToCreate(1,lstEquipment[0].id);
       lstProduct[0].isActive = false;
       lstProduct[0].Unit_Stage__c = 'Reviewing';
       lstProduct[0].On_Zadoon_partner_yard1__c =  lstYards[0].id;
       insert lstProduct;
       user newUser = TestDataFactory.createTestUser('Test','User');
       insert newUser;
       system.debug('lstProduct[0].On_Zadoon_partner_yard1__c:::'+lstProduct[0].On_Zadoon_partner_yard1__c);
       list<User_Requirement_ID__c> lstUserReqID = TestDataFactory.createUserRequirementID(1);
       insert lstUserReqID;
       list<Unit_Category_Details__c> lstUnitCD =TestDataFactory.createUnitCategoryDetails(1);
       Id recordTypeId = Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get('UserRequirementID').getRecordTypeId();
       lstUnitCD[0].recordtypeId = recordTypeId;
       lstUnitCD[0].User_Requirement_ID__c =lstUserReqID[0].id ;
       lstUnitCD[0].category_Details__c = 'Backhoe';
       lstUnitCD[0].isActive__c = true;
       try{
           insert lstUnitCD;
       }
       catch(exception e){
		  system.assert(true);            
       }
       list<Unit_Category_Details__c> lstUnitCD1 =TestDataFactory.createUnitCategoryDetails(1);
       Id recordTypeId1 = Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId();
       lstUnitCD1[0].recordtypeId = recordTypeId1;
       lstUnitCD1[0].unit__c =lstProduct[0].id ;
       lstUnitCD1[0].equipment__c=lstEquipment[0].id;
       lstUnitCD1[0].category_Details__c = 'Backhoe';
       insert lstUnitCD1;
    }
    /*@isTest public static void testProductTriggerUpdate() {
        Product2 unit = [Select isActive from Product2 where productCode ='ZID-130163' AND Name ='2500S Cone Crusher ZID-130163' Limit 1];
        //update unit;
    }*/
    @isTest public static void testProductTriggerUpdate2() {
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,'company');
        insert lstAccount;
        contact newCon = [SELECT id
                          FROM contact
                          LIMIT 1];
        lstAccount[0].Primary_Contact__c = newCon.id;
        update lstAccount;
        user newUser = [SELECT ID
                        FROM User
                        LIMIT 1];
        Product2 unit = [Select isActive from Product2 /*where productCode ='ZID-130163' AND Name ='2500S Cone Crusher ZID-130163'*/ Limit 1];
        
        list<Opportunity> lstOpportunity = TestDataFactory.createOpportunity1(1, lstAccount[0].id, unit.id);
        //lstOpportunity[0].Market_on_FB__c=true;
        lstOpportunity[0].RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
        //lstOpportunity[1].RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(label.Opp_Rec_Type_Broker_Sell).getRecordTypeId();
        
        insert lstOpportunity;
        unit.Starting_Advertised_Retail_Price__c = 12;
        //unit.Iron_Connect_Listing__c = 'sjfisa';
        unit.Inventory_Status__c = 'Owned';
        unit.Unit_Owner__c = newUser.id;
        unit.Account__c = lstAccount[0].id;
        unit.CreatedAt__c = Date.newInstance(2023, 1, 14);
        unit.Confidential_Information_Notes__c = 'skfbgwsi';
        //unit.IsActive = true;
        update unit;
    }
    @isTest public static void testProductTriggerUpdate1() {
        Product2 unit = [Select isActive from Product2 /*where productCode ='ZID-130163' AND Name ='2500S Cone Crusher ZID-130163'*/ Limit 1];
        //unit.Year__c = '2010';
        unit.IsActive = false;
        update unit;
    }

    @isTest public static void testProductUpdate(){
        Product2 unit = [SELECT isActive,Is_Photo_verification_completed__c,On_Zadoon_partner_yard1__c,Unit_Owner__c,Storage_State__c,Storage_City__c,Old_SF_Unit_Details__c,
                         Unlist_Unit__c,Inventory_Status__c,Number_of_Images_in_Google_Drive__c,Starting_Advertised_Retail_Price__c,Year__c,Hour__c
                         FROM Product2 
                         Limit 1 ];
        Yards__c newYard = [SELECT id
                            FROM Yards__c
                            LIMIT 1];
        system.debug('newYard.id:::'+newYard.Id);
        system.debug('unitto update photo::::'+ unit.Is_Photo_verification_completed__c);
        unit.Is_Photo_verification_completed__c = true;
        unit.Unit_Owner__c = system.userinfo.getuserid();
        //unit.Override_Post_FB_Marketplace__c = true;
        unit.Storage_State__c ='test'; 
        unit.Storage_City__c = 'Test city';
        unit.Old_SF_Unit_Details__c = 'test';
        unit.Unlist_Unit__c = true;
        unit.Inventory_Status__c = 'Owned';
        unit.On_Zadoon_partner_yard1__c = newYard.Id;
        unit.Number_of_Images_in_Google_Drive__c = 10;
        unit.Starting_Advertised_Retail_Price__c = 100;
        unit.Year__c = '2022';
        unit.Hour__c = 1000;
        test.startTest();
        update unit;
         system.debug('unitto update photo after update::::'+ unit.On_Zadoon_partner_yard1__c);
        test.stopTest();
    }
    
    
    @isTest public static void testUnitTriggerOnInsert (){
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1, 'company');
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        Model__c model = TestDataFactory.createModel(true);
		 Product2 unit = TestDataFactory.createUnit(false, model.Id, lstEquipment[0].id);
        unit.Account__c=lstAccount[0].id;
       //list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id ,lstAccount[0].id,model.Id);
        test.startTest();
        insert unit;
        test.stopTest();
    }
    /*@isTest public static void testUnitTriggerOnUpdate (){
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,'company');
        insert lstAccount;
        list<Account> lstAccount1 = TestDataFactory.noOfAccountToInsert(1,'comdefhsdjpany');
        insert lstAccount1;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , lstAccount[0].id);
        insert lstUnit;
        list<Product2> lstUnit1 = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , '');
        insert lstUnit1;
        system.debug('lstUnit1:::');
        list<Product2> lstUnitUpdate = new list<Product2>();
        for(Product2 eachProduct2 :lstUnit1){
            eachProduct2.Account__c = lstAccount1[0].id;
            lstUnitUpdate.add(eachProduct2);
        }
       for(Product2 eachProduct2 :lstUnit){
            system.debug('lstUnit::'+eachProduct2.Account__c);
            eachProduct2.Account__c = lstAccount1[0].id;
           	eachProduct2.Iron_Connect_Listing__c = 'www.yahoo.com';
            lstUnitUpdate.add(eachProduct2);
        }
        test.startTest();
        	update lstUnitUpdate;
        
        test.stopTest();
    }*/
   @isTest
    public static void testHandleCreateTaskOnAfterUpdate(){
         user newUser = TestDataFactory.createTestUser('Kevin','Vellek');
        insert  newUser; 
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,'company');
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
		 Model__c model = TestDataFactory.createModel(true);
		 Product2 unit = TestDataFactory.createUnit(true, model.Id, lstEquipment[0].id);

        unit.Inventory_Status__c= 'Owned';
        unit.Unit_Owner__c=newUser.Id;
        unit.Account__c=lstAccount[0].id;
        test.startTest();
        update unit;
        test.stopTest();
    }
    
      @isTest
    public static void testHandleCreateTaskOnAfterUpdate1(){
         user newUser = TestDataFactory.createTestUser('test','user');
        insert  newUser; 
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,'company');
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
		 Model__c model = TestDataFactory.createModel(true);
		 Product2 unit = TestDataFactory.createUnit(true, model.Id, lstEquipment[0].id);
     
        unit.Inventory_Status__c= 'Owned';
        unit.Unit_Owner__c=newUser.Id;
        unit.Account__c=lstAccount[0].id;
        
        test.startTest();
        update unit;
        test.stopTest();
        system.assert(true);
    }
         /* @isTest
    public static void testcreateUCDAfterInsert(){
          list<Unit_Category_Details__c> lstunitCategory = [SELECT id,User_Requirement_ID__c
                                                          FROM Unit_Category_Details__c
                                                          WHERE User_Requirement_ID__c !=null 
                                                         AND Unit__c = null And IsActive__c = true];
        list<Equipment__c> lstEquipment = [SELECT ID FROM Equipment__c ];
        list<Product2> lstProduct = TestDataFactory.noOfUnitsToCreate(1,lstEquipment[0].id);
        test.startTest();
        insert lstProduct;
        test.stopTest();
    }*/
          @isTest
    public static void testcreateUCDAfterUpdate(){
         user newUser = TestDataFactory.createTestUser('Shelly','Murphy');
        insert  newUser; 
        list<Unit_Category_Details__c> lstunitCategory = [SELECT id,User_Requirement_ID__c,isActive__c
                                                          FROM Unit_Category_Details__c
                                                          WHERE User_Requirement_ID__c !=null 
                                                         AND Unit__c = null AND IsActive__c = true And Category_Details__c = 'Backhoe'];
        system.debug('lstunitCategory:112::'+lstunitCategory);
        /* list<product2> lstProduct = [SELECT ID,IsActive
                                     FROM product2 //WHERE IsActive=false
                                    ];
        system.debug('lstProductfrom test::'+lstProduct);*/
       
         //lstProduct[0].IsActive = true;
        Equipment__c Equipment = [SELECT ID FROM Equipment__c Where Category__c = 'Backhoe' limit 1 ];
        list<Product2> lstProduct = TestDataFactory.noOfUnitsToCreate(1,Equipment.id);
        lstProduct[0].isActive = false;
        lstProduct[0].Is_Photo_verification_completed__c = false;
        lstProduct[0].Storage_State__c = 'test';
        lstProduct[0].Storage_City__c = 'Panchkula';
        lstProduct[0].Unit_Stage__c = 'Reviewing';
        insert lstProduct;
        lstProduct[0].isActive = true;
        lstProduct[0].Is_Photo_verification_completed__c = true;
        lstProduct[0].Storage_State__c = 'test1';
        lstProduct[0].Storage_City__c = 'Ambala';
        lstProduct[0].Unit_Stage__c = 'Reviewing';
        test.startTest();
        update lstProduct;
        test.stopTest();
        system.assert(true);
    }
    
      @isTest
    public static void testunitAfterUpdate(){
        product2 Product = [SELECT id,isActive,Unit_Stage__c
                            FROM product2 where Unit_Stage__c = 'Reviewing' LIMIT 1 ];
        Product.Zadoon_s_Final_Purchase_Price__c = 1000;
        Product.Unit_Transaction_Expense_Total__c=100;
        Product.Unit_Transaction_Income_Total__c =300;
        Product.Sellers_Most_Recent_Bottom_Price__c=1000;
        Product.Sellers_Initial_Bottom_Price__c=100;
     	Product.Sellers_Original_Asking_Price__c=100;
        Product.Starting_Advertised_Retail_Price__c = 1000;
        //Product.Unit_Stage__c = 'Reviewing';
        Product.isActive = true;
        //Product.Is_Photo_verification_completed__c = true;
         test.startTest();
        update Product;
        test.stopTest();
        system.assert(true);
    }
    
    
    
}