public class SendEmail_IronDemandUnitsSchedular implements Schedulable {
    
    public void execute(SchedulableContext sc){
        SendEmail_IronDemandUnitBatch obj = new SendEmail_IronDemandUnitBatch();
        Database.executeBatch(obj);
    }
}