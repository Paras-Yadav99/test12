/*
This Batch class is used to update Account records if Opportunity forecasteCategory is changed to Closed.
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          20-Feb-2023         Kizzy Consulting     	 Pushkar               Initial Version
------------------------------------------------------------------------------------------------
*/
public class BatchToUpdateAccountBasedOnOpp implements database.Batchable<sObject>, Database.Stateful{
    public Database.QueryLocator Start(DataBase.BatchableContext bc){
        String query = 'SELECT Id, Number_of_Units_Purchased_from_Acct__c,Number_of_Units_Sold_To_Acct__c,';
        query += '(SELECT id,ForecastCategory,Seller_Account__c,AccountId FROM Opportunities WHERE ForecastCategory =\'Closed\' AND (RecordType.Name =\'Inventory Sell\' OR RecordType.Name =\'Broker Sell\')),';
        query += '(SELECT id,ForecastCategory FROM Opportunities5__r ';
        query += '   WHERE ForecastCategory =\'Closed\' AND RecordType.Name =\'Procurement Opportunity\' )';
        query +=' FROM Account';
        system.debug('query::'+query);
        return Database.getQueryLocator(query);
    }
    public void Execute (Database.BatchableContext dbc , list<Account> lstAccount){
        system.debug('lstAccount::'+lstAccount);
        list<account> lstAccountToUpdate = new list<account>();
        if(lstAccount != null && !lstAccount.isEmpty()){
            for(account eachAccount : lstAccount){
                boolean isupdate = false;
                Account newAccount = new Account();
                newAccount.id = eachAccount.Id;
                if(eachAccount.Opportunities5__r!=null && !eachAccount.Opportunities5__r.isEmpty()){
                    newAccount.Number_of_Units_Purchased_from_Acct__c = eachAccount.Opportunities5__r.Size();
                    isupdate = true;
                }
                if(eachAccount.Opportunities != null && !eachAccount.Opportunities.isEmpty()){
                    newAccount.Number_of_Units_Sold_To_Acct__c = eachAccount.Opportunities.Size();
                    isupdate = true;
                }
                
                if(isupdate){
                    lstAccountToUpdate.add(newAccount);
                }
            }
        }
        
        if(lstAccountToUpdate != null && !lstAccountToUpdate.isEmpty()){
            system.debug('lstAccountToUpdate::'+lstAccountToUpdate);
            Update lstAccountToUpdate;
        }
       
    }
    public void finish(Database.BatchableContext dbc){
        system.debug('Success : Records Updated Successfully');
    }
}