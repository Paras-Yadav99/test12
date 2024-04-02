@IsTest
public class TestLeadShowLstOppController {
    @IsTest
    public static void leadShowLstOppControllerTest(){
        list<Opportunity>lstOpportunity = new list<Opportunity>();
    
        
        Contact NewContact = new Contact();
        NewContact.LastName='Test Conatact';
        //NewContact.AccountID = NewAccount.Id;
        insert NewContact;
        
        Account NewAccount = new Account();
        NewAccount.Name = 'Test Account';
        NewAccount.Primary_Contact__c = NewContact.Id;
        insert NewAccount;
        
        Equipment__c NewEquipment = new Equipment__c();
        NewEquipment.Name = 'Test Equipment';
        NewEquipment.Manufacturer__c = 'Stellar';
        NewEquipment.Base_New__c = '50';
        NewEquipment.MT_Inventory_Type__c = 'Agricultural_Equipment';
        NewEquipment.On_Off_Highway__c='On Highway';
        insert NewEquipment;
        
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
        
        Product2 NewProduct = New Product2();
        NewProduct.Name = 'Test Product';
        NewProduct.Account__c=NewAccount.Id;
        //NewProduct.Primary_Contact__c=NewContact.Id;
        NewProduct.equipment__c=NewEquipment.Id;
        NewProduct.Unit_Owner__c=newUser.Id;
        insert NewProduct;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'mickle';
        opp1.AccountId = NewAccount.Id;
        opp1.Buyer_Primary_Contact__c = NewContact.Id;
        opp1.Product__c = NewProduct.Id;
        opp1.StageName = 'Won - Purchased';
        opp1.CloseDate = Date.newInstance(2023, 12, 20);
        lstOpportunity.add(opp1);
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'jack';
        opp2.AccountId = NewAccount.Id;
        opp2.Product__c = NewProduct.Id;
        opp2.Buyer_Primary_Contact__c = NewContact.Id;
        opp2.StageName = 'Stopped Pursuing';
        opp2.CloseDate = Date.newInstance(2023, 12, 20);
        lstOpportunity.add(opp2);
        insert lstOpportunity;
        
        Opportunity opp3 = new Opportunity();
        opp3.Name = 'mickle';
        opp3.AccountId = NewAccount.Id;
        opp3.Buyer_Primary_Contact__c = NewContact.Id;
        opp3.Product__c = NewProduct.Id;
        opp3.StageName = 'Won - Purchased';
        opp3.CloseDate = Date.newInstance(2023, 12, 20);
        insert opp3;
        
        lead NewLead = new Lead();
        NewLead.LastName = 'Test Lead';
        NewLead.Status='New';
        NewLead.Account__c = NewAccount.Id;
        NewLead.Contact__c = NewContact.Id;
        NewLead.Unit__c = NewProduct.Id;
        NewLead.Company = NewAccount.Name;
        insert NewLead;
        
        lead NewLead1 = new Lead();
        NewLead1.LastName = 'Test Lead';
        NewLead1.Status='New';
        NewLead1.Account__c = NewAccount.Id;
        NewLead1.Contact__c = NewContact.Id;
        NewLead1.Unit__c = NewProduct.Id;
        NewLead1.Company = NewAccount.Name;
        insert NewLead1;
        
        
        System.Test.startTest();
        
        LeadShowLstOppController.AuraResponse auraResponse =LeadShowLstOppController.getOpportunityDetails(NewLead.Id);
        LeadShowLstOppController.AuraResponse auraResponse1 =LeadShowLstOppController.getOpportunityDetails(NewLead1.Id);

        System.Test.stopTest();
    }


}