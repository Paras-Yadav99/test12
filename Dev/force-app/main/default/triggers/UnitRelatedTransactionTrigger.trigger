/*
* Cretated By  : Akhtar Husain
* Created Date : 12/14/2020
* Description  : This trigger is responsible for calculating Unit Related Transaction roll-up Amount to Unit/Product Level. 
* References   : UnitRelatedTransactionTriggerHelper
*/


trigger UnitRelatedTransactionTrigger on Unit_Related_Transaction__c (after insert, after update, after delete, after undelete) {
    
    // metadata record to enable/disable trigger with checkbox
    List< Customization_Settings__mdt> TriggerMdt = [SELECT Id,DeveloperName,Active_Trigger__c from Customization_Settings__mdt
                                                     WHERE DeveloperName ='Unit_Related_Transaction_Trigger'];
    
    if( TriggerMdt != null && TriggerMdt.size()>0 && TriggerMdt[0].Active_Trigger__c) {
        if( UtilityClass.runUnitRelatedTranactionTrigger_Once ) {
            UnitRelatedTransactionTriggerHelper.calculateRollupAmount(trigger.new,trigger.old, trigger.oldMap,Trigger.operationType);
            UtilityClass.runUnitRelatedTranactionTrigger_Once = false;
        }
    }
}