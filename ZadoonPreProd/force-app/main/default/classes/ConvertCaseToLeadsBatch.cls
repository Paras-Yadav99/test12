public class ConvertCaseToLeadsBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start (Database.BatchableContext bc ){
        return Database.getQueryLocator(
            [
                SELECT Id, Description, Subject, SuppliedName, Status, OwnerId, ContactEmail, 
                AccountId, ContactId, UnitCase__c, Opportunity_Related_To__c FROM Case WHERE Is_Processed__c = false
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Case> scope){
        ConvertCaseToLead.run(scope);
        for(Case caseObj : scope){
            caseObj.Is_Processed__c = true;
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc){
        
    }
}