public class taskBatchClass implements Database.Batchable<sObject>{
    public list<id> taskNotDeleted = new list<id>();
    public Database.QueryLocator start (Database.BatchableContext bc ){
        string taskStatusForDelete = System.label.taskStatusForDelete;
        return Database.getQueryLocator(
        								'SELECT id FROM Task '+
            							' WHERE Status = :taskStatusForDelete AND CompletedDateTime <= LAST_N_DAYS:90 '+
            							' LIMIT 4500000');	
    }
    public void execute (Database.BatchableContext bc ,list<task> totaltaskToDelete ){
        taskBatchClassHandler.run(totaltaskToDelete);
    }
    public void finish (Database.BatchableContext bc ){
        system.debug(taskNotDeleted);
    }
}