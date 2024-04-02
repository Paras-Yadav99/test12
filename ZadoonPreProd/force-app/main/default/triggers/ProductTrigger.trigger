trigger ProductTrigger on Product2 (after insert, after update, before insert,before update) {
    
    List<Customization_Settings__mdt> TriggerMdt = [SELECT Id,DeveloperName,Active_Trigger__c from Customization_Settings__mdt
                                                     WHERE DeveloperName ='Product_After_Insert_Trigger'];
    
  /*  if(trigger.isAfter && trigger.isInsert ) {
        ProductTriggerHelper.createPriceBookEntry(trigger.new);
    }*/
    
    if(TriggerMdt != null && TriggerMdt.size()>0 && TriggerMdt.get(0).Active_Trigger__c ){
        if ( UtilityClass.runOnce ) {
            if(trigger.isAfter && ( trigger.isInsert || trigger.isUpdate)) {
                ProductTriggerHelper.createMatchingIronDemandUnits(trigger.new, trigger.oldMap, trigger.isUpdate, trigger.isInsert);
                UtilityClass.runOnce = false;
            }
        }
    
    
    if( trigger.isBefore && (trigger.isInsert || trigger.isUpdate ) && TriggerMdt != null && TriggerMdt.size()>0 && TriggerMdt.get(0).Active_Trigger__c ) {
        ProductTriggerHelper.populateEquipmentModel( trigger.new );
    }
   }
}