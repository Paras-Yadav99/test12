/*
This Schedule Class is used to call the BatchToSendInspectionEmailOnInspection on scheduled events
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          18-Aug-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/
public class ScheduleBatchToSendInsEmailOnInsDay  implements Schedulable{
    
    public void execute (SchedulableContext SC){
        
        BatchToSendInspectionEmailOnInspection batchInstance = NEW BatchToSendInspectionEmailOnInspection();
        id BatchId = DataBase.executeBatch(batchInstance, 200);
    }
   
}