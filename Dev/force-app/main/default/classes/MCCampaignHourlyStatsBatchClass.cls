public class MCCampaignHourlyStatsBatchClass implements database.Batchable<sObject>  {
	
    public list<id> lstOfRecordUndeleted = new list<id>();
    public integer countUnsucessfulNoOfRecordProcessed =0;
    
    public database.QueryLocator start (database.BatchableContext bc){
        
        return database.getQueryLocator(
        								'SELECT id  FROM MC4SF__MC_Campaign_Hourly_Stats__c '+
            							'WHERE CreatedDate < LAST_N_DAYS:14 '+
            							'LIMIT 4500000'); 
    }
    public void execute (database.BatchableContext bc, list<MC4SF__MC_Campaign_Hourly_Stats__c> recordToDelete){
        if(recordToDelete!=null && !recordToDelete.isEmpty()){
            database.DeleteResult[] recordsToDelete =  database.delete(recordToDelete,false);
                for (database.DeleteResult eachSaveResult :recordsToDelete){
                    if(!eachSaveResult.isSuccess()){
                         lstOfRecordUndeleted.add(eachSaveResult.getId());
                    }
                }
        }
    }
    public void finish(database.BatchableContext bc){
        system.debug(lstOfRecordUndeleted);
    }
}