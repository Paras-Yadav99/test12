public class ScheduleBatchCreateTaskOnUnitsClass implements Schedulable{
    
    public void execute (SchedulableContext SC){
        
        BatchCreateTaskonUnits batchInstance = NEW BatchCreateTaskonUnits();
        id BatchId = DataBase.executeBatch(batchInstance, 200);
    }
   
}