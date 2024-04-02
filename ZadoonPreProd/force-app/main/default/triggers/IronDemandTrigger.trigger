trigger IronDemandTrigger on Iron_Demand__c (after insert, after update) {
    
    List<Customization_Settings__mdt> TriggerMdt = [SELECT Id,DeveloperName,Active_Trigger__c from Customization_Settings__mdt
                                                    WHERE DeveloperName ='Iron_Demand_Trigger_Disabled'];
   
    system.debug('trigger disabled ===>'+TriggerMdt);
    if(TriggerMdt != null && TriggerMdt.size()> 0 && TriggerMdt.get(0).Active_Trigger__c){
        if ( UtilityClass.runOnce ) {
            if(trigger.isAfter && ( trigger.isInsert || trigger.isUpdate)){
                IronDemandTriggerHelper.createMatchingIronDemandUnits(trigger.new, trigger.oldMap, trigger.isUpdate, trigger.isInsert);
                UtilityClass.runOnce = false;
            }
        }
    }
}