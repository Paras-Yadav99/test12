global class CreateRecuringTask implements Database.Batchable<sObject> , Database.Stateful {
    private RecuringTaskSchedulerWrapper TaskSchedulerWrapper;

    global CreateRecuringTask(string TaskSchedulerWrapper) {
                this.TaskSchedulerWrapper = (RecuringTaskSchedulerWrapper) JSON.deserialize(TaskSchedulerWrapper, RecuringTaskSchedulerWrapper.class);

        //this.TaskSchedulerWrapper= TaskSchedulerWrapper;
        /*public String ObjectAPIName;
        public String TaskcheckinsAPIName;
        public String Date_Field_API_Name;
        public String Task_Subject;
        public String Task_Description;*/
    }
    public Database.QueryLocator Start(DataBase.BatchableContext bc){
        String query = 'SELECT  ' +TaskSchedulerWrapper.TaskcheckinsAPIName +' , ' +TaskSchedulerWrapper.Date_Field_API_Name +' , '+ TaskSchedulerWrapper.Assigned_To_ID + '  ' ;
        if(string.isnotBlank(TaskSchedulerWrapper.Additional_Fields)){
           query += ' , ' +TaskSchedulerWrapper.Additional_Fields ; 
        }
        query+= ' FROM '+TaskSchedulerWrapper.ObjectAPIName +' WHERE ' +TaskSchedulerWrapper.Date_Field_API_Name + ' = TODAY';
        system.debug('query::'+query);
        return Database.getQueryLocator(query);
    }
    public void Execute (Database.BatchableContext dbc , list<SObject>lstSObject){
        system.debug('lstSObject::'+lstSObject);
        list<Task> lstTask = new list<Task>();
        if(lstSObject!=null && !lstSObject.isEmpty()){
            for(SObject eachSObject : lstSObject){
               /* IF(ISPICKVAL({!$Record.Check_Ins__c}, 'Monthly'), ADDMONTHS(TODAY(),1), 
                   IF(ISPICKVAL({!$Record.Check_Ins__c}, 'Quarterly'), ADDMONTHS(TODAY(),3), 
                      IF(ISPICKVAL({!$Record.Check_Ins__c}, 'Semi-Annually'), ADDMONTHS(TODAY(),6), 
                         IF(ISPICKVAL({!$Record.Check_Ins__c}, 'Annually'), ADDMONTHS(TODAY(),12),  TODAY()))))*/
                if(eachSObject.get(TaskSchedulerWrapper.TaskcheckinsAPIName)=='Monthly'){
                    eachSObject.put(TaskSchedulerWrapper.Date_Field_API_Name, System.Today().addMonths(1));
                }else if(eachSObject.get(TaskSchedulerWrapper.TaskcheckinsAPIName)=='Quarterly'){
                    eachSObject.put(TaskSchedulerWrapper.Date_Field_API_Name, System.Today().addMonths(3));
                }else if(eachSObject.get(TaskSchedulerWrapper.TaskcheckinsAPIName)=='Semi-Annually'){
                    eachSObject.put(TaskSchedulerWrapper.Date_Field_API_Name, System.Today().addMonths(6));
                }else if(eachSObject.get(TaskSchedulerWrapper.TaskcheckinsAPIName)=='Annually'){
                    eachSObject.put(TaskSchedulerWrapper.Date_Field_API_Name, System.Today().addMonths(12));
                }else {
                    eachSObject.put(TaskSchedulerWrapper.Date_Field_API_Name, null );
                }
                Task newTask = new task ();
                if(TaskSchedulerWrapper.ObjectAPIName == 'Account'){
                    
					newTask.Subject = TaskSchedulerWrapper.Task_Subject +TaskSchedulerWrapper.TaskcheckinsAPIName;                    
                }else{
                    newTask.Subject = TaskSchedulerWrapper.Task_Subject;
                }
                
                newTask.Description = TaskSchedulerWrapper.Task_Description;
                newTask.ActivityDate = system.TODAY();
                if(TaskSchedulerWrapper.ObjectAPIName == 'Account'){
                    system.debug('TaskSchedulerWrapper.Assigned_To_ID:::'+TaskSchedulerWrapper.Assigned_To_ID);
                    system.debug('eachSObject.get(TaskSchedulerWrapper.Assigned_To_ID)::'+eachSObject.get(TaskSchedulerWrapper.Assigned_To_ID));
                    newTask.OwnerId = (Id)eachSObject.get(TaskSchedulerWrapper.Assigned_To_ID) ;
                }
                //newTask.OwnerId = 
                if(TaskSchedulerWrapper.ObjectAPIName == 'Contact' || TaskSchedulerWrapper.ObjectAPIName == 'Lead' ){
                    newTask.whoID = eachSObject.id ;
                }else{
                    newTask.whatid = eachSObject.id ;
                }
                
                lstTask.add(newTask);
            }
            system.debug('lstSObject:::'+lstSObject);
            update lstSObject;
           // CreateTaskOnUnitController.handleExecution(lstOpportunity); 
        }
        if(lstTask!=null && !lstTask.isEmpty()){
            insert lstTask;
            system.debug('lstTask:::'+lstTask);
        }
    }
    public void finish(Database.BatchableContext dbc){
        system.debug('Success : Task Creation Success');
    }
    
    
    
    
}