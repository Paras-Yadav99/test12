/*
This trigger handler class is used to create unitcategorydetails object based on category. 
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          07-Aug-2023         Kizzy Consulting     	 Pushkar               Initial Version
------------------------------------------------------------------------------------------------
*/
public with sharing class UserRequirementIDTriggerHandler implements ITriggerHandler{
    private static final string DEVELOPERNAME = 'UserRequirementID';
    public Trigger_Setting__mdt setTriggerSettings() {
        return [select Active__c,Max_Loop_Count__c,Stop_Recursion__c FROM Trigger_Setting__mdt 
                Where DeveloperName=: DEVELOPERNAME LIMIT 1];
    } 
    Public void beforeInsert(List<SObject> triggerNew){
        handleBeforeInsert((List<User_Requirement_ID__c>)triggerNew);
        
    }
    //By implementing this method trigger can handle all the before Update events
    Public void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){    
    }
    //By implementing this method trigger can handle all the before Delete events
    Public void beforeDelete(List<SObject> triggerOld){
        
    }   
    //By implementing this method trigger can handle all the after Insert events
    Public void afterInsert(List<SObject> triggerNew){
        handleafterInsert((List<User_Requirement_ID__c>)triggerNew);
    }
    //By implementing this method trigger can handle all the after Update events
    Public void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){
        handleAfterUpdate((List<User_Requirement_ID__c>) triggerNew, (Map<Id, User_Requirement_ID__c>) triggerOldMap);
    }
    //By implementing this method trigger can handle all the after Delte events
    Public void afterDelete(List<SObject> triggerOld){
        
    }
    //By implementing this method trigger can handle all the after UnDelete events
    Public void afterUndelete(List<SObject> triggerNew){
        
    }
    private static void handleafterInsert(List<User_Requirement_ID__c> triggerNew){  
        //set<string> setUserRequireCategory = new set<string>();
        //list<Iron_Demand_Category__mdt> lstIronDemandCategory;
        //map<string,string> mapOfLabelVsDeveloperName = new map<string,string>();
        list<Unit_Category_Details__c> lstUnitCategoryDetailsInsert = new list<Unit_Category_Details__c>(); 
        //list<Iron_Demand__c> lstIronDemand = new list<Iron_Demand__c>();
        
        if(triggerNew!=null && !triggerNew.isEmpty()){
            for(User_Requirement_ID__c eachUserRequirementID : triggerNew){
                string recordTypeDevName = system.label.Unit_Category_Detail_From_UserRequirement;
                if(string.isNotBlank(RecordTypeDevName)){
                    Id recordTypeId =  Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get(RecordTypeDevName).getRecordTypeId();
                    if(string.isNotBlank(recordTypeId)){
                        
                        Unit_Category_Details__c newUnitCategoryDetails = createUnitCategory(recordTypeId,eachUserRequirementID.Id,eachUserRequirementId.Category__c,eachUserRequirementID.Name);
                        system.debug('recordTypeId::'+ recordTypeId);
                        lstUnitCategoryDetailsInsert.add(newUnitCategoryDetails);
                        system.debug('newUnitCategoryDetails:::'+newUnitCategoryDetails);
                    }
                }
            }
        }
        
        if(lstUnitCategoryDetailsInsert!=null && !lstUnitCategoryDetailsInsert.isEmpty()){
            insert lstUnitCategoryDetailsInsert;
        }
    }
    
                
    
    
    
    //This method will call the future method ,if weight,budget & year range changes
    private static void handleAfterUpdate(List<User_Requirement_ID__c> triggerNew, Map<Id, User_Requirement_ID__c> triggerOldMap){
        //set<string> setOfUserReqIDCategory = new set<string>();
        list<Unit_Category_Details__c> lstUnitCategoryFromUrID = new list<Unit_Category_Details__c>();
        set<string> setofUnitCategoryToMdt = new set<string>{'Common','URID'};
        set<string> setofUnitCategory = new set<string>();
        set<id> setOfUserReqID = new set<id>();
        set<id> setOfUserRequirementID = new set<id>();
        list<task> lstTask = new list<task>();
        list<User_Requirement_ID__c> lstOfUserRequirementID = new list<User_Requirement_ID__c>();
        map<String,User> mapNameVsUser = new map<String,User>();
        list<User> lstUser = [SELECT Id, FirstName, Name, IsActive 
                        FROM User 
                        Where IsActive = true ];
        if(lstUser!=null && !lstUser.isEmpty()){
            for(User eachUsers : lstUser){
                if(!mapNameVsUser.containsKey(eachUsers.Name)){
                    mapNameVsUser.put(eachUsers.Name,eachUsers);
                }
            }
        }
        if(triggerNew != null && !triggerNew.isEmpty()){
            for(User_Requirement_ID__c eachUserRequirement : triggerNew ){
                User_Requirement_ID__c oldUserReq = triggerOldMap.get(eachUserRequirement.id);
                if((isValueChange(eachUserRequirement,oldUserReq,'Max_Budget__c') ||
                   isValueChange(eachUserRequirement,oldUserReq,'Min_Budget__c') ||
                   isValueChange(eachUserRequirement,oldUserReq,'Weight_Max__c') ||
                   isValueChange(eachUserRequirement,oldUserReq,'Weight_Min__c') ||
                   isValueChange(eachUserRequirement,oldUserReq,'Max_Year__c') ||
                   isValueChange(eachUserRequirement,oldUserReq,'Min_Year__c') ||
                   isValueChange(eachUserRequirement,oldUserReq,'Min_Hours__c') ||
                   isValueChange(eachUserRequirement,oldUserReq,'Max_Hours__c') ||
                   isValueChange(eachUserRequirement,oldUserReq,'Brands__c') ||
                   isValueChange(eachUserRequirement,oldUserReq,'Attachment_options__c')) && eachUserRequirement.Status__c == 'Incomplete'
                    ){
                      // setOfUserReqIDCategory.add(eachUserRequirement.Category__c);
                       setOfUserReqID.add(eachUserRequirement.id);
                   }
                
                //Task for the User if WTB Date is changed and WTB priority is set.
                
    //if wtb date is changed and WTB priority is high then create a tasks for VA, President & Hardy
                if(isValueChange(eachUserRequirement,oldUserReq,'WTB_Date__c') && eachUserRequirement.WTB_Date__c !=null
                   && eachUserRequirement.WTB_Priority__c =='High (immediate WTB email)'){
                    if( mapNameVsUser.containsKey(system.label.VA)){
                        string subject = 'Send WTB email with parameters to equipment sellers, end users, dealers, and finance companies.';
                        subject += 'Responses will be sent to you to add to original opp as multiple units.';
                        task newTask =
                            CreateTask.createNewTask(subject,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                        newTask.Task_Type__c = 'Procurement';
                        newTask.Priority = 'High (2hrs or less)';
                        if(newTask!=null){
                            lstTask.add(newTask);
                            system.debug('lstTask:::'+lstTask);
                        }   
                        string subject1 = 'Post WTB on Iron Connect.If it is an ON ROAD truck, or a CRANE,'; 
                        subject1 += ' please DO NOT post on IronConnect,close task as not required.Matching units to be added to opp.';
                        task newTask1 =
                            CreateTask.createNewTask(subject1,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                        newTask1.Task_Type__c = 'Procurement';
                        newTask1.Priority = 'High (2hrs or less)';
                        if(newTask1!=null){
                            lstTask.add(newTask1);
                            system.debug('lstTask:::'+lstTask);
                        }
                           string subject2 = 'Post WTB on MT (crane trader or truck trader as needed), Mascus, Machinio,'; 
                        subject2 += 'Rock & Dirt, Construction Equipment Guide, and Used Equipment Guide. Matches to be added to opp.';
                        task newTask2 =
                            CreateTask.createNewTask(subject2,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                        newTask2.Task_Type__c = 'Procurement';
                        newTask2.Priority = 'High (2hrs or less)';
                        if(newTask2!=null){
                            lstTask.add(newTask2);
                            system.debug('lstTask:::'+lstTask);
                        }
                        string subject3 = 'Search CL, FB, auctions for WTB units; add auction units to live auction tab & other units to SF/opp'; 
                        task newTask3 =
                            CreateTask.createNewTask(subject3,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                        newTask3.Task_Type__c = 'Procurement';
                        newTask3.Priority = 'High (2hrs or less)';
                        if(newTask3!=null){
                            lstTask.add(newTask3);
                            system.debug('lstTask:::'+lstTask);
                        }
                    }
                       //Task for Collin Magliolo
                       if(mapNameVsUser.containsKey(system.label.President)){
                           string subject4 = ' Look for WTB: ';
                           subject4 += eachUserRequirement.WTB_Parameters__c;
                           task newTask4 =
                               CreateTask.createNewTask(subject4,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.President).id,'New');
                           newTask4.Task_Type__c = 'Procurement';
                           newTask4.Priority = 'High (2hrs or less)';
                           if(newTask4 != null){
                               lstTask.add(newTask4);
                               system.debug('lstTask:::'+lstTask);
                           } 
                       }
                       //Task for Hardy
                       if(mapNameVsUser.containsKey(system.label.Inside_Central)){
                           string subject5 = ' Look for WTB: ';
                           subject5 += eachUserRequirement.WTB_Parameters__c;
                           task newTask5 =
                               CreateTask.createNewTask(subject5,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                           newTask5.Task_Type__c = 'Procurement';
                           newTask5.Priority = 'High (2hrs or less)';
                           if(newTask5 != null){
                               lstTask.add(newTask5);
                               system.debug('lstTask:::'+lstTask);
                           }
                       }
                }
                
                 
                //if WTB date is changed and WTB priority is Medium then create a tasks for VA, President & Hardy
                if(isValueChange(eachUserRequirement,oldUserReq,'WTB_Date__c') && eachUserRequirement.WTB_Date__c != null
                   && eachUserRequirement.WTB_Priority__c =='Medium (include w/ weekly WTB)'){
                       if( mapNameVsUser.containsKey(system.label.VA)){
                           string subject = 'Add to weekly WTB email list; matches to be added directly to the opportunity.';
                           task newTask =
                               CreateTask.createNewTask(subject,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask.Task_Type__c = 'Procurement';
                           if(newTask!=null){
                               lstTask.add(newTask);
                               system.debug('lstTask:::'+lstTask);
                           }   
                           string subject1 = 'Post WTB on Iron Connect.If it is an ON ROAD truck, or a CRANE,'; 
                           subject1 += ' please DO NOT post on IronConnect,close task as not required.Matching units to be added to opp.';
                           task newTask1 =
                               CreateTask.createNewTask(subject1,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask1.Task_Type__c = 'Procurement';
                           if(newTask1!=null){
                               lstTask.add(newTask1);
                               system.debug('lstTask:::'+lstTask);
                           }
                           string subject2 = 'Post WTB on MT (crane trader or truck trader as needed), Mascus, Machinio,'; 
                           subject2 += 'Rock & Dirt, Construction Equipment Guide, and Used Equipment Guide. Matches to be added to opp.';
                           task newTask2 =
                               CreateTask.createNewTask(subject2,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask2.Task_Type__c = 'Procurement';
                           if(newTask2!=null){
                               lstTask.add(newTask2);
                               system.debug('lstTask:::'+lstTask);
                           }
                           string subject3 = 'Search CL, FB, auctions for WTB units; add auction units to live auction tab & other units to SF/opp'; 
                           task newTask3 =
                               CreateTask.createNewTask(subject3,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask3.Task_Type__c = 'Procurement';
                           if(newTask3!=null){
                               lstTask.add(newTask3);
                               system.debug('lstTask:::'+lstTask);
                           }
                       }
                       //Task for Collin Magliolo
                       if(mapNameVsUser.containsKey(system.label.President)){
                           string subject4 = ' Look for WTB: ';
                           subject4 += eachUserRequirement.WTB_Parameters__c;
                           task newTask4 =
                               CreateTask.createNewTask(subject4,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.President).id,'New');
                           newTask4.Task_Type__c = 'Procurement';
                           if(newTask4 != null){
                               lstTask.add(newTask4);
                               system.debug('lstTask:::'+lstTask);
                           } 
                       }
                       //Task for Hardy
                       if(mapNameVsUser.containsKey(system.label.Inside_Central)){
                           string subject5 = ' Look for WTB: ';
                           subject5 += eachUserRequirement.WTB_Parameters__c;
                           task newTask5 =
                               CreateTask.createNewTask(subject5,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                           newTask5.Task_Type__c = 'Procurement';
                           if(newTask5 != null){
                               lstTask.add(newTask5);
                               system.debug('lstTask:::'+lstTask);
                           }
                       }
                   }
                   //if wtb date is changed and WTB priority is Low then create a tasks for VA
                if(isValueChange(eachUserRequirement,oldUserReq,'WTB_Date__c') && eachUserRequirement.WTB_Date__c != null
                   && eachUserRequirement.WTB_Priority__c =='Low (Post on iron sites only)' ){
                       if(mapNameVsUser.containsKey(system.label.VA)){
                           string subject = 'Post WTB on Iron Connect.If it is an ON ROAD truck, or a CRANE,';
                           subject += ' please DO NOT post on IronConnect,close task as not required.Matching units to be added to opp.';
                           task newTask =
                               CreateTask.createNewTask(subject,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask.Task_Type__c = 'Procurement';
                           if(newTask != null){
                               lstTask.add(newTask);
                               system.debug('lstTask:::'+lstTask);
                           }
                           
                            string subject1 = ' Post WTB on MT (crane trader or truck trader as needed), Mascus, Machinio,';
                           subject1 += 'Rock & Dirt, Construction Equipment Guide, and Used Equipment Guide. Matches to be added to opp.';
                           task newTask1 =
                               CreateTask.createNewTask(subject1,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask1.Task_Type__c = 'Procurement';
                           if(newTask1 != null){
                               lstTask.add(newTask1);
                               system.debug('lstTask:::'+lstTask);
                           }
                           string subject2 = ' Search CL, FB, auctions for WTB units; add auction units to live auction tab & other units to SF/opp';
                           task newTask2 =
                               CreateTask.createNewTask(subject2,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask2.Task_Type__c = 'Procurement';
                           if(newTask2 != null){
                               lstTask.add(newTask2);
                               system.debug('lstTask:::'+lstTask);
                           }
                       }
                       if(mapNameVsUser.containsKey(system.label.President)){
                           string subject3 = ' Look for WTB: ';
                           subject3 += eachUserRequirement.WTB_Parameters__c;
                           task newTask3 =
                               CreateTask.createNewTask(subject3,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.President).id,'New');
                           newTask3.Task_Type__c = 'Procurement';
                           newTask3.Priority = 'Low (On Due Date)';
                           if(newTask3 != null){
                               lstTask.add(newTask3);
                               system.debug('lstTask:::'+lstTask);
                           } 
                       }
                       if(mapNameVsUser.containsKey(system.label.Inside_Central)){
                           string subject4 = ' Look for WTB: ';
                           subject4 += eachUserRequirement.WTB_Parameters__c;
                           task newTask4 =
                               CreateTask.createNewTask(subject4,eachUserRequirement.Id,null,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                           newTask4.Task_Type__c = 'Procurement';
                           newTask4.Priority = 'Low (On Due Date)';
                           if(newTask4 != null){
                               lstTask.add(newTask4);
                               system.debug('lstTask:::'+lstTask);
                           } 
                       }
                   }
                  //If WTB status is changed to Requested and is not null then Update record
                if(isValueChange(eachUserRequirement,oldUserReq,'WTB_Status__c') && 
                   eachUserRequirement.WTB_Status__c == 'WTB Requested'){
                    User_Requirement_ID__c newUserRequirementID = new User_Requirement_ID__c();
                    newUserRequirementID.id = eachUserRequirement.id;
                    newUserRequirementID.WTB_Date__c = system.today();
                    newUserRequirementID.WTB_Status__c = 'WTB In Process';
					lstOfUserRequirementID.add(newUserRequirementID); 
                } 
                 //If WTB status is changed to Completed and is not null then Update Date.
                if(isValueChange(eachUserRequirement,oldUserReq,'WTB_Status__c') && eachUserRequirement.WTB_Status__c == 'WTB Completed'){
                    User_Requirement_ID__c newUserRequirementID = new User_Requirement_ID__c();
                    newUserRequirementID.id = eachUserRequirement.id;
                    newUserRequirementID.WTB_Date__c = null;
					lstOfUserRequirementID.add(newUserRequirementID); 
                }
            }
        }
        
        if(lstTask != null && !lstTask.isEmpty()){
            system.debug('lstTask:::'+lstTask);
            Insert lstTask;
        }
        
        if(lstOfUserRequirementID != null && !lstOfUserRequirementID.isEmpty()){
            system.debug('lstOfUserRequirementID:::'+lstOfUserRequirementID);
            update lstOfUserRequirementID;
        }
        
        
        if(setOfUserReqID != null && !setOfUserReqID.isEmpty()){
            lstUnitCategoryFromUrID = [SELECT id, Unit__c,User_Requirement_ID__c,isActive__c,RecordTypeId,Category_Details__c
                                       FROM Unit_Category_Details__c 
                                       WHERE User_Requirement_ID__c in :setOfUserReqID AND Unit__c = null 
                 					   AND User_Requirement_ID__c != null AND isActive__c = true ];
        }
         if(lstUnitCategoryFromUrID!=null && !lstUnitCategoryFromUrID.isEmpty()){
             for(Unit_Category_Details__c eachUnitCategory : lstUnitCategoryFromUrID){
                   if(string.isNotBlank(eachUnitCategory.Category_Details__c)){
                    setofUnitCategoryToMdt.add(eachUnitCategory.Category_Details__c); 
                    setofUnitCategory.add(eachUnitCategory.Category_Details__c);
                }
                 if(string.isnotblank(eachUnitCategory.User_Requirement_ID__c)){
                     setOfUserRequirementID.add(eachUnitCategory.User_Requirement_ID__c);
                 }
             }
         }
            //Here we called future method to create iron demand record if not exist.
        if(setOfUserRequirementID!=null && !setOfUserRequirementID.isEmpty() && setofUnitCategoryToMdt!=null && !setofUnitCategoryToMdt.isEmpty() 
            && setofUnitCategory!=null && !setofUnitCategory.isEmpty()  ){
                system.debug('Future method called:::');
            UnitCategoryDetailsFutureClass.FutureUnitCategoryDetails(setOfUserRequirementID,setofUnitCategoryToMdt,setofUnitCategory,null);
        }
        
    }
    //This method is used to add contact Id on UserRequirementId record if any opp/lead id is tagged
    private static void handleBeforeInsert(List<User_Requirement_ID__c> triggerNew){
        system.debug('before insert ');
        set<id> setOfLeadId = new set<id>();
        set<id> setOfOppId = new set<id>();
        Map<id,id> mapOfleadIdVsContactId = new  Map<id,id>();
        Map<id,id> mapOfOppIdVsContactId = new  Map<id,id>{};
            list<lead> lstLead;
        map<id,lead> mapOfLeadIdVsLead;
        map<id,opportunity> mapOfOppIdVsopportunity;
        list<opportunity> lstOpp;
        if(triggerNew!=null && !triggerNew.isEmpty()){
            for(User_Requirement_ID__c eachUserRequirement : triggerNew){
                system.debug('leadid::'+eachUserRequirement.Lead__c);
                if(string.isBlank(eachUserRequirement.Contact__c)){
                    if(string.isNotBlank(eachUserRequirement.Lead__c) ){
                        setOfLeadId.add(eachUserRequirement.Lead__c);
                        system.debug('setOfLeadId::'+setOfLeadId);
                    }
                    else if(string.isNotBlank(eachUserRequirement.Opportunity__c) ){
                        setOfOppId.add(eachUserRequirement.Opportunity__c);
                        system.debug('setOfOppId::'+setOfOppId);
                    }
                }
                if(eachUserRequirement.Status__c == 'Complete'){
                    eachUserRequirement.Status__c.addError('Status Can\'t be Complete');
                }
                
                
            }
        }
        if(setOfLeadId!=null && !setOfLeadId.isEmpty()){
            mapOfLeadIdVsLead = new map<id,lead>([SELECT id,contact__c
                                                  FROM lead 
                                                  WHERE id in : setOfLeadId]);
        }
        system.debug('lstLead:::'+lstLead);
        system.debug('mapOfLeadIdVsLead:::'+mapOfLeadIdVsLead);
        
        if(setOfOppId!=null && !setOfOppId.isEmpty()){
            mapOfOppIdVsopportunity = new map<id,opportunity>([SELECT id,ContactId,Buyer_Primary_Contact__c
                                                               FROM opportunity 
                                                               WHERE id in : setOfOppId]);
        }
        system.debug('mapOfOppIdVsopportunity:::'+mapOfOppIdVsopportunity);
        /*system.debug('lstOpp:::'+lstOpp);
if(lstLead != null && !lstLead.isEmpty()){
for(lead eachLead : lstLead ){
if(string.isNotBlank(eachLead.Contact__c) && !mapOfleadIdVsContactId.containskey(eachLead.Id)){
mapOfleadIdVsContactId.put(eachLead.Id,eachLead.Contact__c);
}
}
}
if(lstOpp != null && !lstOpp.isEmpty()){
for(opportunity eachOpp : lstOpp ){
if(string.isNotBlank(eachOpp.ContactId) && !mapOfOppIdVsContactId.containskey(eachOpp.Id)){
mapOfOppIdVsContactId.put(eachOpp.Id,eachOpp.ContactId);
}
}
}*/
        system.debug('mapOfleadIdVsContactId::'+mapOfleadIdVsContactId);
        system.debug('values:::'+mapOfleadIdVsContactId.values());
        if(triggerNew!=null && !triggerNew.isEmpty()){
            for(User_Requirement_ID__c eachUserRequirement : triggerNew){
                system.debug('eachUserRequirement:::'+eachUserRequirement);
                if(string.isblank(eachUserRequirement.contact__c)){
                    if(string.isNotBlank(eachUserRequirement.Lead__c) && mapOfLeadIdVsLead.containsKey(eachUserRequirement.Lead__c) &&
                       string.isNotBlank(mapOfLeadIdVsLead.get(eachUserRequirement.Lead__c).contact__c) ){
                           system.debug('contact id is blank');
                           eachUserRequirement.Contact__c = mapOfLeadIdVsLead.get(eachUserRequirement.Lead__c).contact__c;
                           system.debug('eachUserRequirement.Contact__c::'+mapOfLeadIdVsLead.get(eachUserRequirement.Lead__c).contact__c);
                       }
                    else if(string.isNotBlank(eachUserRequirement.Opportunity__c) && mapOfOppIdVsopportunity.containsKey(eachUserRequirement.Opportunity__c)
                            && string.isNotBlank(mapOfOppIdVsopportunity.get(eachUserRequirement.Opportunity__c).Buyer_Primary_Contact__c)){
                                eachUserRequirement.Contact__c = mapOfOppIdVsopportunity.get(eachUserRequirement.Opportunity__c).Buyer_Primary_Contact__c;
                                system.debug('eachUserRequirement.Contact__c:::'+eachUserRequirement.Contact__c);
                            }   
                }
                
                if(string.isNotBlank(eachUserRequirement.Lead__c) && string.isBlank(eachUserRequirement.Opportunity__c)){
                    string name = 'Lead'+' ';
                    if(string.isnotblank(eachUserRequirement.Category__c)){
                        name += eachUserRequirement.Category__c + ' '; 
                    }
                    name += eachUserRequirement.Name;  
                    if(string.isnotblank(name)){
                        system.debug('eachUserRequirement.Name:::'+eachUserRequirement.Name);
                        eachUserRequirement.Name = name;
                        system.debug('name::'+name);
                    }
                }
                if(string.isNotBlank(eachUserRequirement.Opportunity__c) && string.isBlank(eachUserRequirement.Lead__c)){
                   string name = 'Opportunity'+' ';
                    if(string.isnotblank(eachUserRequirement.Category__c)){
                        name += eachUserRequirement.Category__c + ' '; 
                    }
                    name += eachUserRequirement.Name;  
                    if(string.isnotblank(name)){
                        system.debug('eachUserRequirement.Name:::'+eachUserRequirement.Name);
                        eachUserRequirement.Name = name;
                        system.debug('name::'+name);
                    }  
                }
                if(string.isnotblank(eachUserRequirement.Contact__c) && string.isBlank(eachUserRequirement.Opportunity__c)
                   && string.isBlank(eachUserRequirement.Lead__c)){
                    string name = 'Contact'+' ';
                    if(string.isnotblank(eachUserRequirement.Category__c)){
                        name += eachUserRequirement.Category__c + ' '; 
                    }
                    name += eachUserRequirement.Name;  
                    if(string.isnotblank(name)){
                        system.debug('eachUserRequirement.Name:::'+eachUserRequirement.Name);
                        eachUserRequirement.Name = name;
                        system.debug('name::'+name);
                    }
                }
                
                
                
            }
        }
    }
    //This method is used to Created unit category Details record 
    public static Unit_Category_Details__c createUnitCategory(Id recordTypeId , Id userRequirementID,string category,string name){
        Unit_Category_Details__c newUnitCategory = new Unit_Category_Details__c();
        if(string.isnotblank(RecordTypeId) && string.isnotblank(UserRequirementID) && string.isnotblank(category)){
            newUnitCategory.Name ='UserRequirementID - '+Name;
            newUnitCategory.RecordTypeId = RecordTypeId;
            newUnitCategory.User_Requirement_ID__c = UserRequirementID;
            newUnitCategory.Category_Details__c = category;
            system.debug('Unit_Category_Details__c::'+newUnitCategory);
        }
        return newUnitCategory;
    }
    
      private static Boolean isValueChange(sObject newValue, sObject oldValue,String fieldName){
        return newValue.get(FieldName) != oldValue.get(FieldName);
    }
    
}