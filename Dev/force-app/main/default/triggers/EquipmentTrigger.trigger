trigger EquipmentTrigger on Equipment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.run(new EquipmentTriggerHandler());
}