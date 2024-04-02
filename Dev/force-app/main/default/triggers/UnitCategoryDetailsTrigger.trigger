trigger UnitCategoryDetailsTrigger on Unit_Category_Details__c 
(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.run(new UnitCategoryDetailsTriggerHandler());
}