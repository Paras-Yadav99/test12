@isTest
private class thisContactPageIronDemandOppMatchTest  {

    static testMethod void thisContactPageIronDemandOppMatchTest() 
    {

        Test.startTest();
        
        // Create Account 
        Account account = new Account(Name='Test Account');
        insert account;
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', MT_Inventory_Type__c = 'Trucks', On_Off_Highway__c = 'On Highway', Base_New__c = 'Darryl Test Model', Name = 'Test Equipment');
        insert equipment;
        
        // Create Unit 
        Product2 ZIDs = new Product2(name='test product', equipment__c = equipment.Id, account__c =account.id, CreatedAt__c = Date.today().addDays(-30));
        insert ZIDs;
 
        // Create Contact 
        Contact clist = new Contact(LastName='ContTest1', email='djung@atlassoftwaregroup.com', AccountId = account.Id, Primary_Contact__c = true);
        insert clist;
        
        // Create account relation 
        // AccountContactRelation AccountContact = new AccountContactRelation(AccountId = account.Id, ContactId = clist.Id);
        // insert AccountContact;
        
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Buyer_Primary_Contact__c = clist.Id;
        newOpportunity.AccountId = account.Id;
		newOpportunity.Name= 'Paras test';
        newOpportunity.Product__c =ZIDs.id;
        newOpportunity.StageName = 'Closed Won';
        //newOpportunity.ForecastCategory = 'Closed';
       	newOpportunity.CloseDate= date.newInstance(2022, 11, 21);
        newOpportunity.AccountId = account.id;
         
        insert newOpportunity;
        
       /* Pricebook2 newPricebook2 = new Pricebook2();
        newPricebook2.Name = 'paras Test';
        newPricebook2.IsActive = true;
        newPricebook2.IsStandard = true;
        insert newPricebook2;*/
        
        PricebookEntry newPricebookEntry = new PricebookEntry();
        newPricebookEntry.Product2Id = ZIDs.id;
        newPricebookEntry.Pricebook2Id =Test.getStandardPricebookId();
        newPricebookEntry.UnitPrice = 23;
        newPricebookEntry.IsActive = true;
        insert newPricebookEntry;
        /*System.DmlException: Insert failed. First exception on row 0; first error: 
REQUIRED_FIELD_MISSING, Error: You can't select units until you've chosen a price book for this opportunity on the units related list.: []*/
        OpportunityLineItem newOpportunityLineItem = new OpportunityLineItem();
        newOpportunityLineItem.Product2Id = ZIDs.id;
        newOpportunityLineItem.OpportunityId = newOpportunity.Id;
        newOpportunityLineItem.PricebookEntryId = newPricebookEntry.id;
        newOpportunityLineItem.Quantity= 1;
        newOpportunityLineItem.TotalPrice=1313;
        insert newOpportunityLineItem;
        
        thisContactPageIronDemandOppMatch IDUnitContacts = new thisContactPageIronDemandOppMatch();
        system.debug('query in test class : ' + [Select Buyer_Primary_Contact__c,o.Name,(Select Product2.Name From OpportunityLineItems) 
                                             From Opportunity o 
                                             Where Buyer_Primary_Contact__c = :clist.Id]);
        IDUnitContacts.thisContactId =clist.id ;
        
        IDUnitContacts.getThisContactZids();
        
        
        Test.stopTest();
        
    }
    
}