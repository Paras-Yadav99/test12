@isTest
public class MarketingDetailTriggerTest {
     @testSetup static void createTestdata(){
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(2,'company');
         for(Account eachAccoutnt :lstAccount){
            eachAccoutnt.Client_Type__c='End User';
        }
        insert lstAccount;
        list<Account> lstAccount1 = TestDataFactory.noOfAccountToInsert(2,'comdefhsdjpany');
        insert lstAccount1;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(2 ,lstEquipment[0].id , lstAccount[0].id);
        insert lstUnit;
        list<Product2> lstUnit1 = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , '');
        
        for(Product2 eachProduct2 :lstUnit1){
            eachProduct2.Account__c = lstAccount1[0].id;
        }
        insert lstUnit1;
         
           Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
         
         list<Opportunity> lstOpportunity = TestDataFactory.createOpportunity(1, lstAccount[0].id, lstUnit[1].id);
         string procurementOpp = System.Label.Opp_Rec_type_Dev_Name_procurement_opp;
         RecordType procurementOppRecordType = [SELECT Id FROM RecordType where DeveloperName =: procurementOpp LIMIT 1 ];
         lstOpportunity[0].RecordTypeId =procurementOppRecordType.id; 
         insert lstOpportunity;
         system.debug('lstOpportunity'+lstOpportunity);
         list<Marketing_Detail__c> lstMarketingDetail = [SELECT Id, Marketed_On_Craigslist__c, 
                                                         Marketed_On_FB_Marketplace__c, Marketed_On_Fleet_Up_Marketplace__c, 
                                                         Marketed_On_Instagram__c, Marketed_On_LinkedIn__c, 
                                                         Marketed_On_Machinio__c, Marketed_On_Mascus__c, Marketed_on_MT_Crane_Truck__c, 
                                                         Marketed_On_MyLittleSalesman__c,  Marketed_On_TradeMachines__c, 
                                                         Do_not_market_anywhere__c,
                                                         Account__c
                                                         FROM Marketing_Detail__c WHERE Account__c IN :lstAccount];
         
    }
    @isTest public static void MarketingDetailTriggerBeforeUpdateTest (){
     /*   staticVariable.UpdatedFromObject = '';
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(2,'company');
        for(Account eachAccoutnt :lstAccount){
            eachAccoutnt.Client_Type__c='End User';
        }
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(1 ,lstEquipment[0].id , lstAccount[0].id);
        insert lstUnit;*/
        list<Account> lstAccount =[SELECT Id, Name FROM Account];
        System.debug('lstAccount :::::::'+lstAccount);
        list<Marketing_Detail__c> lstMarketingDetail = [SELECT Id, Marketed_On_Craigslist__c, 
                                                        Marketed_On_FB_Marketplace__c, Marketed_On_Fleet_Up_Marketplace__c, 
                                                        Marketed_On_Instagram__c, Marketed_On_LinkedIn__c, 
                                                        Marketed_On_Machinio__c, Marketed_On_Mascus__c, Marketed_on_MT_Crane_Truck__c, 
                                                        Marketed_On_MyLittleSalesman__c,  Marketed_On_TradeMachines__c, 
                                                        Do_not_market_anywhere__c,
                                                        Account__c
                                                        FROM Marketing_Detail__c WHERE Account__c IN :lstAccount
                                                        AND Do_not_market_anywhere__c=false];
        System.debug('lstMarketingDetail :::::::'+lstMarketingDetail);
        for(Marketing_Detail__c eachMarketingDetail : lstMarketingDetail){
            eachMarketingDetail.Marketed_on_MT_Crane_Truck__c= false;
            //eachMarketingDetail.Marketed_On_Facebook__c = true;
            eachMarketingDetail.Do_not_market_anywhere__c = true;
        }
        
        test.startTest();
        update lstMarketingDetail;
        test.stopTest();
    }
    @isTest public static void MarketingDetailTriggerBeforeUpdateTest1 (){
        staticVariable.UpdatedFromObject = '';
      /*  list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(2,'company');
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(2 ,lstEquipment[0].id , lstAccount[0].id);
        insert lstUnit;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        list<Opportunity> lstOpportunity = TestDataFactory.createOpportunity(1, lstAccount[0].id, lstUnit[0].id);
        string procurementOpp = System.Label.Opp_Rec_type_Dev_Name_procurement_opp;
            RecordType procurementOppRecordType = [SELECT Id FROM RecordType where DeveloperName =: procurementOpp LIMIT 1 ];
        lstOpportunity[0].RecordTypeId =procurementOppRecordType.id; 
        insert lstOpportunity;*/
        list<Opportunity> lstOpportunity =[SELECT Id, Name FROM Opportunity];
        
        system.debug('lstOpportunity'+lstOpportunity);
        list<Marketing_Detail__c> lstMarketingDetail = [SELECT Id, Marketed_On_Craigslist__c, Marketed_On_Iron_Connect__c,
                                                        Marketed_On_FB_Marketplace__c, Marketed_On_Fleet_Up_Marketplace__c, 
                                                        Marketed_On_Instagram__c, Marketed_On_LinkedIn__c, 
                                                        Marketed_On_Machinio__c, Marketed_On_Mascus__c, Marketed_on_MT_Crane_Truck__c, 
                                                        Marketed_On_MyLittleSalesman__c,  Marketed_On_TradeMachines__c, 
                                                        Do_not_market_anywhere__c,
                                                        Opportunity__c
                                                        FROM Marketing_Detail__c WHERE Opportunity__c IN :lstOpportunity];
        system.debug('lstMarketingDetail:'+lstMarketingDetail);
        for(Marketing_Detail__c eachMarketingDetail : lstMarketingDetail){
           // eachMarketingDetail.Marketed_On_Construction_Equip_Guide__c= false;
            eachMarketingDetail.Marketed_On_Craigslist__c = true;
            eachMarketingDetail.Marketed_On_Iron_Connect__c = true;
            eachMarketingDetail.Marketed_On_Equipment_Trader__c = true;
            eachMarketingDetail.Marketed_on_MT_Crane_Truck__c = true;
            eachMarketingDetail.Call_Won_Lost_Opps_Checked__c = true;
            eachMarketingDetail.Marketed_On_RitchieList__c = true;
            eachMarketingDetail.Marketed_On_FB_Marketplace__c = true;
            eachMarketingDetail.Marketed_On_Rock_Dirt__c = true;
            eachMarketingDetail.Market_on_FB_Group__c = true;
            eachMarketingDetail.FB_Group_Post_Link__c = 'https://zadoon1234--dev.sandbox.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage';
        }
         
        system.debug('lstMarketingDetail:::'+lstMarketingDetail);
        test.startTest();
        update lstMarketingDetail;
        test.stopTest();
    }
     @isTest public static void MarketingDetailTriggerBeforeUpdateTest2 (){
         staticVariable.UpdatedFromObject = '';
      /*  list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(2,'company');
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(2 ,lstEquipment[0].id , lstAccount[0].id);
        insert lstUnit;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;*/

         list<Marketing_Detail__c> lstMarketingDetail1 = [SELECT Id, Marketed_On_Craigslist__c, Marketed_On_Iron_Connect__c,
                                                          Marketed_On_FB_Marketplace__c, Marketed_On_Fleet_Up_Marketplace__c, 
                                                          Marketed_On_Instagram__c, Marketed_On_LinkedIn__c, 
                                                          Marketed_On_Machinio__c, Marketed_On_Mascus__c, Marketed_on_MT_Crane_Truck__c, 
                                                          Marketed_On_MyLittleSalesman__c,  Marketed_On_TradeMachines__c, 
                                                          Do_not_market_anywhere__c,
                                                          Opportunity__c
                                                          FROM Marketing_Detail__c WHERE Updated_From__c !=null AND Unit__c != null];
         system.debug('lstMarketingDetail:1:::'+lstMarketingDetail1);
         for(Marketing_Detail__c eachMarketingDetail : lstMarketingDetail1){
             // eachMarketingDetail.Marketed_On_Construction_Equip_Guide__c= false;
             eachMarketingDetail.Marketed_On_Iron_Connect__c = true;
             eachMarketingDetail.Marketed_On_MyLittleSalesman__c = true;
             eachMarketingDetail.Market_on_FB_Group__c = true;
             eachMarketingDetail.FB_Group_Post_Link__c = 'https://zadoon1234--dev.sandbox.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage';
         }
         test.startTest(); 
         update lstMarketingDetail1;
         test.stopTest();
     }
         @isTest public static void MarketingDetailTriggerBeforeUpdateTest3 (){
         staticVariable.UpdatedFromObject = '';
      /*  list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(2,'company');
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstUnit = TestDataFactory.noOfUnitsToCreate2(2 ,lstEquipment[0].id , lstAccount[0].id);
        insert lstUnit;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;*/

         list<Marketing_Detail__c> lstMarketingDetail1 = [SELECT Id, Marketed_On_Craigslist__c, Marketed_On_Iron_Connect__c,
                                                          Marketed_On_FB_Marketplace__c, Marketed_On_Fleet_Up_Marketplace__c, 
                                                          Marketed_On_Instagram__c, Marketed_On_LinkedIn__c, 
                                                          Marketed_On_Machinio__c, Marketed_On_Mascus__c, Marketed_on_MT_Crane_Truck__c, 
                                                          Marketed_On_MyLittleSalesman__c,  Marketed_On_TradeMachines__c, 
                                                          Do_not_market_anywhere__c,
                                                          Opportunity__c
                                                          FROM Marketing_Detail__c WHERE Updated_From__c !=null AND Unit__c != null];
             system.debug('lstMarketingDetail:1:::'+lstMarketingDetail1);
             for(Marketing_Detail__c eachMarketingDetail : lstMarketingDetail1){
                 // eachMarketingDetail.Marketed_On_Construction_Equip_Guide__c= false;
                 eachMarketingDetail.Marketed_On_Iron_Connect__c = true;
                 eachMarketingDetail.Marketed_On_MyLittleSalesman__c = true;
                 eachMarketingDetail.Market_on_FB_Group__c = true;
                 eachMarketingDetail.FB_Group_Post_Link__c = 'https://zadoon1234--dev.sandbox.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage';
             }
             update lstMarketingDetail1;
             for(Marketing_Detail__c eachMarketingDetail : lstMarketingDetail1){
                 // eachMarketingDetail.Marketed_On_Construction_Equip_Guide__c= false;
                 eachMarketingDetail.Marketed_On_Iron_Connect__c = true;
                 eachMarketingDetail.Marketed_On_MyLittleSalesman__c = true;
                 eachMarketingDetail.Market_on_FB_Group__c = true;
                 eachMarketingDetail.FB_Group_Post_Link__c = 'https://zadoon1234--dev.sandbox.my.salesforce.com/_ui/common/apex/debug/ApexCSIPagetest';
             }
             test.startTest(); 
             update lstMarketingDetail1;
             test.stopTest();
         }

}