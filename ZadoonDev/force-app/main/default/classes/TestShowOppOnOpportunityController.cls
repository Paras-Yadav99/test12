// Test Class for leadGetListOppAndLeadTagWithAccount Apex Class 

@IsTest
public class TestShowOppOnOpportunityController {
    
    @IsTest
    public static void OpportunityControllerProcurementTest(){
        list<Opportunity> lstOpportunityToInsert = new list<Opportunity>();
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(2,'company');
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , lstAccount[0].id);
        
        list<contact>lstContact = TestDataFactory.noOfContactToInsert(1,'testContact');
        insert lstContact;
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        User newUser = new user();
        newUser.LastName = 'Test Code';
        newUser.Email = 'test@test.com';
        newUser.Alias = 'Tcode';
        newUser.Username = 'test2022dee@test.com';
        newUser.CommunityNickname = 'test12';
        newUser.LocaleSidKey = 'en_US';
        newUser.TimeZoneSidKey = 'GMT';
        newUser.ProfileID = pf.id;
        newUser.LanguageLocaleKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        insert newUser;
        
        for(Product2 newProduct2 : lstUnit){
            newProduct2.Unit_Owner__c = newUser.id;
        }
        insert lstUnit;
        
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        
        Id proRecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Procurement Opportunity').getRecordTypeId();
        Id inventorySellRecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Inventory Sell').getRecordTypeId();
        
        list<Opportunity> lstOpportunity1 = TestDataFactory.createOpportunity1(2, lstAccount[0].id, lstUnit[0].id);
        
        for(Opportunity eachOpportunity : lstOpportunity1){
            eachOpportunity.StageName = 'Won - Purchased';
            eachOpportunity.RecordTypeId = proRecordTypeIdOpportunity;
            eachOpportunity.Buyer_Primary_Contact__c = lstContact[0].Id;
            lstOpportunityToInsert.add(eachOpportunity);
        }
        list<Opportunity> lstOpportunity2 = TestDataFactory.createOpportunity1(2, lstAccount[0].id, lstUnit[0].id);
        
        for(Opportunity eachOpportunity : lstOpportunity2){
            eachOpportunity.StageName = 'Stopped Pursuing';
            eachOpportunity.RecordTypeId = inventorySellRecordTypeIdOpportunity;
            eachOpportunity.Buyer_Primary_Contact__c = lstContact[0].Id;
            lstOpportunityToInsert.add(eachOpportunity);
        }
        insert lstOpportunityToInsert;
        System.Test.startTest();
        showOppOnOpportunityController.AuraResponse auraResponse =ShowOppOnOpportunityController.getOpportunityDetails(lstOpportunityToInsert[0].Id);
        	
