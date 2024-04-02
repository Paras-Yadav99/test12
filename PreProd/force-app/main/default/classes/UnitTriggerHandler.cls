public with sharing class UnitTriggerHandler implements ITriggerHandler {
    private static final string DEVELOPER_NAME = 'Unit';
    public Trigger_Setting__mdt setTriggerSettings() {
        return [select Active__c,Max_Loop_Count__c,Stop_Recursion__c FROM Trigger_Setting__mdt 
                Where DeveloperName=:DEVELOPER_NAME LIMIT 1];
    } 
    
    Public void beforeInsert(List<SObject> triggerNew){
        handlebeforeInsert((List<Product2>)triggerNew);   
        //populateEquipmentModel( (List<Product2>)triggerNew);
    } 
    //By implementing this method trigger can handle all the before Update events
    Public void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){  
        handleBeforeUpdate((List<Product2>)triggerNew,(Map<Id, Product2>)triggerOldMap);
        //populateEquipmentModel( (List<Product2>)triggerNew );
    }
    //By implementing this method trigger can handle all the before Delete events
    Public void beforeDelete(List<SObject> triggerOld){
        
    }   
    //By implementing this method trigger can handle all the after Insert events
    Public void afterInsert(List<SObject> triggerNew){
        handleAfterInsert((List<Product2>)triggerNew); 
        if ( UtilityClass.runOnce ) {
            createMatchingIronDemandUnits((List<Product2>)triggerNew,false);
            UtilityClass.runOnce = false;
        }
        //AutoPopulatePricebookEntry((List<Product2>)triggerNew);
        handleAfterUnitInsert((List<Product2>)triggerNew); 
    }
    //By implementing this method trigger can handle all the after Update events
    Public void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){
        handleAfterUpdate((List<Product2>)triggerNew,(Map<Id, Product2>)triggerOldMap);//-- 
        //handleAfterUpdateMarketingDetail((List<Product2>)triggerNew,(Map<Id, Product2>)triggerOldMap);
        if ( UtilityClass.runOnce ) {
            createMatchingIronDemandUnits((List<Product2>)triggerNew,true);
            UtilityClass.runOnce = false;
        }
        
    }
    //By implementing this method trigger can handle all the after Delte events
    Public void afterDelete(List<SObject> triggerOld){
        
    }
    //By implementing this method trigger can handle all the after UnDelete events
    Public void afterUndelete(List<SObject> triggerNew){
        //handleAfterUndelete(Trigger.new, Trigger.newMap);
    }
    
    
    
    public static void handlebeforeInsert(
        List<Product2> units
    ){
        
        PopulateVagueCityHelper helper = new PopulateVagueCityHelper();
        set<Id>setOfYardId = new set<Id>();
        map<id,Yards__c> mapOfPartnerYard;
        Map< ID, Product2 > productMap = new Map< ID, Product2 >([Select id,Model_Unit__c,equipment__r.Model_Equipment__c From Product2 Where ID IN : units]);
           
        for(Product2 unit : units){
            // for( Product2 unit : newList) {
            if( productMap.containsKey(unit.id) && productMap.get(unit.id).equipment__r.Model_Equipment__c != null)
                unit.Model_Unit__c = productMap.get(unit.id).equipment__r.Model_Equipment__c;
        //}
        system.debug('unit.On_Zadoon_partner_yard1__c:::'+unit.On_Zadoon_partner_yard1__c);
            unit.MT_Vague_Display_Location_Name__c = helper.getCity(unit);
            if(unit.IsActive && 
               string.isNotBlank(unit.On_Zadoon_partner_yard1__c)){
                   setOfYardId.add(unit.On_Zadoon_partner_yard1__c);
                   //updateUnitLocation (unit,system.label.Contact_Id_For, '5630 N Highway 441', 
                                      // 'Ocala', 'USA', 'Florida', '34475');
               }
            
            
        }
        if(setOfYardId!=null && !setOfYardId.isEmpty()){
            mapOfPartnerYard =new map<id,Yards__c>([SELECT Id, Storage_City__c, Site_Contact__c, Storage_Zip_Code__c, 
                                                    Storage_Street__c, Storage_State__c, Storage_Country__c
                                                    FROM Yards__c WHERE  Id IN : setOfYardId ]);
        }
        for(Product2 unit : units){
            
            if(//unit.IsActive && 
               string.isNotBlank(unit.On_Zadoon_partner_yard1__c)&&
               mapOfPartnerYard.containsKey(unit.On_Zadoon_partner_yard1__c)&&
              mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c) !=null){
                  unit.Site_Contact__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Site_Contact__c;
                  unit.Storage_City__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Storage_City__c;
                  unit.Storage_Zip_Code__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Storage_Zip_Code__c;
                  unit.Storage_State__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Storage_State__c;
                  unit.Storage_Country__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Storage_Country__c;
                  unit.Storage_Address__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Storage_Street__c;
                  //unit.Site_Contact__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Site_Contact__c;
               }
        }
    }
    public static void handleAfterUpdate(
        List<Product2> units,
        Map<Id, Product2> oldUnitMap){
        list<Task> lstTask = new list<Task>();
        List<Id> filteredUnitsIds = new List<Id>();
       // set<Id> setUserIds = new set<Id>();
        list<lead> lstNewLead;
        map<string,string> mapOfUnitIdvsLeadId = new map<string,string>();
        //    user insideWestUserId;
        set<Id> setOfUnitId = new set<Id>();
        set<Id> setOfUnitIdForOppoName = new set<Id>();
        list<Product2> lstProduct2;
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        //user UserVa = [Select id, Name FROM User WHERE Name =: label.VA LIMIT 1];
        List<Integer> deleteListingIds = new List<Integer>();
       // map<String,RecordType>mapOfDeveloperNameVsRecprdType = new map<String,RecordType>();
        set<id> setProductId = new set<id>();
        set<id> setOfUnitIdToLead = new set<id>();
        list<Unit_Category_Details__c> lstUnitCategoryFromUrID;
        set<string> setproductCategory = new set<string>();
        set<id> setUnitCategoryParentId = new set<id>();
        set<string> setofUnitCategoryToMdt = new set<string>{'Common','URID'};
            set<string> setofUnitCategory = new set<string>();
		set<id> setOfProductIdToDelete = new set<id>();
            list<Iron_Demand__c> lstIronDemand = new list<Iron_Demand__c>();
            //list<task> lstTaskToInsert = new list<task>();
            list<product2> lstUnitUpdate = new list<product2>();
            set<id> setOfProductId = new set<id>();
        map<String,User> mapNameVsUser = new map<String,User>();
        //Opp_Rec_Type_Broker_Sell
        String Opp_Rec_Type_Broker_Sell_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_Type_Broker_Sell).getRecordTypeId();
        //Opp_Rec_Type_Inventory_Sell
        String Opp_Rec_Type_Inventory_Sell_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_Type_Inventory_Sell).getRecordTypeId();
        //Opp_Rec_type_Dev_Name_procurement_opp
        String Opp_Rec_type_Dev_Name_procurement_opp_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
        
        /*list<RecordType>lstRecordType = [SELECT Id, developerName FROM RecordType 
                                             WHERE DeveloperName =: label.Opp_Rec_type_Dev_Name_procurement_opp OR 
                                            DeveloperName =: label.Opp_Rec_Type_Broker_Sell OR 
                                            DeveloperName =: label.Opp_Rec_Type_Inventory_Sell];*/
       /* if(lstRecordType!= Null && !lstRecordType.isEmpty()){
            for(RecordType eachRecordType : lstRecordType ){
                mapOfDeveloperNameVsRecprdType.put(eachRecordType.developerName,eachRecordType);
            } 
        }*/
            list<User> lstUser = [SELECT Id, Username, Name 
                                  FROM User 
                                  WHERE IsActive  = true
                                 ];
        if(lstUser!=null && !lstUser.isEmpty()){
            for(User eachUsers : lstUser){
                mapNameVsUser.put(eachUsers.Name,eachUsers);
            }
        }
        /*if(lstUser!=null && !lstUser.isEmpty()){
            for(User eachUsers : lstUser){
                if(eachUsers.Name==System.Label.Inside_West){
                    insideWestUserId = eachUsers;
                }else{
                    system.debug('lstUsers.Id:'+eachUsers.Id);
                    setUserIds.add(eachUsers.Id);
                }
            }
        }*/
        
        //If Unit isActive field is changed and true
        
        if(units != null && !units.isEmpty()){
            for(Product2 eachProduct :units ){
                Product2 oldProduct = oldUnitMap.get(eachProduct.Id);
                if((hasFieldChanged(eachProduct, oldProduct, 'Year__c') || 
                    hasFieldChanged(eachProduct, oldProduct, 'Manufacturer__c') ||
                    hasFieldChanged(eachProduct, oldProduct, 'Model__c') || 
                    hasFieldChanged(eachProduct, oldProduct, 'Category__c') || 
                    hasFieldChanged(eachProduct, oldProduct, 'Old_SF_Unit_Details__c') || 
                    hasFieldChanged(eachProduct, oldProduct, 'Number_of_Images_in_Google_Drive__c') || 
                    hasFieldChanged(eachProduct, oldProduct, 'Number_of_Videos_in_Google_Drive__c') || 
                    hasFieldChanged(eachProduct, oldProduct, 'Starting_Advertised_Retail_Price__c') || 
                    //hasFieldChanged(unit, oldUnit, 'MT_Live_Advertised__c') || 
                    hasFieldChanged(eachProduct, oldProduct, 'MT_Vague_Display_Location_Name__c') || 
                    hasFieldChanged(eachProduct, oldProduct, 'MT_Location_Vague_Postal_Code__c') || 
                    hasFieldChanged(eachProduct, oldProduct, 'Storage_State__c'))
                  ){
                      filteredUnitsIds.add(eachProduct.Id);
                  } 
                if((hasFieldChanged(eachProduct,oldProduct, 'Old_SF_Unit_Details__c') && eachProduct.Old_SF_Unit_Details__c != null) ||
                   (hasFieldChanged(eachProduct,oldProduct, 'Year__c') && eachProduct.Year__c != null) ||
                   (hasFieldChanged(eachProduct,oldProduct, 'Number_of_Images_in_Google_Drive__c') && eachProduct.Number_of_Images_in_Google_Drive__c != null) ||
                   (hasFieldChanged(eachProduct,oldProduct, 'Number_of_Videos_in_Google_Drive__c') && eachProduct.Number_of_Videos_in_Google_Drive__c != null) || 
                   (hasFieldChanged(eachProduct,oldProduct, 'Starting_Advertised_Retail_Price__c') && eachProduct.Starting_Advertised_Retail_Price__c != null) ||
                   (hasFieldChanged(eachProduct,oldProduct, 'Display_Lowest_Purchase_Price__c') && eachProduct.Display_Lowest_Purchase_Price__c != null) ||
                  (hasFieldChanged(eachProduct,oldProduct, 'Storage_City__c') && string.isnotblank(eachProduct.Storage_City__c)) ||
                  (hasFieldChanged(eachProduct,oldProduct, 'Storage_State__c') && string.isnotblank(eachProduct.Storage_State__c))){
                      string description = '';
                      if(hasFieldChanged(eachProduct,oldProduct, 'Old_SF_Unit_Details__c')){
                          description += 'Old SF Unit Details'+',';
                      }
                       if(hasFieldChanged(eachProduct,oldProduct, 'Year__c')){
                           description += 'Year' + ',';
                       }
                       if(hasFieldChanged(eachProduct,oldProduct, 'Number_of_Images_in_Google_Drive__c')){
                           description += 'Number of Images in Google Drive' + ',';
                       }
                       if(hasFieldChanged(eachProduct,oldProduct, 'Number_of_Videos_in_Google_Drive__c')){
                           description += 'Number of Videos in Google Drive' + ',';
                       }
                       if(hasFieldChanged(eachProduct,oldProduct, 'Starting_Advertised_Retail_Price__c')){
                           description += 'Starting Advertised Retail Price' + ',';
                       }
                       if(hasFieldChanged(eachProduct,oldProduct, 'Display_Lowest_Purchase_Price__c')){
                           description += 'Display Lowest Purchase Price'+' ';
                       }
                      if(hasFieldChanged(eachProduct,oldProduct, 'Storage_City__c')){
                           description += 'Storage City' + ' ';
                      }
                      if(hasFieldChanged(eachProduct,oldProduct, 'Storage_State__c')){
                          description += 'Storage State' + ' ';
                      }
                       if(string.isnotblank(description)){
                           description += 'changed';
                       }
                      
                     /*if(string.isnotblank(eachProduct.Unit_Owner__c)){
                    
                       }*/
                       if(mapNameVsUser.containsKey(system.label.VA)){
                                  string subject = 'Update changed element on FB and all Facebook Groups including Zadoon';
                            if(string.isnotblank(description)){
                                 subject += description;
                             }
                           if (subject.length() > 255) {
                               subject = subject.substring(0, 255);
                               system.debug('subject::'+subject);
                           }
                           system.debug('subject:::'+subject);
                           task newTask1 = 
                               CreateTask.createNewTask(subject,eachProduct.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New'); 
                            if(string.isnotblank(description)){
                                newTask1.Description = description;
                            }
                           if(newTask1!=null){
                               lstTask.add(newTask1);
                               system.debug('Update changed element on FB2:::' + lstTask);
                           } 
                           
                           string subject1 = 'Update changed element on MT,IC,CL';
                             if(string.isnotblank(description)){
                                 subject1 += description;
                             }
                           task newTask2 = 
                               CreateTask.createNewTask(subject1,eachProduct.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New'); 
                           if(string.isnotblank(description)){
                               newTask2.Description = description;
                           }
                           if(newTask2!=null){
                               lstTask.add(newTask2);
                               system.debug('Update changed element2:::' + lstTask);
                           }   
                       }
                       if((hasFieldChanged(eachProduct,oldProduct, 'Starting_Advertised_Retail_Price__c') &&
                           eachProduct.Starting_Advertised_Retail_Price__c != null) && mapNameVsUser.containsKey(system.label.VA) ){
                              task newTask = 
                               CreateTask.createNewTask('Send matching email and MC emails',eachProduct.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New'); 
                           if(newTask!=null){
                               lstTask.add(newTask);
                               system.debug('send matching email:::' + lstTask);

                           }
                       }
                       
                       if(hasFieldChanged(eachProduct,oldProduct, 'Display_Lowest_Purchase_Price__c') &&
                          eachProduct.Display_Lowest_Purchase_Price__c != null && string.isnotblank(eachProduct.Unit_Owner__c)){
                              task newTask = 
                                  CreateTask.createNewTask('Drop sales price accordingly',eachProduct.Id,null,system.today(),eachProduct.Unit_Owner__c,'New'); 
                              if(newTask!=null){
                                  lstTask.add(newTask);
                                  system.debug('Drop sales price accordingly:::' + lstTask);
                              }
                             system.debug('eachProduct.Max_of_Purchased_Created_and_LESC_date__c :::'+eachProduct.Max_of_Purchased_Created_and_LESC_date__c); 
                              
                          }
                      
                  
                       
                }
                if(hasFieldChanged(eachProduct, oldProduct, 'IsActive')){
                    if(eachProduct.Starting_Advertised_Retail_Price__c == null && String.IsNotBlank(eachProduct.Unit_Owner__c) ){
                        task newTask2 = 
                           CreateTask.createNewTask('Update Starting Advertise Retail Price',eachProduct.id,null,system.today(),eachProduct.Unit_Owner__c,'New'); 
                       if(newTask2!=null){
                           lstTask.add(newTask2);
                           system.debug('lstTaskToInsert bucket:::'+lstTask);
                       } 
                    }
                    if(eachProduct.Display_Lowest_Purchase_Price__c == null && String.IsNotBlank(eachProduct.Unit_Owner__c)){
                        task newTask2 = 
                           CreateTask.createNewTask('Update Buy Price',eachProduct.id,null,system.today(),eachProduct.Unit_Owner__c,'New'); 
                       if(newTask2!=null){
                           lstTask.add(newTask2);
                           system.debug('lstTaskToInsert bucket:::'+lstTask);
                       } 
                    }
                    if(eachProduct.Starting_Advertised_Retail_Price__c != null &&
                      eachProduct.Display_Lowest_Purchase_Price__c != null && String.IsNotBlank(eachProduct.Unit_Owner__c)){
                          task newTask2 = 
                              CreateTask.createNewTask('Send Matching Email',eachProduct.id,null,system.today(),eachProduct.Unit_Owner__c,'New'); 
                          if(newTask2!=null){
                              lstTask.add(newTask2);
                              system.debug('lstTaskToInsert bucket:::'+lstTask);
                          }
                    }
                    
                }
                //if unit photo verification field is update,the create a task.
               system.debug('mapNameVsUser.containsKey(system.label.VA):::'+mapNameVsUser.containsKey(system.label.VA));
               system.debug('eachProduct.Is_Photo_verification_completed__c:::'+eachProduct.Is_Photo_verification_completed__c);
                if(hasFieldChanged(eachProduct, oldProduct, 'Is_Photo_verification_completed__c') && 
                   eachProduct.Is_Photo_verification_completed__c == true && 
                   mapNameVsUser.containsKey(system.label.VA) && 
                   string.isnotBlank(eachProduct.Unit_Owner__c)){
                       string subject = 'Send Matching email from unit owner user ';
                       system.debug('subject:::'+subject);
                       task newTask = 
                           CreateTask.createNewTask(subject,eachProduct.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New'); 
                       if(newTask!=null){
                           lstTask.add(newTask);
                           system.debug('lstTaskToInsert bucket:::'+lstTask);
                       }
                       string subject1 = 'Send Mailchimp Email  List on MT , List on IC , List on CL';
                       system.debug('subject:::'+subject1);
                       task newTask1 = 
                           CreateTask.createNewTask(subject1,eachProduct.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New'); 
                       if(newTask1!=null){
                           lstTask.add(newTask1);
                           system.debug('lstTaskToInsert bucket:::'+lstTask);
                       }
                       
                       string subject2 = 'List on FB MP + groups';
                       system.debug('subject:::'+subject2);
                       task newTask2 = 
                           CreateTask.createNewTask(subject2,eachProduct.id,null,system.today(),eachProduct.Unit_Owner__c,'New'); 
                       if(newTask2!=null){
                           lstTask.add(newTask2);
                           system.debug('lstTaskToInsert bucket:::'+lstTask);
                       } 
                       string subject3 = 'List on Zadoon FB Group';
                       system.debug('subject:::'+subject3);
                       task newTask3 = 
                           CreateTask.createNewTask(subject3,eachProduct.id,null,system.today(),eachProduct.Unit_Owner__c,'New'); 
                       if(newTask3 != null){
                           lstTask.add(newTask3);
                           system.debug('lstTaskToInsert bucket:::'+lstTask);
                       }
                }
                system.debug('eachProduct.hour__c:::' + eachProduct.hour__c);
                system.debug('eachProduct.Year__c:::' + eachProduct.Year__c);
                system.debug('eachProduct.Starting_Advertised_Retail_Price__c:::' + eachProduct.Starting_Advertised_Retail_Price__c); 
                //if unit is active and hour,price or year field changes then it call UnitCategoryDetailsFutureClass
                if(eachProduct.IsActive==true && (isValueChange(eachProduct,oldProduct,'hour__c') 
                   || isValueChange(eachProduct,oldProduct,'Starting_Advertised_Retail_Price__c') || isValueChange(eachProduct,oldProduct,'Year__c') 
                                                     || isValueChange(eachProduct,oldProduct,'IsActive'))){
                    setProductId.add(eachProduct.Id);
                       system.debug('eachProduct.hour__c:::' + eachProduct.hour__c);
                       system.debug('eachProduct.Year__c:::' + eachProduct.Year__c);
                        system.debug('eachProduct.Starting_Advertised_Retail_Price__c:::' + eachProduct.Starting_Advertised_Retail_Price__c);
                    if(string.isNotBlank(eachProduct.Category__c)){
                        setproductCategory.add(eachProduct.Category__c);
                        system.debug('setproductCategory:::'+setproductCategory);
                    }
                                                         
                }
                
                //if Unit is changed to inactive,then delete all related iron demand record.
                if(eachProduct.IsActive==false && isValueChange(eachProduct,oldProduct,'IsActive')){
                    setOfProductIdToDelete.add(eachProduct.id);
                }
                if((isValueChange(eachProduct,oldProduct,'Starting_Advertised_Retail_Price__c') || isValueChange(eachProduct,oldProduct,'IsActive')) &&
                   eachProduct.Starting_Advertised_Retail_Price__c != null && eachProduct.IsActive == true){
                       setOfProductId.add(eachProduct.id);
                   }
                
               /* if((hasFieldChanged(eachProduct, oldProduct, 'Inventory_Status__c') ||
                    hasFieldChanged(eachProduct, oldProduct, 'Override_Post_FB_Marketplace__c') )
                   && eachProduct.Inventory_Status__c =='Owned' &&
                   eachProduct.isActive == true
                   && (eachProduct.Marketed_On_FB_Marketplace__c==true || eachProduct.Override_Post_FB_Marketplace__c == true)
                  ){
                      system.debug('task on unit will create');
                     // system.debug('unit.Inventory_Status__c::'+unit.Inventory_Status__c);
					 // system.debug('unit.Unit_Owner__c::'+unit.Unit_Owner__c);
                      system.debug('unit:::'+eachProduct);
                      //if( setUserIds.Contains(unit.Unit_Owner__c)){
                        string subject = 'Post that unit on FB marketplace and the 20 most relevant groups';
                    if (mapNameVsUser.ContainsKey(System.Label.Outside_West)|| 
                        mapNameVsUser.ContainsKey( System.Label.Outside_East)){
                                 
                            if (mapNameVsUser.ContainsKey(System.Label.Inside_West) && 
                                mapNameVsUser.get(System.Label.Inside_West) !=Null){
                                    task newTask = CreateTask.createNewTask(subject,eachProduct.id,
                                                    null,System.today(),mapNameVsUser.get(System.Label.Inside_West).id,
                                                    'New');
                              
                              lstTask.add(newTask);
                          }
                      }else if(String.isNotBlank(eachProduct.Unit_Owner__c)){

                        task newTask = CreateTask.createNewTask(subject,eachProduct.id,
                                        null,System.today(), eachProduct.Unit_Owner__c,
                                        'New');
                                        lstTask.add(newTask);
                      }
                  }*/
                  if(hasFieldChanged(eachProduct, oldProduct, 'IsActive')){
                    if(eachProduct.IsActive == false){
                        deleteListingIds.add(Integer.valueOf(eachProduct.MLS_Number__c));
                    } else{
                        //Id batchJobId = Database.executeBatch(new MLSCalloutBatch(), 1);
                    }
                } 
                // if(hasFieldChanged(unit, oldUnit, 'My_Little_Salesman_Listing__c')){
                //     if(unit.My_Little_Salesman_Listing__c == 'Do not Advertise'){
                //         deleteListingIds.add(Integer.valueOf(unit.MLS_Number__c));
                //     }
                // }
                if(hasFieldChanged(eachProduct, oldProduct, 'Starting_Advertised_Retail_Price__c') &&
                eachProduct.Starting_Advertised_Retail_Price__c != null){
                    if(eachProduct.IsActive && mapNameVsUser.containsKey(System.Label.VA) &&
                       mapNameVsUser.get(System.Label.VA) != null){
                        task newTask = new task();
                        newTask.Subject = 'Send matching email';
                        newTask.ActivityDate = System.today();
                        newTask.Status = 'New';
                        newTask.OwnerId = mapNameVsUser.get(System.Label.VA).id;
                        newTask.WhatId = eachProduct.id;
                        lstTask.add(newTask);
                    }
                }
                /*system.debug('eachProduct::'+eachProduct.Iron_Connect_Listing__c);
                system.debug('oldProduct::'+oldProduct.Iron_Connect_Listing__c);
                if(hasFieldChanged(eachProduct, oldProduct, 'Iron_Connect_Listing__c')  ){
                    setOfUnitId.add(eachProduct.id);
                }*/
                if(hasFieldChanged(eachProduct, oldProduct, 'Inventory_Status__c')  ){
                    setOfUnitIdForOppoName.add(eachProduct.id);
                }
                if(hasFieldChanged(eachProduct, oldProduct, 'Starting_Advertised_Retail_Price__c')||
                hasFieldChanged(eachProduct, oldProduct, 'Old_SF_Unit_Details__c')||
                hasFieldChanged(eachProduct, oldProduct, 'Confidential_Information_Notes__c')){
                    setOfUnitId.add(eachProduct.id);
                }
                //When unit stage is changed to Potential Trade
                if(isValueChange(eachProduct,oldProduct,'Unit_Stage__c') && (eachProduct.Unit_Stage__c != 'Potential Trade' && eachProduct.IsActive ==true)){
                    setOfUnitIdToLead.add(eachProduct.id);
                    
                }
                if(( isValueChange(eachProduct,oldProduct,'IsActive') || 
                    isValueChange(eachProduct,oldProduct,'Number_of_Images_in_Google_Drive__c')) && 
                    eachProduct.IsActive==true && 
                    eachProduct.Number_of_Images_in_Google_Drive__c == null &&
                    string.isNotBlank(eachProduct.Unit_Owner__c)){
                    Task newTask = CreateTask.createNewTask('Obtain Picture to GD',
                                                            eachProduct.id,
                                                            null,
                                                            System.TODAY(),
                                                            eachProduct.Unit_Owner__c,
                                                            'New');
                    
                    lstTask.add(newTask);
                }
                if(( isValueChange(eachProduct,oldProduct,'IsActive') || 
                    isValueChange(eachProduct,oldProduct,'Number_of_Videos_in_Google_Drive__c')) && 
                    eachProduct.IsActive==true && 
                    eachProduct.Number_of_Videos_in_Google_Drive__c == null &&
                    string.isNotBlank(eachProduct.Unit_Owner__c)){
                    Task newTask = CreateTask.createNewTask('Obtain Video to GD',
                                                            eachProduct.id,
                                                            null,
                                                            System.TODAY(),
                                                            eachProduct.Unit_Owner__c,
                                                            'New');
                    
                    lstTask.add(newTask);
                }
                if(( isValueChange(eachProduct,oldProduct,'IsActive') || 
                    isValueChange(eachProduct,oldProduct,'Storage_City__c')) && 
                    eachProduct.IsActive==true && 
                    string.isBlank(eachProduct.Storage_City__c) &&
                    string.isNotBlank(eachProduct.Unit_Owner__c) ){
                    Task newTask = CreateTask.createNewTask('Obtain Storage City',
                                                            eachProduct.id,
                                                            null,
                                                            System.TODAY(),
                                                            eachProduct.Unit_Owner__c,
                                                            'New');
                    
                    lstTask.add(newTask);
                }
                if(( isValueChange(eachProduct,oldProduct,'IsActive') || 
                    isValueChange(eachProduct,oldProduct,'Storage_State__c')) && 
                    eachProduct.IsActive==true && 
                    string.isBlank(eachProduct.Storage_State__c) &&
                    string.isNotBlank(eachProduct.Unit_Owner__c)){
                    Task newTask = CreateTask.createNewTask('Obtain Storage State',
                                                            eachProduct.id,
                                                            null,
                                                            System.TODAY(),
                                                            eachProduct.Unit_Owner__c,
                                                            'New');
                    
                    lstTask.add(newTask);
                }
                if(( isValueChange(eachProduct,oldProduct,'IsActive') || 
                    isValueChange(eachProduct,oldProduct,'Unit_Stage__c')) && 
                    eachProduct.IsActive==true &&
                    string.isNotBlank(eachProduct.Unit_Stage__c) &&
                    eachProduct.Unit_Stage__c != 'Potential Trade' && 
                    eachProduct.Display_Lowest_Purchase_Price__c==null &&
                  	string.isNotBlank(eachProduct.Unit_Owner__c)){
                        Task newTask = CreateTask.createNewTask('Update Seller\'s Original Asking Price field on the Unit Page',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask);	
                }
                /*if((isValueChange(eachProduct,oldProduct,'Storage_City__c') || 
                    isValueChange(eachProduct,oldProduct,'Storage_State__c')) && 
                    eachProduct.IsActive==true && 
                    eachProduct.Do_not_market_unit_anywhere__c == false &&
                  string.isNotBlank(eachProduct.Unit_Owner__c)){
                        //Assign tom  VA
                    Task newTask = CreateTask.createNewTask('Review Descripion',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    newTask.Description ='Run Vague Location task, then update storage location on MT, CL, and IC. Task BN to update FB location for owned units. [Sandip] Location on this unit was updated; make required changes to CL and update CL Post Date field. If this unit has an Iron Connect listing, please update location.  If it does not have an IC listing, please post in Team Z Group Chat and @post CM/HB/MJ to identify whether it should be posted on IC.';
                    lstTask.add(newTask);	
                }*/
                /*if(isValueChange(eachProduct,oldProduct,'Old_SF_Unit_Details__c') && 
                    eachProduct.IsActive==true && 
                    eachProduct.Do_not_market_unit_anywhere__c == false &&
                  string.isNotBlank(eachProduct.Unit_Owner__c)){
                        //Assign tom  VA
                    Task newTask = CreateTask.createNewTask('Update unit details on MT, IC, and CL; task BN to update unit details on FB if owned unit.',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask);	
                }*/
                /*if(isValueChange(eachProduct,oldProduct,'Unlist_Unit__c') && 
                    eachProduct.IsActive==true && 
                    eachProduct.Unlist_Unit__c == true &&
                  string.isNotBlank(eachProduct.Unit_Owner__c)){
                        //Assign tom  VA
                    Task newTask = CreateTask.createNewTask('Unlist unit from MT, CL, and all other iron sites. Task Collin to "remove from FB if appropriate" from the unit page.',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask);	
                        
                        Task newTask1 = CreateTask.createNewTask('Check with unit owner whether it is ready to be relisted. If it is, relist it and UNCHECK the Unlist checkbox.  IF it is not, ask when to relist and reassign this task for that date.',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY()+7,
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask1);	
                }*/
                if(isValueChange(eachProduct,oldProduct,'Starting_Advertised_Retail_Price__c') && 
                    eachProduct.IsActive==true && 
                    eachProduct.Starting_Advertised_Retail_Price__c !=null && 
                    eachProduct.Number_of_Images_in_Google_Drive__c != null &&
                  string.isNotBlank(eachProduct.Unit_Owner__c)){
                        //Assign tom  VA
                    Task newTask = CreateTask.createNewTask('Log into Walker\'s SF account and send matching on this unit from there.',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask);	
                }
               /* if(isValueChange(eachProduct,oldProduct,'Year__c') && 
                    eachProduct.IsActive==true && 
                    string.isNotBlank(eachProduct.Year__c)  && 
                    eachProduct.Do_not_market_unit_anywhere__c == false &&
                  string.isNotBlank(eachProduct.Unit_Owner__c)){
                        //Assign tom  VA
                    Task newTask = CreateTask.createNewTask('The year on this unit has changed; update MT, CL, and IC (ONLY IF UNIT IS LISTED IN THOSE PLACES)',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask);	
                }*/
                if(isValueChange(eachProduct,oldProduct,'Inventory_Status__c') && 
                    eachProduct.IsActive==true &&  
                    eachProduct.Inventory_Status__c == 'Owned'&&
                  string.isNotBlank(eachProduct.Unit_Owner__c)){
                        //eachProduct.Purchase_Date__c = System.TODAY();
                        //Assign tom  hardy
                    Task newTask = CreateTask.createNewTask('Set sell pricing',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask);	
                        //shelly
                        Task newTask1 = CreateTask.createNewTask('Ensure unit marketed on MT and spot-check other IronSites to ensure it\'s listed accurately',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY()+7,
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask1);	
                        //shelly
                        Task newTask2 = CreateTask.createNewTask('Send UNADVERTISED Mailchimp to end users and equipment sellers; EXCLUDE account purchased from',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask2);	
                        //shelly
                        /*Task newTask3 = CreateTask.createNewTask('[Reassign to BN with MC list attached] End User Mailchimp / ID calls- (MC: 2+ opens, top 5, ID: most recent 5) ',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY()+3,
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask3);	*/
                        //shelly
                        Task newTask4 = CreateTask.createNewTask('Market on Craigslist in the  city/region where unit is located; create follow-up task for 30-days out to repost.',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask4);	
                        /* */	
                        //
                        Task newTask6 = CreateTask.createNewTask('Ensure full set of good photos is provided via inspection or via site contact.  Remove not good/auction looking photos to Confidential Information folder.',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask6);	
                        //
                        Task newTask7 = CreateTask.createNewTask('Complete Unit Details - use "Required information for owned units" doc as reference.',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask7);	
                        //shelly
                        Task newTask8 = CreateTask.createNewTask('Put Serial Number Photos  in Online Photos folder, and on MT.  Put full serial from the serial plate in Serial Number field on Unit Page.',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask8);	
                        //shelly
                        Task newTask9 = CreateTask.createNewTask('Obtain shipping dimensions from either inspection report or specalog.  Put in Shipping Dims field in the Freight and Transport section of Unit Page.',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY(),
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask9);	
                        //shelly
                        Task newTask10 = CreateTask.createNewTask('List this unit on IronConnect.',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY()+7,
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                    
                    lstTask.add(newTask10);	
                    /*if(eachProduct.Hour__c < 5000 && eachProduct.CL_Post_Age__c < 7){
                        //hardy
                        Task newTask5 = CreateTask.createNewTask('Send to dealers via SF email',
                                                                eachProduct.id,
                                                                null,
                                                                System.TODAY()+7,
                                                                eachProduct.Unit_Owner__c,
                                                                'New');
                        
                        lstTask.add(newTask5);
                    }*/
                }
                //if either starting advertised retail price is changed or display lowest is changed, then create a task for shelly.
                if((isValueChange(eachProduct,oldProduct,'Starting_Advertised_Retail_Price__c') 
                || isValueChange(eachProduct,oldProduct,'Display_Lowest_Purchase_Price__c') ) 
                 && (eachProduct.Starting_Advertised_Retail_Price__c != null && eachProduct.Display_Lowest_Purchase_Price__c != null) && 
                 mapNameVsUser.ContainsKey(System.Label.VA) && 
                          mapNameVsUser.get(System.Label.VA) !=Null){
                      string subject = 'Send matching email ';
                     task newTask= CreateTask.createNewTask(subject,eachProduct.id,null,system.today(), mapNameVsUser.get(System.Label.VA).id,'New'); 
                     if(newTask!=null){
                         lstTask.add(newTask);
                     }
                 }
            }
        }  
        
            if(lstUnitUpdate != null && !lstUnitUpdate.isEmpty()){
                update lstUnitUpdate;
            }    
        if(setOfUnitIdToLead!=null && !setOfUnitIdToLead.isEmpty()){
            lstNewLead =[SELECT id,Unit__c,OwnerId 
                            FROM lead 
                            WHERE Unit__c in: setOfUnitIdToLead AND Unit__c != NULL]; 
        }
        if(lstNewLead!=null && !lstNewLead.isEmpty()){
            for(lead eachLead :lstNewLead){
                if(!mapOfUnitIdvsLeadId.containsKey(eachLead.Unit__c)){
                        mapOfUnitIdvsLeadId.put(eachLead.Unit__c,eachLead.OwnerId);
                    
                }
            }
        }
        if(units != null && !units.isEmpty()){
            for(Product2 eachProduct :units ){
                Product2 oldProduct = oldUnitMap.get(eachProduct.Id);
                //if unit stage is changed and isactive is true then create a task
                if(isValueChange(eachProduct,oldProduct,'Unit_Stage__c') 
                    && (eachProduct.Unit_Stage__c != 'Potential Trade' && eachProduct.IsActive ==true) 
                    && mapOfUnitIdvsLeadId.containskey(eachProduct.Id)){
                        system.debug('enter after update::::');
                    string subject ='Obtain Buy price on Unit';
                        task newTask= CreateTask.createNewTask(subject,eachProduct.id,null,system.today(),mapOfUnitIdvsLeadId.get(eachProduct.Id),'New');
                        if(newTask!=null){
                            lstTask.add(newTask); 
                        }
                }
           
            }
        }
           
        system.debug('setproductCategoryupdate:::'+setproductCategory);
        if(setproductCategory!=null && !setproductCategory.isEmpty()){
            lstUnitCategoryFromUrID = [SELECT id, Unit__c,User_Requirement_ID__c,isActive__c,RecordTypeId,Category_Details__c
                                        FROM Unit_Category_Details__c 
                                        WHERE Category_Details__c in :setproductCategory AND Unit__c = null 
                                        AND User_Requirement_ID__c != null AND isActive__c = true /*AND Unit__c in : setProductId*/  ];
        }
        system.debug('lstUnitCategoryFromUrID:::'+lstUnitCategoryFromUrID);
        
        if(lstUnitCategoryFromUrID!=null && !lstUnitCategoryFromUrID.isEmpty()){
            for(Unit_Category_Details__c eachUnitCategory : lstUnitCategoryFromUrID){
                if(string.isNotBlank(eachUnitCategory.Category_Details__c)){
                    setofUnitCategoryToMdt.add(eachUnitCategory.Category_Details__c); 
                    setofUnitCategory.add(eachUnitCategory.Category_Details__c);
                }
                if(string.isnotblank(eachUnitCategory.User_Requirement_ID__c)){
                    setUnitCategoryParentId.add(eachUnitCategory.User_Requirement_ID__c);
                }
            }
        }
            system.debug('setUnitCategoryParentId:::'+setUnitCategoryParentId);
            system.debug('setofUnitCategoryToMdt::'+setofUnitCategoryToMdt);
            system.debug('setofUnitCategory::'+setofUnitCategory);
            system.debug('setProductId:::'+setProductId);
        //Here we called future method to create iron demand record if not exist.
        if(setUnitCategoryParentId!=null && !setUnitCategoryParentId.isEmpty() && setofUnitCategoryToMdt != null && !setofUnitCategoryToMdt.isEmpty() 
            && setofUnitCategory!=null && !setofUnitCategory.isEmpty() && setProductId != null && !setProductId.isEmpty() ){
                system.debug('Future method called:::');
            UnitCategoryDetailsFutureClass.FutureUnitCategoryDetails(setUnitCategoryParentId,setofUnitCategoryToMdt,setofUnitCategory,setOfProductId);//setOfProductId
        }
            
            
            if(setOfProductIdToDelete != null && !setOfProductIdToDelete.isEmpty()){
                lstIronDemand = [SELECT ID,Unit_Currently_Interested_In__c 
                                 FROM Iron_Demand__c 
                                 WHERE Unit_Currently_Interested_In__c IN :setOfProductIdToDelete];
            }
            
            if(lstIronDemand != null && !lstIronDemand.isEmpty()){
                delete lstIronDemand;
            }
            
        
        //Set of unit id for updating the iron connect listing link
        
            system.debug('lstTask::'+lstTask);
        
        if(setOfUnitId!=null && !setOfUnitId.isEmpty() ){
            lstProduct2 = [SELECT Id, Starting_Advertised_Retail_Price__c,
                            Old_SF_Unit_Details__c,Confidential_Information_Notes__c,Inventory_Status__c,
                            (SELECT Id, Name, Iron_Connect_listing__c , Starting_Advertised_Retail_Price__c,
                            Confidential_Information_Notes__c,Unit_Details__c,recordTypeId,recordType.DeveloperName
                            FROM Opportunities__r 
                            WHERE recordType.DeveloperName =: label.Opp_Rec_type_Dev_Name_procurement_opp OR 
                            recordType.DeveloperName =: label.Opp_Rec_Type_Broker_Sell OR 
                            recordType.DeveloperName =: label.Opp_Rec_Type_Inventory_Sell) 
                            FROM Product2 WHERE ID IN : setOfUnitId OR ID IN : setOfUnitIdForOppoName];
        }
        if(lstProduct2!=null && !lstProduct2.isEmpty()){
            for(Product2 eachProduct2 : lstProduct2){
                Product2 oldUnit = oldUnitMap.get(eachProduct2.Id);
                if(eachProduct2.Opportunities__r!= Null && !eachProduct2.Opportunities__r.isEmpty()){
                    for(Opportunity eachOpportunity : eachProduct2.Opportunities__r){
                        if( setOfUnitId.contains(eachProduct2.id) && 
                            eachOpportunity.recordType.DeveloperName == label.Opp_Rec_type_Dev_Name_procurement_opp){
                            
                            /*if(hasFieldChanged(eachProduct2, oldUnit, 'Iron_Connect_Listing__c')  ){
                                eachOpportunity.Iron_Connect_listing__c = eachProduct2.Iron_Connect_listing__c;
                            }*/
                            if(hasFieldChanged(eachProduct2, oldUnit, 'Starting_Advertised_Retail_Price__c')||
                            hasFieldChanged(eachProduct2, oldUnit, 'Old_SF_Unit_Details__c')||
                            hasFieldChanged(eachProduct2, oldUnit, 'Confidential_Information_Notes__c')){
                                eachOpportunity.Starting_Advertised_Retail_Price__c = eachProduct2.Starting_Advertised_Retail_Price__c;
                                eachOpportunity.Unit_Details__c = eachProduct2.Old_SF_Unit_Details__c;
                                eachOpportunity.Confidential_Information_Notes__c = eachProduct2.Confidential_Information_Notes__c;
                            }
                                lstOpportunity.add(eachOpportunity);
                        }
                        else if(setOfUnitIdForOppoName.contains(eachProduct2.id) && 
                                (eachOpportunity.recordType.DeveloperName == label.Opp_Rec_Type_Broker_Sell ||
                                    eachOpportunity.recordType.DeveloperName == label.Opp_Rec_Type_Inventory_Sell)){
                                        if(hasFieldChanged(eachProduct2, oldUnit, 'Inventory_Status__c')
                                        && String.isNotBlank(eachProduct2.Inventory_Status__c)){
                                            if(eachProduct2.Inventory_Status__c == 'Brokerage' &&
                                            String.isNotBlank(Opp_Rec_Type_Broker_Sell_Id)){
                                                eachOpportunity.RecordTypeId =Opp_Rec_Type_Broker_Sell_Id;
                                                
                                                lstOpportunity.add(eachOpportunity);	
                                                
                                            }else If(eachProduct2.Inventory_Status__c == 'Owned' &&
                                                        String.isNotBlank(Opp_Rec_Type_Inventory_Sell_Id)){
                                                         eachOpportunity.RecordTypeId = Opp_Rec_Type_Inventory_Sell_Id;
                                                         lstOpportunity.add(eachOpportunity);
                                                         
                                                     }
                                        }
                                    }
                    }
                }
            }
            
        }
        if(lstOpportunity!=null && !lstOpportunity.isEmpty()){
            update lstOpportunity;
        }
        if(filteredUnitsIds.size()> 0){
            // MLSCalloutUpdateBatch obj = new MLSCalloutUpdateBatch(filteredUnitsIds);
            // Id batchJobId = Database.executeBatch(obj, 1);
        }
        
        if(deleteListingIds.size()> 0){
            // MLSCalloutDeleteBatch obj = new MLSCalloutDeleteBatch(deleteListingIds);
            // Id batchJobId = Database.executeBatch(obj, 1);
        }
        if(lstTask!= null && !lstTask.isEmpty()){
            insert lstTask;
            system.debug('lstTask::'+lstTask);
        }
    }
    
    
    /*public static void handleCreateTaskOnAfterUpdate( List<Product2> units,Map<Id, Product2> oldUnitMap){
//String requiredUserName = System.Label.Outside_West;
//String userName = System.Label.Outside_East;        
system.debug('units::'+units);
system.debug('oldUnitMap::'+oldUnitMap);
list<Task> lstNewTask = new list<Task>();
set<Id> setUserIds = new set<Id>();
list<Id> listOfUserId = new list<Id>();

list<User> lstUser = [SELECT Id, Username, Name 
FROM User 
WHERE name=:System.Label.Outside_East
OR name=:System.Label.Outside_West 
OR Name=:System.Label.Inside_West ];
if(lstUser!=null && !lstUser.isEmpty()){
for(User eachUsers : lstUser){
if(eachUsers.Name==System.Label.Inside_West){
listOfUserId.add(eachUsers.Id);
}
system.debug('lstUsers.Id:'+eachUsers.Id);
setUserIds.add(eachUsers.Id);
}
}*/
    /*User newUser = [SELECT Id, Username, Name 
FROM User 
WHERE Name=:System.Label.Inside_West];
system.debug('newUser::' + newUser);*/
    
    
    /*if(units!=null && !units.isEmpty()){
system.debug('entered::'+setUserIds);
for(Product2 unit : units){
Product2 oldUnit = oldUnitMap.get(unit.Id);
if(hasFieldChanged(unit, oldUnit, 'Inventory_Status__c') 
&& unit.Inventory_Status__c =='Owned' 
&& unit.Marketed_On_FB_Marketplace__c==true
){
system.debug('entered condition::');
if( setUserIds.Contains(unit.Unit_Owner__c)){
if(listOfUserId!=null && !listOfUserId.isEmpty()){
task newTask = new task();
newTask.Subject = 'Post that unit on FB marketplace and the 20 most relevant groups';
newTask.ActivityDate = System.today();
newTask.Status = 'New';
newTask.OwnerId = listOfUserId[0];
newTask.WhatId = unit.id;
system.debug('newTask::' + newTask);
lstNewTask.add(newTask);
}
}else if(String.isNotBlank(unit.Unit_Owner__c)){
task newTask = new task();
newTask.Subject = 'Post that unit on FB marketplace and the 20 most relevant groups';
newTask.ActivityDate = System.today();
newTask.Status = 'New';
newTask.OwnerId = unit.Unit_Owner__c;
newTask.WhatId = unit.id;
system.debug('newTask::' + newTask);
lstNewTask.add(newTask);

}
}
} 
}
if(lstNewTask!=null && !lstNewTask.isEmpty()){
system.debug('lstNewTask::'+lstNewTask);
insert lstNewTask;
}
}*/
    public static void handleBeforeUpdate(
        List<Product2> units,
        Map<Id, Product2> oldUnitMap){
            PopulateVagueCityHelper helper = new PopulateVagueCityHelper();
            set<Id>setOfYardId = new set<Id>();
            map<id,Yards__c> mapOfPartnerYard;
            Map< ID, Product2 > productMap = new Map< ID, Product2 >([Select id,Model_Unit__c,equipment__r.Model_Equipment__c From Product2 Where ID IN : units]);
            map<String,User> mapNameVsUser = new map<String,User>();
            list<User> lstUser = [SELECT Id, Username, Name 
                                  FROM User 
                                  WHERE IsActive  = true
                                 ];
            if(lstUser!=null && !lstUser.isEmpty()){
                for(User eachUsers : lstUser){
                    mapNameVsUser.put(eachUsers.Name,eachUsers);
                }
            }
            if(units!=null && !units.isEmpty()){
                for(Product2 unit : units){
                    
                    if( productMap.containsKey(unit.id) && productMap.get(unit.id).equipment__r.Model_Equipment__c != null)
                        unit.Model_Unit__c = productMap.get(unit.id).equipment__r.Model_Equipment__c;

                    Product2 oldUnit = oldUnitMap.get(unit.Id);
                    if(hasFieldChanged(unit, oldUnit, 'Storage_City__c') || 
                       hasFieldChanged(unit, oldUnit, 'Inventory_Status__c'))
                    {
                        unit.MT_Vague_Display_Location_Name__c = helper.getCity(unit);
                    }
                    //If unit is Inactive then "Unit Involved in an Active Opportunity" is set to false
                    if(hasFieldChanged(unit, oldUnit, 'IsActive')  &&  unit.IsActive == false){
                        unit.Unit_Involved_in_an_Active_Opportunity__c = false;
                    }
                    if(hasFieldChanged(unit, oldUnit, 'Starting_Advertised_Retail_Price__c') ){
                        unit.Date_of_Price_Change__c = system.Now();
                    }
                    if(unit.IsActive && 
                       string.isNotBlank(unit.On_Zadoon_partner_yard1__c)&&
                       (hasFieldChanged(unit, oldUnit, 'IsActive') ||
                      hasFieldChanged(unit, oldUnit, 'On_Zadoon_partner_yard1__c'))){
                        setOfYardId.add(unit.On_Zadoon_partner_yard1__c);
                    
                      }
                }
                if(setOfYardId!=null && !setOfYardId.isEmpty()){
                    mapOfPartnerYard =new map<id,Yards__c>([SELECT Id, Storage_City__c, Site_Contact__c, Storage_Zip_Code__c, 
                                                            Storage_Street__c, Storage_State__c, Storage_Country__c FROM Yards__c ]);
                }
                for(Product2 unit : units){
                    Product2 oldUnit = oldUnitMap.get(unit.Id);
                    if(unit.IsActive && 
                       string.isNotBlank(unit.On_Zadoon_partner_yard1__c)&&
                       hasFieldChanged(unit, oldUnit, 'On_Zadoon_partner_yard1__c')&&
                       mapOfPartnerYard.containsKey(unit.On_Zadoon_partner_yard1__c)&&
                       mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c) !=null){
                           unit.Site_Contact__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Site_Contact__c;
                           unit.Storage_City__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Storage_City__c;
                           unit.Storage_Zip_Code__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Storage_Zip_Code__c;
                           unit.Storage_State__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Storage_State__c;
                           unit.Storage_Country__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Storage_Country__c;
                           unit.Storage_Address__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Storage_Street__c;
                           //unit.Site_Contact__c = mapOfPartnerYard.get(unit.On_Zadoon_partner_yard1__c).Site_Contact__c;
                       }else if (string.isBlank(unit.On_Zadoon_partner_yard1__c) &&
                                hasFieldChanged(unit, oldUnit, 'On_Zadoon_partner_yard1__c')&&
                                unit.IsActive )
                       {
                           unit.Site_Contact__c = '';
                           unit.Storage_City__c = '';
                           unit.Storage_Zip_Code__c = '';
                           unit.Storage_State__c = '';
                           unit.Storage_Country__c = '';
                           unit.Storage_Address__c = '';
                       }
                         if(hasFieldChanged(unit, oldUnit, 'Is_Photo_verification_completed__c') && 
                   unit.Is_Photo_verification_completed__c == true && 
                   mapNameVsUser.containsKey(system.label.VA) && 
                   string.isnotBlank(unit.Unit_Owner__c)){
                       unit.Unlist_Unit__c = false;
                       system.debug('unit.Unlist_Unit__c:::'+unit.Unlist_Unit__c);
                   }
                    
                    
                }
                
            }
        }
    
    private static Boolean hasFieldChanged(
        Product2 newUnit, Product2 oldUnit, String fieldName
    ){
        return hasValueChanged(
            newUnit.get(fieldName),
            oldUnit.get(fieldName)
        );
    }
    
    private static Boolean hasValueChanged(Object newValue, Object oldValue){
        return newValue != oldValue;
    }
    
    public static void handleAfterInsert(
        List<Product2> triggerNew
    ){
        list<Task> lstTask = new list<Task>();
        set<Id> setOfAccountId = new set<Id>();
        list<Marketing_Detail__c> lstMarketingDetail;
        list<Marketing_Detail__c> lstMarketingDetailToInsert = new list<Marketing_Detail__c>();
        map<Id,Marketing_Detail__c>mapOfAccountIdVsMarketingDetail = new map<Id,Marketing_Detail__c>();
        list<Product2> lstProduct2 ;
        list<product2> lstProductToUpdate = new list<product2>();
        set<id> setOfProductId = new set<id>();
       /* recordType UnitRecordType;
        if(string.isNotBlank(Label.Marketing_Detail_Unit)){
            system.debug('lfgiadbhgolasezd');
            UnitRecordType = [SELECT Id,DeveloperName 
                              FROM recordType
                              WHERE DeveloperName =:Label.Marketing_Detail_Unit limit 1 ];
        }*/
        Id UnitRecordTypeId;
            
        if(string.isNotBlank(Label.Marketing_Detail_Unit)){
            UnitRecordTypeId =Schema.SObjectType.Marketing_Detail__c.getRecordTypeInfosByDeveloperName()
                .get(Label.Marketing_Detail_Unit).getRecordTypeId();
        }
        if(triggerNew!= null && !triggerNew.isEmpty()){
            for (Product2 eachProduct2 : triggerNew){
                if(string.isNotBlank(eachProduct2.Account__c)){
                    setOfAccountId.add(eachProduct2.Account__c);
                }
                if(eachProduct2.Number_of_Images_in_Google_Drive__c == null &&
                   eachProduct2.IsActive &&
                      string.isNotBlank(eachProduct2.Unit_Owner__c)){
                    Task newTask = CreateTask.createNewTask('Obtain Picture to GD',
                                                            eachProduct2.id,
                                                            null,
                                                            System.TODAY(),
                                                            eachProduct2.Unit_Owner__c,
                                                            'New');
                    
                    lstTask.add(newTask);
                }
                if(eachProduct2.Number_of_Videos_in_Google_Drive__c == null && 
                   eachProduct2.IsActive &&
                      string.isNotBlank(eachProduct2.Unit_Owner__c)){
                    Task newTask = CreateTask.createNewTask('Obtain Video to GD',
                                                            eachProduct2.id,
                                                            null,
                                                            System.TODAY(),
                                                            eachProduct2.Unit_Owner__c,
                                                            'New');
                    
                    lstTask.add(newTask);
                }
                if(eachProduct2.IsActive){
                    if(eachProduct2.Starting_Advertised_Retail_Price__c == null && String.IsNotBlank(eachProduct2.Unit_Owner__c)){
                        task newTask2 = 
                           CreateTask.createNewTask('Update Starting Advertise Retail Price',eachProduct2.id,null,system.today(),eachProduct2.Unit_Owner__c,'New'); 
                       if(newTask2!=null){
                           lstTask.add(newTask2);
                           system.debug('lstTaskToInsert bucket:::'+lstTask);
                       } 
                    }
                    if(eachProduct2.Display_Lowest_Purchase_Price__c == null && String.IsNotBlank(eachProduct2.Unit_Owner__c)){
                        task newTask2 = 
                           CreateTask.createNewTask('Update Buy Price',eachProduct2.id,null,system.today(),eachProduct2.Unit_Owner__c,'New'); 
                       if(newTask2!=null){
                           lstTask.add(newTask2);
                           system.debug('lstTaskToInsert bucket:::'+lstTask);
                       } 
                    }
                    if(eachProduct2.Starting_Advertised_Retail_Price__c != null &&
                      eachProduct2.Display_Lowest_Purchase_Price__c != null && String.IsNotBlank(eachProduct2.Unit_Owner__c)){
                          task newTask2 = 
                              CreateTask.createNewTask('Send Matching Email',eachProduct2.id,null,system.today(),eachProduct2.Unit_Owner__c,'New'); 
                          if(newTask2!=null){
                              lstTask.add(newTask2);
                              system.debug('lstTaskToInsert bucket:::'+lstTask);
                          }
                    }
                    
                }
                /*if(eachProduct2.IsActive == true && eachProduct2.Starting_Advertised_Retail_Price__c != null){
                    setOfProductId.add(eachProduct2.id);
                }*/
                     product2 newProduct = new product2();
                newProduct.id = eachProduct2.Id;
                string name = '';
                if(string.isnotblank(eachProduct2.Category__c)){
                    name += eachProduct2.Category__c+' ';
                }
                if(string.isnotblank(eachProduct2.ZID__c)){
                    name +='ZID-'+ eachProduct2.ZID__c;
                    newProduct.ProductCode = 'ZID-'+ eachProduct2.ZID__c;
                }
                
                newProduct.Name = name;
                lstProductToUpdate.add(newProduct);
                
            }
        }
        
       /* if(setOfProductId != null && !setOfProductId.isEmpty()){
            
        }*/
        if(lstProductToUpdate != null && !lstProductToUpdate.isEmpty()){
            update lstProductToUpdate;
        }
        if(setOfAccountId!=null && !setOfAccountId.isEmpty()){
            lstMarketingDetail = [SELECT Id, Marketed_On_Craigslist__c, Marketed_On_Iron_Connect__c,
                                  Marketed_On_FB_Marketplace__c, 
                                  Marketed_On_Fleet_Up_Marketplace__c,  
                                  Marketed_On_Instagram__c, Marketed_On_LinkedIn__c, Marketed_On_Machinio__c, 
                                  Marketed_On_Mascus__c, Marketed_on_MT_Crane_Truck__c, 
                                  Marketed_On_MyLittleSalesman__c, Marketed_On_RitchieList__c,  Marketed_On_Rock_Dirt__c, Marketed_On_Equipment_Trader__c,
                                  Marketed_On_TradeMachines__c,  
                                  Do_not_market_anywhere__c, 
                                  Account__c, Opportunity__c, Updated_From__c,
                                  Unit__c, IsDeleted 
                                  FROM Marketing_Detail__c WHERE Account__c IN : setOfAccountId];  
        }
        if(lstMarketingDetail!=null && !lstMarketingDetail.isEmpty()){
            for(Marketing_Detail__c eachMarketingDetail : lstMarketingDetail){
                mapOfAccountIdVsMarketingDetail.put(eachMarketingDetail.Account__c,eachMarketingDetail);
            }
        }
        if(triggerNew!= null && !triggerNew.isEmpty()){
            for (Product2 eachProduct2 : triggerNew){
                if(string.isNotBlank(eachProduct2.Account__c) && mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c)!=null){
                    Marketing_Detail__c newMarketingDetail = new Marketing_Detail__c();
                    newMarketingDetail.Name = eachProduct2.Name;
                    if(String.isNotBlank(UnitRecordTypeId)){
                        newMarketingDetail.RecordTypeId = UnitRecordTypeId;
                    }
                    //newMarketingDetail.Marketed_On_Construction_Equip_Guide__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Construction_Equip_Guide__c;
                    newMarketingDetail.Marketed_On_Craigslist__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Craigslist__c ;
                    //newMarketingDetail.Marketed_On_Facebook__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Facebook__c ;
                    newMarketingDetail.Marketed_On_FB_Marketplace__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_FB_Marketplace__c;
                    newMarketingDetail.Marketed_On_Fleet_Up_Marketplace__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Fleet_Up_Marketplace__c;
                    //newMarketingDetail.Marketed_On_GearFlow__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_GearFlow__c;
                    newMarketingDetail.Marketed_On_Instagram__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Instagram__c;
                    newMarketingDetail.Marketed_On_LinkedIn__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_LinkedIn__c;
                    newMarketingDetail.Marketed_On_Machinio__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Machinio__c;
                    newMarketingDetail.Marketed_On_Mascus__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Mascus__c;
                    newMarketingDetail.Marketed_on_MT_Crane_Truck__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_on_MT_Crane_Truck__c;
                    newMarketingDetail.Marketed_On_MyLittleSalesman__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_MyLittleSalesman__c;
                    // newMarketingDetail.Marketed_On_Terrapoint__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Terrapoint__c ;
                    newMarketingDetail.Marketed_On_TradeMachines__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_TradeMachines__c;
                    //newMarketingDetail.Marketed_On_Used_Equip_Guide__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Used_Equip_Guide__c;
                    // newMarketingDetail.Marketed_On_Zonapesada__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Zonapesada__c;
                    newMarketingDetail.Do_not_market_anywhere__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Do_not_market_anywhere__c;
                    newMarketingDetail.Marketed_On_Iron_Connect__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Iron_Connect__c;
                    newMarketingDetail.Marketed_On_Equipment_Trader__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Equipment_Trader__c;
                    newMarketingDetail.Marketed_On_RitchieList__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_RitchieList__c;
                    newMarketingDetail.Marketed_On_Rock_Dirt__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Rock_Dirt__c;
                    
                    newMarketingDetail.Updated_From__c = 'Account';
                    newMarketingDetail.Unit__c = eachProduct2.id;
                    lstMarketingDetailToInsert.add(newMarketingDetail);
                }
            }
            if(lstMarketingDetailToInsert!=null && !lstMarketingDetailToInsert.isEmpty()){
                insert lstMarketingDetailToInsert;
            }
            if(lstTask!= null && !lstTask.IsEmpty()){
                insert lstTask;
            }
        }
    }
    /*
public static void handleAfterUpdateMarketingDetail(
List<Product2> triggerNew,
Map<Id, Product2> oldProduct2Map)
{	

list<Marketing_Detail__c> lstMarketingDetail;
list<Marketing_Detail__c> lstMarketingDetailToInsert = new list<Marketing_Detail__c>();
map<Id,Marketing_Detail__c>mapOfAccountIdVsMarketingDetail = new map<Id,Marketing_Detail__c>();
map<Id,Marketing_Detail__c>mapOfUnitIdVsMarketingDetail = new map<Id,Marketing_Detail__c>();
set<Id> setOfAccountId = new set<Id>();

if(triggerNew!=null && !triggerNew.isEmpty()){
for(Product2 eachProduct2 : triggerNew){
system.debug('eachProduct2.id::'+eachProduct2.id);
system.debug('Account__c:::'+eachProduct2.Account__c);
system.debug('oldProduct2Map.get(eachProduct2.id).Account__c:::'+oldProduct2Map.get(eachProduct2.id).Account__c);
if(eachProduct2.Account__c != oldProduct2Map.get(eachProduct2.id).Account__c 
&& string.isNotBlank(eachProduct2.Account__c)
){
setOfAccountId.add(eachProduct2.Account__c);
}

}
}
system.debug('setOfAccountId:'+setOfAccountId);
if(setOfAccountId!=null && !setOfAccountId.isEmpty()){
lstMarketingDetail = [SELECT Id, Marketed_On_Construction_Equip_Guide__c, Marketed_On_Craigslist__c, 
Marketed_On_Facebook__c, Marketed_On_FB_Marketplace__c, 
Marketed_On_Fleet_Up_Marketplace__c, Marketed_On_GearFlow__c, 
Marketed_On_Instagram__c, Marketed_On_LinkedIn__c, Marketed_On_Machinio__c, 
Marketed_On_Mascus__c, Marketed_on_MT_Crane_Truck__c, 
Marketed_On_MyLittleSalesman__c, Marketed_On_Terrapoint__c, 
Marketed_On_TradeMachines__c, Marketed_On_Used_Equip_Guide__c, 
Marketed_On_Zonapesada__c, Do_not_market_anywhere__c, 
Account__c, Opportunity__c, Updated_From__c,
Unit__c, IsDeleted 
FROM Marketing_Detail__c  
WHERE Account__c IN : setOfAccountId 
OR Unit__c IN : triggerNew];  
}
system.debug('lstMarketingDetail:'+lstMarketingDetail);
if(lstMarketingDetail!=null && !lstMarketingDetail.isEmpty()){
for(Marketing_Detail__c eachMarketingDetail : lstMarketingDetail){
if(string.isNotBlank(eachMarketingDetail.Account__c)){
mapOfAccountIdVsMarketingDetail.put(eachMarketingDetail.Account__c,eachMarketingDetail);
}else if(string.isNotBlank(eachMarketingDetail.Unit__c)){
mapOfUnitIdVsMarketingDetail.put(eachMarketingDetail.Unit__c,eachMarketingDetail);
}

}
}


if(triggerNew!=null && !triggerNew.isEmpty()){
for(Product2 eachProduct2 : triggerNew){
system.debug('eachProduct2.Account__c::'+eachProduct2.Account__c);
system.debug('oldProduct2Map.get(eachProduct2.id).Account__c::'+oldProduct2Map.get(eachProduct2.id).Account__c);
if(eachProduct2.Account__c != oldProduct2Map.get(eachProduct2.id).Account__c 
&& string.isNotBlank(eachProduct2.Account__c)){
if( mapOfUnitIdVsMarketingDetail.get(eachProduct2.id)!= null){
if(mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Updated_From__c == 'Account' && 
mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c)!=null){
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_Construction_Equip_Guide__c =mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Construction_Equip_Guide__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_Craigslist__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Craigslist__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_Facebook__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Facebook__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_FB_Marketplace__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_FB_Marketplace__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_Fleet_Up_Marketplace__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Fleet_Up_Marketplace__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_GearFlow__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_GearFlow__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_Instagram__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Instagram__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_LinkedIn__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_LinkedIn__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_Machinio__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Machinio__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_Mascus__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Mascus__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_on_MT_Crane_Truck__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_on_MT_Crane_Truck__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_MyLittleSalesman__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_MyLittleSalesman__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_Terrapoint__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Terrapoint__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_TradeMachines__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_TradeMachines__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_Used_Equip_Guide__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Used_Equip_Guide__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Marketed_On_Zonapesada__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Zonapesada__c;
mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Do_not_market_anywhere__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Do_not_market_anywhere__c;   
//mapOfUnitIdVsMarketingDetail.get(eachProduct2.id).Account__c =  mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Account__c;
}
}else if(mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c)!=null){
Marketing_Detail__c newMarketingDetail = new Marketing_Detail__c();
newMarketingDetail.Marketed_On_Construction_Equip_Guide__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Construction_Equip_Guide__c;
newMarketingDetail.Marketed_On_Craigslist__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Craigslist__c ;
newMarketingDetail.Marketed_On_Facebook__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Facebook__c ;
newMarketingDetail.Marketed_On_FB_Marketplace__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_FB_Marketplace__c;
newMarketingDetail.Marketed_On_Fleet_Up_Marketplace__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Fleet_Up_Marketplace__c;
newMarketingDetail.Marketed_On_GearFlow__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_GearFlow__c;
newMarketingDetail.Marketed_On_Instagram__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Instagram__c;
newMarketingDetail.Marketed_On_LinkedIn__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_LinkedIn__c;
newMarketingDetail.Marketed_On_Machinio__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Machinio__c;
newMarketingDetail.Marketed_On_Mascus__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Mascus__c;
newMarketingDetail.Marketed_on_MT_Crane_Truck__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_on_MT_Crane_Truck__c;
newMarketingDetail.Marketed_On_MyLittleSalesman__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_MyLittleSalesman__c;
newMarketingDetail.Marketed_On_Terrapoint__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Terrapoint__c ;
newMarketingDetail.Marketed_On_TradeMachines__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_TradeMachines__c;
newMarketingDetail.Marketed_On_Used_Equip_Guide__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Used_Equip_Guide__c;
newMarketingDetail.Marketed_On_Zonapesada__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Marketed_On_Zonapesada__c;
newMarketingDetail.Do_not_market_anywhere__c = mapOfAccountIdVsMarketingDetail.get(eachProduct2.Account__c).Do_not_market_anywhere__c;
newMarketingDetail.Updated_From__c = 'Account';
newMarketingDetail.Unit__c = eachProduct2.id;
lstMarketingDetailToInsert.add(newMarketingDetail);  	    
}
}
}
if(lstMarketingDetailToInsert!=null && !lstMarketingDetailToInsert.isempty()){
insert lstMarketingDetailToInsert;
}
if(mapOfUnitIdVsMarketingDetail.Values()!=null && !mapOfUnitIdVsMarketingDetail.Values().isEmpty()){
update mapOfUnitIdVsMarketingDetail.Values();
}
}     
}*/
    public class myException extends Exception {}
    public static void createMatchingIronDemandUnits( List <Product2 > newList, boolean isUpdate) {
       /* if(newList!=null && !newList.isEmpty()){
            
        }*/
        try {
            Set< String > categorySet = new Set< String > ();
            Set< String > makeSet = new Set< String > ();
            Set< String > modelSet = new Set< String > ();
            set< String > yearSet = new Set< String > ();
            Set< ID > unitIdSet = new Set< ID > ();
            Set< ID > unitDeleteSet = new Set< ID > ();
            for ( Product2 pro : newList ) {
                if(pro.IsActive) {
                    if ( isUpdate ) unitDeleteSet.add(pro.id);
                    if ( String.isNotBlank(pro.category__c)) categorySet.add(pro.category__c);
                    if ( String.isNotBlank(pro.Make__c) ) 	makeSet.add(pro.Make__c);
                    if ( String.isNotBlank(pro.Model__c) )  modelSet.add(pro.Model__c);
                    if ( String.isNotBlank(pro.Year__c) )   yearSet.add(pro.Year__c);
                } else if( !pro.IsActive && isUpdate ) {
                    unitIdSet.add(pro.id);
                }
            }
            //system.debug('unitIdSet---->'+unitIdSet);
            
            // delete all the existing iron demand units from unit whenever units deactivated.
            if( unitIdSet.size() > 0) { 
                List< Iron_Demand_Unit__c > IronDemand_Unit = [SELECT Id FROM Iron_Demand_Unit__c WHERE Unit__c IN :unitIdSet];
                if( IronDemand_Unit != null && IronDemand_Unit.size() > 0) delete IronDemand_Unit;
            }
            
            // delete existing iron demand units which are created through automtion(trigger) whenever unit updated.
            if(unitDeleteSet.size() > 0){
                List< Iron_Demand_Unit__c > IronDemand_UnitDelete = [SELECT Id FROM Iron_Demand_Unit__c WHERE Unit__c IN :unitDeleteSet AND Automation__c=true];
                if( IronDemand_UnitDelete != null && IronDemand_UnitDelete.size() > 0) delete IronDemand_UnitDelete;
            }
            
            // logic to create iron demand units under iron demand and unit whenever matched iron demand found.
            
            String soql = 'SELECT Id,Max_Price__c,Max_Hours__c,Max_Year__c,Min_Year__c FROM Iron_Demand__c WHERE isActive__c = true AND Max_Hours__c != NULL AND Max_Price__c != NULL ';
            if (categorySet.size() > 0) soql += ' AND Category__c IN :categorySet ';
            if(makeSet.size() > 0) soql += ' AND Make__c IN :makeSet ';
            if(modelSet.size() > 0) soql += ' AND Model__c IN :modelSet ';
            if(yearSet.size() > 0) soql += ' AND (Max_Year__c IN :yearSet OR Min_Year__c IN :yearSet)';
            List< Iron_Demand__c > IronDemandList = database.query(soql);
            
            system.debug('IronDemandList====>'+IronDemandList);
            if( IronDemandList != null && IronDemandList.size() > 0) {
                Map< Id,  Iron_Demand_Unit__c > mapOfIronDemandUnit = new Map< Id , Iron_Demand_Unit__c >();
                for( Product2 pro : newList ) {
                    if ( pro.IsActive ) { 
                        for( Iron_Demand__c iron : IronDemandList ) {
                            if( !mapOfIronDemandUnit.containsKey(iron.id) && iron.Max_Hours__c >= pro.Hour__c && iron.Max_Price__c >= pro.Starting_Advertised_Retail_Price__c) {
                                mapOfIronDemandUnit.put(iron.id, new Iron_Demand_Unit__c(Unit__c=pro.id, Iron_Demand__c=iron.id,Automation__c=true));
                            }
                        }
                    }
                }
                system.debug('iron demand map keys=====>'+mapOfIronDemandUnit.keySet().size());
                system.debug('iron demand map values =====>'+mapOfIronDemandUnit.values().size());
                if(mapOfIronDemandUnit.size() > 0) {
                    List < Database.SaveResult > saveResult = Database.insert(mapOfIronDemandUnit.values(), false);
                    if( saveResult != null) {
                        if ( !saveResult[0].isSuccess() ) {
                            for (Database.SaveResult result : saveResult) {
                                for ( Database.Error error: result.getErrors()) {
                                    throw new myException(error.getMessage()+', Error fields: '+error.getFields());
                                }
                            } 
                        }
                    }
                }
            }
        } catch (Exception ex){
            throw new myException(ex.getMessage()+', Error type: '+ex.getTypeName());
        }
    }
    // populate Equipment model to unit model
    /*public static void populateEquipmentModel( List< Product2 > newList ) {
        Map< ID, Product2 > productMap = new Map< ID, Product2 >([Select id,Model_Unit__c,equipment__r.Model_Equipment__c From Product2 Where ID IN : newList]);
        for( Product2 unit : newList) {
            if( productMap.containsKey(unit.id) && productMap.get(unit.id).equipment__r.Model_Equipment__c != null)
                unit.Model_Unit__c = productMap.get(unit.id).equipment__r.Model_Equipment__c;
        }
    }*/
    /*public static void AutoPopulatePricebookEntry( List< Product2 > newList ) {
        List<Pricebook2> pbList = new List<Pricebook2>();
        pbList = [select Id from Pricebook2 where IsStandard = TRUE LIMIT 1];
        system.debug('pbList :  '+pbList);
        if(pbList.size() > 0) {
            List<PricebookEntry> pbEntry = new List <PricebookEntry>();
            for (Product2 newProduct: newList) {
                PricebookEntry z = new PricebookEntry(Pricebook2Id=pbList[0].Id,Product2Id=newProduct.Id, UnitPrice=0.00, IsActive=TRUE, UseStandardPrice=FALSE);
                pbEntry.add(z);
            }
            if(pbEntry.size() > 0 && !test.isRunningTest()) {
                insert pbEntry;
            }
        }
    }*/
    
    //This method is used to Create iron demand record, if new UCD record matches
    public static void handleAfterUnitInsert( List< Product2 > newList){
        //set<string> setRecTypeName = new set<string>();
        set<id> setOfURIDId = new set<id>();
        map<id,boolean> mapOfProductIdVsIsActive = new map<id,boolean>();
        list<Unit_Category_Details__c> lstUnitCategoryToInsert = new list<Unit_Category_Details__c>();
        set<string> setOfUCDCategory = new set<string>();
        list<Unit_Category_Details__c> lstUnitCategoryDetail;
        set<string> setOfUCDCategoryToMDT = new set<string>{'common','URID'};
            set<id> setOfUnitId = new set<id>();
            Id recordTypeId ;
            string RecordTypeDevName = system.label.Unit_Category_Detail_From_Unit;
        
        system.debug('RecordTypeDevName');
        if(string.isNotBlank(RecordTypeDevName)){
             recordTypeId =  Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get(RecordTypeDevName).getRecordTypeId();
        }
            if(newList!=null && !newList.isEmpty()){
                for(Product2 eachProduct : newList){
                    if(!mapOfProductIdVsIsActive.containsKey(eachProduct.Id)){
                        mapOfProductIdVsIsActive.put(eachProduct.Id,eachProduct.IsActive);
                    }
                    if( string.isNotBlank(eachProduct.Category__c) ){
                        string Name = '';
                        if(string.isnotblank(eachProduct.Category__c)){
                            Name += eachProduct.Category__c+' ';
							}
                        if(string.isnotblank(eachProduct.ZID__c)){
                            Name +='ZID-'+ eachProduct.ZID__c;
                        }
                        Unit_Category_Details__c newUCD = new Unit_Category_Details__c();
                        newUCD.Name = 'Unit - '+Name ;
                        newUCD.Unit__c = eachProduct.Id;
                        newUCD.Equipment__c = eachProduct.equipment__c;
                        if(string.isNotBlank(recordTypeId)){
                            newUCD.RecordTypeId = recordTypeId;
                        }
                        
                        newUCD.Category_Details__c =eachProduct.Category__c; 
                        lstUnitCategoryToInsert.add(newUCD);
                    }
                    if(eachProduct.IsActive ==true && eachProduct.Starting_Advertised_Retail_Price__c != null){
                        setOfUnitId.add(eachProduct.id);
                    }
                    if(eachProduct.IsActive ==true){
                        setOfUCDCategory.add(eachProduct.Category__c);  
                      setOfUCDCategoryToMDT.add(eachProduct.Category__c); 
                    }
                   // setRecTypeName.add(eachProduct.Category__c);
                }
            }
        if(lstUnitCategoryToInsert!=null && !lstUnitCategoryToInsert.isEmpty()){
            insert lstUnitCategoryToInsert;
        }
        system.debug('setOfUCDCategory::::'+setOfUCDCategory);
        if(setOfUCDCategory != null && !setOfUCDCategory.isEmpty() ){
            lstUnitCategoryDetail = [SELECT ID,recordtypeid,unit__c,User_Requirement_ID__c,isActive__c,Category_Details__c
                                     FROM Unit_Category_Details__c 
                                     WHERE Category_Details__c in : setOfUCDCategory AND Unit__c = null AND User_Requirement_ID__c != null AND isActive__c=true ];
        }
       
        if(lstUnitCategoryDetail!=null && !lstUnitCategoryDetail.isEmpty()){
            for(Unit_Category_Details__c eachUCD : lstUnitCategoryDetail){
                if(string.isNotBlank(eachUCD.User_Requirement_ID__c)){
                    setOfURIDId.add(eachUCD.User_Requirement_ID__c); 
                }
            }
        }
        
        //Here we called future method where we create iron demand if user requirement meet the unit category 
        if(setOfURIDId!=null && !setOfURIDId.isEmpty() && setOfUCDCategoryToMDT!=null 
           && !setOfUCDCategoryToMDT.isEmpty() && setOfUCDCategory!=null && !setOfUCDCategory.isEmpty() && setOfUnitId != null && !setOfUnitId.isEmpty() ){
            UnitCategoryDetailsFutureClass.FutureUnitCategoryDetails(setOfURIDId,setOfUCDCategoryToMDT,setOfUCDCategory,setOfUnitId);
        }
    }
    
    public static void updateUnitLocation (Product2 unit,string siteContact, string street, 
     									 string city, string country, string state, string zipCode){
    	unit.Site_Contact__c = siteContact;
        unit.Storage_Address__c = Street;
        unit.Storage_City__c = city;
        unit.Storage_Country__c = country;
        unit.Storage_State__c = state;
        
        unit.Storage_Zip_Code__c = zipCode;
    }
    private static Boolean isValueChange(sObject newValue, sObject oldValue,String fieldName){
        return newValue.get(FieldName) != oldValue.get(FieldName);
    }
}