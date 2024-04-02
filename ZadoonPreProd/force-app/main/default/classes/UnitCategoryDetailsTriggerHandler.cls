/*
This class is used to create ironDemand object based on userCategoryDetails object requirement 
and add error when required condition does not match.
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          07-Aug-2023         Kizzy Consulting        Pushkar               Initial Version
------------------------------------------------------------------------------------------------
*/

public with sharing class UnitCategoryDetailsTriggerHandler implements ITriggerHandler {
    public Trigger_Setting__mdt setTriggerSettings() {
        return [select Active__c,Max_Loop_Count__c,Stop_Recursion__c FROM Trigger_Setting__mdt 
                Where DeveloperName='UnitCategoryDetail' LIMIT 1];
    } 
   
    Public void beforeInsert(List<SObject> triggerNew){
        handleBeforeInsert((List<Unit_Category_Details__c>)triggerNew);
        
    }
    //By implementing this method trigger can handle all the before Update events
    Public void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){ 
       // handleBeforeUpdate((List<Unit_Category_Details__c>) triggerNew, (Map<Id, Unit_Category_Details__c>) triggerOldMap);

    }
    //By implementing this method trigger can handle all the before Delete events
    Public void beforeDelete(List<SObject> triggerOld){
        
    }   
    //By implementing this method trigger can handle all the after Insert events
    Public void afterInsert(List<SObject> triggerNew){
        //handleafterInsert((List<User_Requirement_ID__c>)triggerNew);
    }
    //By implementing this method trigger can handle all the after Update events
    Public void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){
        handleAfterUpdate((List<Unit_Category_Details__c>) triggerNew, (Map<Id, Unit_Category_Details__c>) triggerOldMap);
    }
    //By implementing this method trigger can handle all the after Delte events
    Public void afterDelete(List<SObject> triggerOld){
        
    }
    //By implementing this method trigger can handle all the after UnDelete events
    Public void afterUndelete(List<SObject> triggerNew){
        
    }
    private static void handleBeforeInsert(List<Unit_Category_Details__c> triggerNew){
        Map<Id, Unit_Category_Details__c> mapOfParentIDVSUnitCategory = new Map<Id, Unit_Category_Details__c>();
        map<id, Unit_Category_Details__c> mapOfUnitIdVsUnitCategoryDetails = new map<id, Unit_Category_Details__c>();
        Set<Id> setOfParentIds = new Set<Id>();
        set<id> setOfUnitIds = new Set<Id>();
        if(triggerNew != null && !triggerNew.isEmpty()){
            for(Unit_Category_Details__c eachUnitCategory : triggerNew){
                if(string.isNotBlank(eachUnitCategory.User_Requirement_ID__c)){
                    setOfParentIds.add(eachUnitCategory.User_Requirement_ID__c);
                    
                }
                if(string.isNotBlank(eachUnitCategory.Unit__c)){
                    setOfUnitIds.add(eachUnitCategory.Unit__c);
                }
                
                
            }  
        }
        if((setOfParentIds != null && !setOfParentIds.isEmpty()) || (setOfUnitIds != null && !setOfUnitIds.isEmpty())){
            for (Unit_Category_Details__c eachUnitCategory : [SELECT id,User_Requirement_ID__c,unit__c 
                                                              FROM Unit_Category_Details__c 
                                                              WHERE (User_Requirement_ID__c !=null AND User_Requirement_ID__c IN :setOfParentIds)
                                                              OR(unit__c != null AND unit__c IN :setOfUnitIds)]) {
                                                                  
                if( string.isnotblank(eachUnitCategory.User_Requirement_ID__c) && !mapOfParentIDVSUnitCategory.containsKey(eachUnitCategory.User_Requirement_ID__c) ){
                    mapOfParentIDVSUnitCategory.put(eachUnitCategory.User_Requirement_ID__c, eachUnitCategory);
                }
                 if(string.isnotblank(eachUnitCategory.Unit__c) && !mapOfUnitIdVsUnitCategoryDetails.containsKey(eachUnitCategory.Unit__c)){
                    mapOfUnitIdVsUnitCategoryDetails.put(eachUnitCategory.Unit__c,eachUnitCategory);                                                
                }                                                  
                                                                  
            }
            
        }
        // Check if a parent already has a related child record
        for (Unit_Category_Details__c eachUnitCategory : Triggernew) {
            if (mapOfParentIDVSUnitCategory.containsKey(eachUnitCategory.User_Requirement_ID__c)) {
                eachUnitCategory.addError('A User Requirement ID record can have only one Unit Category Details record.');
            }
            if(mapOfUnitIdVsUnitCategoryDetails.containsKey(eachUnitCategory.Unit__c)){
                eachUnitCategory.addError('A Unit record can have only one Unit Category Details record.');
            }
        }
    }
    
    private static void handleAfterUpdate(List<Unit_Category_Details__c> triggerNew, Map<Id, Unit_Category_Details__c> triggerOldMap){
        system.debug('triggerNew::' + triggerNew);
        
        set<id> setUnitCatParentId = new set<id>();
        //set<id> setOfUnitCategoryDetailsID = new set<id>();
        set<id> setOfUnitCategoryId = new set<id>();
        set<string> setOfCategoryDetails = new set<string>();
        set<string> setOfCategoryDetailsFromUnit = new set<string>();
        set<string> setOfCategoryDetailsToMdt = new set<string>{'Common','URID'};
        //set<string> setOfCategoryDetailsFromUnitToMdt = new set<string>{'Common','URID'};
        set<id> setOfUnitCategoryParentId = new set<id>();
        //map<id,User_Requirement_ID__c> mapOfParentIdVSUserReqID = new map<id,User_Requirement_ID__c>();
        set<id> setOfUpdatedIsActiveParentId = new set<id>();
        set<id> setOfUserRequirementID = new set<id>();
        list<Unit_Category_Details__c> lstUnitCategoryFromUserReq;
        list<Iron_Demand__c> lstIronDemand = new list<Iron_Demand__c>();
    
         
        
        if(triggerNew!=null && !triggerNew.isEmpty()){
            for(Unit_Category_Details__c eachUnitCategoryDetails : triggerNew){
                //when unit category details from userRequirement ID is changed and active then we call future method.
                if(eachUnitCategoryDetails.IsActive__c==true && string.isBlank(eachUnitCategoryDetails.Unit__c) &&
                   string.isNotBlank(eachUnitCategoryDetails.User_Requirement_ID__c) && 
                   string.isNotBlank(eachUnitCategoryDetails.Category_Details__c)){
                       setOfUnitCategoryId.add(eachUnitCategoryDetails.Id);
                       setOfCategoryDetails.add(eachUnitCategoryDetails.Category_Details__c); 
                       setOfCategoryDetailsToMdt.add(eachUnitCategoryDetails.Category_Details__c);  
                       //setofRecordTypeId.add(eachUnitCategoryDetails.RecordTypeId);
                       setUnitCatParentId.add(eachUnitCategoryDetails.User_Requirement_ID__c);  
                   }
                
                //when unit category details from user requirement ID active field is changed to inactive then delete related iron demand.
                if(eachUnitCategoryDetails.IsActive__c != triggerOldMap.get(eachUnitCategoryDetails.Id).IsActive__c && 
                   eachUnitCategoryDetails.IsActive__c==false && string.isNotBlank(eachUnitCategoryDetails.User_Requirement_ID__c)){
                       setOfUserRequirementID.add(eachUnitCategoryDetails.User_Requirement_ID__c);
                   }
                
                system.debug('setOfUnitCategoryId:::'+setOfUnitCategoryId);
                system.debug('asetOfCategoryDetails:::'+setOfCategoryDetails);
                system.debug('setUnitCatParentId:::'+setUnitCatParentId);
                system.debug('achUnitCategoryDetails.Unit__c:::'+eachUnitCategoryDetails.Unit__c);
                
                //when unit category details from unit field is changed, then call future method.
                if(string.isNotBlank(eachUnitCategoryDetails.Unit__c) 
                   && string.isBlank(eachUnitCategoryDetails.User_Requirement_ID__c) 
                   && eachUnitCategoryDetails.IsActive__c==false 
                   && string.isNotBlank(eachUnitCategoryDetails.Category_Details__c)){
                       system.debug('enter in unit update::::  ');
                       setOfCategoryDetails.add(eachUnitCategoryDetails.Category_Details__c);
                       setOfCategoryDetailsToMdt.add(eachUnitCategoryDetails.Category_Details__c);
                }
            }
          
            
        }
        
        
        //system.debug('setOfCategoryDetailsFromUnitToMdt::::'+setOfCategoryDetailsFromUnitToMdt);
        if(setOfUserRequirementID !=null && !setOfUserRequirementID.isEmpty()){
            lstIronDemand = [SELECT ID,User_Requirement_ID__c
                             FROM Iron_Demand__c
                             WHERE User_Requirement_ID__c in : setOfUserRequirementID];
        }
        
        if(lstIronDemand != null && !lstIronDemand.isEmpty()){
            delete lstIronDemand;
        }
        if(setOfCategoryDetails != null && !setOfCategoryDetails.isEmpty()){
            lstUnitCategoryFromUserReq = [SELECT id,isActive__c,User_Requirement_ID__c,Unit__c,Category_Details__c
                                          FROM Unit_Category_Details__c
                                          WHERE Category_Details__c in : setOfCategoryDetails 
                                          AND isActive__c =true AND Unit__c=null AND User_Requirement_ID__c != null WITH SECURITY_ENFORCED];
        }
        system.debug('lstUnitCategoryFromUserReq:::'+lstUnitCategoryFromUserReq);
       
        if(lstUnitCategoryFromUserReq!=null && !lstUnitCategoryFromUserReq.isEmpty()){
            for(Unit_Category_Details__c eachUnitCategory : lstUnitCategoryFromUserReq){
                system.debug('eachUnitCategory:::'+eachUnitCategory.User_Requirement_ID__c);
                
                setUnitCatParentId.add(eachUnitCategory.User_Requirement_ID__c);
                
            }
        }
        system.debug('setUnitCatParentId:::'+setUnitCatParentId);
        //system.debug('setOfCategoryDetailsFromUnitToMdt:::'+setOfCategoryDetailsFromUnitToMdt);
        //system.debug('setOfCategoryDetailsFromUnit:::'+setOfCategoryDetailsFromUnit);
         /* //Here we called future method that call after update of unit category details from unit
        if( (setOfUnitCategoryParentId != null && !setOfUnitCategoryParentId.isEmpty()
             && setOfCategoryDetailsFromUnit != null && !setOfCategoryDetailsFromUnit.isEmpty()
             && setOfCategoryDetailsFromUnitToMdt != null && !setOfCategoryDetailsFromUnitToMdt.isEmpty()) || (setUnitCatParentId != null && !setUnitCatParentId.isEmpty()
           && setOfCategoryDetails != null && !setOfCategoryDetails.isEmpty()
           && setOfCategoryDetailsToMdt != null && !setOfCategoryDetailsToMdt.isEmpty())){
               system.debug('entered into future method from unit:::');
               UnitCategoryDetailsFutureClass.FutureUnitCategoryDetails(setOfUnitCategoryParentId,setOfCategoryDetailsFromUnitToMdt,setOfCategoryDetailsFromUnit);
        }*/
         //Here we called future method after update UCD
         System.Debug('setOfCategoryDetails:::' +setOfCategoryDetails); 
         System.Debug('setOfCategoryDetailsToMdt:::' +setOfCategoryDetailsToMdt); 
        if(setUnitCatParentId != null && !setUnitCatParentId.isEmpty()
           && setOfCategoryDetails != null && !setOfCategoryDetails.isEmpty()
          && setOfCategoryDetailsToMdt != null && !setOfCategoryDetailsToMdt.isEmpty()){
               system.debug('entered into future method from user:::');
               UnitCategoryDetailsFutureClass.FutureUnitCategoryDetails(setUnitCatParentId,setOfCategoryDetailsToMdt,setOfCategoryDetails,null);
           }
        
        /*     //Here we called future method that call after update of unit category details from unit
        if( setOfUnitCategoryParentId != null && !setOfUnitCategoryParentId.isEmpty()
           && setOfRecordTypeDevNameFromUnit != null && !setOfRecordTypeDevNameFromUnit.isEmpty()
           && setofRecordTypeIdFromUnit != null && !setofRecordTypeIdFromUnit.isEmpty()){
               system.debug('entered into future method');
               UnitCategoryDetailsFutureClass.FutureUnitCategoryDetails(setOfUnitCategoryParentId,setOfRecordTypeDevNameFromUnit,setofRecordTypeIdFromUnit);
        }*/
        
        /*//Here we called future method 
        if(setUnitCatParentId != null && !setUnitCatParentId.isEmpty()
           && setOfRecordTypeDevName != null && !setOfRecordTypeDevName.isEmpty()
           && setofRecordTypeId != null && !setofRecordTypeId.isEmpty()){
               system.debug('entered into future method');
               UnitCategoryDetailsFutureClass.FutureUnitCategoryDetails(setUnitCatParentId,setOfRecordTypeDevName,setofRecordTypeId);
           }*/
    }
    
    /*//This Method is used to add error,when we change isActive field true and  parent record category(record type) is different 
    private static void handleBeforeUpdate(List<Unit_Category_Details__c> triggerNew, Map<Id, Unit_Category_Details__c> triggerOldMap){
        set<id> setParentId = new  set<id>();
       // set<string> setOfunitCategory = new set<string>();
        //map<string,string> mapOfRecordTypeNameVsCategory = new map<string,string>();
        list<Unit_Category__mdt> lstUnitCategoryMdt;
        map<id,string> mapOfIdVsCategory = new map<id,string>();
        list<User_Requirement_ID__c> lstUserReq;
        if(triggerNew!=null && !triggerNew.isEmpty()){
            for(Unit_Category_Details__c eachUnitCategory :triggerNew ){
                if(eachUnitCategory.IsActive__c !=triggerOldMap.get(eachUnitCategory.id).IsActive__c && eachUnitCategory.IsActive__c==true 
                   && string.isNotBlank(eachUnitCategory.User_Requirement_ID__c) ){
                       setParentId.add(eachUnitCategory.User_Requirement_ID__c);
                       if(string.isNotBlank(eachUnitCategory.Category_Details__c)){
                           //setOfunitCategory.add(eachUnitCategory.Category_Details__c);
                       }
                       
                   }
            }
        }
      
      
     
        if(setParentId!=null && !setParentId.isEmpty()){
           lstUserReq = [SELECT id,category__c,status__c
                         FROM User_Requirement_ID__c 
                         WHERE id in : setParentId];
        }
        if(lstUserReq != null && !lstUserReq.isEmpty()){
            for(User_Requirement_ID__c eachUser : lstUserReq ){
                string Status;
                if(string.isNotBlank(eachUser.Status__c)){
                    Status = eachUser.Status__c;
                }
                system.debug('DevnameAndStatus::'+Status);
                if(!mapOfIdVsCategory.containsKey(eachUser.Id) && string.isNotBlank(Status)){
                   mapOfIdVsCategory.put(eachUser.Id,Status);
                }
            }
        }
        if(triggerNew != null && !triggerNew.isEmpty()){
            for(Unit_Category_Details__c eachUnitCategory :triggerNew ){
                 string categoryDetails;
                if( string.isNotBlank(eachUnitCategory.Category_Details__c)){
                    categoryDetails = 'Incomplete';
                }
                system.debug('recordTypeDevName::'+categoryDetails);
                if(mapOfIdVsCategory.containsKey(eachUnitCategory.User_Requirement_ID__c) && eachUnitCategory.IsActive__c==true){
                    system.debug('mapOfIdVsCategory.get(eachUnitCategor::::'+mapOfIdVsCategory.get(eachUnitCategory.User_Requirement_ID__c));
                    if(categoryDetails != mapOfIdVsCategory.get(eachUnitCategory.User_Requirement_ID__c)){
                        eachUnitCategory.addError('Please Check the Status');
                    }
                }
            }
        }
    }*/
}