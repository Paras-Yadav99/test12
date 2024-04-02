public class EquipmentTriggerHandler implements ITriggerHandler{
    private static final string DEVELOPER_NAME = 'Equipment';
    public Trigger_Setting__mdt setTriggerSettings() {
        
        
        return [select Active__c,Max_Loop_Count__c,Stop_Recursion__c FROM Trigger_Setting__mdt 
                Where DeveloperName=:DEVELOPER_NAME LIMIT 1];
        
    } 
    
    Public void beforeInsert(List<SObject> triggerNew){
        //handleBeforeInsert((List<opportunity>)triggerNew);
        
    }
    //By implementing this method trigger can handle all the before Update events
    Public void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){    
        //handleBeforeUpdate((List<opportunity>)triggerNew,(Map<Id, opportunity>)triggerOldMap);
    }
    //By implementing this method trigger can handle all the before Delete events
    Public void beforeDelete(List<SObject> triggerOld){
        
    }   
    //By implementing this method trigger can handle all the after Insert events
    Public void afterInsert(List<SObject> triggerNew){
        handleAfterInsert((List<Equipment__c>) triggerNew);
    }
    //By implementing this method trigger can handle all the after Update events
    Public void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){
        //handleAfterUpdate((List<Account>) triggerNew, (Map<Id, Account>) triggerOldMap);
        //handleCreateTaskOnAfterUpdate((List<Account>) triggerNew, (Map<Id, Account>) triggerOldMap);
       //handleCreateTaskOnAfterUpdate( (List<Account>) triggerNew, (Map<Id, Account>) triggerOldMap);
    }
    //By implementing this method trigger can handle all the after Delte events
    Public void afterDelete(List<SObject> triggerOld){
        
    }
    //By implementing this method trigger can handle all the after UnDelete events
    Public void afterUndelete(List<SObject> triggerNew){
        
    }
    private static void handleAfterInsert(
        list<Equipment__c> lstTriggerNew
    ){
        if(lstTriggerNew!=null && !lstTriggerNew.isEmpty()){
            list<Task>lstTask = new list<Task>();
            list<User> lstUser = [SELECT id, Name FROM User WHERE Name =: label.VA LIMIT 1];
            for(Equipment__c eachEquipment : lstTriggerNew){
                if(eachEquipment.Operating_Weight__c != null && lstUser!=null && !lstUser.IsEmpty() ){
                    Task newTask = CreateTask.createNewTask('Add Operating Weigh from specalog',
                                                            eachEquipment.id,
                                                            null,
                                                            System.TODAY(),
                                                            lstUser[0].Id,
                                                            'New');
                    
                    lstTask.add(newTask);
                }
                if(string.isNotBlank(eachEquipment.Machine_Specalog__c) && lstUser!=null && !lstUser.IsEmpty() ){
                    Task newTask = CreateTask.createNewTask('Add PDF Specalog link',
                                                            eachEquipment.id,
                                                            null,
                                                            System.TODAY(),
                                                            lstUser[0].Id,
                                                            'New');
                    
                    lstTask.add(newTask);
                }
            }   
        }
    }
}