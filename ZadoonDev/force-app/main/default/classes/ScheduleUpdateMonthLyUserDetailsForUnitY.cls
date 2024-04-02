public class ScheduleUpdateMonthLyUserDetailsForUnitY implements Schedulable{
    
    public void execute (SchedulableContext SC){
        
        UpdateMonthLyUserDetailsForUnit batchInstance = NEW UpdateMonthLyUserDetailsForUnit(true);
        id BatchId = DataBase.executeBatch(batchInstance, 200);
    }
    
}