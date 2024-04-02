public class CreateTaskOnUnitController {
	public static void handleExecution(list<Opportunity>lstOpportunity){
        list<Task> lstTaskToInsert = new list<Task>();
        list<Task> lstTask ;
        map<Id,List<Task>> mapOfUnitIdVsLstTask = new map<Id,List<Task>>();
        set<Id> setUnitId = new set<Id>();
        system.debug('lstOpportunity:'+lstOpportunity);
        if(lstOpportunity!=null && !lstOpportunity.isEmpty() && string.isNotBlank(CreateTaskOnUnit.UserId)){
            for(Opportunity eachopportunity : lstOpportunity){
                setUnitId.add(eachopportunity.Product__c);
            }
            if(setUnitId!=null && !setUnitId.isEmpty()){
                lstTask = [SELECT Id , subject, WhatId 
                           FROM task 
                           WHERE subject = 'Post this unit on FB Group, add Post Date and Fb Group Post Link on Unit.' 
                           AND WhatId IN : setUnitId ];
            }
            if(lstTask!=null && !lstTask.isEmpty()){
                for(task eachTask : lstTask){
                    if(!mapOfUnitIdVsLstTask.containsKey(eachTask.WhatId)){
                        mapOfUnitIdVsLstTask.put(eachTask.WhatId,new list<Task>());
                    }
                    mapOfUnitIdVsLstTask.get(eachTask.WhatId).add(eachTask);
                }
            }
            for(Opportunity eachopportunity : lstOpportunity){
                system.debug('mapOfUnitIdVsLstTask.containsKey(eachopportunity.Product__c):'+mapOfUnitIdVsLstTask);
                if(!mapOfUnitIdVsLstTask.containsKey(eachopportunity.Product__c) ){
                    Task newTask = new Task();
                    newTask.Subject = 'Post this unit on FB Group, add Post Date and Fb Group Post Link on Unit.';
                    newTask.OwnerId = CreateTaskOnUnit.UserId;
                    newTask.WhatId = eachopportunity.Product__c;
                    lstTaskToInsert.add(newTask);
                }
            }
            system.debug('lstTaskToInsert::'+lstTaskToInsert);
            if(lstTaskToInsert!=null && !lstTaskToInsert.isEmpty()){
             	insert lstTaskToInsert;
            }
        }
    }
}