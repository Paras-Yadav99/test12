public class UpdateOpportunityApproval implements database.batchable<sObject> , Database.Stateful {
    public static list<String> lstStageName = new list<String>{'Invoice approved','offer approved','Counteroffer Received','Offer Made','Offer Accepted','Document Review','Pro Forma Sent','Final Negotiations','Pro Forma Signed','Waiting for Buyer\'s Wire','Sent Wire to Seller','Delivering','Closed Won','WTB Created'};
    public Database.QueryLocator Start(DataBase.BatchableContext dbc){
        String query = 'SELECT Id,Name,StageName,Approved__c FROM Opportunity '+
        				'WHERE StageName!= null AND StageName = : lstStageName' ;
        system.debug(Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    public void Execute (Database.BatchableContext dbc , list<Opportunity>lstOpportunity){
        system.debug('lstOpportunity:'+lstOpportunity);
        if(lstOpportunity!=null && !lstOpportunity.isEmpty()){
            for(Opportunity eachOpportunity : lstOpportunity ){
                eachOpportunity.Approved__c = true;
            }
            update lstOpportunity;
        }
    }
    public void finish(Database.BatchableContext dbc){
        system.debug('Success : Approval');
    }
    
}