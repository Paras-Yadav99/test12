trigger UserRequirementIDTrigger on User_Requirement_ID__c
(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new UserRequirementIDTriggerHandler());
}