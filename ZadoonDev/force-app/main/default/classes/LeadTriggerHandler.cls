public class LeadTriggerHandler implements ITriggerHandler{
    private static final string DEVELOPER_NAME = 'lead';
     public Trigger_Setting__mdt setTriggerSettings() {
       
        return [select Active__c,Max_Loop_Count__c,Stop_Recursion__c FROM Trigger_Setting__mdt 
                Where DeveloperName=:DEVELOPER_NAME LIMIT 1];
    
    } 
    
    Public void beforeInsert(List<SObject> triggerNew){
        
            handleBeforeInsert((list<Lead>)triggerNew);
    }
    //By implementing this method trigger can handle all the before Update events
    Public void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){
       handleBeforeUpdate((list<Lead>)triggerNew,
                          (Map<Id,Lead>)triggerOldMap);
     }
    //By implementing this method trigger can handle all the before Delete events
    Public void beforeDelete(List<SObject> triggerOld){
        
    }   
    //By implementing this method trigger can handle all the after Insert events
    Public void afterInsert(List<SObject> triggerNew){
        HandleIronDemandOnInsert((list<Lead>)triggerNew);
        HandleLeadAfterInsert((list<Lead>)triggerNew);
        //It will calulate the no of lead under that unit.
        CalculateNoOfLeads(triggerNew);
    }
    //By implementing this method trigger can handle all the after Update events
    Public void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){
        HandleIronDemandCreationOnUpdate((list<Lead>)triggerNew,
                                        	(Map<Id,Lead>)triggerOldMap);
        
        handleNoOfActiveLeadOnUpdate((list<Lead>)triggerNew,
                                    (Map<Id,Lead>)triggerOldMap);
        HandleLeadAfterUpdate((list<Lead>)triggerNew,(Map<Id,Lead>)triggerOldMap);
        
        
    }
    //By implementing this method trigger can handle all the after Delete events
    Public void afterDelete(List<SObject> triggerOld){
        CalculateNoOfLeads(triggerOld);
    }
    //By implementing this method trigger can handle all the after UnDelete events
    Public void afterUndelete(List<SObject> triggerNew){
        //It will calulate the no of lead under that unit.
        CalculateNoOfLeads(triggerNew);
    }
    
    private static void calculateNoOfLeads(
        List<Lead> leads
    ){
        set<id> setOfUnitId = new set<id>();
        map<id,list<Lead>> mapOfUnitIdVsListOfOpenLead = new map <id,list<Lead>>();
        map<id,list<Lead>> mapOfUnitIdVsListOfClosedLead = new map <id,list<Lead>>();
        map<id,list<Lead>> mapOfUnitIdVsListOfActiveLead = new map <id,list<Lead>>();
        if(leads!=null && !leads.isEmpty()){
            for(lead eachLead : leads){
                if(string.isNotBlank( eachLead.Unit__c)){
                    setOfUnitId.add(eachLead.Unit__c);
                }
            }
        }
        if(setOfUnitId!=null && !setOfUnitId.isEmpty()){
            list<Product2>lstUnit = [SELECT id, name, 
                                        Number_of_Active_leads__c ,Number_of_Closed_leads__c,Number_of_Open_leads__c,
                                        (SELECT id,Name,Status,IsConverted,Unit__c FROM Leads__r)//WHERE Status!='Unqualified' AND IsConverted !=True) 
                                        FROM Product2 
                                        WHERE id IN :setOfUnitId];
            
            
            if(lstUnit != null && !lstUnit.isempty()){
                for(Product2 eachUnit : lstUnit){
                    if(eachUnit.Leads__r!=null && !eachUnit.Leads__r.isEmpty()){
                        for(lead eachLead : eachUnit.Leads__r){
                            if(eachLead.status != 'Qualified'){
                                if(!mapOfUnitIdVsListOfOpenLead.containsKey(eachLead.Unit__c)){
                                    mapOfUnitIdVsListOfOpenLead.put(eachLead.Unit__c,new list<Lead>());
                                    mapOfUnitIdVsListOfOpenLead.get(eachLead.Unit__c).add(eachLead);
                                }else{
                                    mapOfUnitIdVsListOfOpenLead.get(eachLead.Unit__c).add(eachLead);
                                }
                            }else If(eachLead.status == 'Qualified'){
                                if(!mapOfUnitIdVsListOfClosedLead.containsKey(eachLead.Unit__c)){
                                    mapOfUnitIdVsListOfClosedLead.put(eachLead.Unit__c,new list<Lead>());
                                    mapOfUnitIdVsListOfClosedLead.get(eachLead.Unit__c).add(eachLead);
                                }else{
                                    mapOfUnitIdVsListOfClosedLead.get(eachLead.Unit__c).add(eachLead);
                                }
                            }
                            if(eachLead.Status!='Unqualified' && eachLead.IsConverted !=True){
                               if(!mapOfUnitIdVsListOfActiveLead.containsKey(eachLead.Unit__c)){
                                    mapOfUnitIdVsListOfActiveLead.put(eachLead.Unit__c,new list<Lead>());
                                    mapOfUnitIdVsListOfActiveLead.get(eachLead.Unit__c).add(eachLead);
                                }else{
                                    mapOfUnitIdVsListOfActiveLead.get(eachLead.Unit__c).add(eachLead);
                                } 
                            }
                        }
                        
                    }
                    if(mapOfUnitIdVsListOfActiveLead.get(eachUnit.id)!=null 
                       && !mapOfUnitIdVsListOfActiveLead.get(eachUnit.id).isEmpty()){
                        eachUnit.Number_of_Active_leads__c = mapOfUnitIdVsListOfActiveLead.get(eachUnit.id).size();
                    }
                    if(mapOfUnitIdVsListOfClosedLead.get(eachUnit.id)!=null 
                       && !mapOfUnitIdVsListOfClosedLead.get(eachUnit.id).isEmpty()){
                        eachUnit.Number_of_Closed_leads__c = mapOfUnitIdVsListOfClosedLead.get(eachUnit.id).size();
                    }
                    if(mapOfUnitIdVsListOfOpenLead.get(eachUnit.id)!=null 
                       && !mapOfUnitIdVsListOfOpenLead.get(eachUnit.id).isEmpty()){
                        eachUnit.Number_of_Open_leads__c = mapOfUnitIdVsListOfOpenLead.get(eachUnit.id).size();
                    }
                    
                }
            }
            if(lstUnit != null && lstUnit.size()>0){    
                update lstUnit;
                
            }
        }
    }
    private static void HandleIronDemandOnInsert(
        List<Lead> leads
    ){
        set<Id>setOfLeadId = new set<Id>();
        set<Id>setOfContactId = new set<Id>();
        set<Id> setOfEquipmemtId = new set<Id>();
        List<Lead> filteredLeads = new List<Lead>();
        //Map<string,Lead> mapOfStringVsLead = new map<string,Lead>(); 
        map<string, Iron_Demand__c> mapOfStringVsIronDemand = new map<string,Iron_Demand__c>();
        for(Lead ld : leads){
            if(ld.Contact__c != null && ld.Unit__c != null){
                //filteredLeads.add(ld);
                setOfContactId.add(ld.Contact__c);
                setOfLeadId.add(ld.id);
                
            }
        }
        
        list<Lead> lstLead = [SELECT id,
                              Contact__c,
                              Unit__c, 
                              unit__r.equipment__c FROM
                              lead WHERE 
                              id IN :setOfLeadId ];
        
        if(lstLead!=null && !lstLead.isEmpty()){
            for(lead eachLead :lstLead ){
                
                setOfEquipmemtId.add(eachLead.unit__r.equipment__c);
            }
        }
        system.debug('setOfContactId:::'+setOfContactId);
        system.debug('setOfEquipmemtId:::'+setOfEquipmemtId);
        list<Iron_Demand__c> lstIronDemand = [SELECT Id,
                                              IronDemand_Contact__c,
                                              IronDemand_Iron__c 
                                              FROM Iron_Demand__c 
                                              WHERE IronDemand_Contact__c IN : setOfContactId 
                                              AND IronDemand_Iron__c IN :setOfEquipmemtId];
        system.debug('lstIronDemand:::'+lstIronDemand);
        
        if(lstIronDemand!=null && !lstIronDemand.isEmpty()){
            for(Iron_Demand__c eachIronDemand : lstIronDemand){
                string IronDemandcontactIdEquipmentID;
                IronDemandcontactIdEquipmentID = String.valueOf(eachIronDemand.IronDemand_Contact__c) + String.valueOf(eachIronDemand.IronDemand_Iron__c);
                
                mapOfStringVsIronDemand.put(IronDemandcontactIdEquipmentID,eachIronDemand);
            }
            
        }
        
        if(lstLead!=null && !lstLead.isEmpty()){
            for(lead eachLead : lstLead){
                string contactIdEquipmentID;
                contactIdEquipmentID = String.valueOf(eachLead.Contact__c) + String.valueOf(eachLead.unit__r.equipment__c);
                
                if(!mapOfStringVsIronDemand.containsKey(contactIdEquipmentID)){
                    filteredLeads.add(eachLead);
                }
            }
        }
        if(filteredLeads.size()> 0){
            //createIronDemandsFromLeads(filteredLeads);
        }
    }
    
    private static void HandleLeadAfterInsert( List<Lead> leads){
        set<id> setOfUnitId = new set<id>();
        map<id,product2> mapOfIdVsUnit;
        map<string,user> mapofnamevsuser = new map<string,user>();
        list<task> lstTaskToInsert = new list<task>();
        if(leads!=null && !leads.isEmpty()){
            for(Lead eachLead : leads){
                if(string.isnotblank(eachLead.Unit__c)){
                    setOfUnitId.add(eachLead.Unit__c);
                }
            }  
        }
        system.debug('setOfUnitId:::'+setOfUnitId);
        if(setOfUnitId!=null && !setOfUnitId.isEmpty()){
            mapOfIdVsUnit = new map<id,product2>([SELECT id,Display_Lowest_Purchase_Price__c,Unit_Stage__c,IsActive,Starting_Advertised_Retail_Price__c
                                                  FROM product2 WHERE id in:setOfUnitId]);
        }
        Id procurementRecordTypeId;
        if(string.isNotBlank(system.label.Lead_Record_Type_Procurement_lead)){
            procurementRecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
                .get(label.Lead_Record_Type_Procurement_lead).getRecordTypeId();
        }
        system.debug('mapOfIdVsUnit:::'+mapOfIdVsUnit);
        //user newuser;
        list<User> lstUser = [SELECT id,name,username,isactive 
                              FROM User 
                              WHERE isActive = true];
        if(lstUser!=null && !lstUser.isEmpty()){
            for(user eachuser : lstUser){
                if(!mapofnamevsuser.containskey(eachuser.name)){
                   mapofnamevsuser.put(eachuser.name,eachuser);
                }
            }
        }
        
        if(leads!=null && !leads.isEmpty()){
            for(Lead eachLead : leads){
                /*if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId && 
                   string.isnotblank(eachLead.Unit__c) && mapOfIdVsUnit.containsKey(eachLead.Unit__c) && eachLead.Status != 'Eval Required' 
                   && mapOfIdVsUnit.get(eachLead.Unit__c).Unit_Stage__c =='Potential trade'){
                       product2 newProduct = mapOfIdVsUnit.get(eachLead.Unit__c);
                       //Two Task for shelly when Lead is created and unit is associated with it
                       if(mapofnamevsuser.containskey(system.label.VA)){
                           string subject ='Google S/N to see if marketed';
                           string subject1 = 'Search SN on TopBid to confirm year';
                           task newTask= CreateTask.createNewTask(subject,eachLead.Unit__c,null,system.today(),mapofnamevsuser.get(system.label.VA).id,'New');
                           task newTask1 = CreateTask.createNewTask(subject1,eachLead.Unit__c,null,system.today(),mapofnamevsuser.get(system.label.VA).id,'New');
                           if(newTask!=null){
                               lstTaskToInsert.add(newTask);
                           }
                           if(newTask1!=null){
                               lstTaskToInsert.add(newTask1);
                           }
                       }
                   }*/
                    /*//Task for Shelly when Unit contains seller price & Buyer price
                    if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId && string.isnotblank(eachLead.Unit__c)
                       && mapOfIdVsUnit.get(eachLead.Unit__c).Unit_Stage__c =='Potential trade' &&
                       eachLead.Status != 'Eval Required' &&
                       mapOfIdVsUnit.get(eachLead.Unit__c).Display_Lowest_Purchase_Price__c !=null  
                       && mapOfIdVsUnit.get(eachLead.Unit__c).Starting_Advertised_Retail_Price__c !=null 
                       && mapofnamevsuser.containskey(system.label.VA) ){
                           string subject = 'Send matching email ';
                        task newTask= CreateTask.createNewTask(subject,eachLead.Unit__c,null,system.today(),mapofnamevsuser.get(system.label.VA).id,'New'); 
                           if(newTask!=null){
                               lstTaskToInsert.add(newTask);
                           }
                       }*/
                    
             /*system.debug('eachLead.statuscnew:::'+eachLead.status);
                //if lead stage is Eval required,and product id is not null then create a task for VA
                if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId && 
                   eachLead.status == 'Eval Required' 
                   && mapofnamevsuser.containskey(system.label.VA) 
                   && string.isnotblank(eachLead.Unit__c)){
                       system.debug('enter in Eval Required stage');
                       string subject = 'Run manual evaluation';
                       task newTask = 
                           CreateTask.createNewTask(subject,null,eachLead.Id,system.today(),mapofnamevsuser.get(system.label.VA).id,'New');
                       if(newTask!=null){
                           lstTaskToInsert.add(newTask);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       } 
                   }
                    
                    //create a task when buy price is not null
                     if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId && string.isnotblank(eachLead.Unit__c) && 
                        mapOfIdVsUnit.get(eachLead.Unit__c).Display_Lowest_Purchase_Price__c !=null
                            && mapOfIdVsUnit.get(eachLead.Unit__c).Starting_Advertised_Retail_Price__c ==null ){
                      string subject = 'Set Sell Price on the Unit';  
                       task newTask= CreateTask.createNewTask(subject,eachLead.Unit__c,null,system.today(),eachLead.OwnerId,'New');
                        if(newTask!=null){
                           lstTaskToInsert.add(newTask);
                            system.debug('lstTaskToInsert:::'+lstTaskToInsert);
                        }
                    }
                    //Create a task for lead owner when stage of unit is Potential trade or unit is active
                     if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId && string.isnotblank(eachLead.Unit__c) &&
                        mapOfIdVsUnit.get(eachLead.Unit__c).Display_Lowest_Purchase_Price__c ==null 
                            && (mapOfIdVsUnit.get(eachLead.Unit__c).Unit_Stage__c !='Potential trade' && mapOfIdVsUnit.get(eachLead.Unit__c).IsActive == true)){
                                string subject = 'Obtain Buy price on Unit ';  
                                 task newTask = CreateTask.createNewTask(subject,eachLead.Unit__c,null,system.today(),eachLead.OwnerId,'New');
                                if(newTask!=null){
                                  lstTaskToInsert.add(newTask);
                                    system.debug('newTask::'+newTask);
                                }
                            }
                    //When Outbound Relevant Checkbox is checked
                    if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId && string.isnotblank(eachLead.Unit__c) &&
                       string.isnotblank(eachLead.Unit__c) && mapOfIdVsUnit.get(eachLead.Unit__c).Unit_Stage__c =='Potential trade' 
                       && eachLead.Status == 'Eval Required' && string.isnotblank(eachLead.Evaluation_Output__c) && eachLead.Output_Relevant__c == true ){
                           string subject = 'Review Manual Evaluation ';
                           string subject1 = 'Complete Rouse Evaluation if required ';
                           task newTask = CreateTask.createNewTask(subject,null,eachLead.id,system.today(),eachLead.OwnerId,'New');
                           system.debug('newTask:::'+newTask);
                           task newTask1 = CreateTask.createNewTask(subject1,null,eachLead.id,system.today(),eachLead.OwnerId,'New');
                           system.debug('newTask1:::'+newTask1);
                           if(newTask!=null){
                               lstTaskToInsert.add(newTask);
                           }
                           if(newTask1!=null){
                               lstTaskToInsert.add(newTask1);
                           }
                           if(mapofnamevsuser.containskey(system.label.VA)) {
                               if(mapOfIdVsUnit.get(eachLead.Unit__c).Display_Lowest_Purchase_Price__c !=null
                                  && mapOfIdVsUnit.get(eachLead.Unit__c).Starting_Advertised_Retail_Price__c !=null ){
                                      string subject2 = 'Send matching email ';
                                      task newTask2= CreateTask.createNewTask(subject2,eachLead.Unit__c,null,system.today(),mapofnamevsuser.get(system.label.VA).id,'New'); 
                                      if(newTask2!=null){
                                          lstTaskToInsert.add(newTask2);
                                      }
                                  }
                               string subject3 ='Google S/N to see if marketed';
                               string subject4 = 'Search SN on TopBid to confirm year';
                               task newTask3= CreateTask.createNewTask(subject3,eachLead.Unit__c,null,system.today(),mapofnamevsuser.get(system.label.VA).id,'New');
                               task newTask4 = CreateTask.createNewTask(subject4,eachLead.Unit__c,null,system.today(),mapofnamevsuser.get(system.label.VA).id,'New');
                               if(newTask3!=null){
                                   lstTaskToInsert.add(newTask3);
                               }
                               if(newTask4!=null){
                                   lstTaskToInsert.add(newTask4);
                               }
                           }
                       } */
                
                
                   /* //if lead stage is Reviewing, then create 4 tasks for VA(shelly).
                 system.debug('eachLead.status:::'+eachLead.status);
                if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId && 
                   eachLead.Status == 'Reviewing' 
                   && mapofnamevsuser.containskey(system.label.VA) 
                  ){
                       system.debug('Enter in reviewing stage');
                       string subject3 = 'Create Unit';
                       task newTask3 = 
                           CreateTask.createNewTask(subject3,null,eachLead.Id,system.today(),mapofnamevsuser.get(system.label.VA).id,'New');
                       newTask3.Description = 'create unit and edit/organize/rename photos, Serial Number Photo to be moved to confidential info folder,';
                       newTask3.Description +=' update hours and S/N on unit record based on photos/details in lead';
                       if(newTask3!=null){
                           lstTaskToInsert.add(newTask3);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       }
                       string subject = 'Add any inspection reports to associated folder';
                       task newTask = 
                           CreateTask.createNewTask(subject,null,eachLead.Id,system.today(),mapofnamevsuser.get(system.label.VA).id,'New');
                       if(newTask!=null){
                           lstTaskToInsert.add(newTask);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       }
                       string subject1 = 'Confirm year via TopBid and add to field on unit page';
                       task newTask1 = 
                           CreateTask.createNewTask(subject1,null,eachLead.Id,system.today(),mapofnamevsuser.get(system.label.VA).id,'New');
                       if(newTask1!=null){
                           lstTaskToInsert.add(newTask1);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       }
                       string subject2 = 'Associate the unit and lead with appropriate seller info; check for existing accounts for the seller and create A/C if needed.';
                       task newTask2 = 
                           CreateTask.createNewTask(subject2,null,eachLead.Id,system.today(),mapofnamevsuser.get(system.label.VA).id,'New');
                       if(newTask2!=null){
                           lstTaskToInsert.add(newTask2);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       }
                   }*/
            }
        }
        if(lstTaskToInsert!=null && !lstTaskToInsert.isEmpty()){
            system.debug('lstTaskToInsert::'+lstTaskToInsert);
            insert lstTaskToInsert;
            system.debug('lstTaskToInsert::'+lstTaskToInsert);
        }
       
    }
    
    //This method is used to create task when lead unit is updated
    public static void HandleLeadAfterUpdate(
        List<Lead> leads,
        Map<Id, Lead> oldLeadMap){
            system.debug('enter in after update:::');
            map<id,product2> mapOfIdVsUnit;
            list<task> lstTaskToInsert = new list<task>();
            map<String,User> mapNameVsUser = new map<String,User>();
            //set<lead> setOfLead = new set<lead>();
            set<id> setOfUnitId = new set<id>();
            set<id> setOfConvertedLeadId = new set<id>();
            map<id,id> mapOfLeadIDVsOppId = new map<id,id>();
            list<User> newUser  = new list<user>();
            list<lead> lstLeadToUpdate = new list<lead>();
            list<product2> lstProduct = new list<product2>();
            list<User_Requirement_ID__c> lstUserReqId = new list<User_Requirement_ID__c>();
            list<User_Requirement_ID__c> lstUserReqToUpdate = new list<User_Requirement_ID__c>();
            map<id,string> mapOfleadIDVsContactID = new map<id,string>();
            set<id> setOfLeadId = new set<id>();
            list<User_Requirement_ID__c> lstUserRequirement = new list<User_Requirement_ID__c>();
             list<User_Requirement_ID__c> lstUserRequirementTOupdate = new list<User_Requirement_ID__c>();
            list<iron_demand__c> lstIronDemandToUpdate = new list<iron_demand__c>();
            map<id,string> mapOfleadIDVsStatus = new map<id,string>();
            Id procurementRecordTypeId;
             map<id,id> mapofIronDemandIDVsUnitAccountId = new map<id,id>();
            if(string.isNotBlank(system.label.Lead_Record_Type_Procurement_lead)){
                procurementRecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
                    .get(label.Lead_Record_Type_Procurement_lead).getRecordTypeId();
            }
            Id SalesLead;
            if(string.isNotBlank(system.label.Lead_Record_Type_Sales_lead)){
                SalesLead =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
                    .get(label.Lead_Record_Type_Sales_lead).getRecordTypeId();
            }
              newUser = [SELECT id,name,username,Isactive
                        FROM User 
                        WHERE /*name =:system.label.VA AND */ Isactive = true
                        ];
            if(newUser!=null && !newUser.isEmpty()){
                for(user eachUser :newUser ){
                   mapNameVsUser.put(eachUser.Name,eachUser);
                }
            }
            if(leads!=null && !leads.isEmpty()){
                for(Lead eachLead : leads){
                    if((eachLead.Unit__c != oldLeadMap.get(eachLead.Id).Unit__c && string.isnotblank(eachLead.Unit__c))
                       || string.isnotblank(eachLead.Unit__c) ){
                        system.debug('enter in after update');
                        setOfUnitId.add(eachLead.Unit__c);
                    }
                    system.debug('eachLead.RecordTypeId:::'+eachLead.RecordTypeId);
                    if(eachLead.Contact__c!= oldLeadMap.get(eachLead.Id).Contact__c && string.isnotblank(eachLead.Contact__c)
                       && !mapOfleadIDVsContactID.containskey(eachLead.Id) && string.isnotblank(SalesLead) && eachLead.RecordTypeId==SalesLead){
                           mapOfleadIDVsContactID.put(eachLead.Id,eachLead.Contact__c);
                           setOfLeadId.add(eachLead.Id); 
                       }
                    
                     if(eachLead.Status!= oldLeadMap.get(eachLead.Id).Status /*&& eachLead.Status =='Unqualified'*/
                       && !mapOfleadIDVsStatus.containskey(eachLead.Id) && string.isnotblank(SalesLead) && eachLead.RecordTypeId==SalesLead){
                           mapOfleadIDVsStatus.put(eachLead.Id,eachLead.Status);
                           setOfLeadId.add(eachLead.Id); 
                       }
                    system.debug('eachLead.IsConverted:::'+eachLead.IsConverted);
                    system.debug('eachLead.ConvertedOpportunityId:::'+eachLead.ConvertedOpportunityId);
                    system.debug('eachLead.id::::'+eachLead.Id);
                    //If lead is converted then update User Requirement ID 
                    if(eachLead.IsConverted == true && string.isnotblank(eachLead.ConvertedOpportunityId) ){
                        system.debug('eachLead.IsConverted:::'+eachLead.IsConverted);
                        system.debug('eachLead.ConvertedOpportunityId:::'+eachLead.ConvertedOpportunityId);
                        system.debug('eachLead.id::::'+eachLead.Id);
                        setOfConvertedLeadId.add(eachLead.Id);
                        mapOfLeadIDVsOppId.put(eachLead.Id,eachLead.ConvertedOpportunityId);
                    }
                    system.debug('oldLeadMap.get(eachLead.Id).status:::'+oldLeadMap.get(eachLead.Id).status);
                    system.debug(' eachLead.status:::'+ eachLead.Status);
                    //if lead stage is changed and product id is null then create 4 tasks for VA(shelly).
                /*if( string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId &&
                   eachLead.Status != oldLeadMap.get(eachLead.Id).status &&
                   eachLead.Status == 'Reviewing' 
                   && mapNameVsUser.containskey(system.label.VA)){
                       system.debug('enter in reviewing stage');
                       string subject3 = 'Create Unit and check comments for more detail';
                       task newTask3 = 
                           CreateTask.createNewTask(subject3,null,eachLead.Id,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                       newTask3.Description = 'create unit and edit/organize/rename photos, Serial Number Photo to be moved to confidential info folder,';
                       newTask3.Description +=' update hours and S/N on unit record based on photos/details in lead';
                       if(newTask3!=null){
                           lstTaskToInsert.add(newTask3);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       }
                       string subject = 'Add any inspection reports to associated folder';
                       task newTask = 
                           CreateTask.createNewTask(subject,null,eachLead.Id,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                       if(newTask!=null){
                           lstTaskToInsert.add(newTask);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       }
                       string subject2 = 'Associate the unit and lead with appropriate seller info; check for existing accounts for the seller and create A/C if needed.';
                       task newTask2 = 
                           CreateTask.createNewTask(subject2,null,eachLead.Id,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                       if(newTask2!=null){
                           lstTaskToInsert.add(newTask2);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       }
                   }*/
                    
                    if( string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId &&
                   eachLead.Status != oldLeadMap.get(eachLead.Id).status &&
                   eachLead.Status == 'Pending Unit Addition' 
                   && mapNameVsUser.containskey(system.label.VA)){
                      
                      string subject4 = 'Create unit for this Procurement Lead and check comments for more detail';
                       task newTask7 = 
                           CreateTask.createNewTask(subject4,null,eachLead.Id,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                       newTask7.Description = '1) Create unit and edit/organize/rename photos, Serial Number Photo to be moved to confidential info folder,';
                       newTask7.Description +=' update hours and S/N on unit record based on photos/details in lead';//+ '\n' +
                       newTask7.Description += + '\n' +'2)Add any inspection reports to associated folder ';
                       newTask7.Description += + '\n' +'3) Associate the unit and lead with appropriate seller info; check for existing accounts for the seller and create A/C if needed.';
                       
                       if(newTask7!=null){
                           lstTaskToInsert.add(newTask7);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       } 
                       
                       
                       
                      /* system.debug('enter in reviewing stage');
                       string subject3 = 'Create Unit and check comments for more detail';
                       task newTask3 = 
                           CreateTask.createNewTask(subject3,null,eachLead.Id,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                       newTask3.Description = 'create unit and edit/organize/rename photos, Serial Number Photo to be moved to confidential info folder,';
                       newTask3.Description +=' update hours and S/N on unit record based on photos/details in lead';
                       if(newTask3!=null){
                           lstTaskToInsert.add(newTask3);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       }
                       string subject = 'Add any inspection reports to associated folder';
                       task newTask = 
                           CreateTask.createNewTask(subject,null,eachLead.Id,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                       if(newTask!=null){
                           lstTaskToInsert.add(newTask);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       }
                       string subject2 = 'Associate the unit and lead with appropriate seller info; check for existing accounts for the seller and create A/C if needed.';
                       task newTask2 = 
                           CreateTask.createNewTask(subject2,null,eachLead.Id,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                       if(newTask2!=null){
                           lstTaskToInsert.add(newTask2);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       }*/
                   }
                    if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId &&
                       eachLead.Status != oldLeadMap.get(eachLead.Id).status &&
                       eachLead.Status == 'Offer Pending Approval' &&
                       string.isnotblank(eachLead.Unit__c) && eachLead.Offer_Amount__c != null 
                       && string.isnotblank(eachLead.Evaluation_Output__c) && mapNameVsUser.containskey(system.label.Inside_Central)){
                           task newTask = 
                               CreateTask.createNewTask('Approve offer amount',null,eachLead.Id,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                           if(newTask!=null){
                               lstTaskToInsert.add(newTask);
                               system.debug('lstTaskToInser :::' + lstTaskToInsert);
                           } 
                       }
                    
                    
                    if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId &&
                       eachLead.Status != oldLeadMap.get(eachLead.Id).status &&
                       eachLead.Status == 'Offer Approved' &&
                       string.isnotblank(eachLead.Unit__c) ){
                           system.debug('enter in offer Approved:::');
                           lead newLead = new lead();
                           newLead.Id = eachLead.Id;
                           newLead.IsAmountLocked__c = true;
                           lstLeadToUpdate.add(newLead);
                       } 
                    
                //if lead stage is changed to Eval required,and product id is not null then create a task for VA
                if( string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId &&
                   eachLead.Status != oldLeadMap.get(eachLead.Id).Status &&
                   eachLead.Status == 'Eval Required' && mapNameVsUser.containskey(system.label.VA) && string.isnotblank(eachLead.Unit__c)){
                       system.debug('enter in Eval Required stage');
                       string subject = 'Run manual evaluation';
                       task newTask = 
                           CreateTask.createNewTask(subject,null,eachLead.Id,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                       if(newTask!=null){
                           lstTaskToInsert.add(newTask);
                           system.debug('lstTaskToInsert Shipping Dims :::' + lstTaskToInsert);
                       } 
                   }
                    
                    system.debug('procurementRecordTypeId::'+procurementRecordTypeId);
                    system.debug('eachLead.Status::'+eachLead.Status);
                    system.debug('eachLead.Unit__c::'+eachLead.Unit__c);
                    system.debug('eachLead.Deactivate_Unit_after_Lost_Lead__c::'+eachLead.Deactivate_Unit_after_Lost_Lead__c);
                    //if lead stage is Stopped Pursuing/Offer Rejected & deactivate lost lead checkbox ischecked then deactivate unit
                    if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId &&
                       eachLead.Status != oldLeadMap.get(eachLead.Id).Status && string.isnotblank(eachLead.Unit__c) &&
                       (eachLead.Status == 'Stopped Pursuing' || eachLead.Status == 'Offer Rejected') &&
                       eachLead.Deactivate_Unit_after_Lost_Lead__c == true ){
                           system.debug('enter in product update::::');
                           product2 newProduct1 = new product2();
                           newProduct1.Id = eachLead.Unit__c;
                           newProduct1.IsActive = false;
                           newProduct1.Sold_Deactivated_Date__c = system.today();
                           newProduct1.Unit_Stage__c = 'Seller Sold';
                           lstProduct.add(newProduct1);
                       }
                }
            }
            system.debug('setOfLeadId:::'+setOfLeadId);
            if(setOfLeadId != null && !setOfLeadId.isEmpty()){
                lstUserRequirement =[SELECT Id, Name, Lead__c,Lead__r.contact__r.AccountId,
                                     (SELECT id,name,irondemand_contact__c,isUnqualified_closedlost__c,
                                      Unit_Currently_Interested_In__c,Unit_Currently_Interested_In__r.Account__c
                                      FROM iron_demand__r) 
                                     FROM User_Requirement_ID__c 
                                     WHERE Lead__c IN :setOfLeadId AND opportunity__c = null ];
            }
            system.debug('lstUserRequirement:::'+lstUserRequirement);
            if(lstUserRequirement != null && !lstUserRequirement.isEmpty()){
                for(User_Requirement_ID__c eachUserReq1 :lstUserRequirement ){
                    
                    for(iron_demand__c eachIronDemand1 :eachUserReq1.iron_demand__r){
                        if(!mapofIronDemandIDVsUnitAccountId.containsKey(eachUserReq1.Id) &&
                          string.isnotblank(eachIronDemand1.Unit_Currently_Interested_In__r.Account__c)){
                            mapofIronDemandIDVsUnitAccountId.put(eachIronDemand1.Id,eachIronDemand1.Unit_Currently_Interested_In__r.Account__c);
                        }
                    } 
                }
            }
            list<iron_demand__c> lstOfIronDemandTODelete = new list<iron_demand__c>();
            system.debug('lstUserRequirement::'+lstUserRequirement);
            if(lstUserRequirement != null && !lstUserRequirement.isEmpty()){
                for(User_Requirement_ID__c eachUserReq :lstUserRequirement ){
                    if(mapOfleadIDVsContactID.containsKey(eachUserReq.Lead__c) &&
                       mapOfleadIDVsContactID.get(eachUserReq.Lead__c) != null ){
                       eachUserReq.Contact__c = mapOfleadIDVsContactID.get(eachUserReq.Lead__c); 
                    }
                    
                    lstUserRequirementTOupdate.add(eachUserReq);
                    for(iron_demand__c eachIronDemand :eachUserReq.iron_demand__r){
                        system.debug('eachUserReq.iron_demand__r size:::'+eachUserReq.iron_demand__r.size());
                        if(mapOfleadIDVsStatus.containskey(eachUserReq.Lead__c) && mapOfleadIDVsStatus.get(eachUserReq.Lead__c)=='Unqualified'){
                            system.debug('enter in IsUnqualified_ClosedLost__c1');
                            eachIronDemand.IsUnqualified_ClosedLost__c = true;
                        }
                        else if(mapOfleadIDVsStatus.containskey(eachUserReq.Lead__c) && mapOfleadIDVsStatus.get(eachUserReq.Lead__c)!='Unqualified'){
                            system.debug('enter in IsUnqualified_ClosedLost__c1');
                            eachIronDemand.IsUnqualified_ClosedLost__c = false;
                        }
                        If(mapOfleadIDVsContactID.containskey(eachUserReq.Lead__c) && mapOfleadIDVsContactID.get(eachUserReq.Lead__c)!= Null &&
                           string.isnotblank(eachUserReq.Lead__r.contact__r.AccountId)
                           && mapofIronDemandIDVsUnitAccountId.containskey(eachIronDemand.Id) &&
                           mapofIronDemandIDVsUnitAccountId.get(eachIronDemand.Id) != null
                           && eachUserReq.Lead__r.contact__r.AccountId !=mapofIronDemandIDVsUnitAccountId.get(eachIronDemand.Id)){
                               system.debug('enter in child record');
                            eachIronDemand.irondemand_contact__c = mapOfleadIDVsContactID.get(eachUserReq.Lead__c);
                        }
                        if(string.isnotblank(eachUserReq.Lead__r.contact__r.AccountId)
                           && mapofIronDemandIDVsUnitAccountId.containskey(eachIronDemand.Id) && mapofIronDemandIDVsUnitAccountId.get(eachIronDemand.Id) != null
                           && eachUserReq.Lead__r.contact__r.AccountId ==mapofIronDemandIDVsUnitAccountId.get(eachIronDemand.Id)){
                               system.debug('lstIronddemandToDelete');
                               lstOfIronDemandTODelete.add(eachIronDemand);
                           }
                        
                        lstIronDemandToUpdate.add(eachIronDemand);
                    }
                }
            }
            
            if(setOfUnitId!=null && !setOfUnitId.isEmpty()){
                mapOfIdVsUnit = new map<id,product2>([SELECT id,Display_Lowest_Purchase_Price__c,Unit_Stage__c,IsActive,Starting_Advertised_Retail_Price__c 
                                                      FROM product2 
                                                      WHERE id in:setOfUnitId]);
            }
            if(setOfConvertedLeadId != null && !setOfConvertedLeadId.isEmpty()){
                lstUserReqId = [SELECT ID,lead__c,opportunity__c
                                FROM User_Requirement_ID__c
                                WHERE lead__c IN : setOfConvertedLeadId AND opportunity__c =null  ];
            }
            if(lstUserReqId != null && !lstUserReqId.isEmpty()){
                for(User_Requirement_ID__c eachUserReq : lstUserReqId){
                    if(mapOfLeadIDVsOppId.containskey(eachUserReq.Lead__c)){
                        User_Requirement_ID__c newUserReq = new User_Requirement_ID__c();
                        newUserReq.id = eachUserReq.Id;
                        newUserReq.Opportunity__c = mapOfLeadIDVsOppId.get(eachUserReq.Lead__c);
                        newUserReq.Lead__c = null;
                        lstUserReqToUpdate.add(newUserReq);
                    }
                }
            }
            
            if(leads!=null && !leads.isEmpty()){
                for(Lead eachLead : leads){
                    if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId 
                       && string.isnotblank(eachLead.Unit__c) && eachLead.Unit__c != oldLeadMap.get(eachLead.Id).Unit__c &&
                       mapOfIdVsUnit.containsKey(eachLead.Unit__c)){
                           system.debug('criteria matched');
                           product2 newProduct =   mapOfIdVsUnit.get(eachLead.Unit__c);
                           //create a task when buy price is null
                           if(mapOfIdVsUnit.get(eachLead.Unit__c).Display_Lowest_Purchase_Price__c !=null
                              && mapOfIdVsUnit.get(eachLead.Unit__c).Starting_Advertised_Retail_Price__c ==null ){
                                  string subject = 'Set Sell Price on the Unit';  
                                  system.debug('subject:::'+subject);
                                  task newTask = CreateTask.createNewTask(subject,null,eachLead.id,system.today(),eachLead.OwnerId,'New');
                                  if(newTask != null){
                                      lstTaskToInsert.add(newTask);
                                  }
                              }
                     
                              
                           //Task for Shelly when Unit contains seller price & Buyer price and unit is active 
                           if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId  && 
                              string.isnotblank(eachLead.Unit__c) && eachLead.Unit__c != oldLeadMap.get(eachLead.Id).Unit__c  
                              /*mapOfIdVsUnit.get(eachLead.Unit__c).Unit_Stage__c =='Potential trade' &&*/ 
                              && mapNameVsUser.containsKey(system.label.VA) ){
                                   if( mapOfIdVsUnit.get(eachLead.Unit__c).Display_Lowest_Purchase_Price__c !=null
                                      && mapOfIdVsUnit.get(eachLead.Unit__c).Starting_Advertised_Retail_Price__c !=null 
                                      &&mapOfIdVsUnit.get(eachLead.Unit__c).isActive == true){
                                       string subject = 'Send matching email ';
                                       system.debug('subject:::'+subject);
                                       task newTask= CreateTask.createNewTask(subject,eachLead.Unit__c,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New'); 
                                       if(newTask!=null){
                                           lstTaskToInsert.add(newTask);
                                       }
                                   }
                                  if(eachLead.Status != 'Eval Required'){
                                      string subject2 ='Google S/N to see if marketed';
                                      string subject3 = 'Search SN on TopBid to confirm year';
                                      task newTask3= CreateTask.createNewTask(subject2,eachLead.Unit__c,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                                      task newTask4 = CreateTask.createNewTask(subject3,eachLead.Unit__c,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                                      if(newTask3!=null){
                                          lstTaskToInsert.add(newTask3);
                                      }
                                      if(newTask4!=null){
                                          lstTaskToInsert.add(newTask4);
                                      } 
                                  }
                              }   
                           
							system.debug('mapOfIdVsUnit.get(eachLead.Unit__c).Unit_Stage__c:::'+mapOfIdVsUnit.get(eachLead.Unit__c).Unit_Stage__c);                           
                           //Create a task when stage of unit is Potential trade
                           if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId &&
                              eachLead.Unit__c != oldLeadMap.get(eachLead.Id).Unit__c && string.isnotblank(eachLead.Unit__c) &&
                              mapOfIdVsUnit.get(eachLead.Unit__c).Display_Lowest_Purchase_Price__c ==null 
                              && (mapOfIdVsUnit.get(eachLead.Unit__c).Unit_Stage__c !='Potential trade' && mapOfIdVsUnit.get(eachLead.Unit__c).IsActive == true ) 
                              ){
                                  string subject = 'Obtain Buy price on Unit ';
                                  system.debug('eachLead.Unit__c:::'+eachLead.Unit__c);
                                  system.debug('eachLead.OwnerId:::'+eachLead.OwnerId);
                                  //String subject, String WhatId, String WhoId, Date ActivityDate, string OwnerId, String status
                                  task newTask = CreateTask.createNewTask(subject,null,eachLead.id,system.today(),eachLead.OwnerId,'New');
                                  if(newTask!=null){
                                      lstTaskToInsert.add(newTask);
                                  }
                                     string subject1 = 'Set Sell Price on the Unit';  
                                  system.debug('subject:::'+subject1);
                                  task newTask1 = CreateTask.createNewTask(subject1,null,eachLead.id,system.today(),eachLead.OwnerId,'New');
                                  if(newTask1 != null){
                                      lstTaskToInsert.add(newTask1);
                                  }
                                  
                              }
                       }
                          system.debug('eachLead.Output_Relevant__c:::'+eachLead.Output_Relevant__c);
                   
                    //When Outbound Relevant Checkbox is changed to true and evaluation output is not blank
                    if(string.isnotblank(procurementRecordTypeId) && eachLead.RecordTypeId ==procurementRecordTypeId && 
                       string.isnotblank(eachLead.Unit__c) /*&& 
                       mapOfIdVsUnit.get(eachLead.Unit__c).Unit_Stage__c =='Potential trade'*/ &&
                        (/*eachLead.Status !=oldLeadMap.get(eachLead.Id).Status ||*/
						eachLead.Output_Relevant__c !=oldLeadMap.get(eachLead.Id).Output_Relevant__c )
                       && eachLead.Output_Relevant__c ==true && eachLead.Status =='Eval Completed' && 
                       string.isnotblank(eachLead.Evaluation_Output__c) && string.isnotblank(eachLead.Auction_Results__c) &&
                      string.isnotblank(eachLead.Retail_Result__c)){
                           string subject = 'Review Manual Evaluation ';
                           string subject1 = 'Complete Rouse Evaluation if required ';
                           system.debug('subject::'+subject);
                           system.debug('subject::'+subject1);
                           task newTask = CreateTask.createNewTask(subject,null,eachLead.id,system.today(),eachLead.OwnerId,'New');
                           task newTask1 = CreateTask.createNewTask(subject1,null,eachLead.id,system.today(),eachLead.OwnerId,'New');
                           if(newTask!=null){
                               lstTaskToInsert.add(newTask);
                               system.debug('lstTaskToInsert:::'+lstTaskToInsert);
                           }
                           if(newTask1!=null){
                               lstTaskToInsert.add(newTask1);
                               system.debug('lstTaskToInsert:::'+lstTaskToInsert);
                           }
                                if(mapNameVsUser.containskey(system.label.VA)) {
                               if(mapOfIdVsUnit.get(eachLead.Unit__c).Display_Lowest_Purchase_Price__c !=null
                                  && mapOfIdVsUnit.get(eachLead.Unit__c).Starting_Advertised_Retail_Price__c !=null && mapOfIdVsUnit.get(eachLead.Unit__c).isActive == true){
                                      string subject2 = 'Send matching email ';
                                      task newTask2= CreateTask.createNewTask(subject2,eachLead.Unit__c,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New'); 
                                      if(newTask2!=null){
                                          lstTaskToInsert.add(newTask2);
                                      }
                                  }
                                    //if(mapOfIdVsUnit.get(eachLead.Unit__c).Display_Lowest_Purchase_Price__c !=null
                                      // && mapOfIdVsUnit.get(eachLead.Unit__c).Starting_Advertised_Retail_Price__c !=null){
                                           string subject2 ='Google S/N to see if marketed';
                                           string subject3 = 'Search SN on TopBid to confirm year';
                                           task newTask3= CreateTask.createNewTask(subject2,eachLead.Unit__c,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                                           task newTask4 = CreateTask.createNewTask(subject3,eachLead.Unit__c,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                                           if(newTask3!=null){
                                               lstTaskToInsert.add(newTask3);
                                           }
                                           if(newTask4!=null){
                                               lstTaskToInsert.add(newTask4);
                                           }
                                      // }
                                }
                       }
                }
            }
            if(lstTaskToInsert!=null && !lstTaskToInsert.isEmpty()){
                system.debug('lstTaskToInsert:::'+lstTaskToInsert);
                insert lstTaskToInsert;
                system.debug('lstTaskToInsert:::'+lstTaskToInsert);
            }
            if(lstProduct != null && !lstProduct.isEmpty()){
                system.debug('lstProduct:::'+lstProduct);
                update lstProduct;
                system.debug('lstProduct:::'+lstProduct);
            }
            if(lstLeadToUpdate != null && !lstLeadToUpdate.isEmpty()){
                system.debug('lstLeadToUpdate::'+lstLeadToUpdate);
                update lstLeadToUpdate;
                system.debug('lstLeadToUpdate::'+lstLeadToUpdate);
            }
            if(lstUserReqToUpdate != null && !lstUserReqToUpdate.isEmpty()){
                system.debug('lstUserReqToUpdate:::'+lstUserReqToUpdate);
                update lstUserReqToUpdate;
                system.debug('lstUserReqToUpdate:::'+lstUserReqToUpdate);
            }
            
			 if( lstUserRequirementTOupdate!= null && !lstUserRequirementTOupdate.isEmpty()){
                system.debug('lstUserRequirementTOupdate:::'+lstUserRequirementTOupdate);
                update lstUserRequirementTOupdate;
                system.debug('lstUserRequirementTOupdate:::'+lstUserRequirementTOupdate);
            } 
            
             if(lstIronDemandToUpdate != null && !lstIronDemandToUpdate.isEmpty()){
                system.debug('lstIronDemandToUpdate:::'+lstIronDemandToUpdate);
                update lstIronDemandToUpdate;
                system.debug('lstIronDemandToUpdate:::'+lstIronDemandToUpdate);
            }
               if(lstOfIronDemandTODelete != null && !lstOfIronDemandTODelete.isEmpty()){
                system.debug('lstOfIronDemandTODelete:::'+lstOfIronDemandTODelete);
                delete lstOfIronDemandTODelete;
                system.debug('lstOfIronDemandTODelete:::'+lstOfIronDemandTODelete);
            }
            
            
        }
    
    
    
    public static void handleIronDemandCreationOnUpdate(
        List<Lead> leads,
        Map<Id, Lead> oldLeadMap){
        set<Id>setOfLeadId = new set<Id>();
        set<Id>setOfContactId = new set<Id>();
        set<Id> setOfEquipmemtId = new set<Id>();
        set<Id> setOfUnitId = new set<Id>();
        List<Lead> filteredLeads = new List<Lead>();
        map<string, Iron_Demand__c> mapOfStringVsIronDemand = new map<string,Iron_Demand__c>();
        for(Lead ld : leads){
            if(ld.Contact__c != null && ld.Unit__c != null){
                Lead oldLead = oldLeadMap.get(ld.Id);
                if((hasContactChanged(ld, oldLead) || 
                    hasUnitChanged(ld, oldLead))){
                    setOfContactId.add(ld.Contact__c);
                	setOfLeadId.add(ld.id);
                    
                    //filteredLeads.add(ld);
                }
            }
        }
        list<Lead> lstLead = [SELECT id,
                              Contact__c,
                              Unit__c, 
                              unit__r.equipment__c FROM
                               lead WHERE 
                              id IN :setOfLeadId ];
        
        if(lstLead!=null && !lstLead.isEmpty()){
            for(lead eachLead :lstLead ){
                
                setOfEquipmemtId.add(eachLead.unit__r.equipment__c);
            }
        }
        if((setOfContactId!=null && !setOfContactId.isEmpty())&& 
           ((setOfEquipmemtId!=null && !setOfEquipmemtId.isEmpty()))){
               list<Iron_Demand__c> lstIronDemand = [SELECT Id,
                                                  IronDemand_Contact__c,
                                                  IronDemand_Iron__c 
                                                  FROM Iron_Demand__c 
                                                  WHERE IronDemand_Contact__c IN : setOfContactId 
                                                  AND IronDemand_Iron__c IN :setOfEquipmemtId];
            
            if(lstIronDemand!=null && !lstIronDemand.isEmpty()){
                for(Iron_Demand__c eachIronDemand : lstIronDemand){
                    string IronDemandcontactIdEquipmentID;
                    IronDemandcontactIdEquipmentID = String.valueOf(eachIronDemand.IronDemand_Contact__c) + String.valueOf(eachIronDemand.IronDemand_Iron__c);
                    
                    mapOfStringVsIronDemand.put(IronDemandcontactIdEquipmentID,eachIronDemand);
                }
                
            }
        }
        if(lstLead!=null && !lstLead.isEmpty()){
            for(lead eachLead : lstLead){
                string contactIdEquipmentID;
                contactIdEquipmentID = String.valueOf(eachLead.Contact__c) + String.valueOf(eachLead.unit__r.equipment__c);
                
                if(!mapOfStringVsIronDemand.containsKey(contactIdEquipmentID)){
                    filteredLeads.add(eachLead);
                }
            }
        }
        
        if(filteredLeads.size()> 0){
            //createIronDemandsFromLeads(filteredLeads);
        }
            
    }

    private static void createIronDemandsFromLeads(
        List<Lead> leads
    ){
        List<Iron_Demand__c> ironDemandsToInsert = new List<Iron_Demand__c>();
        Map<Id, Product2> leadIdToUnitMap = new Map<Id, Product2>();
        Set<Id> unitIds = new Set<Id>();
        for(Lead lead : leads){
            unitIds.add(lead.Unit__c);
        }
        Map<Id, Product2> unitMap = new Map<Id, Product2>([SELECT Id, Equipment__c FROM Product2 WHERE Id IN :unitIds]);
        
        for(Lead lead : leads){
            if(unitMap.get(lead.Unit__c) != null){
                leadIdToUnitMap.put(lead.Id, unitMap.get(lead.Unit__c));
            }
        }
        for(Lead lead : leads){
            Iron_Demand__c ironDemand = new Iron_Demand__c();
            ironDemand.IronDemand_Contact__c = lead.Contact__c;
            if(leadIdToUnitMap.get(lead.Id) != null && leadIdToUnitMap.get(lead.Id).Equipment__c != null){
                ironDemand.IronDemand_Iron__c = leadIdToUnitMap.get(lead.Id).Equipment__c;
                ironDemandsToInsert.add(ironDemand);
            }
        }
		
        if(ironDemandsToInsert.size() > 0){
            Database.insert(ironDemandsToInsert);
        }
    }

    private static Boolean hasContactChanged(
        Lead newLead, Lead oldLead
    ){
        return hasValueChanged(
            newLead.Contact__c,
            oldLead.Contact__c
        );
    }
    private static Boolean hasRegionChanged(
        Lead newLead, Lead oldLead
    ){
        return hasValueChanged(
            newLead.Region__c,
            oldLead.Region__c
        );
    }
    private static Boolean hasMobileNumberChanged(
        Lead newLead, Lead oldLead
    ){
        return hasValueChanged(
            newLead.MobilePhone,
            oldLead.MobilePhone
        );
    }
    private static Boolean hasOwnerChanged(
        Lead newLead, Lead oldLead
    ){
        return hasValueChanged(
            newLead.OwnerId,
            oldLead.OwnerId
        );
    }
	
    private static Boolean hasUnitChanged(
        Lead newLead, Lead oldLead
    ){
        return hasValueChanged(
            newLead.Unit__c,
            oldLead.Unit__c
        );
    }
	private static Boolean hasStatusChanged(
    Lead newLead, Lead oldLead
    ){
       	return hasValueChanged(
            newLead.status,
            oldLead.status
        ); 
    }
    private static Boolean hasValueChanged(Object newValue, Object oldValue){
        return newValue != oldValue;
    }
    
    
    private static void handleBeforeInsert(List<Lead> triggerNew){
        map<id,contact> mapOfConIdVsContact = new map<id,contact>();
        list<Lead> lstLead = new list<Lead>();
		 list<contact> lstContact = new list<contact>();
          Id recordTypeSalesLead;
        if(string.isnotblank(System.Label.Lead_Record_Type_Sales_lead)){
            recordTypeSalesLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
                .get(System.Label.Lead_Record_Type_Sales_lead).getRecordTypeId();
        }
        set<id> setOfContactIds = new set<id>();
        set<String> setOfLeadSource = new set<String>();
        string leadSourceValues = System.Label.Lead_Source_For_Round_Robin;
        if(string.isNotBlank(leadSourceValues)){
			list<String> lstString = leadSourceValues.split(',');
            
            setOfLeadSource.addAll(lstString);            
        }
        
        if(triggerNew!=null && !triggerNew.isEmpty() ){
            for(lead eachLead : triggerNew){
                if(setOfLeadSource.contains(eachLead.LeadSource)&& 
                   eachLead.Region__c != 'Manual' &&
                  !eachLead.Restrict_Round_Robbin__c){    
                	      
                        if(string.isNotBlank(eachLead.Region__c)
                         && string.isBlank(eachLead.MobilePhone)){
                             lstLead.add(eachLead);
                             
                         }
                      else if(eachLead.LeadSource == 'Call Back'){
                          eachLead.Region__c = 'Not a Lead';
                          //eachLead.Region__c = 'Domestic';
                          //lstLead.add(eachLead);
                      } else if (string.isNotBlank(eachLead.MobilePhone) 
                                 && string.isBlank(eachLead.Region__c) 
                                ){
                                    system.debug('eachLead.MobilePhone.Length::'+eachLead.MobilePhone.Length());
                                    if((eachLead.MobilePhone).startsWith('+') && !(eachLead.MobilePhone).startsWith('+1') ){//&& eachLead.MobilePhone.Length() >10 ){
                                        eachLead.Region__c = 'International';
                                        system.debug('International:::');
                                    }else {
                                        eachLead.Region__c = 'Domestic';//INTERNATIONAL
                                        system.debug('Domestic:::');
                                    }
                                    
                                    lstLead.add(eachLead);        
                                }else if(string.isBlank(eachLead.Region__c) 
                                         && string.isBlank(eachLead.MobilePhone)
                                        ){
                                            eachLead.Region__c = 'DOMESTIC';
                                            lstLead.add(eachLead);
                                        }
                  }
                if(string.isnotblank(eachLead.Contact__c) && string.isnotblank(recordTypeSalesLead) 
                   && eachLead.RecordTypeId ==recordTypeSalesLead){
                    setOfContactIds.add(eachLead.Contact__c);
                }
                
            }
           
            if(lstLead!=null && !lstLead.isEmpty()){
                
                list<Team_Member__c> lstTeamMember = RoundRobinHandler.RoundRobin(lstLead,
                                                                               'Sales_Team__r',
                                                                               'Team_Member__c',
                                                                               'Region__c',
                                                                               'OwnerId',
                                                                               'User__c');
                if(lstTeamMember!=null && !lstTeamMember.isEmpty()){
                    update lstTeamMember;
                }
            }
        }
        
        if(setOfContactIds != null && !setOfContactIds.isEmpty()){
            mapOfConIdVsContact = new map<id,contact>([SELECT id,AccountId,Primary_Contact__c,Account.Primary_Contact__c
                          FROM Contact
                          WHERE Account.Primary_Contact__c IN :setOfContactIds AND AccountId != null]);
        }
        /*if(triggerNew!=null && !triggerNew.isEmpty() ){
            for(lead eachLead : triggerNew){
                if(string.isnotblank(eachLead.Contact__c) && string.isnotblank(recordTypeSalesLead) 
                   && eachLead.RecordTypeId ==recordTypeSalesLead && mapOfConIdVsContact.containsKey(eachLead.Contact__c) &&
                  mapOfConIdVsContact.get(eachLead.Contact__c) != null){
                       eachLead.Account__c = mapOfConIdVsContact.get(eachLead.Contact__c).AccountId;
                   }
                else{
                     eachLead.addError('Please select the primary contact.');
                }
            }
        }*/
    }
    
    private static void handleBeforeUpdate(
        List<Lead> leads,
        Map<Id, Lead> oldLeadMap){
            string leadSourceValues = System.Label.Lead_Source_For_Round_Robin;
            list<Lead> lstLead = new list<Lead>();
            list<contact> lstContact = new list<contact>();
            set<String> setOfLeadSource = new set<String>();
            set<id> setOfContactIds = new set<id>();
            map<id,contact> mapOfConIdVsContact = new map<id,contact>();
            Id procurementRecordTypeId;
            if(string.isNotBlank(system.label.Lead_Record_Type_Procurement_lead)){
                procurementRecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
                    .get(label.Lead_Record_Type_Procurement_lead).getRecordTypeId();
            }
          Id recordTypeSalesLead;
        if(string.isnotblank(System.Label.Lead_Record_Type_Sales_lead)){
            recordTypeSalesLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
                .get(System.Label.Lead_Record_Type_Sales_lead).getRecordTypeId();
        }
		if(string.isNotBlank(leadSourceValues)){
		
            list<String> lstString = leadSourceValues.split(',');
            
            setOfLeadSource.addAll(lstString);            
        }
        system.debug('Before Update :::');                                        
        List<Lead> lstLeadForRoundRobin = new List<Lead>();
        set<Id> setOfOwnerId = new set<Id>();
        set<String> setOfRegion = new set<string>();
        map<String,list<lead>> mapOfOwnerAndRegionVsLead = new map<String,list<lead>>();
                                             
        list<Team_Member__c> lstTeamMemberAssignToSameUser;
        list<lead>lstLeadToChangeOwner = new list<Lead>();  
		set<id> setOfId = new set<id>();
                                                     
       	for(Lead eachLead : leads){
            system.debug('Before Update11 :::');
            system.debug('eachLead.Status:::'+eachLead.Status);
            system.debug('eachLead.IsConverted:::'+eachLead.IsConverted);
            Lead oldLead = oldLeadMap.get(eachLead.Id);
            
            if(hasRegionChanged(eachLead, oldLead) && 
               string.isNotBlank(eachLead.Region__c) && eachLead.Region__c =='Procurement' 
               && eachLead.RecordTypeId==recordTypeSalesLead){
                   eachLead.RecordTypeId = procurementRecordTypeId;
               }else if(eachLead.Region__c !='Manual' && 
                        setOfLeadSource.contains(eachLead.LeadSource) && 
                        !eachLead.Restrict_Round_Robbin__c)
               {
                   if(hasRegionChanged(eachLead, oldLead)&& 
                      string.isNotBlank(eachLead.Region__c)
                     ){
                         lstLeadForRoundRobin.add(eachLead);
                     }
                   
               }
            /**/
            
             if((eachLead.Contact__c != oldLeadMap.get(eachLead.id).Contact__c || 
                 eachLead.Account__c != oldLeadMap.get(eachLead.id).Account__c) 
                && string.isnotblank(eachLead.Contact__c) && string.isnotblank(recordTypeSalesLead) 
                   && eachLead.RecordTypeId ==recordTypeSalesLead){
                    setOfContactIds.add(eachLead.Contact__c);
                }
            
            
            /*if(eachLead.Unit__c !=oldLeadMap.get(eachLead.id).Unit__c && string.isnotblank(eachLead.Unit__c)){
                eachLead.status = 'Eval Required';
            }
            else if(eachLead.Unit__c !=oldLeadMap.get(eachLead.id).Unit__c && string.isBlank(eachLead.Unit__c)){
                eachLead.status = 'Reviewing';
            }*/
            system.debug('eachLead.Status:::'+eachLead.Status);
                system.debug('eachLead.IsConverted:::'+eachLead.IsConverted);
                system.debug('enter in status qualified:::');
            if( eachLead.Status != oldLeadMap.get(eachLead.id).Status && eachLead.Status =='Qualified' && eachLead.IsConverted == true ){
                setOfId.add(eachLead.id);
            }
            
            if(eachLead.Status == 'Eval Required' && (eachLead.Auction_Results__c != oldLeadMap.get(eachLead.id).Auction_Results__c||
                eachLead.Retail_Result__c != oldLeadMap.get(eachLead.id).Retail_Result__c || eachLead.Evaluation_Output__c != oldLeadMap.get(eachLead.id).Evaluation_Output__c)
               && eachLead.Auction_Results__c != null && eachLead.Retail_Result__c != null && eachLead.Evaluation_Output__c != null){
                eachLead.Status = 'Eval Completed';
            }
            
        }
         
            if(setOfContactIds != null && !setOfContactIds.isEmpty()){
                mapOfConIdVsContact = new map<id,contact>([SELECT id,AccountId,Primary_Contact__c,Account.Primary_Contact__c
                          FROM Contact
                          WHERE Account.Primary_Contact__c IN :setOfContactIds AND AccountId != null]);
            /*mapOfConIdVsContact = new map<id,contact>([SELECT id,AccountId,Primary_Contact__c
                          FROM Contact
                          WHERE ID IN :setOfContactIds AND Primary_Contact__c=true AND AccountId != null]);*/
        }
        /*if(lstContact != null && !lstContact.isEmpty()){
            for(contact eachContact : lstContact){
                if(!mapOfConIdVsAccId.containsKey(eachContact.Id)){
                    mapOfConIdVsAccId.put(eachContact.Id,eachContact.AccountId);   
                }
            }
        }*/
        /*if(leads!=null && !leads.isEmpty()){
            for(lead eachLead : leads){
                if((eachLead.Contact__c != oldLeadMap.get(eachLead.id).Contact__c || 
                 eachLead.Account__c != oldLeadMap.get(eachLead.id).Account__c) && 
                   string.isnotblank(eachLead.Contact__c) && string.isnotblank(recordTypeSalesLead) 
                   && eachLead.RecordTypeId ==recordTypeSalesLead && mapOfConIdVsContact.containsKey(eachLead.Contact__c) &&
                  mapOfConIdVsContact.get(eachLead.Contact__c) != null){
                       eachLead.Account__c = mapOfConIdVsContact.get(eachLead.Contact__c).AccountId;
                   }
                else{
                     eachLead.addError('Please select the primary contact.');
                }
            }
        }  */                                      
                                                
                                                
                                                
                                                
             //list<lead> lstLead; 
            map<id,lead> mapOfIdVsLead = new map<id,lead>();
			 if(setOfId !=null && !setOfId.isEmpty()){
                 mapOfIdVsLead = new map<id,lead>([SELECT id,status,isConverted,unit__c,unit__r.Display_Lowest_Purchase_Price__c,unit__r.Starting_Advertised_Retail_Price__c,
                                  					unit__r.Storage_Address__c,unit__r.Storage_City__c,unit__r.Storage_State__c,unit__r.Storage_Zip_Code__c
                                  				   FROM lead 
                                  				   WHERE id in : setOfId ]);                           
                 
             }
             system.debug('setOfId:::'+setOfId);
             system.debug('lstLead:::'+ mapOfIdVsLead);                                   
			                                 
                                                
        list<Team_Member__c> lstTeamMember = RoundRobinHandler.RoundRobin(lstLeadForRoundRobin,
																				   'Sales_Team__r',
                                                                                   'Team_Member__c',
                                                                                   'Region__c',
                                                                                   'OwnerId',
                                                                                   'User__c'); 
        if(lstTeamMember!=null && !lstTeamMember.isEmpty()){
 
            update lstTeamMember;
        }
                                                
        for(Lead eachLead : leads){
        	Lead oldLead = oldLeadMap.get(eachLead.Id);
            string ownerAndRegion;
           
            if(eachLead.Status == 'Qualified' && eachLead.IsConverted ==true && mapOfIdVsLead != null && mapOfIdVsLead.ContainsKey(eachLead.id) 
               && string.isnotblank(eachLead.Unit__c) && mapOfIdVsLead.get(eachLead.id).unit__r.Starting_Advertised_Retail_Price__c == null){
                eachLead.adderror('Set Sell Price on unit'); 
                system.debug('Set Sell Price on unit');
            }
            if(eachLead.Status == 'Qualified' && eachLead.IsConverted ==true && mapOfIdVsLead.ContainsKey(eachLead.id) && 
               string.isNotblank(eachLead.unit__c)&&
               (string.isblank(mapOfIdVsLead.get(eachLead.id).unit__r.Storage_Address__c) || string.isblank(mapOfIdVsLead.get(eachLead.id).unit__r.Storage_City__c)
                || string.isblank(mapOfIdVsLead.get(eachLead.id).unit__r.Storage_State__c) || string.isblank(mapOfIdVsLead.get(eachLead.id).unit__r.Storage_Zip_Code__c))){
                    eachLead.adderror('Please update missing address on Unit.'); 
                    system.debug('Please update missing address.');
                }
        }    
                        
                                                
    }
    private static void handleNoOfActiveLeadOnUpdate(
                                            List<Lead> leads,
                                            Map<Id, Lead> oldLeadMap){
        if(leads!=null&& !leads.isEmpty()){
           
            set<Lead> setOfLead = new set<Lead>();
            for(Lead newLead : leads){
                Lead oldLead = oldLeadMap.get(newLead.Id);
                if((hasUnitChanged(newLead, oldLead) || hasStatusChanged(newLead, oldLead) )){
                    setOfLead.add(newLead);
                    setOfLead.add(oldLead);
                    
                }
            }
        
            if(setOfLead!=null && !setOfLead.isempty()){
                list<Lead> lstLead = new list<Lead>();
                lstLead.addAll(setOfLead);
                //It will update the no of lead under that unit.
            CalculateNoOfLeads(lstLead);
            }                                       
        }                                    	
    }
    
    // get RecordType id based on label Record Type Name 
    private static id getRecordTypeId(string labelValue){
        // To query RecordType Id
        RecordType CurrentRecordType = [SELECT Id
                                        FROM RecordType
                                        WHERE DeveloperName =:labelValue LIMIT 1];
        system.debug(CurrentRecordType.Id);
        return CurrentRecordType.Id;
        
    }
    
}