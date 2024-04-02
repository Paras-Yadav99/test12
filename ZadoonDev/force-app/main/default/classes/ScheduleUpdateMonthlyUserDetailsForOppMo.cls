public class ScheduleUpdateMonthlyUserDetailsForOppMo implements Schedulable{
    
    public void execute (SchedulableContext SC){
        
        UpdateMonthlyUserDetailsForOpp batchInstance = NEW UpdateMonthlyUserDetailsForOpp(false,system.today().year());
        //batchInstance.YearlyData = true;
        id BatchId = DataBase.executeBatch(batchInstance, 200);
    }
    
}