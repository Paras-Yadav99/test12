@isTest 
private class emailUnitContactIronDemandTest {

    static testMethod void emailUnitContactIronDemandTest() 
    {

        Test.startTest();
        
        // Create Account 
        Account newAccount = new Account(Name='Test Account');
        insert newAccount;
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', Base_New__c = 'Darryl Test Model', Name = 'Test Equipment', 
                                                  MT_Inventory_Type__c = 'Trucks',On_Off_Highway__c = 'Off Highway');
        insert equipment;
 
        // Create Contact 
        Contact clist = new Contact(LastName='ContTest1', email='djung@atlassoftwaregroup.com', AccountId = newAccount.Id, Primary_Contact__c = true);
        insert clist;
        Account newAccountUpdate = new Account();
        newAccountUpdate.id=newAccount.id;
        newAccountUpdate.Primary_Contact__c=clist.id;
        update newAccountUpdate;
         // Create Unit 
        Product2 ZIDs = new Product2(name='test product', equipment__c = equipment.Id, account__c =newAccount.id, 
                                     CreatedAt__c = Date.today().addDays(-30), Inventory_Status__c='Owned');
        insert ZIDs;
        
        // Create Iron Demand 
        Iron_Demand__c idlist = new Iron_Demand__c(IronDemand_Contact__c = clist.id, IronDemand_Iron__c = equipment.Id, IsActive__c = TRUE);
        insert idlist;
       Opportunity newOpportunity = new Opportunity(name='test21', StageName='Closed Lost',Product__c=ZIDs.id, 
                                                           ForecastCategoryName='Omitted',CloseDate=date.newInstance(2022, 12, 12),
                                                           AccountId=newAccount.id,Buyer_Primary_Contact__c=clist.id);
        insert newOpportunity;
        
        system.debug('newOpportunity' + newOpportunity);
        list<id> lstProductId =  new list<id>();
        lstProductId.add(ZIDs.Id);
        //emailUnitContactIronDemand.EmailMethod( lstProductId);
        emailUnitContactIronDemandInvoc.EmailMethod( lstProductId);
        Test.stopTest();
        
    }

}