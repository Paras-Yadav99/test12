public class ScheduleUpdateMonthLyUserDetailsForUnitM implements Schedulable{
    
    public void execute (SchedulableContext SC){
        
        UpdateMonthLyUserDetailsForUnit batchInstance = NEW UpdateMonthLyUserDetailsForUnit(false);
        id BatchId = DataBase.executeBatch(batchInstance, 200);
    }
}