        System.Test.stopTest();
    }
    
    @IsTest
    public static void OpportunityControllerInventorySellTest(){
        list<Opportunity> lstOpportunityToInsert = new list<Opportunity>();
        
        list<contact>lstContact = TestDataFactory.noOfContactToInsert(1,'testContact');
        insert lstContact;
        
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,'company');
        lstAccount[0].Primary_Contact__c = lstContact[0].id;
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , lstAccount[0].id);
        
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        User newUser = new user();
        newUser.LastName = 'Test Code';
        newUser.Email = 'test@test.com';
        newUser.Alias = 'Tcode';
        newUser.Username = 'test2022dee@test.com';
        newUser.CommunityNickname = 'test12';
        newUser.LocaleSidKey = 'en_US';
        newUser.TimeZoneSidKey = 'GMT';
        newUser.ProfileID = pf.id;
        newUser.LanguageLocaleKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        insert newUser;
        
        for(Product2 newProduct2 : lstUnit){
            newProduct2.Unit_Owner__c = newUser.id;
        }
        insert lstUnit;
        
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
		Id inventorySellRecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Inventory Sell').getRecordTypeId();
        list<Opportunity> lstOpportunity6 = TestDataFactory.createOpportunity1(4, lstAccount[0].id, lstUnit[0].id);
        
        for(Opportunity eachOpportunity : lstOpportunity6){
            eachOpportunity.StageName = 'Closed Won';
            eachOpportunity.Buyer_Primary_Contact__c = lstContact[0].Id;
            eachOpportunity.RecordTypeId = inventorySellRecordTypeIdOpportunity;
            lstOpportunityToInsert.add(eachOpportunity);
        }
        list<Opportunity> lstOpportunity6A = TestDataFactory.createOpportunity1(4, lstAccount[0].id, lstUnit[0].id);
        
        for(Opportunity eachOpportunity : lstOpportunity6A){
            eachOpportunity.StageName = 'Closed Lost';
            eachOpportunity.Buyer_Primary_Contact__c = lstContact[0].Id;
            eachOpportunity.RecordTypeId = inventorySellRecordTypeIdOpportunity;
            lstOpportunityToInsert.add(eachOpportunity);
        }
        /*list<Opportunity> lstOpportunity7 = TestDataFactory.createOpportunity1(2, lstAccount[0].id, lstUnit[0].id);
        
        for(Opportunity eachOpportunity : lstOpportunity6){
            eachOpportunity.StageName = 'Won - Purchased';
            eachOpportunity.RecordTypeId = inventorySellRecordTypeIdOpportunity;
            lstOpportunityToInsert.add(eachOpportunity);
        }*/
        insert lstOpportunityToInsert;
        System.Test.startTest();
        showOppOnOpportunityController.AuraResponse auraResponse2 =ShowOppOnOpportunityController.getOpportunityDetails(lstOpportunityToInsert[0].Id);

        System.Test.stopTest();
    }
    @IsTest
    public static void OpportunityControllerBrokerSellTest(){
        list<Opportunity> lstOpportunityToInsert = new list<Opportunity>();
        list<contact>lstContact = TestDataFactory.noOfContactToInsert(1,'testContact');
        insert lstContact;
        
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,'company');
        lstAccount[0].Primary_Contact__c = lstContact[0].id;
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , lstAccount[0].id);
        
        
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        User newUser = new user();
        newUser.LastName = 'Test Code';
        newUser.Email = 'test@test.com';
        newUser.Alias = 'Tcode';
        newUser.Username = 'test2022dee@test.com';
        newUser.CommunityNickname = 'test12';
        newUser.LocaleSidKey = 'en_US';
        newUser.TimeZoneSidKey = 'GMT';
        newUser.ProfileID = pf.id;
        newUser.LanguageLocaleKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        insert newUser;
        
        for(Product2 newProduct2 : lstUnit){
            newProduct2.Unit_Owner__c = newUser.id;
        }
        insert lstUnit;
        
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        Id brokerSellerRecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Broker Sell').getRecordTypeId();
       	list<Opportunity> lstOpportunity3 = TestDataFactory.createOpportunity1(2, lstAccount[0].id, lstUnit[0].id);
        
        for(Opportunity eachOpportunity : lstOpportunity3){
            eachOpportunity.StageName = 'Closed Won';
            eachOpportunity.RecordTypeId = brokerSellerRecordTypeIdOpportunity;
            lstOpportunityToInsert.add(eachOpportunity);
        }
        list<Opportunity> lstOpportunity4 = TestDataFactory.createOpportunity1(2, lstAccount[0].id, lstUnit[0].id);
        
        for(Opportunity eachOpportunity : lstOpportunity4){
            eachOpportunity.StageName = 'Closed Won';
            eachOpportunity.Buyer_Primary_Contact__c = lstContact[0].Id;
            eachOpportunity.RecordTypeId = brokerSellerRecordTypeIdOpportunity;
            lstOpportunityToInsert.add(eachOpportunity);
        }
        list<Opportunity> lstOpportunity5 = TestDataFactory.createOpportunity1(2, lstAccount[0].id, lstUnit[0].id);
        
        for(Opportunity eachOpportunity : lstOpportunity5){
            eachOpportunity.StageName = 'Closed Lost';
            eachOpportunity.Buyer_Primary_Contact__c = lstContact[0].Id;
            eachOpportunity.RecordTypeId = brokerSellerRecordTypeIdOpportunity;
            lstOpportunityToInsert.add(eachOpportunity);
        }
        insert lstOpportunityToInsert;
        System.Test.startTest();
        showOppOnOpportunityController.AuraResponse auraResponse1 =ShowOppOnOpportunityController.getOpportunityDetails(lstOpportunityToInsert[0].Id);
        System.Test.stopTest();
    }

}