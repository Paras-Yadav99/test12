trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(trigger.isUpdate && Trigger.isAfter) {
        for(opportunity eachOpp : trigger.New){
            system.debug('eachOpp.stageName -- afterUpdate before Trigger' + eachOpp.stageName);
            system.debug('eachOpp.stageName OLD -- afterUpdate before Trigger' + trigger.OldMap.get(eachOpp.Id).stageName);
        }
    }
    
    TriggerDispatcher.run(new OpportunityTriggerHandler());
}