public class ScheduleUpdateMonthlyUserDetailsForOppYe implements Schedulable{
    
    public void execute (SchedulableContext SC){
        
        UpdateMonthlyUserDetailsForOpp batchInstance = NEW UpdateMonthlyUserDetailsForOpp(true,system.today().year());
        //batchInstance.YearlyData = true;
        id BatchId = DataBase.executeBatch(batchInstance, 200);
    }
    
}