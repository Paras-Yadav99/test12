/*
This Trigger is used to handle events on Unit Inspection sObject
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          11-Sept-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/
trigger UnitInspectionTrigger on Unit_Inspection__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //fire events to Triiger Handler
   TriggerDispatcher.run(new UnitInspectionTriggerHandler());
}