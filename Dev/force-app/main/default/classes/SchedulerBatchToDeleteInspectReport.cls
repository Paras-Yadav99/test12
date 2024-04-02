global class SchedulerBatchToDeleteInspectReport implements Schedulable
{

    global void execute(SchedulableContext sc)

    {

        BatchToDeleteInspectionReport b = new BatchToDeleteInspectionReport(); // Your batch class

      database.executeBatch(b);

    }

}