@isTest(seealldata=true )
private class unitOpportunitiesTest {
/*
    static testMethod void unitOpportunitiesTest() 
    {

         Test.startTest();

        // Create Account 
        Account account = new Account(Name='Test Account');
        insert account;
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', Base__c = 'Darryl Test Model', Name = 'Test Equipment');
        insert equipment;
        
        //get standard pricebook
        // This is how we get the Standard PriceBook Id.  Prior to Summer '14, we needed
        // to use SeeAllData=true, so this is a big improvement
        Id pricebookId = Test.getStandardPricebookId();      
        
        // Create Unit 
        Product2 ZIDs = new Product2(name='test product', equipment__c = equipment.Id, account__c =account.id, CreatedAt__c = Date.today().addDays(-30), ProductCode ='1234');
        insert ZIDs;

      
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiating',CloseDate=Date.today(), Years__c = 2015, Model__c = '1234', AccountId = account.id);
        insert opp1;
        
        
        List<PricebookEntry> entries = [
                SELECT ID
                FROM PricebookEntry
                WHERE Product2Id = :ZIDs.Id
                
            ];
        
        For(PricebookEntry pbe:entries) {
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe.id, quantity=4, totalprice=200);
        insert lineItem1;
        
        }
        
        PageReference pageRef = new PageReference('Unit_Creation_Edit_Form');
        pageRef.getParameters().put('id', ZIDS.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ZIDs);
        unitOpportunities uo = new unitOpportunities(sc);
       
        
        Test.stopTest();
        
    }
    */
}