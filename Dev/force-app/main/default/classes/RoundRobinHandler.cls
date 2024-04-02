/*
    This class is used for round robin logic.
    --------------------------------------------------------------------------------------
    Version#     Date                           Author                    Description
    --------------------------------------------------------------------------------------
    1.0          22-Oct-2022                    Paras Yadav               Initial Version
    --------------------------------------------------------------------------------------
*/
public class RoundRobinHandler {

    /*
    This method is used to get the result based on round robin logic..
    --------------------------------------------------------------------------------------
    Version#     Date                           Author                    Description
    --------------------------------------------------------------------------------------
    1.0          22-oct-2022                    Paras Yadav              Initial Version
    --------------------------------------------------------------------------------------
    @params        string teamParentName, 
                    string userObject,
                    string FilterFieldName,
                    string FieldToUpdate,
                    string FieldAPINameOnRoundRobinObject
    @output      list<Sobject>
    --------------------------------------------------------------------------------------
    */

    public static list<Wrapper>  lstRoundRobinObjBasedOnRegion = new list<Wrapper> ();
    public static list<sObject> lstsObjectToUpdate = new list<sobject>();
    
    public static list<sobject> RoundRobin(list<sobject> lstTriggerNew, //lstLead,
                                                   string teamParentName, //'Sales_Team__r',
                                                    string userObject, //'Team_Member__c',
                                                    string FilterFieldName, //'Region__c',
                                                    string FieldToUpdate,  //'OwnerId',
                                                    string FieldAPINameOnRoundRobinObject  // 'User__c'
                                                    ) {
        
        set<String> setOfFilterFieldValues = new Set<String>();
        Map<String,List<Wrapper>> MapOfSkillVsMembers = new Map<String,List<Wrapper>>();
        list<sObject> lstObjectForRoundRobin = new list<sObject> ();

        if(lstTriggerNew!=null && !lstTriggerNew.isEmpty() ){
            for(sobject eachSObject : lstTriggerNew){
                setOfFilterFieldValues.add(string.valueOf(eachSObject.get(FilterFieldName)));
            }
        }
         system.debug('setOfFilterFieldValues'+setOfFilterFieldValues);
        if(setOfFilterFieldValues!=null && !setOfFilterFieldValues.isEmpty()){
            RoundRobinHandler.getRoundRobinObject(setOfFilterFieldValues,
                                                            lstObjectForRoundRobin,
                                                            MapOfSkillVsMembers,
                                                            userObject,
                                                            teamParentName,
                                                            FilterFieldName,
                                                            FieldAPINameOnRoundRobinObject
                                                            );       
                               
        }
         system.debug('MapOfSkillVsMembers'+MapOfSkillVsMembers);                                               
		if(MapOfSkillVsMembers!=null && !MapOfSkillVsMembers.isEmpty() &&
            lstTriggerNew!=null && !lstTriggerNew.isEmpty() ){
            for(sobject eachSObject : lstTriggerNew){
                system.debug(' MapOfSkillVsMembers:'+ MapOfSkillVsMembers.keyset());
                system.debug(' string.valueOf(eachSObject.get(FilterFieldName)):'+ string.valueOf(eachSObject.get(FilterFieldName)));
                system.debug('FilterFieldName'+FilterFieldName);
                system.debug('lsdgjpiqgs'+(Lead)(eachSObject));
               lstRoundRobinObjBasedOnRegion =MapOfSkillVsMembers.get(string.valueOf(eachSObject.get(FilterFieldName)));
                system.debug(' lstRoundRobinObjBasedOnRegion:'+lstRoundRobinObjBasedOnRegion);
               if(lstRoundRobinObjBasedOnRegion!=null && !lstRoundRobinObjBasedOnRegion.isEmpty()){
                       
                   //Below code is used to check if all the counter of all the branches 
                   //are complete if so reset the
                   // counte to 0.
                   Integer index = 0;
                   while(lstRoundRobinObjBasedOnRegion.size()-1 > = index){
                       if((Decimal)lstRoundRobinObjBasedOnRegion[index].obj.get('capacity__c') - (Decimal)lstRoundRobinObjBasedOnRegion[index].obj.get('counter__c') != 0){
                              break;
                          }
                       index++;
                   }
                   if(index == lstRoundRobinObjBasedOnRegion.size()){
                       for(Wrapper eachTeamMember : lstRoundRobinObjBasedOnRegion){
                           eachTeamMember.obj.put('counter__c',0);
                       }
                       index = 0;
                       lstRoundRobinObjBasedOnRegion.sort();
                           
                   }
                   //ends here
                   if(eachSobject.get(FieldToUpdate)!=lstRoundRobinObjBasedOnRegion[index].obj.get(FieldAPINameOnRoundRobinObject)){
                       
                   
                       eachSobject.put(FieldToUpdate,lstRoundRobinObjBasedOnRegion[index].obj.get(FieldAPINameOnRoundRobinObject)); //FieldToUpdate
                                                                                    
                       Decimal nextCounter =(Decimal)(lstRoundRobinObjBasedOnRegion[index].obj.get('counter__c')) + 1;
                       lstRoundRobinObjBasedOnRegion[index].obj.put('counter__c',nextCounter);
                       lstRoundRobinObjBasedOnRegion.sort();                
                   }  
                }
            }
    
        }
        if(MapOfSkillVsMembers.keySet()!=null && !MapOfSkillVsMembers.keySet().isEmpty()){
            for(string eachSkill :MapOfSkillVsMembers.keySet()){
                list<Wrapper> lstWrapper = MapOfSkillVsMembers.get(eachSkill);
                for(wrapper eachWrapper : lstWrapper){
                     lstsObjectToUpdate.add(eachWrapper.obj);
                }
            }
        }                                                
        /*if(lstRoundRobinObjBasedOnRegion!=null && !lstRoundRobinObjBasedOnRegion.isEmpty()){
            for(Wrapper eachWrapper : lstRoundRobinObjBasedOnRegion) {
                lstsObjectToUpdate.add(eachWrapper.obj);
            }
            
        }*/
        
        system.debug('lstsObjectToUpdate'+lstsObjectToUpdate);
        return lstsObjectToUpdate;
    } 
    /*
    This method is used to get the object on which rounRobin is to be applied.
    --------------------------------------------------------------------------------------
    Version#     Date                           Author                    Description
    --------------------------------------------------------------------------------------
    1.0          11-oct-2022                    Paras Yadav              Initial Version
    --------------------------------------------------------------------------------------
    @params     set<String> setOfFilterFieldValues,
                list<sObject> lstObjectForRoundRobin,
                Map<String,List<Wrapper>> MapOfSkillVsMembers,
                string userObject,
                string teamParentName,
                string FilterFieldName,
                string FieldAPINameOnRoundRobinObject
    @output      none
    --------------------------------------------------------------------------------------
    */
    public static void getRoundRobinObject(set<String> setOfFilterFieldValues,
                                            list<sObject> lstObjectForRoundRobin,
                                            Map<String,List<Wrapper>> MapOfSkillVsMembers,
                                            string userObject,
                                            string teamParentName,
                                            string FilterFieldName,
                                            string FieldAPINameOnRoundRobinObject ) {
                                                
                                                
                                             	string queryString ='SELECT Id, Capacity__c,' +
                                                    ' Counter__c, ' +teamParentName +'.'+FilterFieldName +', '+FieldAPINameOnRoundRobinObject  +
                                                    ' FROM '+ +userObject +' WHERE ' +
                                                    +teamParentName +'.'+FilterFieldName + ' IN :setOfFilterFieldValues And Active__c = true Order by Counter__c asc';
                                                    
                                                    lstObjectForRoundRobin = Database.query(queryString);    
                                                system.debug('lstObjectForRoundRobin'+lstObjectForRoundRobin);
                                                if(lstObjectForRoundRobin!=null && !lstObjectForRoundRobin.isEmpty()){
                                                    for(sObject eachuserObject : lstObjectForRoundRobin){
                                                        
                                                        string teamUserSkill = string.valueOf(eachuserObject.getSObject(teamParentName).get(FilterFieldName));
                                                       
                                                        if(!MapOfSkillVsMembers.containsKey(teamUserSkill)){
                                                            MapOfSkillVsMembers.put(teamUserSkill,
                                                                                    new list<Wrapper>());
                                                        }
                                                        Wrapper obj = new Wrapper(eachuserObject);
                                                        MapOfSkillVsMembers.get(teamUserSkill).add(obj);
                                                        
                                                    }
                                                }
                                            }
}