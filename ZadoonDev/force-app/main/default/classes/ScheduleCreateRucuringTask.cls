global class ScheduleCreateRucuringTask implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        list<Recurring_Task__mdt> lstRecuringTask = [SELECT Id, Object_API_Name__c, Task_check_ins_API_Name__c, 
                                                     Date_Field_API_Name__c, Task_Subject__c, 
                                                     Task_Description__c, IsActive__c,Additional_Fields__c,
                                                     Assigned_To_ID__c
                                                     FROM Recurring_Task__mdt 
                                                    WHERE IsActive__c = true];
        if(lstRecuringTask!=null && !lstRecuringTask.isEmpty()){
            for(Recurring_Task__mdt eachRecurring_Task : lstRecuringTask){
                RecuringTaskSchedulerWrapper wrapper = new RecuringTaskSchedulerWrapper(eachRecurring_Task.Object_API_Name__c,
                                                                                        eachRecurring_Task.Task_check_ins_API_Name__c,
                                                                                        eachRecurring_Task.Date_Field_API_Name__c,
                                                                                        eachRecurring_Task.Task_Subject__c,
                                                                                        eachRecurring_Task.Task_Description__c,
                                                                                       eachRecurring_Task.Additional_Fields__c,
                                                                                       eachRecurring_Task.Assigned_To_ID__c); 
                String TaskSchedulerWrapper = JSON.serialize(wrapper);
  				
                 // Instantiate the batch class with parameters
                CreateRecuringTask batchInstance = new CreateRecuringTask(TaskSchedulerWrapper);
                
                // Execute the batch
                Database.executeBatch(batchInstance);
            }
        }
    }
    
    
}