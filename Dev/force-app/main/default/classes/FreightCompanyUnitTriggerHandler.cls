/*
This class is used to handle events from Freight_Company_Unit_c sObject
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          06-Aug-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/
public class FreightCompanyUnitTriggerHandler implements ITriggerHandler{
	    private static final string DEVELOPER_NAME = 'Freight_Company_Unit_c';
    public Trigger_Setting__mdt setTriggerSettings() {
        
        
        return [select Active__c,Max_Loop_Count__c,Stop_Recursion__c FROM Trigger_Setting__mdt 
                Where DeveloperName=:DEVELOPER_NAME LIMIT 1];
        
    } 
    
    Public void beforeInsert(List<SObject> triggerNew){
        
    } 
    //By implementing this method trigger can handle all the before Update events
    Public void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){  
       
        handleBeforeUpdate((List<Freight_Company_Unit__c>)triggerNew,(Map<Id, Freight_Company_Unit__c>)triggerOldMap);
       
    }
    //By implementing this method trigger can handle all the before Delete events
    Public void beforeDelete(List<SObject> triggerOld){
        
    }   
    //By implementing this method trigger can handle all the after Insert events
    Public void afterInsert(List<SObject> triggerNew){
        
        
    }
    //By implementing this method trigger can handle all the after Update events
    Public void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){
       
        handleAfterUpdate((List<Freight_Company_Unit__c>)triggerNew,(Map<Id, Freight_Company_Unit__c>)triggerOldMap);
       
    }
    //By implementing this method trigger can handle all the after Delte events
    Public void afterDelete(List<SObject> triggerOld){
        
    }
    //By implementing this method trigger can handle all the after UnDelete events
    Public void afterUndelete(List<SObject> triggerNew){
        
    }
    
        /*
     * This method is used to handle the automation on Before Update
	 */
    private static void handleBeforeUpdate(List<Freight_Company_Unit__c> triggerNew, Map<Id, Freight_Company_Unit__c> triggerOldMap){
        
        
        String message = 'Only one Vendor can be Acquired at a time for an Unit.';
        set<string>setOfUnitIds = new set<String>();
        list<Freight_Company_Unit__c>lstFreightCompanyUnit = new list<Freight_Company_Unit__c>();
        Map<String,List<Freight_Company_Unit__c>> mapUnitIdVsAcquiredFCs =  new Map<String,List<Freight_Company_Unit__c>> ();
        
        If(triggerNew!=null && !triggerNew.IsEmpty()){
            for(Freight_Company_Unit__c eachFreightCompanyUnit : triggerNew){
                If(String.IsNotBlank(eachFreightCompanyUnit.Associated_Unit__c)){
                    setOfUnitIds.add(eachFreightCompanyUnit.Associated_Unit__c);
                    If(String.IsNotBlank(eachFreightCompanyUnit.Associated_Unit__c) && (eachFreightCompanyUnit.Freight_Status__c=='Vendor Acquired' )){
                        If(!mapUnitIdVsAcquiredFCs.containsKey(eachFreightCompanyUnit.Associated_Unit__c)){
                            mapUnitIdVsAcquiredFCs.put(eachFreightCompanyUnit.Associated_Unit__c,new List<Freight_Company_Unit__c>());
                        }else{
                            mapUnitIdVsAcquiredFCs.get(eachFreightCompanyUnit.Associated_Unit__c).add(eachFreightCompanyUnit);
                        }
                        
                    }
                }
            }
        }
        
        If(setOfUnitIds!=null && !setOfUnitIds.IsEmpty()){
            lstFreightCompanyUnit =[SELECT Id,
                                    Name,
                                    Freight_Status__c,
                                    Associated_Unit__c,
                                    Freight_Company_Account__c
                                    FROM Freight_Company_Unit__c
                                    WHERE 
                                    Associated_Unit__c IN: setOfUnitIds
                                    AND Freight_Company_Account__c !=null
                                    AND  Freight_Status__c='Vendor Acquired'
                                   ];
        }
        System.debug('Trigger lstFreightCompanyUnitWithParentData :::::..'+lstFreightCompanyUnit);
        If(lstFreightCompanyUnit!=null && !lstFreightCompanyUnit.IsEmpty()){
            
            for(Freight_Company_Unit__c eachFreightCompanyUnit : lstFreightCompanyUnit){
                
                System.debug('No Contains is called:::');
                If(String.IsNotBlank(eachFreightCompanyUnit.Associated_Unit__c) && (eachFreightCompanyUnit.Freight_Status__c=='Vendor Acquired' )){
                    If(!mapUnitIdVsAcquiredFCs.containsKey(eachFreightCompanyUnit.Associated_Unit__c)){
                        mapUnitIdVsAcquiredFCs.put(eachFreightCompanyUnit.Associated_Unit__c,new List<Freight_Company_Unit__c>());
                    }
                    mapUnitIdVsAcquiredFCs.get(eachFreightCompanyUnit.Associated_Unit__c).add(eachFreightCompanyUnit);
                    
                }
                
            }
        }
        
                
        If(triggerNew!=null && !triggerNew.IsEmpty()){
            for(Freight_Company_Unit__c eachFreightCompanyUnit : triggerNew){
                Freight_Company_Unit__c oldeachFreightCompanyUnit = triggerOldMap.get(eachFreightCompanyUnit.Id);
                If(eachFreightCompanyUnit.Freight_Quoted_Amount__c != triggerOldMap.get(eachFreightCompanyUnit.Id).Freight_Quoted_Amount__c){
                    eachFreightCompanyUnit.Freight_Status__c = 'Quotes Received';
                    eachFreightCompanyUnit.Quote_Amount_Received_Date__c = SYSTEM.TODAY();
                    eachFreightCompanyUnit.Is_Quote_Recived__c = true;
                    
                }
                Else If(isValueChange(eachFreightCompanyUnit,oldeachFreightCompanyUnit,'Freight_Status__c')
                        && eachFreightCompanyUnit.Freight_Status__c=='Vendor Acquired') {
                            If(mapUnitIdVsAcquiredFCs.containsKey(eachFreightCompanyUnit.Associated_Unit__c) && mapUnitIdVsAcquiredFCs.get(eachFreightCompanyUnit.Associated_Unit__c) != null && ! mapUnitIdVsAcquiredFCs.get(eachFreightCompanyUnit.Associated_Unit__c).IsEmpty()){
                                eachFreightCompanyUnit.addError(message);
                            }else{
                            eachFreightCompanyUnit.Freight_Approved_Date__c = SYSTEM.TODAY();
                            }
                        }
                Else If(isValueChange(eachFreightCompanyUnit,oldeachFreightCompanyUnit,'Freight_Status__c')
                        && eachFreightCompanyUnit.Freight_Status__c=='Machine Loaded') {
                            eachFreightCompanyUnit.Freight_Pickup_Date__c = SYSTEM.TODAY();
                        }
                Else If(isValueChange(eachFreightCompanyUnit,oldeachFreightCompanyUnit,'Freight_Status__c')
                        && eachFreightCompanyUnit.Freight_Status__c=='Completed') {
                            eachFreightCompanyUnit.Freight_Drop_off_Date__c = SYSTEM.TODAY();
                        }
             }
        }
    }
    
    /*
     * This method is used to handle the automation on after Update
	 */
    private static void handleAfterUpdate(List<Freight_Company_Unit__c> triggerNew, Map<Id, Freight_Company_Unit__c> triggerOldMap){
        System.debug('Trigger is Called on After Update..');
        list<Task> lstTask = new list<Task>();
        Map<String,Account>mapToUpdateIdVsAccount = new Map<String, Account>();
        Map<String,Product2>mapToUpdateIdVsUnit = new Map<String, Product2>();
        
        List<Freight_Company_Unit__c> lstFreightCompanyUnitToBeDeleted = new List<Freight_Company_Unit__c>();
        List<Freight_Company_Unit__c> lstFreightCompanyUnitWithParentData = new List<Freight_Company_Unit__c>();
        List<Freight_Company_Unit__c> lstFromTriggerFreightCompanyUnitWithParentData = new List<Freight_Company_Unit__c>();
        Map<String,List<Freight_Company_Unit__c>> mapUnitIdVsNonShortListedFCs =  new Map<String,List<Freight_Company_Unit__c>> ();
        Map<String,String> mapUnitIsVsOppId =  new Map<String,String> ();
        Map<String,Product2> mapUnitIsVsUnit=  new Map<String,Product2> ();
        List<Opportunity>lstOpportunityToUpdate = new list<Opportunity>();
        map<String,User> mapNameVsUser = new map<String,User>();
        
        set<string>setOfIds = new set<String>();
        set<string>setOppIds = new set<String>();
        set<string>setOfUnitIds = new set<String>();
        Map<ID, Opportunity>mapIdVsOpportunity = new map<ID, Opportunity>();
        List<Messaging.SingleEmailMessage> lstMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        
        //Will be used to validate the opp recordtype to be updated
        //Opp_Rec_Type_Broker_Sell
        String Opp_Rec_Type_Broker_Sell_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_Type_Broker_Sell).getRecordTypeId();
        //Opp_Rec_Type_Inventory_Sell
        String Opp_Rec_Type_Inventory_Sell_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_Type_Inventory_Sell).getRecordTypeId();
        
         list<User> lstUser = [SELECT Id, Username, Name,email
                                  FROM User 
                                  WHERE IsActive  = true
                                 ];
            
            if(lstUser!=null && !lstUser.isEmpty()){
                for(User eachUsers : lstUser){
                    mapNameVsUser.put(eachUsers.Name,eachUsers);
                    
                }
            }
        
        
        If(triggerNew!=null && !triggerNew.IsEmpty()){
            for(Freight_Company_Unit__c eachFreightCompanyUnit : triggerNew){
                setOfIds.add(eachFreightCompanyUnit.Id);
                If(String.IsNotBlank(eachFreightCompanyUnit.Associated_sales_procurement_opp__c)){
                    setOppIds.add(eachFreightCompanyUnit.Associated_sales_procurement_opp__c);
                }
                If(String.IsNotBlank(eachFreightCompanyUnit.Associated_Unit__c)){
                    setOfUnitIds.add(eachFreightCompanyUnit.Associated_Unit__c);
                }
                If(String.IsNotBlank(eachFreightCompanyUnit.Associated_Unit__c) && ! mapUnitIsVsOppId.containsKey(eachFreightCompanyUnit.Associated_Unit__c) && String.IsNotBlank(eachFreightCompanyUnit.Associated_sales_procurement_opp__c)){
                    mapUnitIsVsOppId.put(eachFreightCompanyUnit.Associated_Unit__c,eachFreightCompanyUnit.Associated_sales_procurement_opp__c);
                }
            }
        }
        
        If(setOppIds!=null && !setOppIds.IsEmpty()){
            Map<ID, Opportunity> mapOpp = new Map<ID, Opportunity>([SELECT RecordTypeId FROM Opportunity WHERE Id IN : setOppIds]);
            mapIdVsOpportunity = mapOpp;
        }
        
        If(setOfUnitIds!=null && !setOfUnitIds.IsEmpty()){
            lstFreightCompanyUnitWithParentData =[SELECT Id,
                                                  Name,
                                                  Storage_State__c,
                                                  Storage_City__c,
                                                  Destination_Street__c,
                                                  Destination_City__c, 
                                                  Destination_Zip_Code__c,
                                                  Destination_State__c, 
                                                  Destination_Country__c, 
                                                  Destination_Location_Site_Contact__c,
                                                  Quote_Amount_Received_Date__c,
                                                  Freight_Status__c,
                                                  Freight_Quoted_Amount__c,
                                                  Freight_Company_Account__c,
                                                  Freight_Company_Account__r.Name,
                                                  Freight_Company_Account__r.Primary_Contact__c,                                                  
                                                  Freight_Company_Account__r.Primary_Contact__r.Email,
                                                  Freight_Company_Account__r.Primary_Contact_Email__c,
                                                  Freight_Company_Account__r.Selected_For_Freight__c,
                                                  Freight_Company_Account__r.Primary_Contact__r.FirstName,
                                                  Freight_Requestor__c,
                                                  Freight_Requestor__r.Name,
                                                  Freight_Requestor__r.Email,
                                                  Associated_Unit__c,
                                                  Associated_Unit__r.Name,
                                                  Associated_Unit__r.Freight_Vendor_Chosen__c,
                                                  Associated_Unit__r.Make__c,
                                                  Associated_Unit__r.Model__c,
                                                  Associated_Unit__r.Manufacturer__c,
                                                  Associated_Unit__r.Year__c,
                                                  Associated_Unit__r.Zid__c,
                                                  Freight_Ready_to_Move__c ,
                                                  Freight_Pickup_Date__c ,
                                                  Associated_Unit__r.Freight_Ready_to_move__c,
                                                  Associated_Unit__r.Freight_Vendor_Quote_add_to_unit_page__c,
                                                  Associated_Unit__r.Storage_Address__c,
                                                  Associated_Unit__r.Storage_City__c,
                                                  Associated_Unit__r.Storage_Zip_Code__c,
                                                  Associated_Unit__r.Site_Contact__c,
                                                  Associated_Unit__r.Storage_State__c,
                                                  Associated_Unit__r.Storage_Country__c,
                                                  Associated_sales_procurement_opp__c
                                                  FROM Freight_Company_Unit__c
                                                  WHERE //Id IN:setOfIds AND
                                                  Associated_Unit__c IN: setOfUnitIds
                                                  AND Freight_Company_Account__c !=null
                                                 // AND (Freight_Status__c = 'Quotes Received'
                                                     //  OR Freight_Status__c='Vendor Acquired')
                                                     ];
        }
        System.debug('Trigger lstFreightCompanyUnitWithParentData :::::..'+lstFreightCompanyUnitWithParentData);
        If(lstFreightCompanyUnitWithParentData!=null && !lstFreightCompanyUnitWithParentData.IsEmpty()){
            
            for(Freight_Company_Unit__c eachFreightCompanyUnit : lstFreightCompanyUnitWithParentData){
                IF(!setOfIds.contains(eachFreightCompanyUnit.Id)){
					System.debug('No Contains is called:::');
                    If(String.IsNotBlank(eachFreightCompanyUnit.Associated_Unit__c) && (eachFreightCompanyUnit.Freight_Status__c!='Vendor Acquired' && eachFreightCompanyUnit.Freight_Status__c!='Completed')){
                        If(!mapUnitIdVsNonShortListedFCs.containsKey(eachFreightCompanyUnit.Associated_Unit__c)){
                            mapUnitIdVsNonShortListedFCs.put(eachFreightCompanyUnit.Associated_Unit__c,new List<Freight_Company_Unit__c>());
                        }
                            mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c).add(eachFreightCompanyUnit);
                        
                    }
                }else{
                    lstFromTriggerFreightCompanyUnitWithParentData.add(eachFreightCompanyUnit);
                }
            }
        }
        
        //This list for flow have data with Parent's Fields to be use and all the data is avliable in triggerNew 
        If(lstFromTriggerFreightCompanyUnitWithParentData!=null && !lstFromTriggerFreightCompanyUnitWithParentData.IsEmpty()){
            
            for(Freight_Company_Unit__c eachFreightCompanyUnit : lstFromTriggerFreightCompanyUnitWithParentData){
                If(setOfIds.contains(eachFreightCompanyUnit.Id)){
                    /*
 					 * When Ever Quoted amount is updated
                     */
                    Freight_Company_Unit__c oldeachFreightCompanyUnit = triggerOldMap.get(eachFreightCompanyUnit.Id);
                     If(isValueChange(eachFreightCompanyUnit,oldeachFreightCompanyUnit,'Freight_Status__c') 
                   // If(eachFreightCompanyUnit.Freight_Quoted_Amount__c != triggerOldMap.get(eachFreightCompanyUnit.Id).Freight_Quoted_Amount__c 
                       && String.IsNotBlank(eachFreightCompanyUnit.Freight_Status__c) && 
                       eachFreightCompanyUnit.Freight_Status__c == 'Quotes Received'){
                           
                         Messaging.SingleEmailMessage email =  sendEmailToRequester(eachFreightCompanyUnit,eachFreightCompanyUnit.Freight_Quoted_Amount__c);
                          lstMessagingSingleEmailMessage.add(email);
                           /*
                           String subject = 'Quote recived via Email.';
                           task newTask = new task();
                           newTask = CreateTask.createNewTask(subject, 
                                                              eachFreightCompanyUnit.id, 
                                                              null, 
                                                              System.today(), 
                                                              eachFreightCompanyUnit.Freight_Requestor__c,
                                                              'New');
                           
                           system.debug('newTask::' + newTask);
                           lstTask.add(newTask);*/
                           system.debug('Email sent to FReq::');

                       }
                    /*
					 * When Ever Freight Status is updated
					 */
                    If(isValueChange(eachFreightCompanyUnit,oldeachFreightCompanyUnit,'Freight_Status__c') && eachFreightCompanyUnit.Freight_Status__c=='Vendor Acquired'){
                        if(String.IsNotBlank(eachFreightCompanyUnit.Associated_Unit__c)){
                            
                            //Task for Melissa.
                           // If( String.IsNotBlank(system.label.Office_Manager) && mapNameVsUser.containsKey(system.label.Office_Manager) && String.IsNotBlank(mapNameVsUser.get(system.label.Office_Manager).id)){
                            if(String.IsNotBlank(eachFreightCompanyUnit.Freight_Requestor__c)){ 
                            String subject = 'Send Freight Email to Vendor using DropBox.';
                                task newTask = new task();
                                newTask = CreateTask.createNewTask(subject, 
                                                                   eachFreightCompanyUnit.id, 
                                                                   null, 
                                                                   System.today(), 
                                                                   eachFreightCompanyUnit.Freight_Requestor__c,
                                                                   'New');
                                
                               // system.debug('newTask::' + newTask);
                                lstTask.add(newTask);
                               // system.debug('lstTask::'+lstTask);
                            }
                            
                            decimal fRAmount =  eachFreightCompanyUnit.Freight_Quoted_Amount__c;
                          //  System.debug('Requied If Is Called with :::'+eachFreightCompanyUnit);
                            Product2 newUnitToUpdate = new Product2();
                            newUnitToUpdate.Id = eachFreightCompanyUnit.Associated_Unit__c;
                            newUnitToUpdate.Freight_Vendor_Chosen__c = eachFreightCompanyUnit.Freight_Company_Account__c;
                            newUnitToUpdate.Freight_Status__c = eachFreightCompanyUnit.Freight_Status__c;
                            //newUnitToUpdate.Freight_Vendor_Quote_add_to_unit_page__c= eachFreightCompanyUnit.Freight_Quoted_Amount__c;
                            mapToUpdateIdVsUnit.put(eachFreightCompanyUnit.Associated_Unit__c,newUnitToUpdate);
                            
                            if(!mapToUpdateIdVsAccount.containsKey(eachFreightCompanyUnit.Freight_Company_Account__c)){
                                Account newAccountToUpdate = new Account();
                                newAccountToUpdate.Id = eachFreightCompanyUnit.Freight_Company_Account__c;
                                newAccountToUpdate.Selected_for_Freight__c = getNumberOfSelectedForFreight(integer.valueOf(eachFreightCompanyUnit.Freight_Company_Account__r.Selected_For_Freight__c));
                                mapToUpdateIdVsAccount.put(eachFreightCompanyUnit.Freight_Company_Account__c,newAccountToUpdate);
                            }else{
                                Account newAccountToUpdate = new Account();
                                newAccountToUpdate = mapToUpdateIdVsAccount.get(eachFreightCompanyUnit.Freight_Company_Account__c);
                                newAccountToUpdate.Selected_for_Freight__c = getNumberOfSelectedForFreight(integer.valueOf(eachFreightCompanyUnit.Freight_Company_Account__r.Selected_For_Freight__c));
                                mapToUpdateIdVsAccount.put(eachFreightCompanyUnit.Freight_Company_Account__c,newAccountToUpdate);
                            }
                            //Send Email TO non selected 
                            //sendEmailsToNonShortListedFreights(List<Account>lstAccounts,Product2 eachUnit,Freight_Company_Unit__c eachFreight_Company_Unit)
                            If(mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c) != null 
                               && !mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c).IsEmpty()){
                                //   System.debug('mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c):::'+mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c));
                                   List<Messaging.SingleEmailMessage> lstMessagingSingleEmailMessage1 =  sendEmailsToNonShortListedFreights(mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c),fRAmount);
                                   lstMessagingSingleEmailMessage.addall(lstMessagingSingleEmailMessage1);
                                   
                            }
                        }
                    }
                    /*
                     * If Freight Status is Change to Completed
					 */
                    Else If(isValueChange(eachFreightCompanyUnit,oldeachFreightCompanyUnit,'Freight_Status__c')
                       && eachFreightCompanyUnit.Freight_Status__c=='Completed') {
                           Product2 newUnitToUpdate = new Product2();
                           newUnitToUpdate.Id = eachFreightCompanyUnit.Associated_Unit__c;
                           newUnitToUpdate.Freight_Status__c = eachFreightCompanyUnit.Freight_Status__c;
                           newUnitToUpdate.Freight_Requested_Delivery_Date__c = SYSTEM.TODAY();
                           //To Update Unit Address
                           newUnitToUpdate.Storage_Address__c = eachFreightCompanyUnit.Destination_Street__c;
                           newUnitToUpdate.Storage_City__c = eachFreightCompanyUnit.Destination_City__c;
                           newUnitToUpdate.Storage_Zip_Code__c = eachFreightCompanyUnit.Destination_Zip_Code__c;
                           newUnitToUpdate.Site_Contact__c = eachFreightCompanyUnit.Destination_Location_Site_Contact__c;
                           newUnitToUpdate.Storage_State__c = eachFreightCompanyUnit.Destination_State__c;
                           newUnitToUpdate.Storage_Country__c = eachFreightCompanyUnit.Destination_Country__c;
                           mapToUpdateIdVsUnit.put(eachFreightCompanyUnit.Associated_Unit__c,newUnitToUpdate);
// Destination_Street__c, Destination_City__c, Destination_Zip_Code__c, Destination_State__c, Destination_Country__c, Destination_Location_Site_Contact__c
                           If(String.IsNotBlank(eachFreightCompanyUnit.Associated_sales_procurement_opp__c)){
                               If(mapIdVsOpportunity.containsKey(eachFreightCompanyUnit.Associated_sales_procurement_opp__c)){
                                   String oppRecordTypeId = mapIdVsOpportunity.get(eachFreightCompanyUnit.Associated_sales_procurement_opp__c).recordTypeId;
                                   If(oppRecordTypeId==Opp_Rec_Type_Inventory_Sell_Id || oppRecordTypeId==Opp_Rec_Type_Broker_Sell_Id){
                                       //To update Opp as Closed Won
                                       Opportunity newOpportunityToUpdate  = new Opportunity();
                                       newOpportunityToUpdate.Id = eachFreightCompanyUnit.Associated_sales_procurement_opp__c;
                                //       System.debug('Opp update is called..');
                                        newOpportunityToUpdate.StageName = 'Closed Won';
                                       lstOpportunityToUpdate.add(newOpportunityToUpdate);
                                   }
                               }
                                  }
                           //To Delete the Un-Selected Freight Compony Units
                           If(mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c) != null 
                               && !mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c).IsEmpty()){
                               //    System.debug('mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c):::'+mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c));
                                   lstFreightCompanyUnitToBeDeleted.addAll(mapUnitIdVsNonShortListedFCs.get(eachFreightCompanyUnit.Associated_Unit__c));
                            }
                    }Else If(isValueChange(eachFreightCompanyUnit,oldeachFreightCompanyUnit,'Freight_Status__c')
                       && eachFreightCompanyUnit.Freight_Status__c=='Machine Loaded') {
                           Product2 newUnitToUpdate = new Product2();
                           newUnitToUpdate.Id = eachFreightCompanyUnit.Associated_Unit__c;
                           newUnitToUpdate.Freight_Status__c = eachFreightCompanyUnit.Freight_Status__c;
                           mapToUpdateIdVsUnit.put(eachFreightCompanyUnit.Associated_Unit__c,newUnitToUpdate);
                       }
                }
            }
        }
      //  System.debug('Trigger mapToUpdateIdVsAccount.Values() :::::..'+mapToUpdateIdVsAccount.Values());
        If(mapToUpdateIdVsAccount.Values()!=null && !mapToUpdateIdVsAccount.Values().IsEmpty()){
            Update mapToUpdateIdVsAccount.Values();
        }
        
       // System.debug('Trigger mapToUpdateIdVsUnit.Values() :::::..'+mapToUpdateIdVsUnit.Values());
        If(mapToUpdateIdVsUnit.Values()!=null && !mapToUpdateIdVsUnit.Values().IsEmpty()){
            Update mapToUpdateIdVsUnit.Values();
        }
        
       //  System.debug('lstOpportunityToUpdate :::::..'+lstOpportunityToUpdate);
        If(lstOpportunityToUpdate!=null && !lstOpportunityToUpdate.IsEmpty()){
            update lstOpportunityToUpdate;
        }
        
       // System.debug('lstTask :::::..'+lstTask);
        If(lstTask!=null && !lstTask.IsEmpty()){
            Insert lstTask;
        }
        
      //  System.debug('lstFreightCompanyUnitToBeDeleted :::::..'+lstFreightCompanyUnitToBeDeleted);
        If(lstFreightCompanyUnitToBeDeleted!=null && !lstFreightCompanyUnitToBeDeleted.IsEmpty()){
            delete lstFreightCompanyUnitToBeDeleted;
        }
        if(lstMessagingSingleEmailMessage!=null && !lstMessagingSingleEmailMessage.isEmpty()){
            Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(lstMessagingSingleEmailMessage);
        }
        
    }
    
     /*
     * This method is used to get updated values fo Freight Selection for Freight Accounts.
	 */
    
    private static integer getNumberOfSelectedForFreight(integer prevoiusNumberForFreightSelection){
        integer numberOfSelectedForFreight = 1;
        if(prevoiusNumberForFreightSelection>0){
            numberOfSelectedForFreight = 1+ prevoiusNumberForFreightSelection;
        }
        return numberOfSelectedForFreight;
    }
    
     //TO check the Field Updates 
    private static Boolean isValueChange(sObject newValue, sObject oldValue,String FieldName){
        return newValue.get(FieldName) != oldValue.get(FieldName);
    }
    
     /*
     * This method is used to sending the Email to the Contact.
	 */
    private static List<Messaging.SingleEmailMessage> sendEmailsToNonShortListedFreights(List<Freight_Company_Unit__c>lstFreight_Company_Unit, decimal fRAmount){
      //  System.debug('SEND EMAIL METHOD IS CALLED::::::');
        List<Messaging.SingleEmailMessage> lstMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        for(Freight_Company_Unit__c eachFreight_Company_Unit: lstFreight_Company_Unit){
           // Messaging.SingleEmailMessage email = getEmails(eachFreight_Company_Unit,fRAmount);
           lstMessagingSingleEmailMessage.add(getEmails(eachFreight_Company_Unit,fRAmount)); 
        }
        return lstMessagingSingleEmailMessage;
	//	System.debug('List of email tobe sent ::::'+lstMessagingSingleEmailMessage);        
       // Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(lstMessagingSingleEmailMessage);
        
    }
    
    /*
     * This method is used to sending the Email to the Contact.
	 */
        
    private static Messaging.SingleEmailMessage getEmails(Freight_Company_Unit__c eachFreight_Company_Unit,decimal fRAmount) {
        //Freight_Company_Unit__r.Associated_Unit__r.
        String emailSubject ='Freight Request:';
        String str1 = '';
        If(eachFreight_Company_Unit.Associated_Unit__r.Freight_Ready_to_move__c){
            emailSubject +=' ready to move ';
        }else{
            emailSubject +=' quote only ';
        }
        If(String.isNotBlank(eachFreight_Company_Unit.Associated_Unit__r.Year__c)){
            str1 += eachFreight_Company_Unit.Associated_Unit__r.Year__c +' ';
        }
        If(String.isNotBlank(eachFreight_Company_Unit.Associated_Unit__r.Manufacturer__c)){
            str1 += eachFreight_Company_Unit.Associated_Unit__r.Manufacturer__c +' ';
        }
        str1 ='{'+ eachFreight_Company_Unit.Associated_Unit__r.Model__c +'- From '+eachFreight_Company_Unit.Storage_City__c+', '+eachFreight_Company_Unit.Storage_State__c +' }';
        str1 +=' To '+eachFreight_Company_Unit.Destination_City__c+', '+eachFreight_Company_Unit.Destination_State__c +'- PO # '+eachFreight_Company_Unit.Associated_Unit__r.Name;
        emailSubject +=str1;
        
        String emailBody = createEmailTemplate(eachFreight_Company_Unit,fRAmount);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{eachFreight_Company_Unit.Freight_Company_Account__r.Primary_Contact__r.Email});
        email.setSubject(emailSubject);
        email.setHtmlBody(emailBody);
        return email;
        
    }
    
    /*
     * This method is used to provide the email body to send the Email.
	 */
    private static String createEmailTemplate(Freight_Company_Unit__c eachFreight_Company_Unit, decimal fRAmount){
        String htmlBody ='';
        If(String.isNotBlank(eachFreight_Company_Unit.Freight_Company_Account__r.Primary_Contact__r.FirstName)){
          htmlBody +=eachFreight_Company_Unit.Freight_Company_Account__r.Primary_Contact__r.FirstName +',<br><br>';
        }
        
       
        htmlBody +='Thank you for your quote on this job - we have gone with a quote we received for <b> $' + fRAmount +'</b>  for this load.  Let us try and hit on the next one!';     
       
              
        return htmlBody;
    }
    
    /*
     * This method is used to provide the email body to send the Email.
	 */
    private static Messaging.SingleEmailMessage sendEmailToRequester(Freight_Company_Unit__c eachFreight_Company_Unit, decimal fRAmount){
        String fullRecordURL = URL.getOrgDomainURL().toExternalForm() + '/' + eachFreight_Company_Unit.Id;
        String emailSubject= fRAmount +' Freight Quote for ' +eachFreight_Company_Unit.Associated_Unit__r.Year__c +' ';
         emailSubject += eachFreight_Company_Unit.Associated_Unit__r.Make__c +' ' + eachFreight_Company_Unit.Associated_Unit__r.Model__c ;
        emailSubject+=', '+eachFreight_Company_Unit.Associated_Unit__r.Zid__c +' from '+eachFreight_Company_Unit.Freight_Company_Account__r.Name ;
        String htmlBody ='';
        
        If(String.isNotBlank(eachFreight_Company_Unit.Freight_Requestor__r.Name)){
            htmlBody +=eachFreight_Company_Unit.Freight_Requestor__r.Name +',<br><br>';
        }
        system.debug('Test Email Run Sucessful');
        htmlBody +='A quote in the amount of Quote Amount has been received for the following load.<br><br>';
        htmlBody +=' Vendor : '+ eachFreight_Company_Unit.Freight_Company_Account__r.Name  +'<br>';
        htmlBody += ' Unit : ' +eachFreight_Company_Unit.Associated_Unit__r.Year__c +' '+eachFreight_Company_Unit.Associated_Unit__r.Make__c +' '+eachFreight_Company_Unit.Associated_Unit__r.Model__c + ' ' +eachFreight_Company_Unit.Associated_Unit__r.ZID__c +'<br>';
        htmlBody +=' Origin : ' +eachFreight_Company_Unit.Storage_City__c +' '+eachFreight_Company_Unit.Storage_State__c +'<br>';
        htmlBody += ' Destination : ' +eachFreight_Company_Unit.Destination_City__c +' '+eachFreight_Company_Unit.Destination_State__c  +'<br>';
        htmlBody += ' Ready To Move : ' +eachFreight_Company_Unit.Freight_Ready_to_Move__c +'<br>';
        htmlBody += ' Earliest Pickup Date : ' +eachFreight_Company_Unit.Freight_Pickup_Date__c +'<br>';
        system.debug('sendEmailToRequester:::'+eachFreight_Company_Unit.Freight_Requestor__r.Email);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{eachFreight_Company_Unit.Freight_Requestor__r.Email});
        email.setSubject(emailSubject);
        email.setHtmlBody(htmlBody);
        return email;
        //lstMessagingSingleEmailMessage.add(email);
        
        	//System.debug('List of email tobe sent ::::'+lstMessagingSingleEmailMessage);        
        //Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(lstMessagingSingleEmailMessage);
    }
    
  }