trigger FreightCompanyUnitTrigger on Freight_Company_Unit__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	 TriggerDispatcher.run(new FreightCompanyUnitTriggerHandler());
}