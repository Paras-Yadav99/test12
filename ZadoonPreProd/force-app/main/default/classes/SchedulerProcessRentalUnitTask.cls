global class SchedulerProcessRentalUnitTask implements Schedulable{
    global void execute(SchedulableContext SC) {
        processRentalUnitTask batchToSchedule = new processRentalUnitTask();        
        Database.executeBatch(batchToSchedule);
    }
}