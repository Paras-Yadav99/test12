global class ScheduleCreateTasksForUnitBatch implements Schedulable{
    global void execute(SchedulableContext ctx) {
        CreateTasksForUnitBatch batchObj = new CreateTasksForUnitBatch();
        database.executebatch(batchObj);

        CreateTasksForUnitBatch_CL batchObj_cl = new CreateTasksForUnitBatch_CL();
        database.executebatch(batchObj_cl);
    }
}