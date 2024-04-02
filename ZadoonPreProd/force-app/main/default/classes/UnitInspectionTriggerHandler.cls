/*
This class is used to handle Trigger Events
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          08-Sept-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/
public class UnitInspectionTriggerHandler  implements ITriggerHandler{
    private static final string DEVELOPER_NAME = 'Unit_Inspection';
    public Trigger_Setting__mdt setTriggerSettings() {
        return [select Active__c,Max_Loop_Count__c,Stop_Recursion__c FROM Trigger_Setting__mdt 
                Where DeveloperName=:DEVELOPER_NAME LIMIT 1];
        
    } 
    
    Public void beforeInsert(List<SObject> triggerNew){
        //handleBeforeInsert((List<opportunity>)triggerNew);
        
    }
    //By implementing this method trigger can handle all the before Update events
    Public void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){    
        handleBeforeUpdate((List<Unit_Inspection__c>)triggerNew,(Map<Id, Unit_Inspection__c>)triggerOldMap);
    }
    //By implementing this method trigger can handle all the before Delete events
    Public void beforeDelete(List<SObject> triggerOld){
        
    }   
    //By implementing this method trigger can handle all the after Insert events
    Public void afterInsert(List<SObject> triggerNew){
    }
    //By implementing this method trigger can handle all the after Update events
    Public void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){
       //  try{
        handleAfterUpdate((List<Unit_Inspection__c>)triggerNew,(Map<Id, Unit_Inspection__c>)triggerOldMap);
       /* } catch (Exception e) {
            // Handle the exception here
            handleException(e);
        }*/
    }
    //By implementing this method trigger can handle all the after Delte events
    Public void afterDelete(List<SObject> triggerOld){
        
    }
    //By implementing this method trigger can handle all the after UnDelete events
    Public void afterUndelete(List<SObject> triggerNew){
        
    }
    
    /**
* This method is used to handle the automation on Before Update
*/
    private static void handleBeforeUpdate(List<Unit_Inspection__c> triggerNew, Map<Id, Unit_Inspection__c> triggerOldMap){
        
        
        String message = 'Only one Inspector can be Acquired at a time for an Unit.';
        set<string>setOfUnitIds = new set<String>();
        list<Unit_Inspection__c>lstUnitInspection = new list<Unit_Inspection__c>();
        Map<String,List<Unit_Inspection__c>> mapUnitIdVsAcquiredFCs =  new Map<String,List<Unit_Inspection__c>> ();
        
        If(triggerNew!=null && !triggerNew.IsEmpty()){
            for(Unit_Inspection__c eachUnitInspection : triggerNew){
                If(String.IsNotBlank(eachUnitInspection.Unit__c)){
                    setOfUnitIds.add(eachUnitInspection.Unit__c);
                    If(String.IsNotBlank(eachUnitInspection.Unit__c) && (eachUnitInspection.Inspecion_Status__c=='Inspector Acquired' )){
                        If(!mapUnitIdVsAcquiredFCs.containsKey(eachUnitInspection.Unit__c)){
                            mapUnitIdVsAcquiredFCs.put(eachUnitInspection.Unit__c,new List<Unit_Inspection__c>());
                        }else{
                            mapUnitIdVsAcquiredFCs.get(eachUnitInspection.Unit__c).add(eachUnitInspection);
                        }
                        
                    }
                }
            }
        }
        
        If(setOfUnitIds!=null && !setOfUnitIds.IsEmpty()){
            lstUnitInspection =[SELECT Id,
                                Name,
                                Inspecion_Status__c,
                                Unit__c
                                FROM Unit_Inspection__c
                                WHERE 
                                Unit__c IN: setOfUnitIds
                                AND  Inspecion_Status__c='Inspector Acquired'
                               ];
        }
        System.debug('Trigger lstFreightCompanyUnitWithParentData :::::..'+lstUnitInspection);
        If(lstUnitInspection!=null && !lstUnitInspection.IsEmpty()){
            
            for(Unit_Inspection__c eachFreightCompanyUnit : lstUnitInspection){
                
                System.debug('No Contains is called:::');
                If(String.IsNotBlank(eachFreightCompanyUnit.Unit__c) && (eachFreightCompanyUnit.Inspecion_Status__c=='Inspector Acquired' )){
                    If(!mapUnitIdVsAcquiredFCs.containsKey(eachFreightCompanyUnit.Unit__c)){
                        mapUnitIdVsAcquiredFCs.put(eachFreightCompanyUnit.Unit__c,new List<Unit_Inspection__c>());
                    }
                    mapUnitIdVsAcquiredFCs.get(eachFreightCompanyUnit.Unit__c).add(eachFreightCompanyUnit);
                    
                }
                
            }
        }
        
        
        If(triggerNew!=null && !triggerNew.IsEmpty()){
            for(Unit_Inspection__c newUnitInspection : triggerNew){
                Unit_Inspection__c oldUnitInspection = triggerOldMap.get(newUnitInspection.Id);
                If(isValueChange(newUnitInspection,oldUnitInspection,'Inspecion_Status__c')
                   && newUnitInspection.Inspecion_Status__c=='Inspector Acquired') {
                       If(mapUnitIdVsAcquiredFCs.containsKey(newUnitInspection.Unit__c) && mapUnitIdVsAcquiredFCs.get(newUnitInspection.Unit__c) != null && ! mapUnitIdVsAcquiredFCs.get(newUnitInspection.Unit__c).IsEmpty()){
                           newUnitInspection.addError(message);
                       }
                   }
            }
        }
    }
    
    
    
    
    /**
* This Method is used to Handle all the events on After Update on Unit_Insopection__c sObject records..
* 
*/
    
    Private static void handleAfterUpdate(list<Unit_Inspection__c> triggerNew ,  Map<Id, Unit_Inspection__c> triggerOldMap ){
        Set<Id> setOfUnitId = new Set<Id>();
        Set<Id> setOfUnitInspectionId = new Set<Id>();
        Set<String> setOppStageNames = new Set<String>{'Offer Accepted','Pro Forma Sent','Client Inspection Requested','Client Inspection Scheduled','Inspection Pending','Inspection Scheduled','Client Inspection Completed','Inspection Completed'};
        List<Product2> lstUnits = new List<Product2>();
        List<Opportunity>lstOpportunity = new List<Opportunity>();
        
        Map<String,List<Unit_Inspection__c>> mapUnitIdVsNonShortListedUIs =  new Map<String,List<Unit_Inspection__c>> ();
        Map<String, Opportunity> mapIdVsOpportunity = new Map<String, Opportunity>();
        Map<String, Opportunity> mapUnitIdVsOpportunityToBeUpdated = new Map<String, Opportunity>();
        Map<Id,Product2> mapOfIdVsProduct2 = new Map<Id,Product2>();	
        Map<String,List<Opportunity>> mapUnitIdVsLstOpportunity = new Map<String,List<Opportunity>>();
        //SELECT Id, Inspecion_Status__c, Inspecion_Account__c, Unit__c, Inspection_Inspector__c, Quote_Amount__c, Inspection_Date__c FROM Unit_Inspection__c
        Map<String,User> mapNameVsUser = new Map<String,User>();
        list<task> lstTaskToInsert = new list<task>();
        List<Unit_Inspection__c>lstUnitInspectionWithParentData = new List<Unit_Inspection__c>();
        
        List<Unit_Inspection__c>lstTriggerNewUnitInspectionWithParentData = new List<Unit_Inspection__c>();
        List<Unit_Inspection__c>lstUnitInspectionToBeDeleted = new List<Unit_Inspection__c>();

        Map<String,Product2>mapToUpdateIdVsUnit = new Map<String, Product2>();
        
        //Opp_Rec_Type_Broker_Sell
        String Opp_Rec_Type_Broker_Sell_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_Type_Broker_Sell).getRecordTypeId();
        //Opp_Rec_Type_Inventory_Sell
        String Opp_Rec_Type_Inventory_Sell_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_Type_Inventory_Sell).getRecordTypeId();
        //Opp_Rec_type_Dev_Name_procurement_opp
        String Opp_Rec_type_Dev_Name_procurement_opp_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
        
        
        list<User> lstUser = [SELECT Id, Username, Name 
                              FROM User 
                              WHERE IsActive  = true];
        if(lstUser!=null && !lstUser.isEmpty()){
            for(User eachUsers : lstUser){
                mapNameVsUser.put(eachUsers.Name,eachUsers);                    
            }
        }
        for(Unit_Inspection__c newUnitInspection : triggerNew){
            Unit_Inspection__c oldUnitInspection = triggerOldMap.get(newUnitInspection.Id);
            
            If(String.IsNotBlank(newUnitInspection.Unit__c)){
                setOfUnitId.add(newUnitInspection.Unit__c);
                setOfUnitInspectionId.add(newUnitInspection.Id);
            }
        }
        If(setOfUnitInspectionId!= Null && !setOfUnitInspectionId.IsEmpty()){
            lstUnitInspectionWithParentData = [SELECT Id, 
                                               Name, 
                                               Inspecion_Status__c, 
                                               Inspection_Inspector__c, 
                                               Inspecion_Account__c, 
                                               Unit__c,
                                               Unit__r.ZID__c,
                                               Unit__r.Site_Contact__r.Name,
                                               Unit__r.Site_Contact_Mobile__c,
                                               Unit__r.Name,
                                               Unit__r.Year__c,
                                               Unit__r.Manufacturer__c,
                                               Unit__r.Model__c,
                                               Unit__r.Storage_Zip_Code__c,
                                               Unit__r.Storage_Address__c,
                                               Unit__r.Serial_Number__c,
                                               Unit__r.Storage_State__c,
                                               Unit__r.Storage_City__c,
                                               Inspection_Inspector__r.Email,
                                               Inspection_Inspector__r.FirstName,
                                               Inspection_Inspector__r.Name,
                                               Inspection_Date__c, 
                                               Quote_Amount__c, 
                                               Associated_Opportunity__c 
                                               FROM Unit_Inspection__c
                                               WHERE Unit__c IN : setOfUnitId
                                              ];
         }
         System.debug('Trigger lstUnitInspectionWithParentData :::::..'+lstUnitInspectionWithParentData);
        If(lstUnitInspectionWithParentData!=null && !lstUnitInspectionWithParentData.IsEmpty()){
            
            for(Unit_Inspection__c eachUnitIns : lstUnitInspectionWithParentData){
                IF(!setOfUnitInspectionId.contains(eachUnitIns.Id)){
					System.debug('No Contains is called:::');
                    If(String.IsNotBlank(eachUnitIns.Unit__c) && (eachUnitIns.Inspecion_Status__c!='Vendor Acquired' && eachUnitIns.Inspecion_Status__c!='Completed')){
                        If(!mapUnitIdVsNonShortListedUIs.containsKey(eachUnitIns.Unit__c)){
                            mapUnitIdVsNonShortListedUIs.put(eachUnitIns.Unit__c,new List<Unit_Inspection__c>());
                        }
                            mapUnitIdVsNonShortListedUIs.get(eachUnitIns.Unit__c).add(eachUnitIns);
                        
                    }
                }else{
                    lstTriggerNewUnitInspectionWithParentData.add(eachUnitIns);
                }
            }
        }
        
        If(setOfUnitId!= Null && !setOfUnitId.IsEmpty()){
            lstOpportunity = [SELECT Id,
                              StageName,
                              recordTypeId,
                              Product__c 
                              FROM Opportunity 
                              WHERE Product__c IN : setOfUnitId
                              AND Product__c != null
                              AND stageName IN :setOppStageNames];
        }
        
        // filling the map mapUnitIdVsLstOpportunity
        If(lstOpportunity!= Null && !lstOpportunity.IsEmpty()){
            for(Opportunity eachOpportunity : lstOpportunity){
                If(!mapUnitIdVsLstOpportunity.containsKey(eachOpportunity.Product__c)){
                    mapUnitIdVsLstOpportunity.put(eachOpportunity.Product__c, new list<Opportunity>());
                }
                mapUnitIdVsLstOpportunity.get(eachOpportunity.Product__c).add(eachOpportunity);
                mapIdVsOpportunity.put(eachOpportunity.Id,eachOpportunity);
            }
        }
        
        for(Unit_Inspection__c newUnitInspection : lstTriggerNewUnitInspectionWithParentData){
            Unit_Inspection__c oldUnitInspection = triggerOldMap.get(newUnitInspection.Id);
            
            If(isValueChange(newUnitInspection,oldUnitInspection,'Quote_Amount__c')||isValueChange(newUnitInspection,oldUnitInspection,'Inspection_Date__c')){
                task newTask = new task();
                if(mapNameVsUser.containsKey(System.Label.Office_Manager)){
                    newTask = CreateTask.createNewTask('Inspection Quote Amount or Insppection Date is updated!!', 
                                                       newUnitInspection.id,
                                                       null, 
                                                       System.today(), 
                                                       mapNameVsUser.get(System.Label.Office_Manager).Id,
                                                       'New');
                }
                newTask.Description = 'Ensure Inspection Quote Amount or Inspection Date is Updates are updated.';
                lstTaskToInsert.add(newTask); 
                
                
                
            }
            If(String.IsNotBlank(newUnitInspection.Unit__c) && isValueChange(newUnitInspection,oldUnitInspection,'Inspecion_Status__c')&& newUnitInspection.Inspecion_Status__c == 'Quotes Received'){
                If(String.isNotBlank(newUnitInspection.Associated_Opportunity__c) && 
                   mapIdVsOpportunity.containsKey(newUnitInspection.Associated_Opportunity__c) && 
                   mapIdVsOpportunity.get(newUnitInspection.Associated_Opportunity__c)!= null){
                        
                            /*System.debug('Requied If Is Called with :::'+newUnitInspection);
                            Product2 newUnitToUpdate = new Product2();
                            newUnitToUpdate.Id = newUnitInspection.Unit__c;
                            newUnitToUpdate.Inspection_Status__c = newUnitInspection.Inspecion_Status__c;
                            //newUnitToUpdate.Freight_Vendor_Quote_add_to_unit_page__c= newUnitInspection.Freight_Quoted_Amount__c;
                            mapToUpdateIdVsUnit.put(newUnitInspection.Unit__c,newUnitToUpdate);*/
                       
                    opportunity eachOpportunity = mapIdVsOpportunity.get(newUnitInspection.Associated_Opportunity__c);
                     if(eachOpportunity.StageName =='offer accepted' && eachOpportunity.RecordTypeId==Opp_Rec_type_Dev_Name_procurement_opp_Id){
                            Opportunity OppToBeUpdated = new Opportunity();
                            OppToBeUpdated.Id = eachOpportunity.Id;
                            OppToBeUpdated.stageName = 'Inspection Pending';
                            mapUnitIdVsOpportunityToBeUpdated.put( OppToBeUpdated.Id, OppToBeUpdated);
                           // break;
                        }else if(eachOpportunity.StageName =='Pro Forma Sent' && (eachOpportunity.RecordTypeId==Opp_Rec_Type_Broker_Sell_Id)){
                            Opportunity OppToBeUpdated = new Opportunity();
                            OppToBeUpdated.Id = eachOpportunity.Id;
                            OppToBeUpdated.stageName = 'Client Inspection Requested';
                            mapUnitIdVsOpportunityToBeUpdated.put( OppToBeUpdated.Id, OppToBeUpdated);
                        }
                   }else if(String.IsNotBlank(newUnitInspection.Unit__c) && mapUnitIdVsLstOpportunity.containsKey(newUnitInspection.Unit__c) && mapUnitIdVsLstOpportunity.get(newUnitInspection.Unit__c)!= null && !mapUnitIdVsLstOpportunity.get(newUnitInspection.Unit__c).IsEmpty()){
                    for(Opportunity eachOpportunity : mapUnitIdVsLstOpportunity.get(newUnitInspection.Unit__c)){
                        if(eachOpportunity.StageName =='offer accepted' && eachOpportunity.RecordTypeId==Opp_Rec_type_Dev_Name_procurement_opp_Id){
                            Opportunity OppToBeUpdated = new Opportunity();
                            OppToBeUpdated.Id = eachOpportunity.Id;
                            OppToBeUpdated.stageName = 'Inspection Pending';
                            mapUnitIdVsOpportunityToBeUpdated.put( OppToBeUpdated.Id, OppToBeUpdated);
                            break;
                        }else if(eachOpportunity.StageName =='Pro Forma Sent' && (eachOpportunity.RecordTypeId==Opp_Rec_Type_Broker_Sell_Id)){
                            Opportunity OppToBeUpdated = new Opportunity();
                            OppToBeUpdated.Id = eachOpportunity.Id;
                            OppToBeUpdated.stageName = 'Client Inspection Requested';
                            mapUnitIdVsOpportunityToBeUpdated.put( OppToBeUpdated.Id, OppToBeUpdated);
                        }
                    }
                        
                }
                
                System.debug('Requied If Is Called with :::'+newUnitInspection);
                            Product2 newUnitToUpdate = new Product2();
                            newUnitToUpdate.Id = newUnitInspection.Unit__c;
                            newUnitToUpdate.Inspection_Status__c = newUnitInspection.Inspecion_Status__c;
                            //newUnitToUpdate.Freight_Vendor_Quote_add_to_unit_page__c= newUnitInspection.Freight_Quoted_Amount__c;
                            mapToUpdateIdVsUnit.put(newUnitInspection.Unit__c,newUnitToUpdate);
            }
            System.debug('Requied If Is Called with :::'+newUnitInspection);
            If(isValueChange(newUnitInspection,oldUnitInspection,'Inspecion_Status__c')&& newUnitInspection.Inspecion_Status__c == 'Inspector Acquired'){
                if(String.IsNotBlank(newUnitInspection.Unit__c)){
                    System.debug('Requied If Is Called with :::'+newUnitInspection);
                    decimal fRAmount =  newUnitInspection.Quote_Amount__c;
                    Product2 newUnitToUpdate = new Product2();
                    newUnitToUpdate.Id = newUnitInspection.Unit__c;
                    newUnitToUpdate.Inspection_Status__c = newUnitInspection.Inspecion_Status__c;
                    newUnitToUpdate.Inspection_Inspector__c = newUnitInspection.Inspection_Inspector__c;
                    //newUnitToUpdate.Freight_Vendor_Quote_add_to_unit_page__c= newUnitInspection.Freight_Quoted_Amount__c;
                    mapToUpdateIdVsUnit.put(newUnitInspection.Unit__c,newUnitToUpdate);
                    
                    If(mapUnitIdVsNonShortListedUIs.get(newUnitInspection.Unit__c) != null 
                       && !mapUnitIdVsNonShortListedUIs.get(newUnitInspection.Unit__c).IsEmpty()){
                           System.debug('mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c):::'+mapUnitIdVsNonShortListedUIs.get(newUnitInspection.Unit__c));
                           sendEmailsToNonShortListedInspectorss(mapUnitIdVsNonShortListedUIs.get(newUnitInspection.Unit__c),fRAmount);
                       }
                    SendEmailToSelectedInspector(newUnitInspection);
                }
                if(String.IsNotBlank(newUnitInspection.Unit__c) && mapUnitIdVsLstOpportunity.containsKey(newUnitInspection.Unit__c) && mapUnitIdVsLstOpportunity.get(newUnitInspection.Unit__c)!= null && !mapUnitIdVsLstOpportunity.get(newUnitInspection.Unit__c).IsEmpty()){
					 System.debug('Requied If Is Called with :::'+newUnitInspection);
                   /*  decimal fRAmount =  newUnitInspection.Quote_Amount__c;
                            Product2 newUnitToUpdate = new Product2();
                            newUnitToUpdate.Id = newUnitInspection.Unit__c;
                            newUnitToUpdate.Inspection_Status__c = newUnitInspection.Inspecion_Status__c;
                            //newUnitToUpdate.Freight_Vendor_Quote_add_to_unit_page__c= newUnitInspection.Freight_Quoted_Amount__c;
                            mapToUpdateIdVsUnit.put(newUnitInspection.Unit__c,newUnitToUpdate);
                    		
                    		 If(mapUnitIdVsNonShortListedUIs.get(newUnitInspection.Unit__c) != null 
                               && !mapUnitIdVsNonShortListedUIs.get(newUnitInspection.Unit__c).IsEmpty()){
                                   System.debug('mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c):::'+mapUnitIdVsNonShortListedUIs.get(newUnitInspection.Unit__c));
                                   sendEmailsToNonShortListedInspectorss(mapUnitIdVsNonShortListedUIs.get(newUnitInspection.Unit__c),fRAmount);
                            }
                    				SendEmailToSelectedInspector(newUnitInspection);*/
                    
                    for(Opportunity eachOpportunity : mapUnitIdVsLstOpportunity.get(newUnitInspection.Unit__c)){
                        if(eachOpportunity.StageName =='Inspection Pending' && eachOpportunity.RecordTypeId==Opp_Rec_type_Dev_Name_procurement_opp_Id){
                            Opportunity OppToBeUpdated = new Opportunity();
                            OppToBeUpdated.Id = eachOpportunity.Id;
                            OppToBeUpdated.stageName = 'Inspection Scheduled';
                            mapUnitIdVsOpportunityToBeUpdated.put( OppToBeUpdated.Id, OppToBeUpdated);
                            If(String.isNotBlank(newUnitInspection.Associated_Opportunity__c)){
                                if(checkForOppToRetun(newUnitInspection.Associated_Opportunity__c,eachOpportunity.Id)){
                                break; }else{
                                   break;
                                }
                            }
                        }else if(eachOpportunity.StageName =='Client Inspection Requested' && (eachOpportunity.RecordTypeId==Opp_Rec_Type_Inventory_Sell_Id || eachOpportunity.RecordTypeId==Opp_Rec_Type_Broker_Sell_Id)){
                            Opportunity OppToBeUpdated = new Opportunity();
                            OppToBeUpdated.Id = eachOpportunity.Id;
                            OppToBeUpdated.stageName = 'Client Inspection Scheduled';
                            mapUnitIdVsOpportunityToBeUpdated.put( OppToBeUpdated.Id, OppToBeUpdated);
                            If(String.isNotBlank(newUnitInspection.Associated_Opportunity__c) && checkForOppToRetun(newUnitInspection.Associated_Opportunity__c,eachOpportunity.Id)){
                                break;
                            }
                        }
                    }
                }
            }
            //Task for Mellisa to Pay to the Inspector for the inspection after the completion of Inspection
            If(isValueChange(newUnitInspection,oldUnitInspection,'Inspecion_Status__c')&& newUnitInspection.Inspecion_Status__c == 'Completed'){
                System.debug('Requied If Is Called with :::'+newUnitInspection);
                Product2 newUnitToUpdate = new Product2();
                newUnitToUpdate.Id = newUnitInspection.Unit__c;
                newUnitToUpdate.Inspection_Status__c = newUnitInspection.Inspecion_Status__c;
                newUnitToUpdate.Inspection_Completion_Date__c = SYSTEM.TODAY();
                //newUnitToUpdate.Freight_Vendor_Quote_add_to_unit_page__c= newUnitInspection.Freight_Quoted_Amount__c;
                mapToUpdateIdVsUnit.put(newUnitInspection.Unit__c,newUnitToUpdate);
                
                task newTask = new task();
                if(mapNameVsUser.containsKey(System.Label.Admin1)){
                    newTask = CreateTask.createNewTask('Pay for inspection and add URT', 
                                                       newUnitInspection.id,
                                                       null, 
                                                       System.today(), 
                                                       mapNameVsUser.get(System.Label.Admin1).Id,
                                                       'New');
                }
                newTask.Description = 'Ensure Inspection Quote Amount or Inspection Date is Updates are updated.';
                lstTaskToInsert.add(newTask); 
                
                 //To Delete the Un-Selected Freight Compony Units
                If(mapUnitIdVsNonShortListedUIs.get(newUnitInspection.Unit__c) != null 
                   && !mapUnitIdVsNonShortListedUIs.get(newUnitInspection.Unit__c).IsEmpty()){
                       System.debug('mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c):::'+mapUnitIdVsNonShortListedUIs.get(newUnitInspection.Unit__c));
                       lstUnitInspectionToBeDeleted.addAll(mapUnitIdVsNonShortListedUIs.get(newUnitInspection.Unit__c));
                   }
                
                if(String.IsNotBlank(newUnitInspection.Unit__c) && mapUnitIdVsLstOpportunity.containsKey(newUnitInspection.Unit__c) && mapUnitIdVsLstOpportunity.get(newUnitInspection.Unit__c)!= null && !mapUnitIdVsLstOpportunity.get(newUnitInspection.Unit__c).IsEmpty()){
                    
                    
                    for(Opportunity eachOpportunity : mapUnitIdVsLstOpportunity.get(newUnitInspection.Unit__c)){
                        if(eachOpportunity.StageName =='Inspection Scheduled' && eachOpportunity.RecordTypeId==Opp_Rec_type_Dev_Name_procurement_opp_Id){
                            Opportunity OppToBeUpdated = new Opportunity();
                            OppToBeUpdated.Id = eachOpportunity.Id;
                            OppToBeUpdated.stageName = 'Inspection Completed';
                            mapUnitIdVsOpportunityToBeUpdated.put( OppToBeUpdated.Id, OppToBeUpdated);
                           
                            If(String.isNotBlank(newUnitInspection.Associated_Opportunity__c)){
                                if(checkForOppToRetun(newUnitInspection.Associated_Opportunity__c,eachOpportunity.Id)){
                                break; }else{
                                   break;
                                }
                            }
                        }else if(eachOpportunity.StageName =='Client Inspection Scheduled' && (eachOpportunity.RecordTypeId==Opp_Rec_Type_Inventory_Sell_Id || eachOpportunity.RecordTypeId==Opp_Rec_Type_Broker_Sell_Id)){
                            Opportunity OppToBeUpdated = new Opportunity();
                            OppToBeUpdated.Id = eachOpportunity.Id;
                            OppToBeUpdated.stageName = 'Client Inspection Completed';
                            mapUnitIdVsOpportunityToBeUpdated.put( OppToBeUpdated.Id, OppToBeUpdated);
                            If(String.isNotBlank(newUnitInspection.Associated_Opportunity__c) && checkForOppToRetun(newUnitInspection.Associated_Opportunity__c,eachOpportunity.Id)){
                                break;
                            }
                        }
                        
                    }
                }
            }
        }
        
        System.debug('Trigger mapToUpdateIdVsUnit.Values() :::::..'+mapToUpdateIdVsUnit.Values());
        If(mapToUpdateIdVsUnit.Values()!=null && !mapToUpdateIdVsUnit.Values().IsEmpty()){
            Update mapToUpdateIdVsUnit.Values();
        }
        
        If(mapUnitIdVsOpportunityToBeUpdated.Values() != null && ! mapUnitIdVsOpportunityToBeUpdated.Values().IsEmpty()){
            System.debug('mapUnitIdVsOpportunityToBeUpdated.Values():::'+mapUnitIdVsOpportunityToBeUpdated.Values());
            update mapUnitIdVsOpportunityToBeUpdated.Values();
        }
        
        if(lstTaskToInsert!=null && !lstTaskToInsert.isEmpty()){
            System.debug('Task to be created :::'+lstTaskToInsert);
            Insert lstTaskToInsert;
        } 
        
        System.debug('lstUnitInspectionToBeDeleted :::::..'+lstUnitInspectionToBeDeleted);
        If(lstUnitInspectionToBeDeleted!=null && !lstUnitInspectionToBeDeleted.IsEmpty()){
            delete lstUnitInspectionToBeDeleted;
        }

        
    }
    
    //TO check the Field Updates 
    private static Boolean isValueChange(sObject newValue, sObject oldValue,String FieldName){
        return newValue.get(FieldName) != oldValue.get(FieldName);
    }
    
    //TO Validate Opp Id
    private static boolean checkForOppToRetun(string oppIdfromUIs , String OppIdFromLoop){
        return(oppIdfromUIs==OppIdFromLoop);
    }
    
     /*
     * This method is used to sending the Email to the Contact.
	 */
    private static void sendEmailsToNonShortListedInspectorss(List<Unit_Inspection__c>lstUnitInspections, decimal fRAmount){
        System.debug('SEND EMAIL METHOD IS CALLED::::::');
        List<Messaging.SingleEmailMessage> lstMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        for(Unit_Inspection__c eachUnitINS: lstUnitInspections){
           lstMessagingSingleEmailMessage.add(getEmails(eachUnitINS,fRAmount)); 
        }
		System.debug('List of email tobe sent ::::'+lstMessagingSingleEmailMessage);        
        Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(lstMessagingSingleEmailMessage);
        
    }
    
    
    /*
     * This method is used to sending the Email to the Contact.
	 */
        
    private static Messaging.SingleEmailMessage getEmails(Unit_Inspection__c eachUnitInspection,decimal fRAmount) {
        //Freight_Company_Unit__r.Associated_Unit__r.
        //String emailSubject ='Freight Request:';
        String Subject ='Inspection Request:';
        If(String.IsNotBlank(eachUnitInspection.Unit__r.Year__c)){
            Subject +=' '+eachUnitInspection.Unit__r.Year__c;
        }
        If(String.IsNotBlank(eachUnitInspection.Unit__r.Manufacturer__c)){
            Subject +=' '+eachUnitInspection.Unit__r.Manufacturer__c;
        }
        If(String.IsNotBlank(eachUnitInspection.Unit__r.Model__c)){
            Subject +=' '+eachUnitInspection.Unit__r.Model__c;
        }
        If(String.IsNotBlank(eachUnitInspection.Unit__r.Storage_City__c)){
            
            Subject +=' '+eachUnitInspection.Unit__r.Storage_City__c;
        }
        If(String.IsNotBlank(eachUnitInspection.Unit__r.Storage_State__c)){
            Subject +=', '+eachUnitInspection.Unit__r.Storage_State__c;
        }
        String emailBody = createEmailTemplate(eachUnitInspection,fRAmount);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{eachUnitInspection.Inspection_Inspector__r.Email});
        email.setSubject(Subject);
        email.setHtmlBody(emailBody);
        return email;
        
    }

    
      /*
     * This method is used to provide the email body to send the Email.
	 */
    private static String createEmailTemplate(Unit_Inspection__c eachUnitInspection, decimal fRAmount){
        String htmlBody ='';
        If(String.isNotBlank(eachUnitInspection.Inspection_Inspector__r.FirstName)){
          htmlBody +=eachUnitInspection.Inspection_Inspector__r.FirstName +',<br><br>';
        }
        
       
        htmlBody +='Thank you for your quote on this job - we have gone with a quote we received for <b> $' + fRAmount +'</b>  for this Inspection.  Let us try and hit on the next one!';     
       
              
        return htmlBody;
    }
    
      /*
     * This method is used to sending the Email to the Contact.
	 */
        
    private static void SendEmailToSelectedInspector(Unit_Inspection__c eachUnitInspection) {
        //Freight_Company_Unit__r.Associated_Unit__r.
        //String emailSubject ='Freight Request:';
        String Subject ='Inspection Request:';
        If(String.IsNotBlank(eachUnitInspection.Unit__r.Year__c)){
            Subject +=' '+eachUnitInspection.Unit__r.Year__c;
        }
        If(String.IsNotBlank(eachUnitInspection.Unit__r.Manufacturer__c)){
            Subject +=' '+eachUnitInspection.Unit__r.Manufacturer__c;
        }
        If(String.IsNotBlank(eachUnitInspection.Unit__r.Model__c)){
            Subject +=' '+eachUnitInspection.Unit__r.Model__c;
        }
        If(String.IsNotBlank(eachUnitInspection.Unit__r.Storage_City__c)){
            
            Subject +=' '+eachUnitInspection.Unit__r.Storage_City__c;
        }
        If(String.IsNotBlank(eachUnitInspection.Unit__r.Storage_State__c)){
            Subject +=', '+eachUnitInspection.Unit__r.Storage_State__c;
        }
        String emailBody = createHtmlBodyForSelectedIns(eachUnitInspection);
        
        List<Messaging.SingleEmailMessage> lstMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        
       
        
		System.debug('List of email tobe sent ::::'+lstMessagingSingleEmailMessage);        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{eachUnitInspection.Inspection_Inspector__r.Email});
        email.setSubject(Subject);
        email.setHtmlBody(emailBody);
        lstMessagingSingleEmailMessage.add(email);
        
        
        Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(lstMessagingSingleEmailMessage);
    }

    
    
    private static String createHtmlBodyForSelectedIns(Unit_Inspection__c eachUnitInspection){
        String InsSiteUrl = ' https://zadoon1234--dev.sandbox.my.salesforce-sites.com/?parm1=';
        String emailBody ='';
        emailBody =eachUnitInspection.Inspection_Inspector__r.FirstName +',<br><br>' +
            'Thank you for your quote! We would love for you to handle this inspection for us. Following are some instructions, please review these prior to sending an inspector out. <b>There is a link in the services requested checklist section where you can complete the inspection.</b><br><br>' +
            'Please include the '+eachUnitInspection.Unit__r.Name +' as the PO# in all documentation, including invoices, credit card authorizations, bills of sale, etc.<br><br>' +
            '<b>Please note that this is a time-sensitive matter</b> - our deal is predicated on the information that you will provide in this inspection. We realize that your schedule may be busy, and we are happy to work with you in terms of getting us on the schedule. However, we require all completed inspection forms, photos, videos, ECU readings, service history, and invoice/receipt etc. to be delivered to us within twenty-four (24) hours of the inspection being completed.<br><br>' +
            '<b><u>Unit Details:</u></b><br><br>' +
            eachUnitInspection.Unit__r.Year__c+' '+eachUnitInspection.Unit__r.Manufacturer__c+' '+ eachUnitInspection.Unit__r.Model__c+'<br>' +
            'SN: '+ eachUnitInspection.Unit__r.Serial_Number__c+'<br>' +
            'PO#:'+ eachUnitInspection.Unit__r.ZID__c+'<br>' +
            'Site Contact: '+ eachUnitInspection.Unit__r.Site_Contact__r.Name+', '+ eachUnitInspection.Unit__r.Site_Contact_Mobile__c+'<br>'+
            eachUnitInspection.Unit__r.Storage_Address__c+'<br>' +
            eachUnitInspection.Unit__r.Storage_City__c+', '+eachUnitInspection.Unit__r.Storage_State__c+', '+eachUnitInspection.Unit__r.Storage_Zip_Code__c+'<br>' +
            'Availability: {!Opportunity.Availability__c}<br>' +
            'Special instructions: {!Opportunity.Special_Instructions__c}<br><br>' +
            '<b>Services requested checklist - all items must be completed!</b><br>' +
            '[&nbsp;&nbsp;] Complete inspection report found here: https://zadoon1234--dev.sandbox.my.salesforce-sites.com/?parm1='+eachUnitInspection.Unit__c +'<br>' +
            '[&nbsp;&nbsp;] Limit tech to two (2) hours on site; should not take more than about 90 minutes to complete this inspection<br>' +
            '&nbsp;&nbsp;&nbsp;'+ '\t\u2022 ' +' If your tech needs more than 2 hours, please have him/her call Hardy (970-310-0202) at the 2-hour point for instructions as to whether to proceed.<br>' +
            '[&nbsp;&nbsp;] Complete the attached inspection form completely (will require running and operating the machine)<br>' +
            '[&nbsp;&nbsp;] If any items on the checklist are not marked "A" please provide an explanation as to why<br>' +
            '[&nbsp;&nbsp;] Obtain pictures/videos (attached to the form or found here) and add them to the inspection report<br>' +
            '[&nbsp;&nbsp;] Obtain a full list of active and archived codes<br>' +
            '[&nbsp;&nbsp;] If you are an on-brand dealer for the machine:<br>' +
            '&nbsp;&nbsp;&nbsp;'+ '\t\u2022 ' +' Provide ECU reading and related info (Matris/CatFacts/KomCare/KomTrax/etc.)<br>' +
            '&nbsp;&nbsp;&nbsp;'+ '\t\u2022 ' +' Provide any service history<br>' +
            '[&nbsp;&nbsp;] Call Hardy at 970-310-0202 while still onsite, but when completed with inspection, for a quick 5-minute phone call<br><br>' +
            '[&nbsp;&nbsp;] To begin the inspection, please click here: '+InsSiteUrl + eachUnitInspection.Unit__c +'<br><br>'+
            'Thanks,<br>';
       
        return emailBody;
    }
    
  
}