public class CaseTriggerHandler implements ITriggerHandler{
	private static final string DEVELOPER_NAME = 'Case';
     public Trigger_Setting__mdt setTriggerSettings() {
       
        
        return [select Active__c,Max_Loop_Count__c,Stop_Recursion__c FROM Trigger_Setting__mdt 
                Where DeveloperName=:DEVELOPER_NAME LIMIT 1];
    
    } 
    
    Public void beforeInsert(List<SObject> triggerNew){
		 
    }
    //By implementing this method trigger can handle all the before Update events
    Public void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){    
      
    }
    //By implementing this method trigger can handle all the before Delete events
    Public void beforeDelete(List<SObject> triggerOld){
        
    }   
    //By implementing this method trigger can handle all the after Insert events
    Public void afterInsert(List<SObject> triggerNew){
        //handleAfterInsert((List<opportunity>)triggerNew);
        CalculateNoOfCasesOnUnit((List<Case>)triggerNew);
    }
    //By implementing this method trigger can handle all the after Update events
    Public void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){
       	CalculateNoOfCasesOnUnitOnUpdate((List<Case>)triggerNew,(Map<Id, Case>) triggerOldMap);
    }
    //By implementing this method trigger can handle all the after Delte events
    Public void afterDelete(List<SObject> triggerOld){
      	CalculateNoOfCasesOnUnit((List<Case>)triggerOld);
    }
    //By implementing this method trigger can handle all the after UnDelete events
    Public void afterUndelete(List<SObject> triggerNew){
     	CalculateNoOfCasesOnUnit((List<Case>)triggerNew);
    }
   
    private static void CalculateNoOfCasesOnUnit(
        list<Case> lstTriggerNew
    ){
        if(lstTriggerNew!=null && !lstTriggerNew.isEmpty()){
            //set<id> setOfUnitId = new set<Id>();
            map<Id,list<Case>> mapOfUnitIdVsLstCase = new map<Id,list<Case>>();
            list<Product2> lstUnit  ;
            for(Case eachCase : lstTriggerNew){
                if(string.isNotBlank(eachCase.UnitCase__c)){
                    
                    if(!mapOfUnitIdVsLstCase.containsKey(eachCase.UnitCase__c)){
                        mapOfUnitIdVsLstCase.put(eachCase.UnitCase__c, new list<Case>());
                    }
                    mapOfUnitIdVsLstCase.get(eachCase.UnitCase__c).add(eachCase);
                }
            }
            if(mapOfUnitIdVsLstCase.KeySet()!=null && !mapOfUnitIdVsLstCase.KeySet().isEmpty()){
                lstUnit = [SELECT Id, name,Number_of_cases__c FROM Product2 WHERE Id IN : mapOfUnitIdVsLstCase.KeySet()] ;
                //mapOfidVsUnit = [SELECT Id, name FROM Product2 WHERE Id IN : setOfUnitId ];
            }
            if(lstUnit!=null && !lstUnit.isEmpty()){
                for(Product2 eachProduct2 : lstUnit){
                    if(mapOfUnitIdVsLstCase.containsKey(eachProduct2.id) &&
                      mapOfUnitIdVsLstCase.get(eachProduct2.id)!=null && 
                      !mapOfUnitIdVsLstCase.get(eachProduct2.id).isEmpty()) {
                        eachProduct2.Number_of_cases__c += mapOfUnitIdVsLstCase.get(eachProduct2.id).Size();
                    }
                }
            }
            
            
        }
    }
    
     private static void CalculateNoOfCasesOnUnitOnUpdate(List<Case>triggerNew,
                                                        Map<Id, Case> triggerOldMap
                                                         )
     {
         if(triggerNew!=null && !triggerNew.isEmpty()){
             set<Case> setCase = new set<Case>();
             list<Case> lstCase = new List<Case>();
             for(case eachCase : triggerNew){
                 case oldCase =triggerOldMap.get(eachCase.id);
                 if(hasFieldChanged(eachCase,oldCase,'UnitCase__c')){
                     setCase.add(eachCase);
                     setCase.add(oldCase);
                 }
                 
             }
             if(setCase!=null && !setCase.isEmpty()){
                 lstCase.addAll(setCase);
                 CalculateNoOfCasesOnUnit(lstCase);
             }
         }                                                       
                                                            
                                                            
        
    }
    
    private static Boolean hasFieldChanged(
        case newCase, case oldCase, String fieldName
    ){
        return hasValueChanged(
            newCase.get(fieldName),
            oldCase.get(fieldName)
        );
    }
    
    private static Boolean hasValueChanged(Object newValue, Object oldValue){
        return newValue != oldValue;
    }
    
}