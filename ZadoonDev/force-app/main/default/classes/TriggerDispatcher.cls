/*
This class is responsible for making sure all of the applicable methods on your 
trigger handler are called, depending on the current trigger context. 
It also contains a check to make sure that the trigger has not been disabled. 
If the trigger has been disabled (more on this below), then the trigger events will not be fired
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          19-Aug-2016                    Daksh Madan               Initial Version
--------------------------------------------------------------------------------------
*/
public class TriggerDispatcher {
    // static map of handlername, times run() was invoked
	private static Map<String, LoopCount> loopCountMap;
	
	private static final Integer MAXCOUNT = 5;
	/*
        Call this method from your trigger, passing in an instance of a trigger handler which implements ITriggerHandler.
        This method will fire the appropriate methods on the handler depending on the trigger context.
    */
	// static initialization
	static {
		loopCountMap = new Map<String, LoopCount>();
	}
	
	//Checks to see if the trigger has been disabled
    private static Boolean isDisabled(Trigger_Setting__mdt triggerSetting) {
		return (triggerSetting.Active__c == false);
	}
    
	
    public static void run(ITriggerHandler handler) {
        system.debug('handler '+String.valueOf(handler));
		Trigger_Setting__mdt triggerSetting = handler.setTriggerSettings();
		// Check to see if the trigger has been disabled. If it has, return
        if (TriggerDispatcher.isDisabled(triggerSetting))
            return;
		
		TriggerDispatcher.setMaxLoopCount(handler, triggerSetting);
		
		if(TriggerDispatcher.addToLoopCount(handler, triggerSetting))
			return;
		
        // Detect the current trigger context and fire the relevant methods on the trigger handler:
 
        // before trigger logic
        if (Trigger.IsBefore )
        {
            if (Trigger.IsInsert)
                handler.beforeInsert(trigger.new);
 
            if (Trigger.IsUpdate)
                handler.beforeUpdate(trigger.new, trigger.oldMap);
 
            if (Trigger.IsDelete)
                handler.beforeDelete(trigger.old);
        }
         
        // after trigger logic
        if (Trigger.IsAfter)
        {
            if (Trigger.IsInsert)
                handler.afterInsert(Trigger.new);
 
            if (Trigger.IsUpdate)
                handler.afterUpdate(trigger.new, trigger.oldMap);
 
            if (trigger.IsDelete)
                handler.afterDelete(trigger.old);
 
            if (trigger.isUndelete)
                handler.afterUndelete(trigger.new);
        }
    }
	
	@TestVisible
	private static String getHandlerName(ITriggerHandler handler) {
		return String.valueOf(handler).subString(0,String.valueOf(handler).indexOf(':'));
	}
	
	// increment the loop count
	@TestVisible
	private static Boolean addToLoopCount(ITriggerHandler handler, Trigger_Setting__mdt triggerSetting) {
		String handlerName = getHandlerName(handler);
		if(TriggerDispatcher.loopCountMap.containsKey(handlerName)) {
			Boolean exceeded = TriggerDispatcher.loopCountMap.get(handlerName).increment();
			if(exceeded) {
				Boolean stopRecursion = triggerSetting.Stop_Recursion__c;
				if(stopRecursion) return true;
				Integer max = TriggerDispatcher.loopCountMap.get(handlerName).max;
				throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
			}
		}
		return false;
	}
	
	private static void setMaxLoopCount(ITriggerHandler handler, Trigger_Setting__mdt triggerSetting) {
		String handlerName = getHandlerName(handler);
		Integer max = integer.valueOf(triggerSetting.Max_Loop_Count__c);
		if(!TriggerDispatcher.loopCountMap.containsKey(handlerName)) {
		  TriggerDispatcher.loopCountMap.put(handlerName, new LoopCount(max));
		} else {
		  TriggerDispatcher.loopCountMap.get(handlerName).setMax(max);
		}
	}

	
	/***************************************
   * inner classes
   ***************************************/

  // inner class for managing the loop count per handler
  @TestVisible
	private class LoopCount {
		private Integer max;
		private Integer count;

		public LoopCount() {
		  this.max = TriggerDispatcher.MAXCOUNT;
		  this.count = 0;
		}

		public LoopCount(Integer max) {
		  this.max = max;
		  this.count = 0;
		}

		public Boolean increment() {
		  this.count++;
		  return this.exceeded();
		}

		public Boolean exceeded() {
		  if(this.max < 0) return false;
		  if(this.count > this.max) {
			return true;
		  }
		  return false;
		}

		public Integer getMax() {
		  return this.max;
		}

		public Integer getCount() {
		  return this.count;
		}

		public void setMax(Integer max) {
		  this.max = max;
		}
	}
	
	// exception class
	public class TriggerHandlerException extends Exception {}

}