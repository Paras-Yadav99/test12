public class AccountTriggerHandler implements ITriggerHandler{
    private static final string DEVELOPER_NAME = 'Account';
    public Trigger_Setting__mdt setTriggerSettings() {
        
        
        return [select Active__c,Max_Loop_Count__c,Stop_Recursion__c FROM Trigger_Setting__mdt 
                Where DeveloperName=:DEVELOPER_NAME LIMIT 1];
        
    } 
    
    Public void beforeInsert(List<SObject> triggerNew){
        //handleBeforeInsert((List<opportunity>)triggerNew);
        
    }
    //By implementing this method trigger can handle all the before Update events
    Public void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){    
        //handleBeforeUpdate((List<opportunity>)triggerNew,(Map<Id, opportunity>)triggerOldMap);
    }
    //By implementing this method trigger can handle all the before Delete events
    Public void beforeDelete(List<SObject> triggerOld){
        
    }   
    //By implementing this method trigger can handle all the after Insert events
    Public void afterInsert(List<SObject> triggerNew){
        handleAfterInsert((List<Account>) triggerNew);
    }
    //By implementing this method trigger can handle all the after Update events
    Public void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){
        handleAfterUpdate((List<Account>) triggerNew, (Map<Id, Account>) triggerOldMap);
        //handleCreateTaskOnAfterUpdate((List<Account>) triggerNew, (Map<Id, Account>) triggerOldMap);
       //handleCreateTaskOnAfterUpdate( (List<Account>) triggerNew, (Map<Id, Account>) triggerOldMap);
    }
    //By implementing this method trigger can handle all the after Delte events
    Public void afterDelete(List<SObject> triggerOld){
        
    }
    //By implementing this method trigger can handle all the after UnDelete events
    Public void afterUndelete(List<SObject> triggerNew){
        
    }
    public static void handleAfterInsert(
        list<Account> lstTriggerNew 
    ){
        recordType AccountRecordType;
        system.debug('system.Label.Marketing_Detail_Account::'+system.Label.Marketing_Detail_Account);
        if(string.isNotBlank(system.Label.Marketing_Detail_Account)){
            system.debug('lfgiadbhgolasezd');
            AccountRecordType = [SELECT Id,DeveloperName  
                                              FROM recordType
                                              WHERE DeveloperName =:Label.Marketing_Detail_Account limit 1 ];
        }
        list<Fields_For_Marketing_Checkbox__mdt> lstofFields = [SELECT Id, Client_Type_For_Marketing_Checkbox__c,
                                                                    Client_Type_For_Marketing_Checkbox__r.Client_Type__c, 
                                                                    Checkbox_field_API_Name__c, Checked__c, DeveloperName 
                                                                FROM Fields_For_Marketing_Checkbox__mdt];
        system.debug('lstofFields'+lstofFields.size());
        map<String,list<String>>mapOfClientTypeVsListOfField = new map<String,list<String>>();
        if(lstofFields!=null && !lstofFields.isempty()){
            for(Fields_For_Marketing_Checkbox__mdt eachfield : lstofFields){
                if(!mapOfClientTypeVsListOfField.containskey(eachfield.Client_Type_For_Marketing_Checkbox__r.Client_Type__c)){
                    mapOfClientTypeVsListOfField.put(eachfield.Client_Type_For_Marketing_Checkbox__r.Client_Type__c,new list<String>());
                    mapOfClientTypeVsListOfField.get(eachfield.Client_Type_For_Marketing_Checkbox__r.Client_Type__c).add(eachfield.Checkbox_field_API_Name__c);
                }else{
                    mapOfClientTypeVsListOfField.get(eachfield.Client_Type_For_Marketing_Checkbox__r.Client_Type__c).add(eachfield.Checkbox_field_API_Name__c);
                }
            }
        }
        system.debug('mapOfClientTypeVsListOfField'+mapOfClientTypeVsListOfField);
        list<Marketing_Detail__c> lstMarketingDetail = new list<Marketing_Detail__c>();
        if(lstTriggerNew!=null && !lstTriggerNew.isEmpty()){
            for(Account eachAccount : lstTriggerNew){
                //String subject, String WhatId, String WhoId, Date ActivityDate, string OwnerId, String status)
                Task newTask = CreateTask.createNewTask('Update Marketing Details',
                                                        eachAccount.id,
                                                        null,
                                                        System.TODAY(),
                                                        eachAccount.OwnerId,
                                                        'New');
                
                
                if(mapOfClientTypeVsListOfField.get(eachAccount.Client_Type__c)!=null && 
                  !mapOfClientTypeVsListOfField.get(eachAccount.Client_Type__c).isEmpty()){
                      system.debug('mapOfClientTypeVsListOfField::'+mapOfClientTypeVsListOfField.get(eachAccount.Client_Type__c));
                      Marketing_Detail__c eachMarketingDetail = new Marketing_Detail__c();
                      eachMarketingDetail.Name = eachAccount.Name;
                      if(AccountRecordType != null){ 
                          eachMarketingDetail.RecordTypeId = AccountRecordType.id;
                      }
                      eachMarketingDetail.Account__c = eachAccount.id;
                      for(string eachString : mapOfClientTypeVsListOfField.get(eachAccount.Client_Type__c)){
                          eachMarketingDetail.put(eachString,True);
                      }
                      lstMarketingDetail.add(eachMarketingDetail);
                  }else{
                      Marketing_Detail__c eachMarketingDetail = new Marketing_Detail__c();
                      eachMarketingDetail.Name = eachAccount.Name;
                      if(AccountRecordType != null){ 
                          eachMarketingDetail.RecordTypeId = AccountRecordType.id;
                      }
                      eachMarketingDetail.Account__c = eachAccount.id;
                      
                      lstMarketingDetail.add(eachMarketingDetail);
                  }
                      
            }
            if(lstMarketingDetail!=null && !lstMarketingDetail.isEmpty()){
                insert lstMarketingDetail;
            }
        }
    }
    private static void handleAfterUpdate(
        list<Account> lstTriggerNew , 
        Map<Id, Account> mapTriggerOldMap
    ){
         
        
        if(lstTriggerNew!=null && !lstTriggerNew.isEmpty()){
            //list<id> lstAccountIds = new list<id>();
            list<Task> lstTask = new list<Task>();
            set<Id> setUserIds = new set<Id>();
            list<Id> listOfUserId = new list<Id>();
            
            set <id> setOfAccountId = new set<Id>();
            map<Id,Marketing_Detail__c>mapOfAccountIdVsLstMarketingDetail = new map<Id,Marketing_Detail__c>();
            for(Account eachAccount : lstTriggerNew){
                if(eachAccount.Client_Type__c != mapTriggerOldMap.get(eachAccount.Id).Client_Type__c && 
                   string.isNotBlank(eachAccount.Client_Type__c)){
                       setOfAccountId.add(eachAccount.Id);
                   }
                
               /* if(eachAccount.Do_not_market_FB_Marketplace__c != mapTriggerOldMap.get(eachAccount.Id).Do_not_market_FB_Marketplace__c
                   && eachAccount.Do_not_market_FB_Marketplace__c ==false){
                       system.debug('entered');
                       lstAccountIds.add(eachAccount.id);
                       system.debug('lstAccountIds:' + lstAccountIds);
                   }*/
            }
            
            /*if(lstAccountIds!=null && !lstAccountIds.IsEmpty()){
                list<User> lstUser = [SELECT Id, Username, Name 
                                      FROM User 
                                      WHERE name=:System.Label.Outside_East
                                      OR name=:System.Label.Outside_West OR Name=:System.Label.Inside_West];
                if(lstUser!=null && !lstUser.isEmpty()){
                    for(User eachUsers : lstUser){
                        if(eachUsers.Name==System.Label.Inside_West){
                            listOfUserId.add(eachUsers.Id);
                        }
                        system.debug('lstUsers.Id:'+eachUsers.Id);
                        setUserIds.add(eachUsers.Id);
                        
                    }
                }
                
                list<product2> lstProduct;
                
                    lstProduct = [SELECT id,Name,Account__c,Unit_Owner__c,Inventory_Status__c  
                                  FROM product2 
                                  WHERE Account__c IN :lstAccountIds AND Inventory_Status__c='Owned' AND IsActive = true 
                                 ]; 
                    // AND Unit_Owner__c IN : lstUserIds];
               
                
                
                if(lstProduct!=null && !lstProduct.isEmpty()  ){
                    for(product2 eachProduct : lstProduct){
                        system.debug('eachProduct::'+eachProduct);
                        if(setUserIds.Contains(eachProduct.Unit_Owner__c)&& listOfUserId!=null && !listOfUserId.isEmpty()){
                            task newTask = new task();
                            newTask.Subject = 'Post that unit on FB marketplace and the 20 most relevant groups';
                            newTask.ActivityDate = System.today();
                            newTask.Status = 'New';
                            newTask.OwnerId = listOfUserId[0];
                            newTask.WhatId = eachProduct.id;
                            system.debug('newTask::' + newTask);
                            lstTask.add(newTask);
                            system.debug('lstTask::'+lstTask);
                        }
                        else{
                            if( String.isNotBlank(eachProduct.Unit_Owner__c)){
                                task newTask = new task();
                                newTask.Subject = 'Post that unit on FB marketplace and the 20 most relevant groups';
                                newTask.ActivityDate = System.today();
                                newTask.Status = 'New';
                                newTask.OwnerId = eachProduct.Unit_Owner__c;
                                newTask.WhatId = eachProduct.id;
                                system.debug('newTask::' + newTask);
                                lstTask.add(newTask);
                                system.debug('lstTask::' + lstTask); 
                            }
                        }
                    }
                }
                if(lstTask!=null && !lstTask.isEmpty()){
                    system.debug('lstTask::'+lstTask);
                    Insert lstTask;
                }
            }  */
            
            
            
            if(setOfAccountId!= null && !setOfAccountId.isEmpty()){
                recordType AccountRecordType;
                if(string.isNotBlank(system.Label.Marketing_Detail_Account)){
                    AccountRecordType = [SELECT Id,DeveloperName  
                                         FROM recordType
                                         WHERE DeveloperName =:Label.Marketing_Detail_Account limit 1 ];
                    
                }
                list<Fields_For_Marketing_Checkbox__mdt> lstofFields = [SELECT Id, Client_Type_For_Marketing_Checkbox__c,
                                                                        Client_Type_For_Marketing_Checkbox__r.Client_Type__c, 
                                                                        Checkbox_field_API_Name__c, Checked__c, DeveloperName 
                                                                        FROM Fields_For_Marketing_Checkbox__mdt];
                
                map<String,list<String>>mapOfClientTypeVsListOfField = new map<String,list<String>>();
                if(lstofFields!=null && !lstofFields.isempty()){
                    for(Fields_For_Marketing_Checkbox__mdt eachfield : lstofFields){
                        if(!mapOfClientTypeVsListOfField.containskey(eachfield.Client_Type_For_Marketing_Checkbox__r.Client_Type__c)){
                            mapOfClientTypeVsListOfField.put(eachfield.Client_Type_For_Marketing_Checkbox__r.Client_Type__c,new list<String>());
                            mapOfClientTypeVsListOfField.get(eachfield.Client_Type_For_Marketing_Checkbox__r.Client_Type__c).add(eachfield.Checkbox_field_API_Name__c);
                        }else{
                            mapOfClientTypeVsListOfField.get(eachfield.Client_Type_For_Marketing_Checkbox__r.Client_Type__c).add(eachfield.Checkbox_field_API_Name__c);
                        }
                    }
                }
                list<Marketing_Detail__c>lstMarketingDetail = [SELECT Id,  
                                                               Marketed_On_Craigslist__c,  Marketed_On_FB_Marketplace__c, 
                                                               Marketed_On_Fleet_Up_Marketplace__c,  Marketed_On_Instagram__c, 
                                                               Marketed_On_LinkedIn__c, Marketed_On_Machinio__c, Marketed_On_Mascus__c,
                                                               Marketed_on_MT_Crane_Truck__c, Marketed_On_MyLittleSalesman__c,
                                                               Marketed_On_TradeMachines__c, 
                                                               Do_not_market_anywhere__c,
                                                               Unit__c,Opportunity__c,Account__c
                                                               FROM Marketing_Detail__c WHERE Account__c IN : lstTriggerNew 
                                                              ];
                if(lstMarketingDetail!=Null && !lstMarketingDetail.isEmpty()){
                    for(Marketing_Detail__c eachMarketingDetail : lstMarketingDetail){
                        markMarketingDetailRecordNull(eachMarketingDetail);
                        mapOfAccountIdVsLstMarketingDetail.put(eachMarketingDetail.Account__c,eachMarketingDetail);
                        
                        //mapOfAccountIdVsLstMarketingDetail.put(eachMarketingDetail.Account__c,);
                    }
                }
                for(Account eachAccount : lstTriggerNew){
                    if(mapOfAccountIdVsLstMarketingDetail.containsKey(eachAccount.id) &&
                       mapOfAccountIdVsLstMarketingDetail.get(eachAccount.id) != null){
                           Marketing_Detail__c eachMarketingDetail = mapOfAccountIdVsLstMarketingDetail.get(eachAccount.id); 
                           if(mapOfClientTypeVsListOfField.get(eachAccount.Client_Type__c)!=null && 
                              !mapOfClientTypeVsListOfField.get(eachAccount.Client_Type__c).isEmpty()){     
                                  for(string eachString : mapOfClientTypeVsListOfField.get(eachAccount.Client_Type__c)){
                                      eachMarketingDetail.put(eachString,True);
                                  }
                              }
                       } 
                }
                if(mapOfAccountIdVsLstMarketingDetail.values()!= null && 
                   !mapOfAccountIdVsLstMarketingDetail.values().isEmpty()){
                       update mapOfAccountIdVsLstMarketingDetail.values();
                   }
            }  
        }
    }
    
    public static void markMarketingDetailRecordNull(Marketing_Detail__c eachMarketingDetail){
        eachMarketingDetail.Marketed_On_Craigslist__c = False ;
        eachMarketingDetail.Do_not_market_anywhere__c = False ;
        eachMarketingDetail.Marketed_On_FB_Marketplace__c = False ;
        eachMarketingDetail.Marketed_On_Fleet_Up_Marketplace__c = False ;
        eachMarketingDetail.Marketed_On_Instagram__c = False ;
        eachMarketingDetail.Marketed_On_LinkedIn__c = False ;
        eachMarketingDetail.Marketed_On_Machinio__c = False ;
        eachMarketingDetail.Marketed_On_Mascus__c = False ;
        eachMarketingDetail.Marketed_on_MT_Crane_Truck__c =False ;
        eachMarketingDetail.Marketed_On_MyLittleSalesman__c = False ;
        eachMarketingDetail.Marketed_On_TradeMachines__c = False ;
        eachMarketingDetail.Marketed_On_Iron_Connect__c = False ;
        eachMarketingDetail.Market_on_FB_Group__c = False ;
        eachMarketingDetail.Marketed_On_Equipment_Trader__c = false;
        eachMarketingDetail.Marketed_On_RitchieList__c = false;
        eachMarketingDetail.Marketed_On_Rock_Dirt__c = false;
    }    
}