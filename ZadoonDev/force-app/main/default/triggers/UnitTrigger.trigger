trigger UnitTrigger on Product2 (before insert, after insert, after update, before update,before delete ,after delete, after undelete) {
    TriggerDispatcher.run(new UnitTriggerHandler());
     if(trigger.isUpdate && Trigger.isAfter) {
        for(Product2 eachUnit : trigger.New){
            system.debug('eachUnit.Inventory_Status__c -- afterUpdate before Trigger' + eachUnit.Inventory_Status__c);
            system.debug('eachUnit.Inventory_Status__c OLD -- afterUpdate before Trigger' + trigger.OldMap.get(eachUnit.Id).Inventory_Status__c);
        }
    }
    /*if(Trigger.isAfter){
        if(Trigger.isInsert){
            //UnitTriggerHandler.handleAfterInsert(Trigger.new);
            
            //Id batchJobId = Database.executeBatch(new MLSCalloutBatch(), 1);
        }else if(Trigger.isUpdate){
            //UnitTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
           // UnitTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
            
        }else if(Trigger.isUndelete){
           // UnitTriggerHandler.handleAfterUndelete(Trigger.new, Trigger.newMap);
        } else if(Trigger.isDelete){
           // UnitTriggerHandler.handleAfterDelete(Trigger.old, Trigger.oldMap);
        } 
    }else if(Trigger.isBefore){
        if(Trigger.isUpdate){
            //UnitTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        } else if(Trigger.isInsert){
           // UnitTriggerHandler.beforeInsert(Trigger.new);
        }
    }*/
    
}