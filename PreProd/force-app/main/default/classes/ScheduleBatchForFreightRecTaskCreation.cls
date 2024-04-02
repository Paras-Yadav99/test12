/*
This Schedule Class is used to call the BatchForFreightRecTaskCreation on scheduled events
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          18-Aug-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/
public class ScheduleBatchForFreightRecTaskCreation  implements Schedulable{
    
    public void execute (SchedulableContext SC){
        
        BatchForFreightRecTaskCreation batchInstance = NEW BatchForFreightRecTaskCreation();
        id BatchId = DataBase.executeBatch(batchInstance, 200);
    }
   
}