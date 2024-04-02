public class CreateTask {
    public static task createNewTask(String subject, String WhatId, String WhoId, Date ActivityDate, string OwnerId, String status){
        task newTask = new task();
        newTask.Subject = subject;
        newTask.WhatId = WhatId;
        newTask.WhoId = WhoId;
        newTask.ActivityDate = ActivityDate;
        newTask.OwnerId = OwnerId;
        newTask.status = status;
        return newTask;
    }
}