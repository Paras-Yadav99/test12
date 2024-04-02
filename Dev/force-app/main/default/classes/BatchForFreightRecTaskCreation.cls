/*
This Batch Class is used to create Recurring task on Freight for Melissa to track Freight after Three Days to Pickup Date.
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          13-Oct-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/
public class BatchForFreightRecTaskCreation implements Database.Batchable<sObject> {
    
    public Database.QueryLocator Start(DataBase.BatchableContext dbc){
        // get query from controller
        Date day3Before = System.today().addDays(-3);
        String query = 'SELECT Id, Name, Freight_Pickup_Date__c FROM Freight_Company_Unit__c '+
            ' WHERE Freight_Pickup_Date__c <=: day3Before AND Freight_Status__c = \'Machine Loaded\'';
        
        system.debug('Query Data::'+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
        
    } 
        public void Execute (Database.BatchableContext dbc , list<Freight_Company_Unit__c>lstFreights){

        system.debug('lstUnits:'+lstFreights);
        list<Task> lstTask = new list<Task>();
        map<String,User> mapNameVsUser = new map<String,User>();
        list<User> lstUser = [SELECT Id, Username, Name,email
                              FROM User 
                              WHERE IsActive  = true
                             ];
        
        if(lstUser!=null && !lstUser.isEmpty()){
            for(User eachUsers : lstUser){
                mapNameVsUser.put(eachUsers.Name,eachUsers);
            }
        }
        
        if(lstFreights!=null && !lstFreights.isEmpty()){
            
            for(Freight_Company_Unit__c  eachFreight :  lstFreights){
                String Subject =' Track Freight Location for Today or Mark as completed.';
                if(mapNameVsUser.containsKey(System.Label.Office_Manager)){
                    Task  newTask = CreateTask.createNewTask(Subject, 
                                                             eachFreight.id,
                                                             null, 
                                                             System.today(), 
                                                             mapNameVsUser.get(System.Label.Office_Manager).Id,
                                                             'New');
                    lstTask.add(newTask);
                }
            }
            if(lstTask != Null &&! lstTask.IsEmpty()){
                insert lstTask;
            }
            //BatchToSendInsEmailOnInsDayCtrl.handleExecution(lstUnitInspections);
        }
    }
    public void finish(Database.BatchableContext dbc){
        system.debug('Success : Task Creation Successfull!!');
    }

}