public interface ITriggerHandler {
    //By implementing this method trigger can handle all the before Insert events
    void beforeInsert(List<SObject> triggerNew);
    //By implementing this method trigger can handle all the before Update events
    void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap);
    //By implementing this method trigger can handle all the before Delete events
    void beforeDelete(List<SObject> triggerOld);
    //By implementing this method trigger can handle all the after Insert events
    void afterInsert(List<SObject> triggerNew);
    //By implementing this method trigger can handle all the after Update events
    void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap);
    //By implementing this method trigger can handle all the after Delte events
    void afterDelete(List<SObject> triggerOld);
    //By implementing this method trigger can handle all the after UnDelete events
    void afterUndelete(List<SObject> triggerNew);
    
	//this method is used to set the trigger settings
	Trigger_Setting__mdt setTriggerSettings();
}