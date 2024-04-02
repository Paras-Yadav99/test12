public class CreateTaskOnUnit implements Database.Batchable<sObject> , Database.Stateful {
    public static string userName = System.Label.Admin1;
	public static string UserId = [Select id,name FROM User WHERE Name =: userName limit 1].id;
    public Database.QueryLocator Start(DataBase.BatchableContext bc){
        String query = 'SELECT Id, Market_on_FB_Group__c, StageName, Product__c, ';
               query +=' Product__r.FB_Group_Post_Date__c, Product__r.FB_Group_Post_Link__c, Product__r.IsActive ';
        	   query +=' FROM Opportunity WHERE StageName = \'Proactive Brokerage\' AND Product__c !=null AND  Market_on_FB_Group__c = true AND ';
               query +=' Product__r.FB_Group_Post_Date__c =null AND Product__r.FB_Group_Post_Link__c = null AND Product__r.IsActive = True';
        return Database.getQueryLocator(query);
    }
    public void Execute (Database.BatchableContext dbc , list<Opportunity>lstOpportunity){
        if(lstOpportunity!=null && !lstOpportunity.isEmpty()){
           CreateTaskOnUnitController.handleExecution(lstOpportunity); 
        }
    }
    public void finish(Database.BatchableContext dbc){
            system.debug('Success : Task Creation Success');
        }
}