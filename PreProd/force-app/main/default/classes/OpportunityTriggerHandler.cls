public class OpportunityTriggerHandler implements ITriggerHandler{
    private static final string DEVELOPER_NAME = 'Opportunity';
    public Trigger_Setting__mdt setTriggerSettings() {
        
        return [select Active__c,Max_Loop_Count__c,Stop_Recursion__c FROM Trigger_Setting__mdt 
                Where DeveloperName=:DEVELOPER_NAME LIMIT 1];
    } 
    
    Public void beforeInsert(List<SObject> triggerNew){
        //Financial Checkbox can't be checked by sales user
        handleBeforeInsert((List<opportunity>)triggerNew);
        
    } 
    //By implementing this method trigger can handle all the before Update events
    Public void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){  
        //Financial Checkbox can't be checked by sales user
        handleBeforeUpdate((List<opportunity>)triggerNew,(Map<Id, opportunity>)triggerOldMap);
    }
    //By implementing this method trigger can handle all the before Delete events
    Public void beforeDelete(List<SObject> triggerOld){
        
    }   
    //By implementing this method trigger can handle all the after Insert events
    Public void afterInsert(List<SObject> triggerNew){
        
        handleAfterInsert((List<opportunity>)triggerNew);
        CalculateNoOfOpenOpportunity((List<opportunity>)triggerNew,false);
        
    }
    //By implementing this method trigger can handle all the after Update events
    Public void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){
        system.debug('size::'+triggerNew.size());
        handleNoOfSalesOppOnUpdate((List<opportunity>)triggerNew,(Map<Id, opportunity>)triggerOldMap);
        
    }
    //By implementing this method trigger can handle all the after Delete events
    Public void afterDelete(List<SObject> triggerOld){
        CalculateNoOfOpenOpportunity((List<opportunity>)triggerOld,false);
        
    }
    //By implementing this method trigger can handle all the after UnDelete events
    Public void afterUndelete(List<SObject> triggerNew){
        CalculateNoOfOpenOpportunity((List<opportunity>)triggerNew,false);
        
    }
    private static void handleBeforeInsert(list<Opportunity> lstTriggerNew){
        if(lstTriggerNew!=null && !lstTriggerNew.isEmpty()){
            set<Id> setOfUnitId = new set<Id>();
            set<id> setOfOppId = new set<id>();
            map<Id,Product2> mapOfIdVsProduct2;	
            set<id> setOfContactId = new set<id>();
            list<string> lstOfUserName;
            list<opportunity> lstOpportunity = new list<opportunity>();
            string usersFullName = System.Label.User_Name_for_Financial_Checkbox;
            Id procurementRecordTypeId;
            ID inventorySellRecordTypeId;
            if(string.isNotBlank(label.Opp_Rec_Type_Inventory_Sell)){
                inventorySellRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                    .get(label.Opp_Rec_Type_Inventory_Sell).getRecordTypeId();
            }
            if(string.isNotBlank(UsersFullName)){
                lstOfUserName = UsersFullName.split(',');
            }
            if(string.isNotBlank(label.Opp_Rec_type_Dev_Name_procurement_opp)){
                procurementRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                    .get(label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
            }
             Id BrokrageSellRecordTypeId;
        if(string.isNotBlank(label.Opp_Rec_Type_Broker_Sell)){
            BrokrageSellRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(label.Opp_Rec_Type_Broker_Sell).getRecordTypeId();
        }
            
            map<id,User> mapUserIdVsUser = new Map<ID, User>([SELECT id, Name FROM User WHERE Name IN : lstOfUserName ]);
            string errorMessage = 'Procurement Opportunity for this Unit is alredy created : ' + label.Zadoon_Org_EndPoint;
            
            for(opportunity eachOpportunity : lstTriggerNew){
                system.debug('eachOpportunity.Id:::'+eachOpportunity.Id);
                setOfOppId.add(eachOpportunity.Id);
                if(string.isnotblank(eachOpportunity.Seller_Primary_Contact_old__c)){
                    setOfContactId.add(eachOpportunity.Seller_Primary_Contact_old__c);
                }
                 if(string.isnotblank(eachOpportunity.Buyer_Primary_Contact__c)){
                    setOfContactId.add(eachOpportunity.Buyer_Primary_Contact__c);
                }
                if(eachOpportunity.Financials_complete__c == true){
                    //system.debug('eachOpportunity.CreatedById'+eachOpportunity.OwnerId);
                    if(!mapUserIdVsUser.containsKey(UserInfo.getUserId())){
                        eachOpportunity.addError('You can not mark the checkbox Financials Complete');
                    }
                }
                if(String.isNotBlank( procurementRecordTypeId) && eachOpportunity.RecordTypeId == procurementRecordTypeId){
                    if(String.isNotBlank(eachOpportunity.Product__c)){
                        setOfUnitId.add(eachOpportunity.Product__c);
                        
                    }
                    
                    /*if(mapOfRTNameVsRT.containsKey(label.Opp_Rec_type_Dev_Name_procurement_opp)  && 
eachOpportunity.RecordTypeId == mapOfRTNameVsRT.get(label.Opp_Rec_type_Dev_Name_procurement_opp).id &&
eachOpportunity.Inspection_Status__c == 'Completed' && 
string.isBlank(eachOpportunity.Inspection_Conversation_Notes_from_Owner__c)){
eachOpportunity.addError('inspection status can\'t be changed to Completed until Inspection Conversation Notes from Owner is filled out');
}*/
                    if(String.isNotBlank( procurementRecordTypeId)  && 
                       eachOpportunity.RecordTypeId == procurementRecordTypeId && 
                       (eachOpportunity.StageName == 'Wire Pending' ||
                        eachOpportunity.StageName == 'Won - Purchased' ||
                        eachOpportunity.StageName == 'Won - Brokered')&& 
                       (string.isBlank(eachOpportunity.Inspection_Status__c) || 
                        eachOpportunity.Inspection_Status__c == 'Pending' ||
                        eachOpportunity.Inspection_Status__c == 'Scheduled')){
                            eachOpportunity.addError('Stage can not be changed to Closed until Inspection status is completed OR Not Required.');
                        }
                }
            }
        list<contact> lstContact = new list<contact>();
            map<id,id> mapOfConIdVsAccId = new map<id,id>();
            system.debug('setOfContactId:::'+setOfContactId);
            if(setOfContactId != null && !setOfContactId.isEmpty()){
                lstContact = [SELECT id, AccountId
                              FROM contact
                              WHERE ID IN : setOfContactId AND AccountId != null ];
            }
            system.debug('lstContact:::'+lstContact);
            if(lstContact != null && !lstContact.isEmpty()){
                for(contact eachCon : lstContact){
                    if(!mapOfConIdVsAccId.containsKey(eachCon.id)){
                      mapOfConIdVsAccId.put(eachCon.id,eachCon.AccountId);  
                        system.debug('mapOfConIdVsAccId:::'+mapOfConIdVsAccId);
                    }
                }
            }
            
            
            if(setOfUnitId!=null && !setOfUnitId.isempty() && String.isNotBlank( procurementRecordTypeId) /*&&
mapOfRTNameVsRT.containsKey(label.Opp_Rec_type_Dev_Name_procurement_opp) */
              ){
                  mapOfIdVsProduct2 =new map<Id,Product2>([SELECT id,Name,Starting_Advertised_Retail_Price__c,
                                                           Old_SF_Unit_Details__c,Confidential_Information_Notes__c,Unit_Source__c,
                                                           (SELECT id,Name From Opportunities__r WHERE RecordTypeId =:procurementRecordTypeId ) 
                                                           FROM Product2 WHERE Id IN : setOfUnitId]);
              }
            
            
            for(opportunity eachOpportunity : lstTriggerNew){
                
                if(String.isNotBlank( procurementRecordTypeId) && eachOpportunity.RecordTypeId == procurementRecordTypeId ){
                    
                    if(String.isNotBlank(eachOpportunity.Product__c) && 
                       mapOfIdVsProduct2.containsKey(eachOpportunity.Product__c)
                       && mapOfIdVsProduct2.get(eachOpportunity.Product__c).Opportunities__r != null && 
                       !mapOfIdVsProduct2.get(eachOpportunity.Product__c).Opportunities__r.IsEmpty()){
                           //system.debug('eachOpportunity::' + eachOpportunity);
                           errorMessage = errorMessage + mapOfIdVsProduct2.get(eachOpportunity.Product__c).id;
                           eachOpportunity.addError(errorMessage);
                           system.debug('eachOpportunity.addError(errorMessage):::');
                       }else if (String.isNotBlank(eachOpportunity.Product__c) && mapOfIdVsProduct2.containsKey(eachOpportunity.Product__c)
                                 && mapOfIdVsProduct2.get(eachOpportunity.Product__c) != null
                                ){
                                    system.debug('mapOfIdVsProduct2.get(eachOpportunity.Product__c).St::'+mapOfIdVsProduct2.get(eachOpportunity.Product__c).Starting_Advertised_Retail_Price__c);
                                    eachOpportunity.Starting_Advertised_Retail_Price__c = mapOfIdVsProduct2.get(eachOpportunity.Product__c).Starting_Advertised_Retail_Price__c;
                                    eachOpportunity.Unit_Details__c = mapOfIdVsProduct2.get(eachOpportunity.Product__c).Old_SF_Unit_Details__c;
                                    eachOpportunity.Confidential_Information_Notes__c = mapOfIdVsProduct2.get(eachOpportunity.Product__c).Confidential_Information_Notes__c;
                                }
                }
                if(String.isNotBlank( procurementRecordTypeId) && 
                   eachOpportunity.RecordTypeId == procurementRecordTypeId 
                   && eachOpportunity.StageName == 'Initializing' && string.isnotblank(eachOpportunity.Product__c) ){
                       system.debug('enter in stage update:::');
                       eachOpportunity.StageName = 'Reviewing';
                   }
                if(String.isNotBlank( procurementRecordTypeId) && 
                   eachOpportunity.RecordTypeId == procurementRecordTypeId && string.isnotblank(eachOpportunity.Product__c)){
                       eachOpportunity.LeadSource = mapOfIdVsProduct2.get(eachOpportunity.Product__c).Unit_Source__c;
                   }
                
                    //if Sales Opp buyer primary contact is not null, then assign Buyer account primary contact to Opp.
                    system.debug('eachOpportunity.Buyer_Primary_Contact__c11:::'+eachOpportunity.Buyer_Primary_Contact__c);
                    system.debug('eachOpportunity.Buyer_Primary_Contact__c:::'+eachOpportunity.Buyer_Primary_Contact__c);
                system.debug('eachOpportunity.Buyer_Primary_Contact__r.AccountId:::'+eachOpportunity.Buyer_Primary_Contact__r.AccountId);
                system.debug('mapOfConIdVsAccId.get(eachOpportunity.Buyer_Primary_Contact__c):::'+mapOfConIdVsAccId.get(eachOpportunity.Buyer_Primary_Contact__c));

                    if(((string.isnotblank(inventorySellRecordTypeId) && eachOpportunity.RecordTypeId ==inventorySellRecordTypeId) 
                        || (string.isnotblank(BrokrageSellRecordTypeId) && eachOpportunity.RecordTypeId ==BrokrageSellRecordTypeId))
                       && string.isnotblank(eachOpportunity.Buyer_Primary_Contact__c) 
                       && mapOfConIdVsAccId.containsKey(eachOpportunity.Buyer_Primary_Contact__c) ){
                           system.debug('mapOfConIdVsAccId.get(eachOpportunity.Buyer_Primary_Contact__c):::'+mapOfConIdVsAccId.get(eachOpportunity.Buyer_Primary_Contact__c));
                           system.debug('eachOpportunity.Buyer_Primary_Contact__c:::'+eachOpportunity.Buyer_Primary_Contact__c);
                           system.debug('eachOpportunity.Buyer_Primary_Contact__r.AccountId:::'+eachOpportunity.Buyer_Primary_Contact__r.AccountId);
                           //eachOpportunity.accountid = mapOfConIdVsAccId.get(eachOpportunity.Buyer_Primary_Contact__c);
                       }
                    
                    //if Sales Opp seller primary contact is not null, then assign seller account primary contact to Opp.
                    system.debug('eachOpportunity.Buyer_Primary_Contact__c:::'+eachOpportunity.Seller_Primary_Contact_old__c);
                    system.debug('eachOpportunity.Seller_Primary_Contact_old__r.AccountId:::'+eachOpportunity.Seller_Primary_Contact_old__r.AccountId);
                    if(((string.isnotblank(inventorySellRecordTypeId) 
                       && eachOpportunity.RecordTypeId ==inventorySellRecordTypeId) || string.isnotblank(BrokrageSellRecordTypeId) 
                       && eachOpportunity.RecordTypeId ==BrokrageSellRecordTypeId)
                       && string.isnotblank(eachOpportunity.Seller_Primary_Contact_old__c) && mapOfConIdVsAccId.containsKey(eachOpportunity.Seller_Primary_Contact_old__c)){
                           system.debug('mapOfConIdVsAccId.containsKey(eachOpportunity.Seller_Primary_Contact_old__c):::'+mapOfConIdVsAccId.get(eachOpportunity.Seller_Primary_Contact_old__c));
                           system.debug('eachOpportunity.Buyer_Primary_Contact__c:::'+eachOpportunity.Seller_Primary_Contact_old__c);
                           system.debug('eachOpportunity.Seller_Primary_Contact_old__r.AccountId:::'+eachOpportunity.Seller_Primary_Contact_old__r.AccountId);
                           //eachOpportunity.Seller_Account__c =mapOfConIdVsAccId.get(eachOpportunity.Seller_Primary_Contact_old__c);
                       }
            }
            
        }
    }
    private static void handleBeforeUpdate(
        list<Opportunity> lstTriggerNew , 
        Map<Id, Opportunity> mapTriggerOldMap
    ){
        set<Id> setOfUnitId = new set<Id>();
        map<Id,Product2> mapOfIdVsProduct2;	
        string errorMessage = 'Opportunity RecordType is not updated it already has Procurement Opportunity : ' + label.Zadoon_Org_EndPoint;
        list<string> lstOfUserName;
        set<id> setOfOppId = new set<id>();
        list<opportunity> lstOpp = new list<opportunity>();
        string UsersFullName = System.Label.User_Name_for_Financial_Checkbox;
        if(string.isNotBlank(UsersFullName)){
            lstOfUserName = UsersFullName.split(',');
        }
        map<id,User> mapUserIdVsUser = new Map<ID, User>([SELECT id, Name FROM User WHERE Name IN : lstOfUserName  ]);
        Id procurementRecordTypeId;
        
        if(string.isNotBlank(label.Opp_Rec_type_Dev_Name_procurement_opp)){
            procurementRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
        }
        String Opp_Rec_type_Dev_Name_procurement_opp_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
        Id rentalRecordTypeId;
        if(string.isNotBlank(label.Opp_Rec_type_Dev_Name_Rental)){
            rentalRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(label.Opp_Rec_type_Dev_Name_Rental).getRecordTypeId();
        }
        ID inventorySellRecordTypeId;
        if(string.isNotBlank(label.Opp_Rec_Type_Inventory_Sell)){
            inventorySellRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(label.Opp_Rec_Type_Inventory_Sell).getRecordTypeId();
        }
        Id BrokrageSellRecordTypeId;
        if(string.isNotBlank(label.Opp_Rec_Type_Broker_Sell)){
            BrokrageSellRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(label.Opp_Rec_Type_Broker_Sell).getRecordTypeId();
        }
        for(opportunity eachOpportunity : lstTriggerNew){
            opportunity oldOpportunity = mapTriggerOldMap.get(eachOpportunity.id);
            setOfOppId.add(eachOpportunity.id);
            if(eachOpportunity.Financials_complete__c == true || mapTriggerOldMap.get(eachOpportunity.id).Financials_complete__c ==true){
                if(eachOpportunity.Financials_complete__c != mapTriggerOldMap.get(eachOpportunity.id).Financials_complete__c){
                    if(!mapUserIdVsUser.containsKey(UserInfo.getUserId())){
                        eachOpportunity.addError('You can not mark the checkbox Financials Complete');
                    }
                }
                
                else if(!mapUserIdVsUser.containsKey(UserInfo.getUserId())){
                    eachOpportunity.addError('You did not have access to edit the record.');
                }
            }
            
            if(((string.isnotblank(inventorySellRecordTypeId) && eachOpportunity.RecordTypeId == inventorySellRecordTypeId) ||
                (string.isnotblank(BrokrageSellRecordTypeId) && eachOpportunity.RecordTypeId == BrokrageSellRecordTypeId)) 
               && isValueChange(eachOpportunity,oldOpportunity,'Approved__c') && eachOpportunity.Approved__c == true &&
               eachOpportunity.StageName == 'Invoice approved'){
                   eachOpportunity.StageName ='Pro Forma Sent';
               }
              if(string.isnotblank(procurementRecordTypeId) && eachOpportunity.RecordTypeId == procurementRecordTypeId && 
               string.isblank(eachOpportunity.Year_from_Unit__c) && isValueChange(eachOpportunity,oldOpportunity,'Invoice_Details__c')
               && eachOpportunity.Invoice_Details__c == true && eachOpportunity.StageName == 'Offer Accepted' ){
                   eachOpportunity.addError('Add Year Field on Unit');
               }
            
            if(string.isnotblank(procurementRecordTypeId) && eachOpportunity.RecordTypeId == procurementRecordTypeId && 
               string.isblank(eachOpportunity.Manufacturer__c) && isValueChange(eachOpportunity,oldOpportunity,'Invoice_Details__c')
               && eachOpportunity.Invoice_Details__c == true && eachOpportunity.StageName == 'Offer Accepted' ){
                   eachOpportunity.addError('Add  Manufacturer field on Unit');
               }
            
            if(string.isnotblank(procurementRecordTypeId) && eachOpportunity.RecordTypeId == procurementRecordTypeId && 
               eachOpportunity.Hours_from_Units__c == null && isValueChange(eachOpportunity,oldOpportunity,'Invoice_Details__c')
               && eachOpportunity.Invoice_Details__c == true && eachOpportunity.StageName == 'Offer Accepted' ){
                   eachOpportunity.addError('Add Hours field on Unit');
               }
            
            if(string.isnotblank(procurementRecordTypeId) && eachOpportunity.RecordTypeId == procurementRecordTypeId && 
               string.isblank(eachOpportunity.Unit_S_N__c) && isValueChange(eachOpportunity,oldOpportunity,'Invoice_Details__c')
               && eachOpportunity.Invoice_Details__c == true && eachOpportunity.StageName == 'Offer Accepted' ){
                   eachOpportunity.addError('Add Serial Number field on Unit');
               }
            
            if(string.isnotblank(procurementRecordTypeId) && eachOpportunity.RecordTypeId == procurementRecordTypeId && 
               eachOpportunity.Offer_Amount__c == null && isValueChange(eachOpportunity,oldOpportunity,'Invoice_Details__c')
               && eachOpportunity.Invoice_Details__c == true && eachOpportunity.StageName == 'Offer Accepted' ){
                   eachOpportunity.addError('Add Offer amount on Unit');
               }
            system.debug('isValueChange:::'+isValueChange(eachOpportunity,oldOpportunity,'Freight_Option__c'));
            system.debug('eachOpportunity.Freight_Option__c:::'+eachOpportunity.Freight_Option__c);
            system.debug('eachOpportunity.Pro_Forma_Shipping_Cost__c:::'+eachOpportunity.Pro_Forma_Shipping_Cost__c);
            if(((string.isnotblank(inventorySellRecordTypeId) && eachOpportunity.RecordTypeId == inventorySellRecordTypeId) ||
               (string.isnotblank(BrokrageSellRecordTypeId) && eachOpportunity.RecordTypeId == BrokrageSellRecordTypeId)) && isValueChange(eachOpportunity,oldOpportunity,'StageName') &&
              eachOpportunity.StageName == 'Closed Lost' && string.isblank(eachOpportunity.Loss_Reason__c) ){
                 eachOpportunity.addError('Loss Reason should not be blank at close lost stage');
            }
              if(((string.isnotblank(inventorySellRecordTypeId) && eachOpportunity.RecordTypeId == inventorySellRecordTypeId) ||
               (string.isnotblank(BrokrageSellRecordTypeId) && eachOpportunity.RecordTypeId == BrokrageSellRecordTypeId)) && isValueChange(eachOpportunity,oldOpportunity,'StageName') &&
              eachOpportunity.StageName == 'Invoice Pending Approval' && string.isblank(eachOpportunity.Freight_Option__c) ){
                 eachOpportunity.addError('Select freight option');
            }
            system.debug(' eachOpportunity.StageName:::'+ eachOpportunity.StageName);
            system.debug('eachOpportunity.Pro_Forma_Price_Sent__c:::'+eachOpportunity.Pro_Forma_Price_Sent__c);
            system.debug('eachOpportunity.Freight_Option__c:::'+eachOpportunity.Freight_Option__c);
            system.debug('stagevalue change:::'+isValueChange(eachOpportunity,oldOpportunity,'StageName'));
            system.debug('freightchange:::'+isValueChange(eachOpportunity,oldOpportunity,'Freight_Option__c'));
            
            
            if(((string.isnotblank(inventorySellRecordTypeId) && eachOpportunity.RecordTypeId == inventorySellRecordTypeId) ||
                (string.isnotblank(BrokrageSellRecordTypeId) && eachOpportunity.RecordTypeId == BrokrageSellRecordTypeId)) &&
               (isValueChange(eachOpportunity,oldOpportunity,'Freight_Option__c')|| isValueChange(eachOpportunity,oldOpportunity,'StageName'))
               && (eachOpportunity.Freight_Option__c == 'Zadoon'|| eachOpportunity.Freight_Option__c == 'Buyer') && 
               eachOpportunity.StageName =='Invoice Pending Approval' && eachOpportunity.Pro_Forma_Price_Sent__c == null){
                   eachOpportunity.addError('Update Pro forma price sent');
               }
            if(((string.isnotblank(inventorySellRecordTypeId) && eachOpportunity.RecordTypeId == inventorySellRecordTypeId) ||
                (string.isnotblank(BrokrageSellRecordTypeId) && eachOpportunity.RecordTypeId == BrokrageSellRecordTypeId)) &&
               isValueChange(eachOpportunity,oldOpportunity,'Freight_Option__c') && 
               eachOpportunity.Freight_Option__c == 'Zadoon'){
                   if( eachOpportunity.Pro_Forma_Shipping_Cost__c == null){
                   eachOpportunity.addError('Update Pro forma shipping cost');
                        
                   }else if ( string.isblank(eachOpportunity.Shipping_City__c) ||
                            string.isblank(eachOpportunity.Shipping_Country__c) ||
                            string.isblank(eachOpportunity.Shipping_Postal_Code__c) ||
                            string.isblank(eachOpportunity.Shipping_State__c) ||
                            string.isblank(eachOpportunity.Shipping_Street__c) ){
                       
                   eachOpportunity.addError('Update Shipping address'); 
                   }
               }
            if(((string.isnotblank(inventorySellRecordTypeId) && eachOpportunity.RecordTypeId == inventorySellRecordTypeId) ||
                (string.isnotblank(BrokrageSellRecordTypeId) && eachOpportunity.RecordTypeId == BrokrageSellRecordTypeId)) &&
               isValueChange(eachOpportunity,oldOpportunity,'Freight_Option__c') && 
               ( eachOpportunity.Freight_Option__c == 'Buyer') && string.isblank(eachOpportunity.Billing_address__c)){
                   eachOpportunity.addError('Update billing address'); 
               }
            if(((string.isnotblank(inventorySellRecordTypeId) && eachOpportunity.RecordTypeId == inventorySellRecordTypeId) ||
                (string.isnotblank(BrokrageSellRecordTypeId) && eachOpportunity.RecordTypeId == BrokrageSellRecordTypeId)) &&
               isValueChange(eachOpportunity,oldOpportunity,'Freight_Option__c') && 
               (eachOpportunity.Freight_Option__c == 'Zadoon' || eachOpportunity.Freight_Option__c == 'Buyer') && string.isblank(eachOpportunity.Unit_S_N__c)){
                   eachOpportunity.addError('Fill out S/N field on unit record');
               }
            
            /*if(((string.isnotblank(inventorySellRecordTypeId) && eachOpportunity.RecordTypeId == inventorySellRecordTypeId) ||
                (string.isnotblank(BrokrageSellRecordTypeId) && eachOpportunity.RecordTypeId == BrokrageSellRecordTypeId)) &&
               isValueChange(eachOpportunity,oldOpportunity,'Freight_Option__c') && 
               eachOpportunity.Freight_Option__c == 'Buyer' && string.isnotblank(eachOpportunity.Unit_S_N__c)){
                   eachOpportunity.addError('Fill out S/N field on unit record');
               }
            if(((string.isnotblank(inventorySellRecordTypeId) && eachOpportunity.RecordTypeId == inventorySellRecordTypeId) ||
                (string.isnotblank(BrokrageSellRecordTypeId) && eachOpportunity.RecordTypeId == BrokrageSellRecordTypeId)) &&
               isValueChange(eachOpportunity,oldOpportunity,'Freight_Option__c') && 
               eachOpportunity.Freight_Option__c == 'Buyer' && string.isnotblank(eachOpportunity.Billing_address__c)){
                   eachOpportunity.addError('Update billing address');
               }*/
           
            if(String.isNotBlank( procurementRecordTypeId) && 
               eachOpportunity.RecordTypeId != mapTriggerOldMap.get(eachOpportunity.id).RecordTypeId &&
               eachOpportunity.RecordTypeId == procurementRecordTypeId){
                   
                   if(String.isNotBlank(eachOpportunity.Product__c)){
                       setOfUnitId.add(eachOpportunity.Product__c);
                   }
               }
            
            if(String.isNotBlank( procurementRecordTypeId) && 
               eachOpportunity.RecordTypeId == procurementRecordTypeId &&
               eachOpportunity.Inspection_Status__c != mapTriggerOldMap.get(eachOpportunity.id).Inspection_Status__c && 
               eachOpportunity.Inspection_Status__c == 'Completed' && 
               string.isBlank(eachOpportunity.Inspection_Conversation_Notes_from_Owner__c)){
                   // eachOpportunity.addError('inspection status can\'t be changed to Completed until Inspection Conversation Notes from Owner is filled out');
               }
            if(String.isNotBlank( procurementRecordTypeId) && 
               eachOpportunity.RecordTypeId == procurementRecordTypeId && 
               eachOpportunity.StageName != mapTriggerOldMap.get(eachOpportunity.id).StageName &&
               (eachOpportunity.StageName == 'Wire Pending' ||
                eachOpportunity.StageName == 'Won - Purchased' ||
                eachOpportunity.StageName == 'Won - Brokered')&&  
               (string.isBlank(eachOpportunity.Inspection_Status__c) || 
                eachOpportunity.Inspection_Status__c == 'Pending' ||
                eachOpportunity.Inspection_Status__c == 'Scheduled')){
                    eachOpportunity.addError('Stage can not be changed to Closed until Inspection status is completed OR Not Required.');
                }
            //when opp stage is document review stage, product is not empty and inspection status is completed, change opp stage to wire pending
            if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) && eachOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id && 
               eachOpportunity.StageName == 'Offer Accepted' && string.isnotblank(eachOpportunity.Product__c) &&
               isValueChange(eachOpportunity,oldOpportunity,'Inspection_Status__c') &&
               (eachOpportunity.Inspection_Status__c =='Completed' 
                || eachOpportunity.Inspection_Status__c =='Not Required')){
                    eachOpportunity.StageName = 'Document Review';
                }
            if(hasStageChanged(eachOpportunity, oldOpportunity) 
               && eachOpportunity.StageName == 'Pro Forma Signed' 
               && string.isnotblank(eachOpportunity.OwnerId)){
                   eachOpportunity.StageName = 'Waiting for Buyer\'s Wire';
               }
            if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
               && eachOpportunity.RecordTypeId != Opp_Rec_type_Dev_Name_procurement_opp_Id  &&
               hasCategoryChanged(eachOpportunity, oldOpportunity) && eachOpportunity.ForecastCategory =='Closed'){
                   if(eachOpportunity.Total_Cost__c != null ){
                       eachOpportunity.Zadoon_s_Final_Sale_Price__c =eachOpportunity.Total_Cost__c;
                   }
               }
            //If WTB status is changed to Requested and is not null then Update record
            if(isValueChange(eachOpportunity,oldOpportunity,'WTB_Status__c') && eachOpportunity.WTB_Status__c == 'WTB Requested'){
                eachOpportunity.WTB_Date__c = system.today();
                eachOpportunity.WTB_Status__c = 'WTB In Process';
                
            } 
            //If WTB status is changed to Completed and is not null then Update Date.
            if(isValueChange(eachOpportunity,oldOpportunity,'WTB_Status__c') && eachOpportunity.WTB_Status__c == 'WTB Completed'){
                eachOpportunity.WTB_Date__c = null;
            }
          
        }
        
            list<opportunity> lstOpportunity = [SELECT id,Seller_Primary_Contact__c,Product__c,RecordTypeId,StageName,
											    product__r.Primary_Contact__c,Buyer_Primary_Contact__c,account.Primary_Contact__c,Seller_Account__r.Primary_Contact__c
                                                ,Seller_Mobile_Ph__c,accountid,Seller_Phone_Ph__c,Seller_Primary_Contact_old__c,Buyer_Primary_Contact__r.AccountId,
                                                Seller_Primary_Contact_old__r.AccountId,product__r.account__r.Primary_Contact__r.MobilePhone,Product__r.Lead_Unit_Owner__c,
                                                Product__r.account__c,product__r.account__r.Primary_Contact__r.Phone,product__r.account__r.Primary_Contact__c,Invoice_Details__c
                                                FROM opportunity 
                                                WHERE ID IN : lstTriggerNew];
            
                //------------------Process Builder - Update contacts on opp 2---------------//
                           /*system.debug('newOpportunity.Seller_Primary_Contact__c::'+newOpportunity.Seller_Primary_Contact__c);
                           system.debug('newOpportunity.Product__r.account__c:::'+newOpportunity.Product__r.account__c);
                           system.debug('newOpportunity.product__r.Primary_Contact__r.MobilePhone:::'+newOpportunity.product__r.account__r.Primary_Contact__r.MobilePhone);
                           system.debug('newOpportunity.product__r.Primary_Contact__r.Phone:::'+newOpportunity.product__r.account__r.Primary_Contact__r.Phone);*/
            if(lstOpportunity != null && !lstOpportunity.isEmpty()){
                for(opportunity eachOpp : lstOpportunity){
                     opportunity oldOpportunity = mapTriggerOldMap.get(eachOpp.id);
                    if(string.isnotblank(eachOpp.Seller_Primary_Contact__c) 
                       && string.isnotblank(eachOpp.Product__c) 
                       && string.isnotblank(eachOpp.Product__r.account__c) && string.isnotblank( procurementRecordTypeId)
                       && string.isnotblank(rentalRecordTypeId) && 
                       (eachOpp.RecordTypeId != procurementRecordTypeId || eachOpp.RecordTypeId != rentalRecordTypeId ) 
                       && eachOpp.product__r.account__r.Primary_Contact__r.MobilePhone != null 
                       && eachOpp.product__r.account__r.Primary_Contact__r.Phone != null ){
                           eachOpp.Seller_Mobile_Ph__c = eachOpp.product__r.account__r.Primary_Contact__r.MobilePhone;
                           eachOpp.Seller_Phone_Ph__c = eachOpp.product__r.account__r.Primary_Contact__r.Phone;
                           //system.debug('newOppyyyyyyy:::'+newOpp);
                       }
                    else if(string.isnotblank(eachOpp.Seller_Primary_Contact__c) 
                            && string.isnotblank(eachOpp.Product__c) 
                            && string.isnotblank(eachOpp.Product__r.Lead_Unit_Owner__c)
                            && string.isnotblank( procurementRecordTypeId)
                            && string.isnotblank(rentalRecordTypeId) && 
                            (eachOpp.RecordTypeId != procurementRecordTypeId || eachOpp.RecordTypeId != rentalRecordTypeId ) 
                            && eachOpp.product__r.Lead_Unit_Owner__r.MobilePhone != null && eachOpp.product__r.Lead_Unit_Owner__r.Phone != null ){
                                eachOpp.Seller_Mobile_Ph__c = eachOpp.product__r.Lead_Unit_Owner__r.MobilePhone;
                                eachOpp.Seller_Phone_Ph__c = eachOpp.product__r.Lead_Unit_Owner__r.Phone;
                                //system.debug('newOppyyyyyyy:::'+newOpp);
                            }
                    if(string.isnotblank(procurementRecordTypeId) && eachOpp.RecordTypeId == procurementRecordTypeId && 
                       string.isblank(eachOpp.product__r.account__r.Primary_Contact__c) && isValueChange(eachOpp,oldOpportunity,'Invoice_Details__c')
                       && eachOpp.Invoice_Details__c == true && eachOpp.StageName == 'Offer Accepted' ){
                           eachOpp.addError('Add Account primary contact on Unit');
                       }
                    //if Sales Opp buyer primary contact is not null, then assign Buyer account primary contact to Opp.
                    if(((string.isnotblank(inventorySellRecordTypeId) 
                       && eachOpp.RecordTypeId ==inventorySellRecordTypeId) || string.isnotblank(BrokrageSellRecordTypeId) 
                       && eachOpp.RecordTypeId ==BrokrageSellRecordTypeId)
                       && isValueChange(eachOpp,oldOpportunity,'Buyer_Primary_Contact__c')  && string.isnotblank(eachOpp.Buyer_Primary_Contact__c) && string.isnotblank(eachOpp.account.Primary_Contact__c) ){
                           //eachOpp.accountid = eachOpp.account.Primary_Contact__c;
                       }
                    //if Sales Opp seller primary contact is not null, then assign seller account primary contact to Opp.
                    if(((string.isnotblank(inventorySellRecordTypeId) 
                       && eachOpp.RecordTypeId ==inventorySellRecordTypeId) || string.isnotblank(BrokrageSellRecordTypeId) 
                       && eachOpp.RecordTypeId ==BrokrageSellRecordTypeId) && isValueChange(eachOpp,oldOpportunity,'Seller_Primary_Contact_old__c') 
                       && string.isnotblank(eachOpp.Seller_Primary_Contact_old__c) && string.isnotblank(eachOpp.Seller_Primary_Contact_old__r.AccountId)){
                           //eachOpp.Seller_Account__c = eachOpp.Seller_Primary_Contact_old__r.AccountId;
                       }
                }
            }
        /* system.debug('newOpportunity.Accountid:::'+newOpportunity.Accountid);
                            system.debug('newOpportunity.Account.Primary_Contact__:::'+ newOpportunity.Account.Primary_Contact__c);
                           system.debug('newOpportunity.Buyer_Primary_Contact__c:::'+newOpportunity.Buyer_Primary_Contact__c);
                           if(string.isnotblank(newOpportunity.Accountid) &&  string.isnotblank(newOpportunity.Account.Primary_Contact__c) 
                              && string.isnotblank(newOpportunity.Buyer_Primary_Contact__c) ){
                                  if(newOpportunity.Buyer_Primary_Contact__c != newOpportunity.Account.Primary_Contact__c ){
                                      opportunity newOpp = new opportunity();
                                      newOpp.id = newOpportunity.Id; 
                                      newOpp.Buyer_Primary_Contact__c = newOpportunity.Account.Primary_Contact__c;
                                      lstOFOppToUpdate.add(newOpp);
                                      system.debug('newOpp.Buyer_Primary_Contact__c::::'+newOpp);
                                  }
                              }*/
        
        
        
        /*if(setOfOppId != null && !setOfOppId.isEmpty()){
            lstOpp = [SELECT id,accountid,account.primary_contact__c,Buyer_Primary_Contact__c,RecordTypeId
                      FROM opportunity
                      WHERE ID IN : setOfOppId];
        }
       
        if(lstOpp != null && !lstOpp.isEmpty()){
            for(opportunity eachOpp : lstOpp){
                system.debug('lstOpp:::'+lstOpp);
                system.debug('eachOpp.Accountid:::'+eachOpp.Accountid);
                system.debug('eachOpp.Account.Primary_Contact__:::'+ eachOpp.Account.Primary_Contact__c);
                system.debug('eachOpp.Buyer_Primary_Contact__c:::'+eachOpp.Buyer_Primary_Contact__c);
                if(string.isnotblank(eachOpp.Accountid) &&  string.isnotblank(eachOpp.Account.Primary_Contact__c) 
                   && string.isnotblank(eachOpp.Buyer_Primary_Contact__c) //&& string.isnotblank(inventorySellRecordTypeId) && eachOpp.RecordTypeId == inventorySellRecordTypeId
                    ){
                       if(eachOpp.Buyer_Primary_Contact__c != eachOpp.Account.Primary_Contact__c ){
                           eachOpp.Buyer_Primary_Contact__c = eachOpp.Account.Primary_Contact__c;
                           //lstOFOppToUpdate.add(newOpp);
                           system.debug('newOpp:::ererer::'+eachOpp);
                           system.debug('newOpp.Buyer_Primary_Contact__c::::'+eachOpp.Buyer_Primary_Contact__c);
                       }
                   }else{
                       eachOpp.Buyer_Primary_Contact__c =null;
                   }
            }
        }*/
        
        system.debug('setOfUnitId:'+setOfUnitId);
        if(setOfUnitId!=null && !setOfUnitId.isempty() && String.isNotBlank( procurementRecordTypeId) ){
            mapOfIdVsProduct2 =new map<Id,Product2>([SELECT id,Name,Starting_Advertised_Retail_Price__c,
                                                     Old_SF_Unit_Details__c,Confidential_Information_Notes__c,Unit_Source__c,
                                                     (SELECT id,Name From Opportunities__r WHERE RecordTypeId =:procurementRecordTypeId )
                                                     FROM Product2 WHERE Id IN : setOfUnitId]);
        }
        system.debug('mapOfIdVsProduct2::'+mapOfIdVsProduct2);
        if(lstTriggerNew!=null && !lstTriggerNew.isEmpty()){
            for(opportunity eachOpportunity : lstTriggerNew){
                
                if(String.isNotBlank( procurementRecordTypeId) && 
                   eachOpportunity.RecordTypeId != mapTriggerOldMap.get(eachOpportunity.id).RecordTypeId &&
                   eachOpportunity.RecordTypeId == ProcurementRecordTypeId && 
                   String.isNotBlank(eachOpportunity.Product__c) && 
                   mapOfIdVsProduct2.containsKey(eachOpportunity.Product__c)){
                       if(mapOfIdVsProduct2.get(eachOpportunity.Product__c).Opportunities__r != null && 
                          !mapOfIdVsProduct2.get(eachOpportunity.Product__c).Opportunities__r.IsEmpty() ){
                              errorMessage = errorMessage + mapOfIdVsProduct2.get(eachOpportunity.Product__c).id;
                              eachOpportunity.addError(errorMessage);
                          }else if(mapOfIdVsProduct2.get(eachOpportunity.Product__c) != null  ){
                              eachOpportunity.Starting_Advertised_Retail_Price__c = mapOfIdVsProduct2.get(eachOpportunity.Product__c).Starting_Advertised_Retail_Price__c;
                              eachOpportunity.Unit_Details__c = mapOfIdVsProduct2.get(eachOpportunity.Product__c).Old_SF_Unit_Details__c;
                              eachOpportunity.Confidential_Information_Notes__c = mapOfIdVsProduct2.get(eachOpportunity.Product__c).Confidential_Information_Notes__c;
                          }
                   }
            }
        }
        
    }
    
    private static void handleAfterInsert(
        list<Opportunity> lstTriggerNew
    ){
        if(lstTriggerNew!=null && !lstTriggerNew.isEmpty()){
            
            Id OpportunityRecordTypeId;
            
            if(string.isNotBlank(Label.Marketing_Detail_Opportunity)){
                OpportunityRecordTypeId =Schema.SObjectType.Marketing_Detail__c.getRecordTypeInfosByDeveloperName()
                    .get(Label.Marketing_Detail_Opportunity).getRecordTypeId();
            }
            Id UnitRecordTypeId;
            
            if(string.isNotBlank(Label.Marketing_Detail_Unit)){
                UnitRecordTypeId =Schema.SObjectType.Marketing_Detail__c.getRecordTypeInfosByDeveloperName()
                    .get(Label.Marketing_Detail_Unit).getRecordTypeId();
            }
             Id BrokrageSellRecordTypeId;
        if(string.isNotBlank(label.Opp_Rec_Type_Broker_Sell)){
            BrokrageSellRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(label.Opp_Rec_Type_Broker_Sell).getRecordTypeId();
        }
            
            
            /*id marketingDetailUnitRecordType;
if(string.isNotBlank(Label.Marketing_Detail_Unit)){
// string MDUnitRecordTypeName = Label.Marketing_Detail_Unit;
marketingDetailUnitRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Marketing_Detail_Unit).getRecordTypeId();
}*/
            set<id> setCustomAvaTax = new set<Id>();
            list<AvaTax_Line_Item__c> lstAvaTaxLineItem = new list<AvaTax_Line_Item__c>();
            list<Custom_AvaTax__c> lstCustomAvaTax = new list<Custom_AvaTax__c>();
            map<Id,Opportunity> mapOfUnitIdVSOpportunity = new map<Id,Opportunity>();
            map<Id,Opportunity> mapOfOpportunityIdVsOpportunity = new Map<Id,Opportunity>();
            list<Marketing_Detail__c> lstMarketingDetail ;
            set<id> setOfOppId = new set<id>();
            list<opportunity> lstOpportunity = new list<opportunity>();
            list<Marketing_Detail__c> lstMarketingDetailToInsert = new list<Marketing_Detail__c>();
            map<Id,Marketing_Detail__c> mapOfUnitIdVsMarketingDetails = new map<Id,Marketing_Detail__c>();
            map<String,User> mapNameVsUser = new map<String,User>();
             list<Task> lstTask = new list<Task>();
            list<opportunity> lstOppToUpdate = new list<opportunity>();
            //string procurementOpp = System.Label.Opp_Rec_type_Dev_Name_procurement_opp;
            Id procurementRecordTypeId;
            ID inventorySellRecordTypeId;
            
            if(string.isNotBlank(label.Opp_Rec_type_Dev_Name_procurement_opp)){
                procurementRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                    .get(label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
            }
            
               Id rentalRecordTypeId;
            
            if(string.isNotBlank(label.Opp_Rec_type_Dev_Name_Rental)){
                rentalRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                    .get(label.Opp_Rec_type_Dev_Name_Rental).getRecordTypeId();
            }
            if(string.isNotBlank(label.Opp_Rec_Type_Inventory_Sell)){
                inventorySellRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                    .get(label.Opp_Rec_Type_Inventory_Sell).getRecordTypeId();
            }
            
            list<User> lstUser = [SELECT Id, Username, Name,email
                                  FROM User 
                                  WHERE IsActive  = true
                                 ];
            
            if(lstUser!=null && !lstUser.isEmpty()){
                for(User eachUsers : lstUser){
                    mapNameVsUser.put(eachUsers.Name,eachUsers);
                    
                }
            }
            
            for(Opportunity eachOpportunity : lstTriggerNew){
                setOfOppId.add(eachOpportunity.id);
                if(eachOpportunity.RecordTypeId == procurementRecordTypeId &&string.isNotBlank(eachOpportunity.Product__c )){
                    mapOfUnitIdVSOpportunity.put(eachOpportunity.Product__c,eachOpportunity);
                }
               	mapOfOpportunityIdVsOpportunity.put(eachOpportunity.id,eachOpportunity);
                Custom_AvaTax__c newCustomAvaTax = new Custom_AvaTax__c();
                newCustomAvaTax.Opportunity__c = eachOpportunity.id;
                newCustomAvaTax.Shipping_City__c = eachOpportunity.Shipping_City__c;
                newCustomAvaTax.Shipping_Street__c = eachOpportunity.Shipping_Street__c;
                newCustomAvaTax.Shipping_Postal_Code__c = eachOpportunity.Shipping_Postal_Code__c;
                newCustomAvaTax.Shipping_State__c = eachOpportunity.Shipping_State__c;
                newCustomAvaTax.Shipping_Country__c = eachOpportunity.Shipping_Country__c;
                newCustomAvaTax.Account__c = eachOpportunity.AccountId;
                    
                lstCustomAvaTax.add(newCustomAvaTax);
                    
                /*if(eachOpportunity.Buyer_Aggrement_Signed__c == false ){
                          string subject = 'Buyer Agreement is not signed.';
                           task newTask =
                               CreateTask.createNewTask(subject,eachOpportunity.id,null,system.today(),eachOpportunity.OwnerId,'New');
                            if(newTask!=null){
                               lstTask.add(newTask);
                               system.debug('lstTask:::'+lstTask);
                           } 
                    }
                    
                    if(eachOpportunity.Seller_Aggrement_signed__c == false ){
                        string subject = 'Seller Agreement is not signed.';
                        task newTask =
                            CreateTask.createNewTask(subject,eachOpportunity.id,null,system.today(),eachOpportunity.OwnerId,'New');
                        if(newTask!=null){
                            lstTask.add(newTask);
                            system.debug('lstTask:::'+lstTask);
                        } 
                    }*/
                    
                    /*  //if Sales Opp buyer primary contact is not null, then assign Buyer account primary contact to Opp.
                    if(string.isnotblank(inventorySellRecordTypeId) 
                       && eachOpportunity.RecordTypeId ==inventorySellRecordTypeId 
                       && string.isnotblank(eachOpportunity.Buyer_Primary_Contact__c)  ){
                           eachOpportunity.accountid = eachOpportunity.account.Primary_Contact__c;
                       }
                    //if Sales Opp seller primary contact is not null, then assign seller account primary contact to Opp.
                    if(string.isnotblank(inventorySellRecordTypeId) 
                       && eachOpportunity.RecordTypeId ==inventorySellRecordTypeId 
                       && string.isnotblank(eachOpportunity.Seller_Primary_Contact_old__c) && string.isnotblank(eachOpportunity.Seller_Primary_Contact_old__r.AccountId)){
                           eachOpportunity.Seller_Account__c = eachOpportunity.Seller_Primary_Contact_old__r.AccountId;
                       }*/
                    
                    
                    //if Sales Opp buyer primary contact is null, then create a task for Opp owner .
                    if(((string.isnotblank(inventorySellRecordTypeId) && eachOpportunity.RecordTypeId == inventorySellRecordTypeId) ||
                        (string.isnotblank(BrokrageSellRecordTypeId) && eachOpportunity.RecordTypeId == BrokrageSellRecordTypeId))
                       && string.isblank(eachOpportunity.Buyer_Primary_Contact__c)){
                        string subject = 'Add Buyer Primary Contact.';
                           task newTask =
                               CreateTask.createNewTask(subject,eachOpportunity.id,null,system.today(),eachOpportunity.OwnerId,'New');
                            if(newTask!=null){
                               lstTask.add(newTask);
                               system.debug('lstTask:::'+lstTask);
                           } 
                    }
                      //if Sales Opp seller primary contact is  null, then create a task for Opp owner.
                    if((string.isnotblank(BrokrageSellRecordTypeId) && eachOpportunity.RecordTypeId == BrokrageSellRecordTypeId)
                       && string.isblank(eachOpportunity.Seller_Primary_Contact_old__c)){
                           string subject = 'Add Seller Primary Contact. ';
                           task newTask =
                               CreateTask.createNewTask(subject,eachOpportunity.id,null,system.today(),eachOpportunity.OwnerId,'New');
                            if(newTask!=null){
                               lstTask.add(newTask);
                               system.debug('lstTask1:::'+lstTask);
                           } 
                       }
                    //Task for Hardy when Send_machine_to_on_brand_dealers__c is true
                    if(eachOpportunity.Send_machine_to_on_brand_dealers__c == true 
                       && mapNameVsUser.containsKey(system.label.Inside_Central)){
                        string subject = 'Send that unit to on-brand dealers';
                        system.debug('subject:::'+subject);
                        task newTask = 
                            CreateTask.createNewTask(subject,eachOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                        if(newTask!=null){
                            lstTask.add(newTask);
                            system.debug('lstTaskToInsert Shipping Dims :::' + lstTask);
                        }
                    }
                    //Task for opp owner when Call_previous_won_lost_opps__c is true 
                    if(eachOpportunity.Call_previous_won_lost_opps__c == true 
                       && string.isnotblank(eachOpportunity.OwnerId)){
                        string subject = 'Call won/lost opps';
                        system.debug('subject:::' + subject);
                        task newTask = 
                            CreateTask.createNewTask(subject,eachOpportunity.Id,null,system.today(),eachOpportunity.OwnerId,'New');
                        newTask.Description =  '1. Contact a total of 10 won/lost opps (5 won/5 lost, 2 won/8 lost, or whatever combination makes sense'; 
                        newTask.Description += '2. Send an email to the customer and CC the original sales opp owner'; 
                        newTask.Description += '3. If that person no longer works at the company, CC Hardy';
                        newTask.Description += '4. Follow up with a phone call  Note : Start with Opps, then call Iron Demands';
                        if(newTask!=null){
                            lstTask.add(newTask);
                            system.debug('lstTaskToInsert Shipping Dims :::' + lstTask);
                        }
                    }
                    
                    
                    /*
                    system.debug('mapNameVsUser.containsKey(system.label.VA):::'+mapNameVsUser.containsKey(system.label.VA));
                    system.debug('eachOpportunity.StageName:::'+eachOpportunity.StageName);
                     system.debug('eachOpportunity.Product__c::'+eachOpportunity.Product__c);
                     system.debug('mapNameVsUser.containsKey(system.label.VA)::'+mapNameVsUser.containsKey(system.label.VA));
                    if(eachOpportunity.RecordTypeId == procurementRecordTypeId && string.isNotBlank(eachOpportunity.Product__c) && 
                       mapNameVsUser.containsKey(system.label.VA) && eachOpportunity.StageName == 'Reviewing' ){
                           string subject = 'Add inspection report to Google Drive and create link on Unit Page field called "Inspection Report - Google Drive Link".';
                           task newTask =
                               CreateTask.createNewTask(subject,eachOpportunity.Product__c,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           //newTask.ZID__c = eachOpportunity.Product__c;
                           newTask.Task_Type__c = 'Operations';
                           newTask.Priority ='High (2hrs or less)';
                           if(newTask!=null){
                               lstTask.add(newTask);
                               system.debug('lstTask:::'+lstTask);
                           }  
                       }*/
                }
            
           /* if(lstTask != null && !lstTask.isEmpty()){
                insert lstTask;
                system.debug('lstTask::'+lstTask);
            }
            
            if(setOfOppId != null && !setOfOppId.isEmpty()){
                lstOpportunity = [SELECT id,product__c,Seller_Primary_Contact__c,product__r.account__c,recordtypeid,product__r.Primary_Contact__c,
                                  product__r.account__r.Primary_Contact__r.MobilePhone,Seller_Mobile_Ph__c,Seller_Phone_Ph__c,product__r.account__r.Primary_Contact__r.Phone
                                  FROM opportunity
                                  WHERE ID IN : setOfOppId ];  
            }
            
            if(lstOpportunity !=null && !lstOpportunity.isEmpty()){
                for(opportunity eachOpp : lstOpportunity ){
                    if(string.isnotblank(eachOpp.Seller_Primary_Contact__c) 
                       && string.isnotblank(eachOpp.Product__c) 
                       && string.isnotblank(eachOpp.Product__r.account__c) && string.isnotblank( procurementRecordTypeId)
                       && string.isnotblank(rentalRecordTypeId) && 
                       (eachOpp.RecordTypeId != procurementRecordTypeId || eachOpp.RecordTypeId != rentalRecordTypeId ) ){
                           opportunity newOpp = new opportunity();
                           newOpp.id = eachOpp.Id;
                           newOpp.Seller_Mobile_Ph__c = eachOpp.product__r.account__r.Primary_Contact__r.MobilePhone;
                           newOpp.Seller_Phone_Ph__c = eachOpp.product__r.account__r.Primary_Contact__r.Phone;
                       }
                }
            }*/
            
            if(setOfOppId != null && !setOfOppId.isEmpty()){
                lstOpportunity = [SELECT id,product__c,Seller_Primary_Contact__c,product__r.account__c,recordtypeid,product__r.Primary_Contact__c,Buyer_Primary_Contact__c,
                                  account.Primary_Contact__c,Seller_Account__r.Primary_Contact__c,product__r.account__r.Primary_Contact__r.MobilePhone,Seller_Mobile_Ph__c,accountid,
                                  Seller_Phone_Ph__c,product__r.account__r.Primary_Contact__r.Phone,Seller_Primary_Contact_old__c,Buyer_Primary_Contact__r.AccountId,Seller_Primary_Contact_old__r.AccountId
                                  FROM opportunity
                                  WHERE ID IN : setOfOppId ];  
            }
            system.debug('lstOpportunity:::'+lstOpportunity);
         
            
            if(mapOfUnitIdVSOpportunity.keyset()!=null && !mapOfUnitIdVSOpportunity.isEmpty()){
                lstMarketingDetail = [SELECT Id, Marketed_On_Iron_Connect__c,
                                      Marketed_On_Craigslist__c, Marketed_On_FB_Marketplace__c, 
                                      Marketed_On_Fleet_Up_Marketplace__c,  Marketed_On_Instagram__c, 
                                      Marketed_On_LinkedIn__c, Marketed_On_Machinio__c, Marketed_On_Mascus__c,
                                      Marketed_on_MT_Crane_Truck__c, Marketed_On_MyLittleSalesman__c,Marketed_On_Equipment_Trader__c,
                                      Marketed_On_TradeMachines__c, Marketed_On_RitchieList__c,  Marketed_On_Rock_Dirt__c,
                                      Do_not_market_anywhere__c,Updated_From__c,
                                      Unit__c,Opportunity__c,Account__c
                                      FROM Marketing_Detail__c WHERE Unit__c IN : mapOfUnitIdVSOpportunity.keyset() ];
            }
            if(lstMarketingDetail!=null && !lstMarketingDetail.isEmpty()){
                for(Marketing_Detail__c eachMarketingDetail : lstMarketingDetail){
                    if(string.isNotBlank(eachMarketingDetail.Unit__c)){
                        mapOfUnitIdVsMarketingDetails.put(eachMarketingDetail.Unit__c,eachMarketingDetail);
                    }
                }
            }
            if(String.isNotBlank(procurementRecordTypeId)){
                for(Opportunity eachOpportunity : lstTriggerNew){
                    if(eachOpportunity.RecordTypeId == procurementRecordTypeId &&
                       string.isNotBlank(eachOpportunity.Product__c)  && 
                       mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c) !=null){
                           staticVariable.UpdatedFromObject='Opportunity';   
                           Marketing_Detail__c newMarketingDetail = new Marketing_Detail__c();
                           newMarketingDetail.Name = eachOpportunity.name;
                           //newMarketingDetail.Marketed_On_Construction_Equip_Guide__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Construction_Equip_Guide__c;
                           newMarketingDetail.Marketed_On_Craigslist__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Craigslist__c ;
                           //newMarketingDetail.Marketed_On_Facebook__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Facebook__c ;
                           newMarketingDetail.Marketed_On_FB_Marketplace__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_FB_Marketplace__c;
                           newMarketingDetail.Marketed_On_Fleet_Up_Marketplace__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Fleet_Up_Marketplace__c;
                           //newMarketingDetail.Marketed_On_GearFlow__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_GearFlow__c;
                           newMarketingDetail.Marketed_On_Instagram__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Instagram__c;
                           newMarketingDetail.Marketed_On_LinkedIn__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_LinkedIn__c;
                           newMarketingDetail.Marketed_On_Machinio__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Machinio__c;
                           newMarketingDetail.Marketed_On_Mascus__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Mascus__c;
                           newMarketingDetail.Marketed_on_MT_Crane_Truck__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_on_MT_Crane_Truck__c;
                           newMarketingDetail.Marketed_On_MyLittleSalesman__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_MyLittleSalesman__c;
                           //newMarketingDetail.Marketed_On_Terrapoint__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Terrapoint__c ;
                           newMarketingDetail.Marketed_On_TradeMachines__c =mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_TradeMachines__c;
                           //newMarketingDetail.Marketed_On_Used_Equip_Guide__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Used_Equip_Guide__c;
                           //newMarketingDetail.Marketed_On_Zonapesada__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Zonapesada__c;
                           newMarketingDetail.Do_not_market_anywhere__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Do_not_market_anywhere__c;
                           newMarketingDetail.Marketed_On_Iron_Connect__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Iron_Connect__c;
                           newMarketingDetail.Marketed_On_Equipment_Trader__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Equipment_Trader__c;
                           newMarketingDetail.Marketed_On_RitchieList__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_RitchieList__c;
                           newMarketingDetail.Marketed_On_Rock_Dirt__c = mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Marketed_On_Rock_Dirt__c;
                           //newMarketingDetail.Account__c = eachOpportunity.Account__c;
                           newMarketingDetail.Updated_From__c = 'Account';
                           //mapOfUnitIdVsMarketingDetails.get(eachOpportunity.Product__c).Updated_From__c = 'Opportunity';
                           
                           newMarketingDetail.Opportunity__c = eachOpportunity.id;
                           if(String.isNotBlank(OpportunityRecordTypeId) ){
                               newMarketingDetail.RecordTypeId = OpportunityRecordTypeId;
                           }
                           lstMarketingDetailToInsert.add(newMarketingDetail);
                           
                       }else if (String.isNotBlank(procurementRecordTypeId) &&
                                 eachOpportunity.RecordTypeId == procurementRecordTypeId &&
                                 string.isNotBlank(eachOpportunity.Product__c)){
                                     Marketing_Detail__c newMarketingDetail = new Marketing_Detail__c();
                                     newMarketingDetail.Opportunity__c = eachOpportunity.id;
                                     newMarketingDetail.Updated_From__c = 'Account';
                                     //newMarketingDetail.Account__c = eachOpportunity.Account__c;
                                     if(String.isNotBlank(OpportunityRecordTypeId)){
                                         newMarketingDetail.RecordTypeId = OpportunityRecordTypeId;
                                     }
                                     lstMarketingDetailToInsert.add(newMarketingDetail);
                                     
                                     Marketing_Detail__c newMarketingDetail1 = new Marketing_Detail__c();
                                     if(string.isNotBlank(eachOpportunity.Product__c)){
                                         newMarketingDetail1.Unit__c = eachOpportunity.Product__c;                                         
                                     }
                                     if(String.isNotBlank(UnitRecordTypeId) ){
                                         newMarketingDetail1.RecordTypeId = UnitRecordTypeId;
                                     }
                                     lstMarketingDetailToInsert.add(newMarketingDetail1);
                                 }
                  
                }
            }
            
            /*
            if(lstTriggerNew != null && !lstTriggerNew.isEmpty()){
                for(Opportunity eachOpportunity : lstTriggerNew){
                    //Task for Hardy when Send_machine_to_on_brand_dealers__c is true
                    if(eachOpportunity.Send_machine_to_on_brand_dealers__c == true 
                       && mapNameVsUser.containsKey(system.label.Inside_Central)){
                        string subject = 'Send that unit to on-brand dealers';
                        system.debug('subject:::'+subject);
                        task newTask = 
                            CreateTask.createNewTask(subject,eachOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                        if(newTask!=null){
                            lstTask.add(newTask);
                            system.debug('lstTaskToInsert Shipping Dims :::' + lstTask);
                        }
                    }
                    //Task for opp owner when Call_previous_won_lost_opps__c is true 
                    if(eachOpportunity.Call_previous_won_lost_opps__c == true 
                       && string.isnotblank(eachOpportunity.OwnerId)){
                        string subject = 'Call won/lost opps';
                        system.debug('subject:::' + subject);
                        task newTask = 
                            CreateTask.createNewTask(subject,eachOpportunity.Id,null,system.today(),eachOpportunity.OwnerId,'New');
                        newTask.Description =  '1. Contact a total of 10 won/lost opps (5 won/5 lost, 2 won/8 lost, or whatever combination makes sense'; 
                        newTask.Description += '2. Send an email to the customer and CC the original sales opp owner'; 
                        newTask.Description += '3. If that person no longer works at the company, CC Hardy';
                        newTask.Description += '4. Follow up with a phone call  Note : Start with Opps, then call Iron Demands';
                        if(newTask!=null){
                            lstTask.add(newTask);
                            system.debug('lstTaskToInsert Shipping Dims :::' + lstTask);
                        }
                    }
                    
                } 
            }*/
            
            
            if(lstCustomAvaTax!=null && !lstCustomAvaTax.isEmpty()){
                insert lstCustomAvaTax;
                for(Custom_AvaTax__c eachCustomAvaTax : lstCustomAvaTax){
                    AvaTax_Line_Item__c newAvaTaxLineItem = new AvaTax_Line_Item__c();
                    if(mapOfOpportunityIdVsOpportunity.containsKey(eachCustomAvaTax.Opportunity__c)){
                        setCustomAvaTax.add(eachCustomAvaTax.id);
                        newAvaTaxLineItem.Name = mapOfOpportunityIdVsOpportunity.get(eachCustomAvaTax.Opportunity__c).Name;
                        newAvaTaxLineItem.Amount__c = mapOfOpportunityIdVsOpportunity.get(eachCustomAvaTax.Opportunity__c).Pro_Forma_Price_Sent__c;
                        newAvaTaxLineItem.Custom_AvaTax__c = eachCustomAvaTax.id;
                        newAvaTaxLineItem.Quantity__c = '1';
                        newAvaTaxLineItem.Unit__c  = mapOfOpportunityIdVsOpportunity.get(eachCustomAvaTax.Opportunity__c).Product__c;
                        lstAvaTaxLineItem.add(newAvaTaxLineItem);
                        //newAvaTaxLineItem.Amount__c = 
                    }
                }
            }
            if(lstAvaTaxLineItem!=null && !lstAvaTaxLineItem.isEmpty()){
                insert lstAvaTaxLineItem;
                /*for(AvaTax_Line_Item__c eachCustomAvaTaxLineItem : lstAvaTaxLineItem ){
                    CustomAvaTaxCalculator.AvaTaxId= eachCustomAvaTaxLineItem.Custom_AvaTax__c;
                    CustomAvaTaxCalculator.calculateTax();
                }*/
            }
            if(setCustomAvaTax!=null && !setCustomAvaTax.IsEmpty()){
                //CalculateCustomAvaTax.executeAsyncCall(setCustomAvaTax);
               // Database.executeBatch(new CalculateCustomAvaTaxBatchClass(setCustomAvaTax), 1);
            }
            
            if(lstTask != null && !lstTask.isEmpty()){
                system.debug('lstTask:::'+lstTask);
                insert lstTask;
                system.debug('lstTask:::'+lstTask);
            }
            
            
            if(lstMarketingDetailToInsert!=null && !lstMarketingDetailToInsert.isEmpty()){
                insert lstMarketingDetailToInsert;
            }
            if(mapOfUnitIdVsMarketingDetails.Values()!=null && !mapOfUnitIdVsMarketingDetails.Values().isEmpty()){
               // update mapOfUnitIdVsMarketingDetails.Values();
            }
            if(lstOppToUpdate != null && !lstOppToUpdate.isEmpty()){
                update lstOppToUpdate;
            }
        }
    }
    
    private static void calculateNoOfOpenOpportunity(
        list<Opportunity> lstTriggerNew,
        boolean isUpdate
    ){
        set<id> setOfUnitId = new set<id>();
        set<id> setOfUnitIdActive = new set<id>();
        set<Id>setRecordTypeId = new set<Id>();
        Id inventorySellRecordTypeId;
        Id brokerSellRecordTypeId;
        if(string.isNotBlank(label.Opp_Rec_Type_Broker_Sell)){
            brokerSellRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(label.Opp_Rec_Type_Broker_Sell).getRecordTypeId();
        }
        if(String.isNotBlank(brokerSellRecordTypeId)){
            setRecordTypeId.add(brokerSellRecordTypeId);
        }
        
        
        if(string.isNotBlank(label.Opp_Rec_Type_Inventory_Sell)){
            inventorySellRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(label.Opp_Rec_Type_Inventory_Sell).getRecordTypeId();
        }
        if(String.isNotBlank(inventorySellRecordTypeId)){
            setRecordTypeId.add(inventorySellRecordTypeId);
        }
        
        if(lstTriggerNew!=null && !lstTriggerNew.isEmpty()){
            for(Opportunity eachOpportunity : lstTriggerNew){
                if(string.isNotBlank( eachOpportunity.Product__c) && setRecordTypeId.contains(eachOpportunity.RecordTypeId) ){
                    setOfUnitId.add(eachOpportunity.Product__c);
                }
                if(string.isNotBlank( eachOpportunity.Product__c) && 
                   setRecordTypeId.contains(eachOpportunity.RecordTypeId) && eachOpportunity.StageName !='Closed Lost' 
                   && isUpdate == false){
                       setOfUnitIdActive.add(eachOpportunity.Product__c);
                   }
            }
        }
        if(setOfUnitIdActive!=null && !setOfUnitIdActive.isEmpty()){
            //Check 'Unit Involved in an Active Opportunity' when it has related sales opportunities whose stage is not equal to Closed Lost 
            //and unit is active
            updateUnitInvolved (setOfUnitIdActive);
        }
        if(setOfUnitId!=null && !setOfUnitId.isEmpty() && 
           setRecordTypeId!=null && !setRecordTypeId.isEmpty()){
               
               list<Product2>lstUnit = [SELECT id, name, Number_of_Sales_Opportunities__c,
                                        (SELECT id,RecordTypeId 
                                         FROM Opportunities__r 
                                         WHERE RecordTypeId IN : setRecordTypeId )
                                        FROM Product2 
                                        WHERE id IN :setOfUnitId];
               
               
               if(lstUnit != null && !lstUnit.isempty()){
                   for(Product2 eachUnit : lstUnit){
                       eachUnit.Number_of_Sales_Opportunities__c = eachUnit.Opportunities__r.size();
                   }
               }
               if(lstUnit != null && lstUnit.size()>0){    
                   update lstUnit;
                   
               }
           }
        
    }
    private static void handleNoOfSalesOppOnUpdate(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap){
        system.debug('triggerNewafterUpdate:::'+triggerNew);
        if(triggerNew!=null&& !triggerNew.isEmpty()){
            set<Id> setOpportunityIds = new set<Id>();
            list<task> lstTaskToInsert = new list<task>();
            List<Product2>lstProductsToBeUpdated = new LIst<Product2>();
            //set<id> setOfOppId = new set<id>();
            List<Opportunity>lstOpportunityQuery = new LIst<Opportunity>();
            List<Messaging.SingleEmailMessage> lstMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
            set<Id> setUnitId = new set<Id>();
            set<Opportunity> setOfOpportunity = new set<Opportunity>();
            set<id> setOfProductId = new set<id>();
            set<Id> setUserIds = new set<Id>();
            //list<opportunity> lstOFOppToUpdate = new list<opportunity>();
            list<opportunity> lstOFOpportunityToUpdate = new list<opportunity>();
            list<product2> lstOFUnitToUpdate = new list<product2>();
            list<product2> lstProduct = new list<product2>();
            list<Account> lstAccount = new list<Account>();
            map<string,EmailTemplate> mapofStringVsEmailTemplate = new map<string,EmailTemplate>();
            list<EmailTemplate> lstEmailtemp = new list<EmailTemplate>();
            //set<id> setOfOppToUpdate = new set<id>();
            list<opportunity> lstOpp;
            map<id,string> mapOfOppIdVsContactId = new map<id,string>();
            map<id,string> mapOfOppIdVsStageName = new map<id,string>();
            list<User_Requirement_ID__c> lstUserRequirement = new list<User_Requirement_ID__c>();
            list<User_Requirement_ID__c> lstUserRequirementTOupdate = new list<User_Requirement_ID__c>();
            list<iron_demand__c> lstIronDemandToUpdate = new list<iron_demand__c>();
            map<id,id> mapofIronDemandIDVsUnitAccountId = new map<id,id>();
            map<String,User> mapNameVsUser = new map<String,User>();
            map<String,User> mapIDVsUser = new map<String,User>();
            list<Messaging.SingleEmailMessage> lstMessage = new list<Messaging.SingleEmailMessage>();
            //Opp_Rec_Type_Broker_Sell
            String Opp_Rec_Type_Broker_Sell_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_Type_Broker_Sell).getRecordTypeId();
            //Opp_Rec_Type_Inventory_Sell
            String Opp_Rec_Type_Inventory_Sell_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_Type_Inventory_Sell).getRecordTypeId();
            //Opp_Rec_type_Dev_Name_procurement_opp
            String Opp_Rec_type_Dev_Name_procurement_opp_Id= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
            list<opportunity> lstOppToUpdate = new list<opportunity>();
            set<id> setOfAccountId = new set<id>();
            map<id,string> mapOfAccIdVsString = new map<id,string>();
            //Manager User to assighn the Task when Stage is change Client Inspection Requested
            //User managerUser = new User();
            // String MangerRoleName = 'Manager';
            // lstEmail to be sent with attachements.
			list< Messaging.SingleEmailMessage> lstEmailWithAttachements = new list< Messaging.SingleEmailMessage>();
            
            //For AvaTax 
            set<Id> SetOfOpportunityId = new Set<Id>();
            list<Custom_AvaTax__c> lstCustomAvaTax = new list<Custom_AvaTax__c>();
            Map<Id, Opportunity> triggerNewMap = ( Map<Id, Opportunity>)trigger.newMap;
            list<AvaTax_Line_Item__c> lstAvaTaxLineItem = new list<AvaTax_Line_Item__c>();
            set<Id> setAvataxId = new set<Id>();
            Id rentalRecordTypeId;
            if(string.isNotBlank(label.Opp_Rec_type_Dev_Name_Rental)){
                rentalRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                    .get(label.Opp_Rec_type_Dev_Name_Rental).getRecordTypeId();
            }
            list<User> lstUser = [SELECT Id, Username, Name,email
                                  FROM User 
                                  WHERE IsActive  = true
                                 ];
            
            if(lstUser!=null && !lstUser.isEmpty()){
                for(User eachUsers : lstUser){
                    system.debug('eachUsers.Name::'+eachUsers.Name);
                    mapNameVsUser.put(eachUsers.Name,eachUsers);
                    mapIDVsUser.put(eachUsers.id,eachUsers);
                }
            }
            OrgWideEmailAddress newOrgWideEmail = new OrgWideEmailAddress();
            if(string.isnotblank(system.label.Office_Manager)){
                newOrgWideEmail = [SELECT Id, CreatedById, Address, DisplayName 
                                   FROM OrgWideEmailAddress 
                                   WHERE DisplayName =: system.label.Office_Manager
                                   LIMIT 1];
            }
            
            list<Task> lstTask = new list<Task>();
            list<Product2> lstProduct2 = new list<Product2>();
            
            id procurementRecordTypeId;
            if(string.isNotBlank(label.Opp_Rec_type_Dev_Name_procurement_opp)){
                procurementRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                    .get(label.Opp_Rec_type_Dev_Name_procurement_opp).getRecordTypeId();
            }
            for(Opportunity newOpportunity : triggerNew){
                setOpportunityIds.add(newOpportunity.Id);
                Opportunity oldOpportunity = triggerOldMap.get(newOpportunity.Id);
                //To Calculate AvaTax amount
                if(isValueChange(newOpportunity,oldOpportunity,'Pro_Forma_Price_Sent__c')){
                    SetOfOpportunityId.add(newOpportunity.Id);
                }
                
                
                if((hasUnitChanged(newOpportunity, oldOpportunity) || hasRecordTypeChanged(newOpportunity, oldOpportunity) )){
                    
                    setOfOpportunity.add(oldOpportunity);
                    setOfOpportunity.add(newOpportunity);
                }
                
                  if(isValueChange(newOpportunity,oldOpportunity,'Buyer_Primary_Contact__c') &&
                   string.isnotblank(newOpportunity.Buyer_Primary_Contact__c) && string.isnotblank(Opp_Rec_Type_Inventory_Sell_Id) &&
                  string.isnotblank(Opp_Rec_Type_Broker_Sell_Id) && !mapOfOppIdVsContactId.containsKey(newOpportunity.id)){
                    mapOfOppIdVsContactId.put(newOpportunity.id,newOpportunity.Buyer_Primary_Contact__c);
                      setOFOpportunityID.add(newOpportunity.id);
                }
                if(isValueChange(newOpportunity,oldOpportunity,'StageName') &&
                   /*newOpportunity.StageName == 'Closed Lost' &&*/ string.isnotblank(Opp_Rec_Type_Inventory_Sell_Id) &&
                   string.isnotblank(Opp_Rec_Type_Broker_Sell_Id) && !mapOfOppIdVsStageName.containsKey(newOpportunity.id) &&
                  (newOpportunity.RecordTypeId ==Opp_Rec_Type_Inventory_Sell_Id || newOpportunity.RecordTypeId ==Opp_Rec_Type_Broker_Sell_Id) ){
                       mapOfOppIdVsStageName.put(newOpportunity.id,newOpportunity.StageName);
                       setOFOpportunityID.add(newOpportunity.id);
                   }
                
                if(isValueChange(newOpportunity,oldOpportunity,'StageName') && newOpportunity.ForecastCategory =='Closed' ){
                    if((string.isnotblank(Opp_Rec_Type_Inventory_Sell_Id) && newOpportunity.RecordTypeId ==Opp_Rec_Type_Inventory_Sell_Id) 
                       || (string.isnotblank(Opp_Rec_Type_Broker_Sell_Id) && newOpportunity.RecordTypeId ==Opp_Rec_Type_Broker_Sell_Id) 
                       && !mapOfAccIdVsString.containsKey(newOpportunity.AccountId)){
                           system.debug('enter in sales opportunity');
                           setOfAccountId.add(newOpportunity.AccountId);
                           mapOfAccIdVsString.put(newOpportunity.AccountId,'Sales Opportunity'); 
                       }
                    else if(newOpportunity.RecordTypeId ==procurementRecordTypeId && string.isnotBlank(newOpportunity.Seller_Account__c) 
                            && !mapOfAccIdVsString.containsKey(newOpportunity.Seller_Account__c)){
                                system.debug('enter in proc opportunity');
                                setOfAccountId.add(newOpportunity.Seller_Account__c);
                                mapOfAccIdVsString.put(newOpportunity.Seller_Account__c,'Procurement Opportunity');
                            }
                }
                
                
               /* opportunity newOpp = new opportunity();
                if(string.isNotBlank(newOpportunity.id)){
                    newOpp.id = newOpportunity.id;
                }*/
               
                //if wtb date is changed and WTB priority is high then create a tasks for VA, President & Hardy
                if(isValueChange(newOpportunity,oldOpportunity,'WTB_Date__c') && newOpportunity.WTB_Date__c !=null
                   && newOpportunity.WTB_Priority__c =='High (immediate WTB email)'){
                    if( mapNameVsUser.containsKey(system.label.VA)){
                        
                        string subject = 'Send WTB email with parameters to equipment sellers, end users, dealers, and finance companies.';
                        subject += 'Responses will be sent to you to add to original opp as multiple units.';
                        task newTask =
                            CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                        newTask.Task_Type__c = 'Procurement';
                        newTask.Priority = 'High (2hrs or less)';
                        if(newTask!=null){
                            lstTask.add(newTask);
                            system.debug('lstTask:::'+lstTask);
                        }   
                        string subject1 = 'Post WTB on Iron Connect.If it is an ON ROAD truck, or a CRANE,'; 
                        subject1 += ' please DO NOT post on IronConnect,close task as not required.Matching units to be added to opp.';
                        task newTask1 =
                            CreateTask.createNewTask(subject1,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                        newTask1.Task_Type__c = 'Procurement';
                        newTask1.Priority = 'High (2hrs or less)';
                        if(newTask1!=null){
                            lstTask.add(newTask1);
                            system.debug('lstTask:::'+lstTask);
                        }
                           string subject2 = 'Post WTB on MT (crane trader or truck trader as needed), Mascus, Machinio,'; 
                        subject2 += 'Rock & Dirt, Construction Equipment Guide, and Used Equipment Guide. Matches to be added to opp.';
                        task newTask2 =
                            CreateTask.createNewTask(subject2,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                        newTask2.Task_Type__c = 'Procurement';
                        newTask2.Priority = 'High (2hrs or less)';
                        if(newTask2!=null){
                            lstTask.add(newTask2);
                            system.debug('lstTask:::'+lstTask);
                        }
                        string subject3 = 'Search CL, FB, auctions for WTB units; add auction units to live auction tab & other units to SF/opp'; 
                        task newTask3 =
                            CreateTask.createNewTask(subject3,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
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
                           subject4 += newOpportunity.WTB_Parameters__c;
                           task newTask4 =
                               CreateTask.createNewTask(subject4,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.President).id,'New');
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
                           subject5 += newOpportunity.WTB_Parameters__c;
                           task newTask5 =
                               CreateTask.createNewTask(subject5,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                           newTask5.Task_Type__c = 'Procurement';
                           newTask5.Priority = 'High (2hrs or less)';
                           if(newTask5 != null){
                               lstTask.add(newTask5);
                               system.debug('lstTask:::'+lstTask);
                           }
                       }
                    
                }
  				
                
                //if WTB date is changed and WTB priority is Medium then create a tasks for VA, President & Hardy
                if(isValueChange(newOpportunity,oldOpportunity,'WTB_Date__c') && newOpportunity.WTB_Date__c != null
                   && newOpportunity.WTB_Priority__c =='Medium (include w/ weekly WTB)'){
                       if( mapNameVsUser.containsKey(system.label.VA)){
                           string subject = 'Add to weekly WTB email list; matches to be added directly to the opportunity.';
                           task newTask =
                               CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask.Task_Type__c = 'Procurement';
                           if(newTask!=null){
                               lstTask.add(newTask);
                               system.debug('lstTask:::'+lstTask);
                           }   
                           string subject1 = 'Post WTB on Iron Connect.If it is an ON ROAD truck, or a CRANE,'; 
                           subject1 += ' please DO NOT post on IronConnect,close task as not required.Matching units to be added to opp.';
                           task newTask1 =
                               CreateTask.createNewTask(subject1,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask1.Task_Type__c = 'Procurement';
                           if(newTask1!=null){
                               lstTask.add(newTask1);
                               system.debug('lstTask:::'+lstTask);
                           }
                           string subject2 = 'Post WTB on MT (crane trader or truck trader as needed), Mascus, Machinio,'; 
                           subject2 += 'Rock & Dirt, Construction Equipment Guide, and Used Equipment Guide. Matches to be added to opp.';
                           task newTask2 =
                               CreateTask.createNewTask(subject2,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask2.Task_Type__c = 'Procurement';
                           if(newTask2!=null){
                               lstTask.add(newTask2);
                               system.debug('lstTask:::'+lstTask);
                           }
                           string subject3 = 'Search CL, FB, auctions for WTB units; add auction units to live auction tab & other units to SF/opp'; 
                           task newTask3 =
                               CreateTask.createNewTask(subject3,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask3.Task_Type__c = 'Procurement';
                           if(newTask3!=null){
                               lstTask.add(newTask3);
                               system.debug('lstTask:::'+lstTask);
                           }
                       }
                       //Task for Collin Magliolo
                       if(mapNameVsUser.containsKey(system.label.President)){
                           string subject4 = ' Look for WTB: ';
                           subject4 += newOpportunity.WTB_Parameters__c;
                           task newTask4 =
                               CreateTask.createNewTask(subject4,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.President).id,'New');
                           newTask4.Task_Type__c = 'Procurement';
                           if(newTask4 != null){
                               lstTask.add(newTask4);
                               system.debug('lstTask:::'+lstTask);
                           } 
                       }
                       //Task for Hardy
                       if(mapNameVsUser.containsKey(system.label.Inside_Central)){
                           string subject5 = ' Look for WTB: ';
                           subject5 += newOpportunity.WTB_Parameters__c;
                           task newTask5 =
                               CreateTask.createNewTask(subject5,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                           newTask5.Task_Type__c = 'Procurement';
                           if(newTask5 != null){
                               lstTask.add(newTask5);
                               system.debug('lstTask:::'+lstTask);
                           }
                       }
                   }
               //if wtb date is changed and WTB priority is Low then create a tasks for VA
                if(isValueChange(newOpportunity,oldOpportunity,'WTB_Date__c') && newOpportunity.WTB_Date__c != null
                   && newOpportunity.WTB_Priority__c =='Low (Post on iron sites only)' ){
                       if(mapNameVsUser.containsKey(system.label.VA)){
                           string subject = 'Post WTB on Iron Connect.If it is an ON ROAD truck, or a CRANE,';
                           subject += ' please DO NOT post on IronConnect,close task as not required.Matching units to be added to opp.';
                           task newTask =
                               CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask.Task_Type__c = 'Procurement';
                           if(newTask != null){
                               lstTask.add(newTask);
                               system.debug('lstTask:::'+lstTask);
                           }
                           
                            string subject1 = ' Post WTB on MT (crane trader or truck trader as needed), Mascus, Machinio,';
                           subject1 += 'Rock & Dirt, Construction Equipment Guide, and Used Equipment Guide. Matches to be added to opp.';
                           task newTask1 =
                               CreateTask.createNewTask(subject1,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask1.Task_Type__c = 'Procurement';
                           if(newTask1 != null){
                               lstTask.add(newTask1);
                               system.debug('lstTask:::'+lstTask);
                           }
                           string subject2 = ' Search CL, FB, auctions for WTB units; add auction units to live auction tab & other units to SF/opp';
                           task newTask2 =
                               CreateTask.createNewTask(subject2,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask2.Task_Type__c = 'Procurement';
                           if(newTask2 != null){
                               lstTask.add(newTask2);
                               system.debug('lstTask:::'+lstTask);
                           }
                       }
                       if(mapNameVsUser.containsKey(system.label.President)){
                           string subject3 = ' Look for WTB: ';
                           subject3 += newOpportunity.WTB_Parameters__c;
                           task newTask3 =
                               CreateTask.createNewTask(subject3,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.President).id,'New');
                           newTask3.Task_Type__c = 'Procurement';
                           newTask3.Priority = 'Low (On Due Date)';
                           if(newTask3 != null){
                               lstTask.add(newTask3);
                               system.debug('lstTask:::'+lstTask);
                           } 
                       }
                       if(mapNameVsUser.containsKey(system.label.Inside_Central)){
                           string subject4 = ' Look for WTB: ';
                           subject4 += newOpportunity.WTB_Parameters__c;
                           task newTask4 =
                               CreateTask.createNewTask(subject4,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                           newTask4.Task_Type__c = 'Procurement';
                           newTask4.Priority = 'Low (On Due Date)';
                           if(newTask4 != null){
                               lstTask.add(newTask4);
                               system.debug('lstTask:::'+lstTask);
                           } 
                       }
                   }
               
                system.debug('newOpportunity.StageName:::'+newOpportunity.StageName);
                //If opp stage is changed and stage name is Waiting for Buyer's Wire then create a task for office manager.
                if(hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName == 'Waiting for Buyer\'s Wire' 
                  && mapNameVsUser.containsKey(system.label.Office_Manager)){
                    string subject = 'Wire should be coming in for '+ newOpportunity.Pro_Forma_Price_Sent__c +'.  Once received, move opp to delivering (if we are doing freight) or closed won stage';
                    task newTask =
                        CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Office_Manager).id,'New');
                    newTask.Task_Type__c = 'Sales Administration';
                    if(newTask!=null){
                        lstTask.add(newTask);
                        system.debug('lstTask:::'+lstTask);
                    }
                }
                system.debug('Opp_Rec_type_Dev_Name_procurement_opp_Id::::'+Opp_Rec_type_Dev_Name_procurement_opp_Id);
                
                //If opp forecast Category is changed and value is closed and record type is not equal to procurement opp then create the task.
                if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                   && newOpportunity.RecordTypeId != Opp_Rec_type_Dev_Name_procurement_opp_Id  &&
                   hasCategoryChanged(newOpportunity, oldOpportunity) && newOpportunity.ForecastCategory =='Closed' 
                   && mapNameVsUser.containsKey(system.label.Office_Manager) ){
                     string subject = 'Send Paid Invoice to buyer, copy opp owner; begin freight process if needed';
                    task newTask =
                        CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Office_Manager).id,'New');
                    newTask.Task_Type__c = 'Finance';
                    if(newTask!=null){
                        lstTask.add(newTask);
                        system.debug('lstTask:::'+lstTask);
                    }
                       string subject1 = 'Record sale in QBO and upload wire/invoice file to Unit';
                       task newTask1 =
                           CreateTask.createNewTask(subject1,newOpportunity.Id,null,newOpportunity.CloseDate,mapNameVsUser.get(system.label.Office_Manager).id,'New');
                       newTask1.Task_Type__c = 'Finance';
                       if(newTask1!=null){
                           lstTask.add(newTask1);
                           system.debug('lstTask:::'+lstTask);
                       }
                           string subject2 = 'Update Opp GP to reflect correct GP amount';
                       task newTask2 =
                           CreateTask.createNewTask(subject2,newOpportunity.Id,null,newOpportunity.CloseDate,mapNameVsUser.get(system.label.Office_Manager).id,'New');
                       newTask2.Task_Type__c = 'Sales Administration';
                       if(newTask2!=null){
                           lstTask.add(newTask2);
                           system.debug('lstTask:::'+lstTask);
                       }
						String subject3 = 'Post a picture of this unit on a truck';
                       Date firstDayOfNextMonth = Date.newInstance(
                           Date.today().year(),
                           Date.today().month() + 1,
                           1
                       );
						System.debug('First day of next month: ' + firstDayOfNextMonth);
                       task newTask3 = 
                           CreateTask.createNewTask(subject3,newOpportunity.Id,null,firstDayOfNextMonth,mapNameVsUser.get(system.label.Office_Manager).id,'New');
                       newTask3.Task_Type__c = 'Marketing';
                       newTask3.Description ='Post a picture of this unit on a truck, or a picture of it with a "SOLD" stamp on it, to Zadoon\'s FB AND LinkedIn Pages. Create tasks for CM and HB to post on their FB/LinkedIn pages.';
                       if(newTask3!=null){
                           lstTask.add(newTask3);
                           system.debug('lstTask:::'+lstTask);
                       }
                       if(mapNameVsUser.containsKey(system.label.VA)){
                           string subject4 = 'Unlist this unit from MT/IC/CL';
                           task newTask4 =
                               CreateTask.createNewTask(subject4,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           newTask4.Task_Type__c = 'Marketing';
                           if(newTask4!=null){
                               lstTask.add(newTask4);
                               system.debug('lstTask:::'+lstTask);
                           } 
                       }
                       if(string.isnotblank(newOpportunity.OwnerId)){
                           string subject5 = 'Won opp follow-up & review request.If good review, task Sales Admin to post positive review on FB/Social Media.';
                           task newTask5 =
                               CreateTask.createNewTask(subject5,newOpportunity.Id,null,system.today(),newOpportunity.OwnerId,'New');
                           newTask5.Task_Type__c = 'Sales Administration';
                           if(newTask5!=null){
                               lstTask.add(newTask5);
                               system.debug('lstTask:::'+lstTask);
                           }   
                       }
                }
                if(hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName == 'Received Buyers Wire'  
                   && newOpportunity.RecordTypeId == Opp_Rec_Type_Broker_Sell_Id 
                   && string.isnotblank(Opp_Rec_Type_Broker_Sell_Id) && string.isnotblank(newOpportunity.OwnerId)){
                       string subject = 'Pay the seller';
                       task newTask =
                           CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),newOpportunity.OwnerId,'New');
                       newTask.Task_Type__c = 'Procurement';
                       if(newTask != null){
                           //lstTask.add(newTask);
                           system.debug('lstTask:::' + lstTask);
                       } 
                   }
                //If proc opp stage is changed to offer made and ownerid is not blank, create a task for opp owner 
                if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                   && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id  
                   && hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName =='Offer Made' 
                   && string.isnotblank(newOpportunity.OwnerId)){
                       string subject = 'Follow up with seller to see if there has been progress.';
                       task newTask =
                           CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today()+7,newOpportunity.OwnerId,'New');
                       newTask.Task_Type__c = 'Procurement';
                       if(newTask != null){
                           lstTask.add(newTask);
                           system.debug('lstTask:::' + lstTask);
                       } 
                   }
                system.debug('newOpportunity.StageName:::'+newOpportunity.StageName);
                //if Proc opp stage is changed to offer made and starting advertised retail price is null, create a task for Hardy. 
                    if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                   && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id  
                   && hasStageChanged(newOpportunity, oldOpportunity) 
                       && newOpportunity.StageName =='Offer Made' 
                   && mapNameVsUser.containsKey(system.label.Inside_Central) && newOpportunity.Starting_Advertised_Retail_Price__c == null){
                       string subject = 'Set competitive sell pricing based on comparable MT units.';
                       task newTask =
                           CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                       newTask.Task_Type__c = 'Procurement';
                       newTask.Priority = 'High (2hrs or less)';
                       if(newTask != null){
                           lstTask.add(newTask);
                           system.debug('lstTask:::' + lstTask);
                       } 
                   }
            
             
                
                
                /*if(hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName == 'Client Inspection Requested'
                  && newOpportunity.Unit_Inventory_Status__c == 'Brokerage' && string.isnotblank(newOpportunity.OwnerId) 
                   ){
                setOfOppToUpdate.add(newOpportunity.id);
                }*/
                
                
                if(hasStageChanged(newOpportunity, oldOpportunity) 
                   && newOpportunity.StageName == 'Pro Forma Signed' 
                   && string.isnotblank(newOpportunity.OwnerId)){
                    string subject = 'Send copy of signed pro forma to buyer.';
                    task newTask =
                        CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),newOpportunity.OwnerId,'New');
                    newTask.Task_Type__c = 'Sales Administration';
                    if(newTask != null){
                        lstTask.add(newTask);
                        system.debug('lstTask:::' + lstTask);
                    }
                       //newOpp.StageName = 'Waiting for Buyer\'s Wire';
                }
                
               /* if( hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName == 'Closed Lost' ){
                    opportunity newOpp = new opportunity();
                    newOpp.id = newOpportunity.id;
                    newOpp.ForecastCategory = 'Omitted';
                    lstOFOppToUpdate.add(newOpp);
                }*/
                if(hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName == 'Closed Lost' 
                   && string.isnotblank(newOpportunity.OwnerId) && string.isnotblank(Opp_Rec_Type_Broker_Sell_Id) 
                   && newOpportunity.RecordTypeId == Opp_Rec_Type_Broker_Sell_Id){
                    string subject = 'Opp lost, let seller know no deal, or let the unit owner know to inform the seller.';
                    task newTask =
                        CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),newOpportunity.OwnerId,'New');
                    newTask.Task_Type__c = 'Procurement';
                    if(newTask!=null){
                        lstTask.add(newTask);
                        system.debug('lstTask:::'+lstTask);
                    }
                }
                
                if(hasUnitChanged(newOpportunity, oldOpportunity) || 
                   hasRecordTypeChanged(newOpportunity, oldOpportunity) ||
                   hasStageChanged(newOpportunity, oldOpportunity) || 
                   (newOpportunity.StageName == 'Closed Lost') || oldOpportunity.StageName == 'Closed Lost'){
                       if(string.isNotBlank(newOpportunity.Product__c)){
                           setUnitId.add(newOpportunity.Product__c);
                       }
                       if(string.isNotBlank(oldOpportunity.Product__c)){
                           setUnitId.add(oldOpportunity.Product__c);
                       }
                   }
          
                
                /*//When opp stage is updated to offer Accepted and product is not blank
                if(hasStageChanged(newOpportunity, oldOpportunity) &&
                   newOpportunity.StageName == 'offer Accepted' && string.isnotblank(newOpportunity.Product__c)){
                       system.debug('entered in offer Accepted:::');
                       setOfOppId.add(newOpportunity.id);
                   }*/
                /*//when opp stage is either offer Accepted or proactive brokerage and product is not null
                if(hasStageChanged(newOpportunity, oldOpportunity) &&
                   (newOpportunity.StageName == 'offer Accepted' || newOpportunity.StageName == 'Proactive Brokerage') && string.isnotblank(newOpportunity.Product__c)){
                       setOfOppId.add(newOpportunity.id);
                   }*/
                
                //when opp stage is document review stage, product is not empty and inspection status is completed, change opp stage to wire pending
                if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id && 
                   newOpportunity.StageName == 'Document Review' && string.isnotblank(newOpportunity.Product__c) &&
                   isValueChange(newOpportunity,oldOpportunity,'Inspection_Status__c') &&
                   (newOpportunity.Inspection_Status__c =='Completed' 
                        || newOpportunity.Inspection_Status__c =='Not Required')){
                       //newOpp.StageName = 'Wire Pending';
                       //if unit is updated and stage is wire pending then create a task for office manager
                       if(mapNameVsUser.containsKey(system.label.Office_Manager)){
                           string subject = 'confirm wire instructions and queue up wire';
                           system.debug('subject1122:::'+subject);
                           task newTask =
                               CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Office_Manager).id,'New');
                           if(newTask!=null){
                               lstTask.add(newTask);
                               system.debug('lstTask:::'+lstTask);
                           }
                       }
                   }
                
                if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) && 
                   newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id && hasStageChanged(newOpportunity, oldOpportunity)
                   && newOpportunity.StageName =='offer Accepted' && newOpportunity.Invoice_Details__c ==false && string.isnotblank(newOpportunity.OwnerId)){
                       string subject = 'Obtain missing elements';
                       system.debug('subject112:::'+subject);
                       task newTask =
                           CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),newOpportunity.OwnerId,'New');
                       if(newTask!=null){
                           lstTask.add(newTask);
                           system.debug('lstTask:::'+lstTask);                     
                       }        
                   }       
                       
                if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                   && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id  
                   && hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName =='Won - Purchased' ){
                       if(mapNameVsUser.ContainsKey(system.label.Office_Manager)){
                           string subject = 'Update Zadoon\'s final purchase price to purchase amount.'; 
                           task newTask =
                               CreateTask.createNewTask(subject,newOpportunity.id,null,system.today(),mapNameVsUser.get(system.label.Office_Manager).id,'New');
                           newTask.Task_Type__c = 'Procurement';
                           if(newTask != null){
                               lstTask.add(newTask);
                               system.debug('lstTask:::' + lstTask);
                           }
                           string subject1 = 'Obtain a full set of marketing photos and videos.'; 
                           task newTask1 =
                               CreateTask.createNewTask(subject1,newOpportunity.id,null,system.today(),mapNameVsUser.get(system.label.Office_Manager).id,'New');
                           newTask1.Task_Type__c = 'Procurement';
                           if(newTask1 != null){
                               lstTask.add(newTask1);
                               system.debug('lstTask:::' + lstTask);
                           }
                           
                           string subject2 = 'Update related unit details like the Acc Purchased From, Account, Inventory Status, Purchase Date fields';
                           task newTask2 =
                               CreateTask.createNewTask(subject2,newOpportunity.id,null,system.today(),mapNameVsUser.get(system.label.Office_Manager).id,'New');
                           newTask2.Task_Type__c = 'Procurement';
                           if(newTask2 != null){
                               lstTask.add(newTask2);
                               system.debug('lstTask:::' + lstTask);
                           }
                       }
                   }
                
                //If Opp stage is changed to Waiting for Buyer's Wire	 stage, then one day after task is created for opp owner  
                if(((string.isnotblank(Opp_Rec_Type_Inventory_Sell_Id) && newOpportunity.RecordTypeId == Opp_Rec_Type_Inventory_Sell_Id) ||
                    (string.isnotblank(Opp_Rec_Type_Broker_Sell_Id) && newOpportunity.RecordTypeId == Opp_Rec_Type_Broker_Sell_Id)) && 
                   hasStageChanged(newOpportunity, oldOpportunity) &&
                   newOpportunity.StageName == 'Waiting for Buyer\'s Wire'){
                       
                   }
                
                     //Task for Hardy when Send_machine_to_on_brand_dealers__c is updated to true 
                    if(isValueChange(newOpportunity,oldOpportunity,'Send_machine_to_on_brand_dealers__c') && 
                       newOpportunity.Send_machine_to_on_brand_dealers__c == true && mapNameVsUser.containsKey(system.label.Inside_Central)){
                        string subject = 'Send that unit to on-brand dealers';
                        system.debug('subject:::'+subject);
                        task newTask = 
                            CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                        if(newTask!=null){
                            lstTask.add(newTask);
                            system.debug('lstTaskToInsert Shipping Dims :::' + lstTask);
                        }
                    }
                    //Task for opp owner when Call_previous_won_lost_opps__c is updated to true 
                    if(isValueChange(newOpportunity,oldOpportunity,'Call_previous_won_lost_opps__c') &&
                       newOpportunity.Call_previous_won_lost_opps__c == true && string.isnotblank(newOpportunity.OwnerId)){
                        string subject = 'Call won/lost opps';
                        system.debug('subject:::' + subject);
                        task newTask = 
                            CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),newOpportunity.OwnerId,'New');
                        newTask.Description =  '1. Contact a total of 10 won/lost opps (5 won/5 lost, 2 won/8 lost, or whatever combination makes sense'; 
                        newTask.Description += '2. Send an email to the customer and CC the original sales opp owner'; 
                        newTask.Description += '3. If that person no longer works at the company, CC Hardy';
                        newTask.Description += '4. Follow up with a phone call  Note : Start with Opps, then call Iron Demands';
                        if(newTask!=null){
                            lstTask.add(newTask);
                            system.debug('lstTaskToInsert Shipping Dims :::' + lstTask);
                        }
                    }
                
                if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                   && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id  
                   && hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName =='Proactive Brokerage' 
                   && (newOpportunity.Client_Type__c =='Manufacturer Dealer' || 
                       newOpportunity.Client_Type__c == 'End User' ||
                       newOpportunity.Client_Type__c == 'Equipment Seller')  ){
                           if(newOpportunity.Mailchimp_Email__c == 'Unadvertised' && mapNameVsUser.ContainsKey(system.label.VA) ){
                               string subject = 'send Unadvertised Email.';
                               task newTask =
                                   CreateTask.createNewTask(subject,newOpportunity.id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                               if(newTask != null){
                                   lstTask.add(newTask);
                                   system.debug('lstTask:::' + lstTask);
                               }
                           }
                           system.debug('newOpportunity.Mailchimp_Email_:::'+newOpportunity.Mailchimp_Email__c);
                           if(newOpportunity.Mailchimp_Email__c == 'Advertised' && mapNameVsUser.ContainsKey(system.label.VA)){
                               task newTask1 =
                                   CreateTask.createNewTask('Check Opp to see if Advertised.',newOpportunity.id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                               if(newTask1 != null){
                                   lstTask.add(newTask1);
                                   system.debug('lstTask:::' + lstTask);
                               } 
                           }
                           /*if(newOpportunity.Market_on_MT__c == true && mapNameVsUser.ContainsKey(system.label.VA)){
                                task newTask2 =
                                   CreateTask.createNewTask('Post on MT site.',newOpportunity.id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                               if(newTask2 != null){
                                   lstTask.add(newTask2);
                                   system.debug('lstTask:::' + lstTask);
                               }
                           }*/
                           /*if(newOpportunity.Market_on_CL__c == true && mapNameVsUser.ContainsKey(system.label.VA)){
                               task newTask3 =
                                   CreateTask.createNewTask('Post on CL site.',newOpportunity.id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                               if(newTask3 != null){
                                   lstTask.add(newTask3);
                                   system.debug('lstTask:::' + lstTask);
                               } 
                           }*/
                          /* system.debug('mapNameVsUser.containsKey(system.label.Office_Manager)::'+mapNameVsUser.containsKey(system.label.Office_Manager));
                           if(newOpportunity.Market_on_FB__c == true && mapNameVsUser.containsKey(system.label.Office_Manager)){
                                task newTask4 =
                                    CreateTask.createNewTask('Post on FB site.',newOpportunity.id,null,system.today(),mapNameVsUser.get(system.label.Office_Manager).id,'New');
                               if(newTask4 != null){
                                   lstTask.add(newTask4);
                                   system.debug('newTask4:::'+newTask4);
                                   system.debug('lstTask:::' + lstTask);
                               }  
                           }*/
                           
                           if(newOpportunity.Market_on_IC__c == true && mapNameVsUser.ContainsKey(system.label.VA)){
                                 task newTask4 =
                                    CreateTask.createNewTask('Post on IC site.',newOpportunity.id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                               if(newTask4 != null){
                                   lstTask.add(newTask4);
                                   system.debug('lstTask:::' + lstTask);
                               } 
                           }
                           if(mapNameVsUser.containsKey(system.label.Inside_Central)){
                               task newTask5 =
                                   CreateTask.createNewTask('Send Dealer Email if Appropriate.',newOpportunity.id,null,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                               if(newTask5 != null){
                                   lstTask.add(newTask5);
                                   system.debug('newTask5:::'+newTask5);
                                   system.debug('lstTask:::' + lstTask);
                               }  
                           }
                           if(string.isnotblank(newOpportunity.OwnerId)){
                               /*string subject6 = 'Update sell pricing based on seller\'s most recent bottom price.';
                               system.debug('subject6:::'+subject6);
                                task newTask6 =
                                   CreateTask.createNewTask(subject6,newOpportunity.id,null,system.today(),newOpportunity.OwnerId,'New');
                               if(newTask6 != null){
                                   lstTask.add(newTask6);
                                   system.debug('lstTask:::' + lstTask);
                               }*/
                               
                               string subject7  = 'Follow up on this proactive brokerage opp.';
                               system.debug('subject7:::'+subject7);
                               task newTask7 =
                                   CreateTask.createNewTask(subject7,newOpportunity.id,null,system.today(),newOpportunity.OwnerId,'New');
                               if(newTask7 != null){
                                   lstTask.add(newTask7);
                                   system.debug('lstTask:::' + lstTask);
                               }
                           }
                           if(mapNameVsUser.ContainsKey(system.label.VA)){
                               string subject8  = 'Send matching email.This unit is in proactive brokerage.';
                               system.debug('subject8:::'+subject8);
                               task newTask8 =
                                   CreateTask.createNewTask(subject8,newOpportunity.id,null,system.today(),newOpportunity.OwnerId,'New');
                               if(newTask8 != null){
                                   lstTask.add(newTask8);
                                   system.debug('lstTask:::' + lstTask);
                               }
                           }
                       }
                //lstOFOppToUpdate.add(newOpp);
                //system.debug('lstOFOppToUpdate11:::'+lstOFOppToUpdate);
            }
            
            list<iron_demand__c> lstOfIronDemandTODelete = new list<iron_demand__c>();
            if(setOFOpportunityID != null && !setOFOpportunityID.isEmpty()){
                lstUserRequirement =[SELECT Id, Name, Lead__c,opportunity__c,opportunity__r.Buyer_Primary_Contact__r.AccountId,
                                     (SELECT id,name,irondemand_contact__c,isUnqualified_closedlost__c ,
                                      Unit_Currently_Interested_In__c,Unit_Currently_Interested_In__r.Account__c
                                      FROM iron_demand__r) 
                                     FROM User_Requirement_ID__c 
                                     WHERE opportunity__c IN :setOFOpportunityID AND  Lead__c= null ];
            }
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
            system.debug('lstUserRequirement::'+lstUserRequirement);
               if(lstUserRequirement != null && !lstUserRequirement.isEmpty()){
                for(User_Requirement_ID__c eachUserReq :lstUserRequirement ){
                    if(mapOfOppIdVsContactId.containsKey(eachUserReq.opportunity__c) &&
                       mapOfOppIdVsContactId.get(eachUserReq.opportunity__c) != null){
                       eachUserReq.Contact__c = mapOfOppIdVsContactId.get(eachUserReq.opportunity__c); 
                    }
                    
                    lstUserRequirementTOupdate.add(eachUserReq);
                    for(iron_demand__c eachIronDemand :eachUserReq.iron_demand__r){
                        system.debug('eachUserReq.iron_demand__r size:::'+eachUserReq.iron_demand__r.size());
                        if(mapOfOppIdVsStageName.containskey(eachUserReq.opportunity__c) &&
                           mapOfOppIdVsStageName.get(eachUserReq.opportunity__c)=='Closed Lost'){
                            system.debug('enter in IsUnqualified_ClosedLost__c1');
                            eachIronDemand.IsUnqualified_ClosedLost__c = true;
                        }
                        else if(mapOfOppIdVsStageName.containskey(eachUserReq.opportunity__c) &&
                           mapOfOppIdVsStageName.get(eachUserReq.opportunity__c)!='Closed Lost'){
                            system.debug('enter in not IsUnqualified_ClosedLost__c1');
                            eachIronDemand.IsUnqualified_ClosedLost__c = false;
                        }
                        If(mapOfOppIdVsContactId.containskey(eachUserReq.opportunity__c) && 
                           mapOfOppIdVsContactId.get(eachUserReq.opportunity__c)!= Null &&
                           string.isnotblank(eachUserReq.opportunity__r.Buyer_Primary_Contact__r.AccountId)
                           && mapofIronDemandIDVsUnitAccountId.containskey(eachIronDemand.Id) &&
                           mapofIronDemandIDVsUnitAccountId.get(eachIronDemand.Id) != null
                           && eachUserReq.opportunity__r.Buyer_Primary_Contact__r.AccountId !=mapofIronDemandIDVsUnitAccountId.get(eachIronDemand.Id)){
                            eachIronDemand.irondemand_contact__c = mapOfOppIdVsContactId.get(eachUserReq.opportunity__c);
                        }
                         if(    string.isnotblank(eachUserReq.opportunity__r.Buyer_Primary_Contact__r.AccountId)
                           && mapofIronDemandIDVsUnitAccountId.containskey(eachIronDemand.Id) &&
                           mapofIronDemandIDVsUnitAccountId.get(eachIronDemand.Id) != null
                           && eachUserReq.opportunity__r.Buyer_Primary_Contact__r.AccountId ==mapofIronDemandIDVsUnitAccountId.get(eachIronDemand.Id)){
                               system.debug('lstIronddemandToDelete');
                               lstOfIronDemandTODelete.add(eachIronDemand);
                           }
                        lstIronDemandToUpdate.add(eachIronDemand);
                    }
                }
            }
            
            list<account> lstSelleraccount = new list<account>();
            system.debug('setOfAccountId:::'+setOfAccountId);
            if(setOfAccountId != null && !setOfAccountId.isEmpty()){
               lstSelleraccount = [SELECT id,Number_of_Units_Purchased_from_Acct__c,Number_of_Units_Sold_To_Acct__c,
                                    (SELECT id,ForecastCategory
                                     FROM Opportunities 
                                     WHERE ForecastCategory ='Closed' AND 
                                     (RecordType.Name ='Inventory Sell' OR RecordType.Name ='Broker Sell')),
                                    (SELECT id, ForecastCategory
                                     FROM Opportunities5__r
                                     WHERE ForecastCategory ='Closed' AND 
                                     RecordType.Name ='Procurement Opportunity')
                                    FROM account
                                    WHERE id IN :setOfAccountId];
                system.debug('lstSelleraccount:::'+lstSelleraccount);
            }
            list<account> lstAccountToUpdate = new list<account>();
            if(lstSelleraccount != null && !lstSelleraccount.isEmpty()){
                for(account eachAccount : lstSelleraccount){
                    
                    system.debug('enter in Number_of_Units_Purchased_from_Acct__c');
                    system.debug('mapOfAccIdVsString.get(eachAccount.id)::'+mapOfAccIdVsString.get(eachAccount.id));
                    boolean isupdate = false;
                    Account newAccount = new Account();
                        newAccount.id = eachAccount.Id;
                    if(eachAccount.Opportunities5__r!=null && !eachAccount.Opportunities5__r.isEmpty()){
                        isupdate = true;
                        newAccount.Number_of_Units_Purchased_from_Acct__c = eachAccount.Opportunities5__r.Size();
                    }
                    if(eachAccount.Opportunities != null && !eachAccount.Opportunities.isEmpty()){
                        isupdate = true;
                        newAccount.Number_of_Units_Sold_To_Acct__c = eachAccount.Opportunities.Size();
                    }
                    if(isupdate){
                        lstAccountToUpdate.add(newAccount);
                    }
                    /*Integer count = 0;
                    if(mapOfAccIdVsString.containsKey(eachAccount.id) &&
                       mapOfAccIdVsString.get(eachAccount.id) != null && mapOfAccIdVsString.get(eachAccount.id)=='Procurement Opportunity'){
                           system.debug('eachAccount.Opportunities5__r.size()::'+eachAccount.Opportunities5__r.size());
                           if(eachAccount.Opportunities5__r.size()>0){
                               for(Opportunity eachOpp : eachAccount.Opportunities5__r){
                                   if(eachOpp.ForecastCategory =='Closed' && eachOpp.RecordType.Name==mapOfAccIdVsString.get(eachAccount.id)){
                                       count++; 
                                   }
                               }  
                           }
                          
                           system.debug('countProcur::'+count);
                           account newAccount = new account();
                           newAccount.Id = eachAccount.id;
                           newAccount.Number_of_Units_Purchased_from_Acct__c = count;
                           lstAccountToUpdate.add(newAccount);
                       }
                    else if(mapOfAccIdVsString.containsKey(eachAccount.id) &&
                            mapOfAccIdVsString.get(eachAccount.id) != null && mapOfAccIdVsString.get(eachAccount.id)=='Sales Opportunity'){
                                system.debug('enter in Number_of_Units_Sold_To_Acct__c');
                                system.debug('eachAccount.Opportunities.size()::'+eachAccount.Opportunities.size());
                                if(eachAccount.Opportunities.size()>0){
                                    for(Opportunity eachOpp : eachAccount.Opportunities){
                                        if(eachOpp.ForecastCategory =='Closed' && 
                                           (eachOpp.RecordTypeId==Opp_Rec_Type_Inventory_Sell_Id ||
                                            eachOpp.RecordTypeId==Opp_Rec_Type_Broker_Sell_Id)){
                                                count++; 
                                            }
                                    }  
                                }
                                
                                system.debug('countSales::'+count);
                                account newAccount = new account();
                                newAccount.Id = eachAccount.id;
                                newAccount.Number_of_Units_Sold_To_Acct__c = count;
                                lstAccountToUpdate.add(newAccount);
                            }*/
                    
                    
                }
            }
            
            
            system.debug('SetOfOpportunityId:::'+SetOfOpportunityId);
            if(SetOfOpportunityId != null && !SetOfOpportunityId.isEmpty()){
                lstCustomAvaTax = [SELECT Account__c, Id, Name, Opportunity__c, Sales_Tax__c, Shipping_City__c, Shipping_Country__c,
                                   Shipping_Postal_Code__c, Shipping_State__c, Shipping_Street__c, Status__c , Opportunity__r.Freight_Option__c,
                                   (SELECT Id, Name, Amount__c, Custom_AvaTax__c, 
                                    Quantity__c, Unit__c, Tax__c FROM AvaTax_Line_Items__r)
                                   FROM Custom_AvaTax__c WHERE Opportunity__c IN : SetOfOpportunityId];
            }
            system.debug('lstCustomAvaTax:::'+lstCustomAvaTax);
            if(lstCustomAvaTax!=null && !lstCustomAvaTax.IsEmpty()){
                for(Custom_AvaTax__c eachCustomAvaTax : lstCustomAvaTax){
                    if(eachCustomAvaTax.Opportunity__r.Freight_Option__c == 'Zadoon'){
                    
                        eachCustomAvaTax.Shipping_City__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).Shipping_City__c;
                        eachCustomAvaTax.Shipping_Street__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).Shipping_Street__c;
                        eachCustomAvaTax.Shipping_Postal_Code__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).Shipping_Postal_Code__c;
                        eachCustomAvaTax.Shipping_State__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).Shipping_State__c;
                        eachCustomAvaTax.Shipping_Country__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).Shipping_Country__c;
                        eachCustomAvaTax.Account__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).AccountId;
                        setAvataxId.add(eachCustomAvaTax.id);
                    }else If (eachCustomAvaTax.Opportunity__r.Freight_Option__c == 'Buyer'){
                        eachCustomAvaTax.Shipping_City__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).Pro_Forma_City__c;
                        eachCustomAvaTax.Shipping_Street__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).Pro_Forma_Address__c;
                        eachCustomAvaTax.Shipping_Postal_Code__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).Pro_Forma_Zip__c;
                        eachCustomAvaTax.Shipping_State__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).Pro_Forma_State__c;
                        eachCustomAvaTax.Shipping_Country__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).Pro_Forma_Country__c;
                        eachCustomAvaTax.Account__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).AccountId;
                        setAvataxId.add(eachCustomAvaTax.id);
                    }
                    for(AvaTax_Line_Item__c eachAvaTaxLineItem : eachCustomAvaTax.AvaTax_Line_Items__r){
                        eachAvaTaxLineItem.Amount__c = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).Pro_Forma_Price_Sent__c;
                        eachAvaTaxLineItem.Unit__c  = triggerNewMap.get(eachCustomAvaTax.Opportunity__c).Product__c;
                        lstAvaTaxLineItem.add(eachAvaTaxLineItem);
                    }
                }
                Update lstCustomAvaTax;
                if(lstAvaTaxLineItem!=null && !lstAvaTaxLineItem.IsEmpty()){
                    Update lstAvaTaxLineItem;
                }
                if(setAvataxId!=null && !setAvataxId.IsEmpty()){
                    Database.executeBatch(new CalculateCustomAvaTaxBatchClass(setAvataxId), 1);
                }
            }
            List<ContentDocumentLink> files = new List<ContentDocumentLink>();
            map<string,list<ContentDocumentLink>> mapOfIDVSContentDocumentLink = new map<string,list<ContentDocumentLink>>();
            if((setOpportunityIds != null && !setOpportunityIds.isEmpty())){
                //mapOfIDVSContentDocumentLink =  EmailFileAttachments.getAttachements(setOpportunityIds);
            }
            if((setOpportunityIds != null && !setOpportunityIds.isEmpty())){
                lstOpp = [SELECT id,StageName,RecordTypeId,Unit_Inventory_Status__c,Product__c,Product__r.equipment__r.category__c,Product__r.Inventory_Status__c,Product__r.Purchase_Date__c,
                          product__r.equipment__r.Bucket_Size_in_yards__c,Product__r.equipment__r.Horsepower__c,Product__r.Unlist_Unit__c,Inspection_Status__c,Year_from_Unit__c,Unit_S_N__c,Invoice_signed__c,
                          Product__r.equipment__r.Operating_Weight__c,Product__r.equipment__r.Shipping_Height_in_feet_inches__c,Product__r.IsActive,Invoice_Details__c,Primary_Contact__c,Account__c,Buyer_Contact_Email__c,
                          Product__r.equipment__r.Shipping_Length_in_feet_inches__c,Product__r.equipment__r.Shipping_Weight_in_lbs__c,Product__r.Zadoon_s_Final_Purchase_Price__c,product__r.account__r.Primary_Contact__r.FirstName,
                          Product__r.equipment__r.Shipping_Width_in_feet_inches__c,Product__r.Storage_City__c,Product__r.Storage_Address__c,Product__r.Storage_State__c,Manufacturer__c,Model_from_Unit__c,product__r.Manufacturer__c,
                          Product__r.Storage_Zip_Code__c,Product__r.Procurement_Offer_Amount__c,Product__r.Starting_Advertised_Retail_Price__c,Product__r.Display_Lowest_Purchase_Price__c,Freight_Option__c,Buyer_Aggrement_Signed__c,
                          Product__r.Is_Photo_verification_completed__c,Product__r.account__c,Zadoon_s_Final_Sale_Price__c,Offer_Amount__c,Accountid,Deactivate_Unit_after_Lost_Opp__c,Product__r.Inspection_Conversation_Notes_from_Owner__c
                          , Name, Total_Cost__c, ForecastCategory, Is_Payment_Sent__c, Buyer_Primary_Contact__c, Buyer_Primary_Contact__r.Name, Buyer_Primary_Contact__r.Email,Contact_Email__c,Pro_Forma_Account_Name__c,
                          Product__r.Equipment_Specalog__c,Client_Type__c,ForecastCategoryName,Product__r.Lead_Unit_Owner__c,product__r.account__r.Primary_Contact__c,Product__r.Hour__c,Inspection_Conversation_Notes_from_Owner__c,
                          Product__r.Name,Product__r.Model__c,Product__r.Serial_Number__c,Product__r.Year__c,  Product__r.Unit_Owner__c,Product__r.Make__c, Product__r.Final_Sale_Price__c,Seller_Payment_Sent__c,Seller_Aggrement_signed__c,
                          Seller_Account__c, Seller_Account__r.Name,  Product__r.Unit_Owner__r.Name,  Product__r.Sold_Deactivated_Date__c, Owner.FirstName,Owner.Name,Account.Primary_Contact__c,Owner.Email,
                          Seller_Primary_Contact__c,product__r.Primary_Contact__c,product__r.account__r.Primary_Contact__r.MobilePhone,Seller_Mobile_Ph__c,Seller_Phone_Ph__c,product__r.account__r.Primary_Contact__r.Phone,
                          (SELECT ID,HelloSign__Latest_Action__c,HelloSign__Template__c,HelloSign__Template__r.Name
                           FROM HelloSign__HelloSign_Document_Statuses__r
                           /*WHERE HelloSign__Latest_Action__c ='Signature Completed'*/)
                          FROM opportunity
                          WHERE Id IN : setOpportunityIds]; 
                
            }
            if((setOpportunityIds != null && !setOpportunityIds.isEmpty())){
                files = [SELECT Id, ContentDocumentId,ContentDocument.title,LinkedEntityId
                         FROM ContentDocumentLink
                         WHERE LinkedEntityId IN :setOpportunityIds ];

            }
            
            
            map<string,list<ContentDocumentLink>> mapOfIdVsContentDecoumentLink = new map<string,list<ContentDocumentLink>>();
            map<id,ContentVersion> mapOfIdVsContentVersion = new map<id,ContentVersion>();
            List<Attachment> attachmentsToInsert = new List<Attachment>();
            list<ContentDocumentLink> lstContDoc = new List<ContentDocumentLink>();
            list<ContentVersion> lstAttachment = new List<ContentVersion>();
            List<ID> fileIDs = new List<ID>();
            
            List<ContentDocumentLink> files1 = new List<ContentDocumentLink>();
            List<ContentVersion> docs  = new List<ContentVersion> ();
            if((setOpportunityIds != null && !setOpportunityIds.isEmpty())){
                files1 = [SELECT Id, ContentDocumentId,ContentDocument.title,LinkedEntityId
                         FROM ContentDocumentLink
                         WHERE LinkedEntityId IN :setOpportunityIds ];
            }
                
                If(files!=NULL && ! files.IsEmpty()){
                    for (ContentDocumentLink docLink : files) {
                        if(!mapOfIdVsContentDecoumentLink.containskey(docLink.LinkedEntityId)){
                            mapOfIdVsContentDecoumentLink.put(docLink.LinkedEntityId,new list<ContentDocumentLink>());
                        }
                        if(mapOfIdVsContentDecoumentLink.containskey(docLink.LinkedEntityId)){
                            mapOfIdVsContentDecoumentLink.get(docLink.LinkedEntityId).add(docLink);
                        }
                        
                        fileIDs.add(docLink.ContentDocumentId);
                    }
                }
                
                If(fileIDs!=NULL && ! fileIDs.IsEmpty()){
                    docs = [SELECT Id,ContentDocumentId,VersionData,
                            FileExtension, Title 
                            FROM ContentVersion 
                            WHERE ContentDocumentId IN : fileIDs];
                }
            
            if (docs != null && !docs.IsEmpty()) {
                System.debug('lst docs::'+docs);
                for (ContentVersion attachment : docs) {
                    if(!mapOfIdVsContentVersion.containsKey(attachment.ContentDocumentId)){
                        mapOfIdVsContentVersion.put(attachment.ContentDocumentId,attachment);
                    }
                }
                System.debug('mapOfIdVsContentVersion docs::'+mapOfIdVsContentVersion);
            }
            
            
            system.debug('system.label.Zadoon_LLC_Account:::'+system.label.Zadoon_LLC_Account);
            if(string.isnotblank(system.label.Zadoon_LLC_Account)){
                lstAccount = [SELECT id,name
                              FROM Account
                              WHERE name =: system.label.Zadoon_LLC_Account Limit 1]; 
            }
           
            if(string.isnotblank(system.label.Opp_send_email_to_buyer) || string.isnotblank(system.label.Purchase_route_email_to_seller)){
                lstEmailtemp = [SELECT Id, Name 
                                FROM EmailTemplate 
                                where name = :system.label.Opp_send_email_to_buyer 
                                OR name = :system.label.Purchase_route_email_to_seller 
                                OR name = : system.label.Zadoon_Handling_freight_Email
                               ];
            }
            system.debug('lstEmailtemp::'+lstEmailtemp);
            if(lstEmailtemp != null && !lstEmailtemp.isEmpty()){
                for(EmailTemplate eachEmailTemplate : lstEmailtemp){
                    if(!mapofStringVsEmailTemplate.containsKey(eachEmailTemplate.Name)){
                        mapofStringVsEmailTemplate.put(eachEmailTemplate.Name,eachEmailTemplate);
                    }
                }
            }
                        
            map<id,Product2> mapOfIdVsProduct = new map<id,Product2>();
            system.debug('lstOpp:::'+lstOpp);
            if(lstOpp!=null && !lstOpp.isEmpty()){
                for(opportunity newOpportunity : lstOpp){
                    Opportunity oldOpportunity = triggerOldMap.get(newOpportunity.Id);
                    
                   // product2 newProduct = new product2();
                    
                    // Need To Update the logic
                    // 
                    if(string.isNotBlank(newOpportunity.Product__c) && !mapOfIdVsProduct.ContainsKey(newOpportunity.Product__c)){
                        mapOfIdVsProduct.put(newOpportunity.Product__c,new Product2());
                        mapOfIdVsProduct.get(newOpportunity.Product__c).id = newOpportunity.Product__c;
                    }
                    opportunity newOpp = new  opportunity();
                    newOpp.id = newOpportunity.Id;
                    //system.debug('emailtemp.id:::'+emailtemp.id);
                    //If Proc Opportunity Forecast Category is Closed, then update unit zadoon final purchase price and a task for opp owner
                    if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                       && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id  
                       && isValueChange(newOpportunity,oldOpportunity,'ForecastCategoryName') 
                       && newOpportunity.ForecastCategoryName =='Closed' 
                       && newOpportunity.Offer_Amount__c != null && 
                      string.isNotBlank(newOpportunity.Product__c) && mapOfIdVsProduct.containsKey(newOpportunity.Product__c)){
                           //mapOfIdVsProduct.get(newOpportunity.Product__c).id = newOpportunity.Product__c;
                           mapOfIdVsProduct.get(newOpportunity.Product__c).Zadoon_s_Final_Purchase_Price__c = newOpportunity.Offer_Amount__c;
                           //system.debug('newProduct.Zadoon_s_Final_Purchase_Price__c:::'+newProduct.Zadoon_s_Final_Purchase_Price__c);
                          //  newProduct.Zadoon_s_Final_Purchase_Price__c = newOpportunity.Offer_Amount__c;
                          // system.debug('newProduct.Zadoon_s_Final_Purchase_Price__c:::'+newProduct.Zadoon_s_Final_Purchase_Price__c);
                           system.debug('newOpportunity.Product__r.unit_owner__c:::'+newOpportunity.Product__r.unit_owner__c);
                            if(string.isnotblank(newOpportunity.Product__r.unit_owner__c)){
                           string subject = 'Confirm “Zadoon Final Purchase Price” is accurate on the Unit.';
                                system.debug('1122subject::'+subject);
                               task newTask =
                                   CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),newOpportunity.Product__r.unit_owner__c,'New');
                               if(newTask != null){
                                   lstTask.add(newTask);
                                   system.debug('lstTask:::' + lstTask);
                               }  
                            }
                      }
                    //If stage is change to Proactive brokrage and product id is not null 
                    if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                       && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id && 
                       isValueChange(newOpportunity,oldOpportunity,'StageName') 
                       && newOpportunity.StageName == 'Proactive Brokerage' && string.isnotblank(newOpportunity.Product__c) ){
                           mapOfIdVsProduct.get(newOpportunity.Product__c).Is_Opp_Proactive_Brokrage__c  = true;
                       }
                    //If stage is not equal to Proactive brokrage and product id is not null 
                    if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) 
                       && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id && 
                       isValueChange(newOpportunity,oldOpportunity,'StageName') 
                       && newOpportunity.StageName != 'Proactive Brokerage' && string.isnotblank(newOpportunity.Product__c)){
                           mapOfIdVsProduct.get(newOpportunity.Product__c).Is_Opp_Proactive_Brokrage__c  = false;
                       }
                    
                    
                    //If PROC opp Inspection_Conversation_Notes_from_Owner__c is changed and true and unit on opp is not null then update unit Inspection_Conversation_Notes_from_Owner__c
                    if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                       && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id && string.isnotblank(newOpportunity.Product__c) &&
                       isValueChange(newOpportunity,oldOpportunity,'Inspection_Conversation_Notes_from_Owner__c') && 
                       string.isnotblank(newOpportunity.Inspection_Conversation_Notes_from_Owner__c) && mapOfIdVsProduct.containsKey(newOpportunity.Product__c)){
                           system.debug('Inspection_Conversation_Notes_from_Owner__c');
                           mapOfIdVsProduct.get(newOpportunity.Product__c).Inspection_Conversation_Notes_from_Owner__c = newOpportunity.Inspection_Conversation_Notes_from_Owner__c;
                           system.debug('mapOfIdVsProduct:::'+mapOfIdVsProduct);
                       }
                    system.debug(' newOpportunity.Invoice_Details__c:::'+ newOpportunity.Invoice_Details__c);
                    system.debug('newOpportunity.Primary_Contact__c:::'+newOpportunity.Primary_Contact__c);
                    system.debug('newOpportunity.Year_from_Unit__c:::'+newOpportunity.Year_from_Unit__c);
                    system.debug('newOpportunity.Manufacturer__c:::'+newOpportunity.Manufacturer__c);
                    system.debug('newOpportunity.Product__r.Hour__c:::'+newOpportunity.Product__r.Hour__c);
                    system.debug('newOpportunity.Serial_Number__c::::'+newOpportunity.Product__r.Serial_Number__c);
                    system.debug('newOpportunity.Product__c:::'+newOpportunity.Product__c);
                //send email to buyer if invoice details checkbox is checked & required fields are not empty. 
                if(isValueChange(newOpportunity,oldOpportunity,'Invoice_Details__c') && string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) 
                   && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id &&
                   newOpportunity.Invoice_Details__c ==true && string.isnotblank(newOpportunity.Product__r.account__r.Primary_Contact__c) &&
                   string.isnotblank(newOpportunity.Year_from_Unit__c) && string.isNotBlank(newOpportunity.Manufacturer__c) &&
                   string.isnotblank(newOpportunity.Product__c)
                   && string.isnotblank(newOpportunity.Model_from_Unit__c) &&
                   newOpportunity.Product__r.Hour__c != null
                   && string.isnotblank(newOpportunity.Product__r.Serial_Number__c)  &&
                   mapIdVsUser.containsKey(newOpportunity.OwnerId) && mapNameVsUser.containsKey(system.label.Office_Manager) && 
                   mapNameVsUser.containsKey(system.label.Inside_Central) && newOpportunity.StageName == 'offer Accepted' ){
                       list<string> lstEmailToCC= new  list<string>();
                       system.debug('email send1::::::');
                       //lstEmailToCC.add(mapIdVsUser.get(newOpportunity.OwnerId).email);
                       lstEmailToCC.add(mapNameVsUser.get(system.label.Office_Manager).email);
                       //lstEmailToCC.add(mapNameVsUser.get(system.label.Inside_Central).email);
                       //mapIdVsUser.get(newOpportunity.OwnerId).email,mapNameVsUser.get(system.label.Office_Manager).email, mapNameVsUser.get(system.label.Inside_Central).email
                       if(lstEmailToCC != null && !lstEmailToCC.isEmpty() && mapofStringVsEmailTemplate.containsKey('Opp send email to buyer')){
                           Messaging.SingleEmailMessage Messaging = 
                           emailToBuyer(newOpportunity.Contact_Email__c,lstEmailToCC,newOpportunity.id,newOpportunity.Product__r.account__r.Primary_Contact__c,mapofStringVsEmailTemplate.get('Opp send email to buyer').id);
                           system.debug('email send::::::');
                           if(Messaging != null ){
                               lstMessage.add(Messaging);   
                           }
                       }
                   }
                
                    
                    system.debug('newOpportunity.Inspection_Status__c:::'+newOpportunity.Inspection_Status__c);
                    system.debug('mapIdVsUser.containsKey(newOpportunity.OwnerId):::'+mapIdVsUser.containsKey(newOpportunity.OwnerId));
                    system.debug('newOpportunity.Inspection_Status__c:::'+newOpportunity.Inspection_Status__c);
                    system.debug('newOpportunity.Contact_Email__c::'+newOpportunity.Contact_Email__c);
                    system.debug('newOpportunity.Product__r.account__r.Primary_Contact__c:::'+newOpportunity.Product__r.account__r.Primary_Contact__c);
                    
                       if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id && 
                   hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName == 'Won - Purchased' && 
                   string.isnotblank(newOpportunity.Product__c) && 
                   newOpportunity.Inspection_Status__c =='Completed' && mapIdVsUser.containsKey(newOpportunity.OwnerId) &&
                   string.isnotblank(newOpportunity.Contact_Email__c) && string.isnotblank(newOpportunity.Product__r.account__r.Primary_Contact__c)
                          && newOpportunity.Offer_Amount__c != null
                   && string.isnotblank(newOpportunity.Unit_S_N__c) && string.isnotblank(newOpportunity.product__r.account__r.Primary_Contact__r.FirstName)){
                       system.debug('email sent1133:::');
                       //send email to seller from office manager and CC opp owner
                       /*if(mapofStringVsEmailTemplate.containsKey('Purchase route email to seller')){
                           Messaging.SingleEmailMessage Messaging = 
                           emailToSeller(newOpportunity.id,mapIdVsUser.get(newOpportunity.OwnerId).email,newOpportunity.Contact_Email__c,newOrgWideEmail.id,newOpportunity.Product__r.account__r.Primary_Contact__c,mapofStringVsEmailTemplate.get('Purchase route email to seller').id);
                           if(Messaging != null ){
                               lstMessage.add(Messaging);   
                           }
                       }*/
                       lstMessagingSingleEmailMessage.add(EmailEventHelper.handleSendEmailOnIs_Payment_SentUpdation(newOpportunity,newOrgWideEmail.id));

                       system.debug('email sent11334:::');
                       //setOfOppId.add(newOpportunity.id);
                   }
                    
                    if( hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName == 'Client Inspection Requested'
                       && newOpportunity.Unit_Inventory_Status__c == 'Brokerage' && string.isnotblank(newOpportunity.OwnerId)){
                           string subject = 'Send buyer agreement via HelloSign.Create tasks to follow up if no response.';
                           subject += 'Update Buyer Agreement Status field to "Sent"; change to "Completed" once signed. Leave task open until signature completed.';
                           system.debug('subject::'+subject);
                           task newTask =
                               CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),newOpportunity.OwnerId,'New');
                           newTask.Task_Type__c = 'Sales Administration';
                           if(newTask != null){
                               lstTask.add(newTask);
                               system.debug('lstTask:::' + lstTask);
                           }
                           if(string.isnotblank(newOpportunity.Product__r.Unit_Owner__c) && string.isnotblank(newOpportunity.Product__c)){
                               string subject1 = 'Send seller agreement via HelloSign.  Create tasks to follow up if no response.';
                               subject1 += 'Update Seller Agreement Status field to "Sent";change to "Completed" once signed. Leave task open until signature completed.';
                               task newTask1 =
                                   CreateTask.createNewTask(subject1,newOpportunity.Product__c,null,system.today(),newOpportunity.Product__r.Unit_Owner__c,'New');
                               newTask1.Task_Type__c = 'Procurement';
                               if(newTask1 != null){
                                   lstTask.add(newTask1);
                                   system.debug('lstTask:::' + lstTask);
                               }  
                           }
                       }
                    //If Proc opp stage is changed to Rejected/Stopped Pursuing	and deactivated unit is true, change related unit isactive to false and create a task for VA
                if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                   && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id  
                   && string.isnotblank(newOpportunity.Product__c) &&
                   hasStageChanged(newOpportunity, oldOpportunity) 
                   &&(newOpportunity.StageName =='Rejected' || newOpportunity.StageName =='Stopped Pursuing')
                  && newOpportunity.Deactivate_Unit_after_Lost_Opp__c == true ) {
                      mapOfIdVsProduct.get(newOpportunity.Product__c).id = newOpportunity.Product__c;
                      mapOfIdVsProduct.get(newOpportunity.Product__c).IsActive = false;
                      if(mapNameVsUser.containsKey(system.label.VA)){
                          string subject = 'Unlist unit from all forms of marketing.';
                          task newTask =
                              CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                          newTask.Task_Type__c = 'Procurement';
                          newTask.Priority = 'High (2hrs or less)';
                          if(newTask != null){
                              lstTask.add(newTask);
                              system.debug('lstTask:::' + lstTask);
                          }  
                      }
                       
                   }
                    
					system.debug('isValueChange(new):::'+isValueChange(newOpportunity,oldOpportunity,'Seller_Payment_Sent__c')); 
                    system.debug('newOpportunity.Seller_Payment_Sent__c:::'+newOpportunity.Seller_Payment_Sent__c);
                    system.debug('newOpportunity.Unit_S_N__c::'+newOpportunity.Unit_S_N__c);
                    system.debug('newOpportunity.product__r.account__r.Primary_Contact__r.FirstName:::'+newOpportunity.product__r.account__r.Primary_Contact__r.FirstName);
                    system.debug('newOpportunity.Product__r.account__r.Primary_Contact__c:::'+newOpportunity.Product__r.account__r.Primary_Contact__c);
                    system.debug('newOpportunity.Contact_Email__c::'+newOpportunity.Contact_Email__c);
                    system.debug('Opp_Rec_Type_Broker_Sell_Id:::'+Opp_Rec_Type_Broker_Sell_Id);
                    system.debug('newOpportunity.StageName:::'+newOpportunity.StageName);
                    system.debug('newOpportunity.Product__c):::'+newOpportunity.Product__c);
                    system.debug('newOpportunity.Inspection_Status__c:::'+newOpportunity.Inspection_Status__c);
                    system.debug('newOpportunity.Offer_Amount__c:::'+newOpportunity.Offer_Amount__c);
                    system.debug('mapofStringVsEmailTemplate.containsKey:::'+mapofStringVsEmailTemplate.containsKey('Purchase route email to seller'));
                    
                    if((string.isnotblank(Opp_Rec_Type_Broker_Sell_Id) && newOpportunity.RecordTypeId == Opp_Rec_Type_Broker_Sell_Id) && 
                       newOpportunity.StageName == 'Received Buyers Wire' && isValueChange(newOpportunity,oldOpportunity,'Seller_Payment_Sent__c') &&
                       string.isnotblank(newOpportunity.Product__c) && newOpportunity.Seller_Payment_Sent__c != null /*&&
                       newOpportunity.Inspection_Status__c =='Completed'*/ && mapIdVsUser.containsKey(newOpportunity.OwnerId) &&
                       string.isnotblank(newOpportunity.Contact_Email__c) && string.isnotblank(newOpportunity.Product__r.account__r.Primary_Contact__c)
                       && newOpportunity.Offer_Amount__c != null
                       && string.isnotblank(newOpportunity.Unit_S_N__c) && string.isnotblank(newOpportunity.product__r.account__r.Primary_Contact__r.FirstName)){
                       system.debug('email sent1133:::');
                       //send email to seller from office manager and CC opp owner
                       /*if(mapofStringVsEmailTemplate.containsKey('Purchase route email to seller')){
                           Messaging.SingleEmailMessage Messaging = 
                           emailToSeller(newOpportunity.id,mapIdVsUser.get(newOpportunity.OwnerId).email,newOpportunity.Contact_Email__c,newOrgWideEmail.id,newOpportunity.Product__r.account__r.Primary_Contact__c,mapofStringVsEmailTemplate.get('Purchase route email to seller').id);
                           if(Messaging != null ){
                               lstMessage.add(Messaging);  
                           }
                       }*/
                           lstMessagingSingleEmailMessage.add(EmailEventHelper.handleSendEmailOnIs_Payment_SentUpdation(newOpportunity,newOrgWideEmail.id));

                                                  system.debug('email sent11334:::');
                       //setOfOppId.add(newOpportunity.id);
                       
                            
                           
                   }
                    
                    if(((string.isnotblank(Opp_Rec_Type_Inventory_Sell_Id) && newOpportunity.RecordTypeId == Opp_Rec_Type_Inventory_Sell_Id) ||
                        (string.isnotblank(Opp_Rec_Type_Broker_Sell_Id) && newOpportunity.RecordTypeId == Opp_Rec_Type_Broker_Sell_Id)) && 
                       ((isValueChange(newOpportunity,oldOpportunity,'Seller_Payment_Sent__c') && newOpportunity.Seller_Payment_Sent__c != null) ||
                       (isValueChange(newOpportunity,oldOpportunity,'StageName') && newOpportunity.StageName == 'Received Buyers Wire'))){
                           string Sub = 'Check-in for sales opp owner for';
                           if(string.isnotblank(newOpportunity.Pro_Forma_Account_Name__c)){
                               sub += newOpportunity.Pro_Forma_Account_Name__c;
                           }
                           task newTasks;
                           if(mapNameVsUser.containsKey(System.Label.VA)){
                               newTasks = CreateTask.createNewTask(sub, 
                                                                   newOpportunity.id,
                                                                   null, 
                                                                   System.today(), 
                                                                   mapNameVsUser.get(System.Label.VA).Id,
                                                                   'New');
                               newTasks.Description = 'Check with opp owner to determine frequency of check in tasks';
                           }
                           if(newTasks != null){
                               lstTask.add(newTasks);
                           }
                           
                           if(newOpportunity.Product__r.Inventory_Status__c != 'Owned'){
                               string Sub1 = 'Check-in for unit owner for';
                               if(string.isnotblank(newOpportunity.Account__c)){
                                   sub1 += newOpportunity.Account__c;
                               }
                               task newTasks1;
                               if(mapNameVsUser.containsKey(System.Label.VA)){
                                   newTasks1 = CreateTask.createNewTask(sub, 
                                                                        newOpportunity.id,
                                                                        null, 
                                                                        System.today(), 
                                                                        mapNameVsUser.get(System.Label.VA).Id,
                                                                        'New');
                                   newTasks.Description = 'Check with unit owner to determine frequency of check in tasks';
                               }
                               if(newTasks1 != null){
                                   lstTask.add(newTasks1);
                               }
                           }
                           
                           
                           String Subject = 'Send paid invoice to ';
                           if(String.IsNotBlank(newOpportunity.AccountId)){
                               Subject += newOpportunity.AccountId + 'for';
                           }
                           If(String.IsNotBlank(newOpportunity.Product__r.Name)){
                               Subject += newOpportunity.Product__r.Name+' and CC '+newOpportunity.Owner.Name;
                           }
                           task newTask ;
                           if(mapNameVsUser.containsKey(System.Label.Office_Manager)){
                               newTask = CreateTask.createNewTask(Subject, 
                                                                  newOpportunity.id,
                                                                  null, 
                                                                  System.today(), 
                                                                  mapNameVsUser.get(System.Label.Office_Manager).Id,
                                                                  'New');
                           }
                           lstTask.add(newTask);
                           task newTask0 = new task();
                           if(mapNameVsUser.containsKey(System.Label.Office_Manager)){
                               newTask0 = CreateTask.createNewTask('Ensure GP is accurate, and if it is, mark the Financials Completed checkbox', 
                                                                   newOpportunity.id,
                                                                   null, 
                                                                   System.today(), 
                                                                   mapNameVsUser.get(System.Label.Office_Manager).Id,
                                                                   'New');
                           }
                           newTask0.Description = 'Ensure QBO buy/sell records and URTs on both QBO and SF are updated';
                           
                           lstTask.add(newTask0);
                           
                           task newTask1 = new task();
                           
                           String subjectB = 'Create sold unit post for ';
                           if(String.IsNotBlank(newOpportunity.Product__r.Name)){
                               subjectB +=newOpportunity.Product__r.Name;
                           }
                           
                           if(mapNameVsUser.containsKey(System.Label.VA)){
                               newTask1 = CreateTask.createNewTask(subjectB, 
                                                                   newOpportunity.id,
                                                                   null, 
                                                                   getLastdateOftheMonth(System.today()), 
                                                                   mapNameVsUser.get(System.Label.VA).Id,
                                                                   'New');
                           }
                           lstTask.add(newTask1);
                           date newDate = System.today();
                           if(String.IsNotBlank(String.valueOf(newOpportunity.Product__r.Sold_Deactivated_Date__c))){
                               newDate = newOpportunity.Product__r.Sold_Deactivated_Date__c;
                           }
                           task newTask2 = new task();
                           newTask2 = CreateTask.createNewTask('Won Opp Follow Up and Review Request', 
                                                               newOpportunity.id,
                                                               null, 
                                                               newDate.addDays(10), 
                                                               newOpportunity.OwnerId,
                                                               'New');
                           lstTask.add(newTask2); 
                           mapOfIdVsProduct.get(newOpportunity.Product__c).id = newOpportunity.Product__c;
                           mapOfIdVsProduct.get(newOpportunity.Product__c).IsActive = false;
                           mapOfIdVsProduct.get(newOpportunity.Product__c).Sold_Deactivated_Date__c = system.today();
                           mapOfIdVsProduct.get(newOpportunity.Product__c).Unit_Stage__c = 'Zadoon Sold';
                           mapOfIdVsProduct.get(newOpportunity.Product__c).Final_Sale_Price__c = newOpportunity.Total_Cost__c;
                           
                           if((string.isnotblank(Opp_Rec_Type_Broker_Sell_Id) && newOpportunity.RecordTypeId == Opp_Rec_Type_Broker_Sell_Id) && 
                              isValueChange(newOpportunity,oldOpportunity,'Seller_Payment_Sent__c') && newOpportunity.Seller_Payment_Sent__c != null &&
                              newOpportunity.Freight_Option__c == 'Zadoon'){
                                  opportunity eachOpp = new opportunity();
                                  eachOpp.id = newOpportunity.id;
                                  eachOpp.StageName = 'Delivering';
                                  lstOppToUpdate.add(eachOpp);
                              }
                           if((string.isnotblank(Opp_Rec_Type_Inventory_Sell_Id) && newOpportunity.RecordTypeId == Opp_Rec_Type_Inventory_Sell_Id) && 
                              (isValueChange(newOpportunity,oldOpportunity,'StageName') && newOpportunity.StageName == 'Received Buyers Wire') /*&& newOpportunity.Seller_Payment_Sent__c != null*/ &&
                              newOpportunity.Freight_Option__c == 'Buyer'){
                                  opportunity eachOpp1 = new opportunity();
                                  eachOpp1.id = newOpportunity.id;
                                  eachOpp1.StageName = 'Closed Won';
                                  lstOppToUpdate.add(eachOpp1);
                              }
                           
                       } 
                    

                    //if(/*setOfOppId.Contains(newOpportunity.id) && */
                       //String.isNotBlank(newOpportunity.Product__c) && 
                       //String.isNotBlank(newOpportunity.Product__r.equipment__c)){
                           system.debug('newOpportunity.Product__r.equipment__r.Horsepower__c:::'+newOpportunity.Product__r.equipment__r.Horsepower__c);
                           //If Address is not blank, and stage is offer Accepted the a task is created for melissa
                           if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) && 
                              newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id && 
                              String.isNotBlank(newOpportunity.Product__c) && 
                              String.isNotBlank(newOpportunity.Product__r.equipment__c) &&
                              string.isnotblank(newOpportunity.Product__r.Storage_City__c) 
                              && string.isnotblank(newOpportunity.Product__r.Storage_Address__c)
                              && string.isnotblank(newOpportunity.Product__r.Storage_State__c)
                              && string.isnotblank(newOpportunity.Product__r.Storage_Zip_Code__c)
                              && mapNameVsUser.containsKey(system.label.Office_Manager)
                              && mapNameVsUser.containsKey(system.label.VA) && hasStageChanged(newOpportunity, oldOpportunity)
                              && newOpportunity.StageName == 'offer Accepted' ){
                                  string subject = 'Obtain rough freight estimates to closest yard';
                                  string Subject1 = 'Search SN on TopBid to confirm year; if not available, call a dealer. Update new field called "Year Confirmation Method"';
                                  system.debug('subject:::'+subject);
                                  system.debug('Subject1::'+Subject1);
                                  task newTask =
                                      CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Office_Manager).id,'New');
                                  task newTask1 = 
                                      CreateTask.createNewTask(Subject1,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                                  if(newTask!=null){
                                      lstTask.add(newTask);
                                      system.debug('lstTask:::'+lstTask);
                                  }
                                  if(newTask1!=null){
                                      lstTask.add(newTask1);
                                      system.debug('lstTask:::'+lstTask);
                                  }
                              }
                           
                           //if shipping dims are null & stage is offer Accepted then a task is assiged for shelly
                    if(String.isNotBlank(newOpportunity.Product__c) && 
                       String.isNotBlank(newOpportunity.Product__r.equipment__c) && 
                       (newOpportunity.Product__r.equipment__r.Shipping_Height_in_feet_inches__c == null 
                        || newOpportunity.Product__r.equipment__r.Shipping_Length_in_feet_inches__c == null 
                        || newOpportunity.Product__r.equipment__r.Shipping_Weight_in_lbs__c == null
                        || newOpportunity.Product__r.equipment__r.Shipping_Width_in_feet_inches__c == null)
                       && mapNameVsUser.containsKey(system.label.VA) && hasStageChanged(newOpportunity, oldOpportunity) 
                       && newOpportunity.StageName == 'offer Accepted' 
                       && string.isnotblank(newOpportunity.Product__r.equipment__c)
                       && string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id ){//
                           string subject = 'Update Shipping Dims';
                           task newTask = 
                               CreateTask.createNewTask(subject,newOpportunity.Product__r.equipment__c,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                           if(newTask!=null){
                               lstTask.add(newTask);
                               system.debug('lstTask Shipping Dims :::'+lstTask);
                           }
                       }
                           // if operating weight is null & stage is offer Accepted then a task is assiged for shelly
                    if(String.isNotBlank(newOpportunity.Product__c) && 
                       String.isNotBlank(newOpportunity.Product__r.equipment__c) && 
                       string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id && 
                       newOpportunity.Product__r.equipment__r.Operating_Weight__c ==null &&
                       mapNameVsUser.containsKey(system.label.VA) && hasStageChanged(newOpportunity, oldOpportunity) 
                       && newOpportunity.StageName == 'offer Accepted'){
                           string subject = 'Update operating weight';
                           task newTask = 
                               CreateTask.createNewTask(subject,newOpportunity.Product__r.equipment__c,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New'); 
                           if(newTask!=null){
                               lstTask.add(newTask);
                               system.debug('lstTask operating weight :::'+lstTask);
                           }
                       }
                           //if category is dozer and horsepower is null, then a task is assiged for Shelly
                           if(String.isNotBlank(newOpportunity.Product__c) && 
                       String.isNotBlank(newOpportunity.Product__r.equipment__c) && string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) &&
                              newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id &&
                              (hasStageChanged(newOpportunity, oldOpportunity) || isValueChange(newOpportunity,oldOpportunity,'Product__c')) &&
                               newOpportunity.StageName == 'offer Accepted' && newOpportunity.Product__r.equipment__r.category__c =='Dozer' 
                              && newOpportunity.Product__r.equipment__r.Horsepower__c==null
                              && mapNameVsUser.containsKey(system.label.VA) ){//
                                  string subject = 'Update HorsePower';
                                  system.debug('subject::'+subject);
                                  task newTask = 
                                      CreateTask.createNewTask(subject,newOpportunity.Product__r.equipment__c,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New'); 
                                  if(newTask!=null){
                                      lstTask.add(newTask);
                                      system.debug('lstTask horse power:::'+lstTask);
                                  }
                              }
                           //if category is wheel loader and bucket size is null, then a task is assiged for shelly
                           if(String.isNotBlank(newOpportunity.Product__c) && 
                       String.isNotBlank(newOpportunity.Product__r.equipment__c) && 
                              string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) &&
                              newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id &&
                               (hasStageChanged(newOpportunity, oldOpportunity) ||isValueChange(newOpportunity,oldOpportunity,'Product__c')) 
                              && newOpportunity.StageName == 'offer Accepted' &&
                              (newOpportunity.Product__r.equipment__r.category__c =='Wheel loader' 
                              && newOpportunity.Product__r.equipment__r.Bucket_Size_in_yards__c == null
                              && mapNameVsUser.containsKey(system.label.VA))){
                                  string subject = 'Update Loader Bucket size';
                                  task newTask = 
                                      CreateTask.createNewTask(subject,newOpportunity.Product__r.equipment__c,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New'); 
                                  if(newTask!=null){
                                      lstTask.add(newTask);
                                      system.debug('lstTask bucket:::'+lstTask);
                                  }  
                              }
                          
                           system.debug('newOpportunity.Total_Cost__c:::'+newOpportunity.Total_Cost__c);
                           system.debug('newOpportunity.ForecastCategory:::'+newOpportunity.ForecastCategory);
                           system.debug('newOpportunity.RecordTypeId:::'+newOpportunity.RecordTypeId);
                           system.debug('Opp_Rec_type_Dev_Name_procurement_opp_Id'+Opp_Rec_type_Dev_Name_procurement_opp_Id);
                           
                     //if forecastCategory is closed and total cost is not null and recordtype is not procurementOPP then, update Unit
                    if(String.isNotBlank(newOpportunity.Product__c) && 
                       String.isNotBlank(newOpportunity.Product__r.equipment__c) && 
                       newOpportunity.Total_Cost__c != null && hasCategoryChanged(newOpportunity, oldOpportunity) && newOpportunity.ForecastCategory == 'Closed'
                       && string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) && string.isnotblank(newOpportunity.Product__c)
                       && newOpportunity.RecordTypeId != Opp_Rec_type_Dev_Name_procurement_opp_Id){
                           //product2 newProduct = new product2();
                           //newProduct.id = newOpportunity.Product__c;
                           mapOfIdVsProduct.get(newOpportunity.Product__c).id = newOpportunity.Product__c;
                           //mapOfIdVsProduct.get(newOpportunity.Product__c).id = newOpportunity.Product__c;
                           mapOfIdVsProduct.get(newOpportunity.Product__c).Final_Sale_Price__c = newOpportunity.Total_Cost__c;
                           mapOfIdVsProduct.get(newOpportunity.Product__c).IsActive =false;
                           mapOfIdVsProduct.get(newOpportunity.Product__c).Sold_Deactivated_Date__c = system.today();
                           mapOfIdVsProduct.get(newOpportunity.Product__c).Unit_Stage__c = 'Zadoon Sold';
                           // lstProduct.add(newProduct);
                       }
                           
                    if(String.isNotBlank(newOpportunity.Product__c) && 
                       String.isNotBlank(newOpportunity.Product__r.equipment__c) &&
                       String.isNotBlank(procurementRecordTypeId) && 
                       hasStageChanged(newOpportunity, oldOpportunity) && 
                       newOpportunity.StageName == 'Won - Purchased' &&
                       newOpportunity.RecordTypeId  == procurementRecordTypeId 
                      ){
                          //Update Unit
                          mapOfIdVsProduct.get(newOpportunity.Product__c).id = newOpportunity.Product__c;
                          mapOfIdVsProduct.get(newOpportunity.Product__c).Inventory_Status__c = 'Owned';
                          mapOfIdVsProduct.get(newOpportunity.Product__c).Account_Purchased_From_For_Inventory__c = newOpportunity.Product__r.account__c;
                          mapOfIdVsProduct.get(newOpportunity.Product__c).Unlist_Unit__c = true;
                          mapOfIdVsProduct.get(newOpportunity.Product__c).IsActive = true;
                          mapOfIdVsProduct.get(newOpportunity.Product__c).Sold_Deactivated_Date__c = null;
                          mapOfIdVsProduct.get(newOpportunity.Product__c).Purchase_Date__c = system.today();
                          mapOfIdVsProduct.get(newOpportunity.Product__c).Unit_Stage__c = 'Keep Only for Iron Demand';
                          mapOfIdVsProduct.get(newOpportunity.Product__c).Zadoon_s_Final_Purchase_Price__c =newOpportunity.Offer_Amount__c;   
                          if(lstAccount!=null && !lstAccount.isEmpty()){
                              mapOfIdVsProduct.get(newOpportunity.Product__c).account__c = lstAccount[0].id;
                          }
                          //lstProduct.add(newProduct);
                          //system.debug('newProduct:::'+newProduct);
                          //Create a task for shelly and melissa if opportunity stage is won purchased  and unit is updated
                          if(hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName =='Won - Purchased' 
                             && mapNameVsUser.containsKey(system.label.VA) 
                             && mapNameVsUser.containsKey(system.label.Office_Manager)){
                                 string subject = 'Complete Unit Verification object for this unit';
                                 task newTask =
                                     CreateTask.createNewTask(subject,newOpportunity.Product__c,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                                 if(newTask!=null){
                                     lstTask.add(newTask);
                                     system.debug('lstTask:::'+lstTask);
                                 }
                                 string subject1 = 'Pressure Wash if Needed, Interior Clean if Needed';
                                 task newTask1 =
                                     CreateTask.createNewTask(subject1,newOpportunity.Product__c,null,system.today(),mapNameVsUser.get(system.label.Office_Manager).id,'New');
                                 if(newTask1!=null){
                                     lstTask.add(newTask1);
                                     system.debug('lstTask  newTask1:::'+lstTask);
                                 }
                             }
                      }
                    //If seller Opportunity, stage or final sale price or total cost is changed, then update unit
                    if(String.isNotBlank(newOpportunity.Product__c) && 
                       String.isNotBlank(newOpportunity.Product__r.equipment__c) && 
                       (string.isnotblank(Opp_Rec_Type_Broker_Sell_Id) && string.isnotblank(Opp_Rec_Type_Inventory_Sell_Id)) &&
                       (newOpportunity.RecordTypeId == Opp_Rec_Type_Broker_Sell_Id  || newOpportunity.RecordTypeId == Opp_Rec_Type_Inventory_Sell_Id) &&
                       (hasStageChanged(newOpportunity, oldOpportunity) ||
                        isValueChange(newOpportunity,oldOpportunity,'Zadoon_s_Final_Sale_Price__c') ||
                        isValueChange(newOpportunity,oldOpportunity,'Total_Cost__c') )&& 
                       (newOpportunity.StageName =='Pro Forma Signed' ||
                        newOpportunity.StageName =='Waiting for Buyer\'s Wire' || 
                        newOpportunity.StageName == 'Closed Lost' ||
                        newOpportunity.StageName == 'Closed Won') && newOpportunity.Total_Cost__c !=null
                      ){
                                 //product2 newProduct = new product2();
                                 //newProduct.Id = newOpportunity.Product__c;
                                 //mapOfIdVsProduct.get(newOpportunity.Product__c).id = newOpportunity.Product__c;
                                 mapOfIdVsProduct.get(newOpportunity.Product__c).Final_Sale_Price__c = newOpportunity.Total_Cost__c;
                                 //lstProduct.add(newProduct);
                                 //system.debug('newProductToooooo:::'+newProduct);
                             }
                           //If Procurement opp offer amount or stage field is changed,then update related unit final purchase price 
                    if(String.isNotBlank(newOpportunity.Product__c) && 
                       String.isNotBlank(newOpportunity.Product__r.equipment__c) &&
                       string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id) && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id 
                       && (hasStageChanged(newOpportunity, oldOpportunity) ||isValueChange(newOpportunity,oldOpportunity,'Offer_Amount__c')) &&
                       (newOpportunity.StageName =='Won - Purchased' ||
                        newOpportunity.StageName =='Won - Brokered') && string.isnotblank(newOpportunity.Product__c) && newOpportunity.Offer_Amount__c !=null ){
                                  // product2 newProduct = new product2();
                                   //newProduct.Id = newOpportunity.Product__c;
                                   //mapOfIdVsProduct.get(newOpportunity.Product__c).id = newOpportunity.Product__c;
                                   mapOfIdVsProduct.get(newOpportunity.Product__c).Zadoon_s_Final_Purchase_Price__c = newOpportunity.Offer_Amount__c;
                                   //lstProduct.add(newProduct);
                                   //system.debug('newProductToooooo1122:::'+newProduct);
                               }
                           //If Proc Opp stage is changed to offer accepted,then 
                           if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                              && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id  
                              && hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName =='Offer Accepted' 
                              ){
                                  if(mapNameVsUser.containsKey(system.label.Office_Manager)){
                                      string subject = 'Coordinate Inspection;update inspection section including inspection status on Opp.';
                                      task newTask =
                                          CreateTask.createNewTask(subject,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Office_Manager).id,'New');
                                      newTask.Task_Type__c = 'Procurement';
                                      newTask.Priority = 'High (2hrs or less)';
                                      if(newTask != null){
                                          lstTask.add(newTask);
                                          system.debug('lstTask:::' + lstTask);
                                      }
                                      string subject6 = 'Determine when the Unit needs to be moved.';
                                      task newTask6 =
                                          CreateTask.createNewTask(subject6,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.Office_Manager).id,'New');
                                      if(newTask6 != null){
                                          lstTask.add(newTask6);
                                          system.debug('lstTask:::' + lstTask);
                                      }
                                     
                                  }
                                  system.debug('system.label.VA:::'+system.label.VA);
                                  system.debug('mapNameVsUser.containsKey(system.label.VA):::'+mapNameVsUser.containsKey(system.label.VA));
                                  
                                  if(mapNameVsUser.containsKey(system.label.VA)){
                                      string subject4 = 'Use TopBid to confirm year of Unit and put confidential notes.';
                                      task newTask4 =
                                          CreateTask.createNewTask(subject4,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                                      if(newTask4 != null){
                                          lstTask.add(newTask4);
                                          system.debug('lstTask:::' + lstTask);
                                      }
                                      string subject5 = 'Log into Walker\'s SF account and send matching email on this unit.';
                                      task newTask5 =
                                          CreateTask.createNewTask(subject5,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                                      if(newTask5 != null){
                                          lstTask.add(newTask5);
                                          system.debug('lstTask:::' + lstTask);
                                      }
                                  }
                                  if(string.isnotblank(newOpportunity.OwnerId)){
                                       string subject7 = 'Inspection is being schedule.1) Speak with the inspector; 2) ensure they get appropriate pics/vids;';
                                        subject7 += '3) get a build sheet/service history (if dealer); and 4) ensure completed inspection report and ECU (Matris/etc.)are completed.';
                                      task newTask7 =
                                          CreateTask.createNewTask(subject7,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                                      if(newTask7 != null){
                                          lstTask.add(newTask7);
                                          system.debug('lstTask:::' + lstTask);
                                      } 
                                  }
                                  if(string.isblank(newOpportunity.Product__r.Equipment_Specalog__c) && mapNameVsUser.containsKey(system.label.VA) ){
                                      string subject1 = 'If not already there,add Specalog PDF for this unit to the "Specalog Link" field on the equipment page.';
                                      task newTask1 =
                                          CreateTask.createNewTask(subject1,newOpportunity.Id,null,system.today(),mapNameVsUser.get(system.label.VA).id,'New');
                                      newTask1.Task_Type__c = 'Procurement';
                                      if(newTask1 != null){
                                          lstTask.add(newTask1);
                                          system.debug('lstTask:::' + lstTask);
                                      }
                                  }
                                  /*if((string.isblank(newOpportunity.Product__r.Storage_City__c) 
                                      || string.isblank(newOpportunity.Product__r.Storage_Address__c)
                                      || string.isblank(newOpportunity.Product__r.Storage_State__c)) 
                                     && string.isnotblank(newOpportunity.OwnerId)){
                                         string subject2 = 'Obtain Unit Details, unit address, and site contact;'; 
                                         subject2 +='have VAs create Contact Record for site contact; update Site Contact and address info on unit page.';
                                         task newTask2 =
                                             CreateTask.createNewTask(subject2,newOpportunity.Id,null,system.today(),newOpportunity.OwnerId,'New');
                                         newTask2.Task_Type__c = 'Procurement';
                                         newTask2.Description = 'https://docs.google.com/document/d/10e6rwLWyRF-ce126J0ATS1n-5tbiOYp7atqpM6xLrJ0/edit';
                                         if(newTask2 != null){
                                             lstTask.add(newTask2);
                                             system.debug('lstTask:::' + lstTask);
                                         }  
                                     }*/
                                  
                                  if(string.isnotblank(newOpportunity.Product__c) && newOpportunity.Product__r.Starting_Advertised_Retail_Price__c == null 
                                     && mapNameVsUser.containsKey(system.label.Inside_Central) ){
                                      string subject3 = 'Update the sell pricing on the basis of Final Purchase Price.'; 
                                      task newTask3 =
                                          CreateTask.createNewTask(subject3,newOpportunity.id,null,system.today(),mapNameVsUser.get(system.label.Inside_Central).id,'New');
                                      newTask3.Task_Type__c = 'Procurement';
                                      if(newTask3 != null){
                                          lstTask.add(newTask3);
                                          system.debug('lstTask:::' + lstTask);
                                      } 
                                  }
                               
                                  /*
                                  newOpp.StageName = 'Document Review';
                                  */
                              }
                           
                           if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                              && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id  
                              && hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName =='Wire Pending'){
                                  if(string.isnotblank(newOpportunity.OwnerId)){
                                      string subject = 'Review inspection report with at least one other teammate, update confidential info notes once completed.'; 
                                      task newTask =
                                          CreateTask.createNewTask(subject,newOpportunity.id,null,system.today(),newOpportunity.OwnerId,'New');
                                      newTask.Task_Type__c = 'Procurement';
                                      if(newTask != null){
                                          lstTask.add(newTask);
                                          system.debug('lstTask:::' + lstTask);
                                      } 
                                         string subject2 = 'Get seller invoice with "free and clear of liens/encumbrances" verbiage and wire info.'; 
                                      task newTask2 =
                                          CreateTask.createNewTask(subject2,newOpportunity.id,null,system.today(),newOpportunity.OwnerId,'New');
                                      newTask2.Task_Type__c = 'Finance';
                                      if(newTask2 != null){
                                          lstTask.add(newTask2);
                                          system.debug('lstTask:::' + lstTask);
                                      } 
                                  }
                                  if(mapNameVsUser.ContainsKey(system.label.Office_Manager)){
                                      string subject1 = 'Confirm wire info by phone and add to BOS.  Incl year, make, model, S/N and ZID in the payment'; 
                                         subject1 += 'details of wire. And let Hardy know when completed.'; 
                                      task newTask1 =
                                          CreateTask.createNewTask(subject1,newOpportunity.id,null,system.today(),mapNameVsUser.get(system.label.Office_Manager).id,'New');
                                      newTask1.Task_Type__c = 'Procurement';
                                      if(newTask1 != null){
                                          lstTask.add(newTask1);
                                          system.debug('lstTask:::' + lstTask);
                                      } 
                                  }
                              }
                         
                           if(string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                              && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id  
                              && hasStageChanged(newOpportunity, oldOpportunity) && newOpportunity.StageName =='Proactive Brokerage' 
                              && (newOpportunity.Client_Type__c =='Manufacturer Dealer' || 
                                  newOpportunity.Client_Type__c == 'End User' ||
                                  newOpportunity.Client_Type__c == 'Equipment Seller')  && string.isnotblank(newOpportunity.product__c)){
                                      if(string.isnotblank(newOpportunity.product__r.Unit_Owner__c)){
                                          string subject = 'Ensure Unit Details are completed.';
                                          task newTask =
                                              CreateTask.createNewTask(subject,newOpportunity.Product__c,null,system.today(),newOpportunity.OwnerId,'New');
                                          if(newTask != null){
                                              lstTask.add(newTask);
                                              system.debug('lstTask:::' + lstTask);
                                          }
                                      }
                                  }
                           
                           if(String.isNotBlank(newOpportunity.Product__c) && 
                       String.isNotBlank(newOpportunity.Product__r.equipment__c) && 
                              string.isnotblank(Opp_Rec_type_Dev_Name_procurement_opp_Id)
                              && newOpportunity.RecordTypeId == Opp_Rec_type_Dev_Name_procurement_opp_Id  
                              && string.isnotblank(newOpportunity.product__c) && isValueChange(newOpportunity,oldOpportunity,'Offer_Amount__c')
                              && newOpportunity.Offer_Amount__c != null){
                                  //mapOfIdVsProduct.get(newOpportunity.Product__c).id = newOpportunity.Product__c;
                                  mapOfIdVsProduct.get(newOpportunity.Product__c).Procurement_Offer_Amount__c = newOpportunity.Offer_Amount__c;
                                  mapOfIdVsProduct.get(newOpportunity.Product__c).Procurement_Offer_Date__c =  system.today();  
                                  //system.debug('newprocdata :::'+newProduct);
                              }
                           
                          
            //---------------------------------------------------------------------------------------------------------------//
                           /*system.debug('newOpportunity.Accountid:::'+newOpportunity.Accountid);
                            system.debug('newOpportunity.Account.Primary_Contact__:::'+ newOpportunity.Account.Primary_Contact__c);
                           system.debug('newOpportunity.Buyer_Primary_Contact__c:::'+newOpportunity.Buyer_Primary_Contact__c);
                           if(string.isnotblank(newOpportunity.Accountid) &&  string.isnotblank(newOpportunity.Account.Primary_Contact__c) 
                              && string.isnotblank(newOpportunity.Buyer_Primary_Contact__c) ){
                                  if(newOpportunity.Buyer_Primary_Contact__c != newOpportunity.Account.Primary_Contact__c ){
                                      opportunity newOpp = new opportunity();
                                      newOpp.id = newOpportunity.Id; 
                                      newOpp.Buyer_Primary_Contact__c = newOpportunity.Account.Primary_Contact__c;
                                      lstOFOppToUpdate.add(newOpp);
                                      system.debug('newOpp.Buyer_Primary_Contact__c::::'+newOpp);
                                  }
                              }*/
                           
                           
                          /* //if opportunity stage is won purchase, product is not null and inspection status is not null then update unit records 
                           if(newOpportunity.StageName == 'Won - Purchased' && 
                              string.isnotblank(newOpportunity.Product__c) && 
                              newOpportunity.Inspection_Status__c =='Completed' && 
                              newOpportunity.Product__r.Procurement_Offer_Amount__c != null &&
                              newAccount != null && !newAccount.IsEmpty() && string.isnotblank(newOpportunity.Product__r.account__c)){
                                  product2 newProduct = new product2();
                                  newProduct.Id = newOpportunity.Product__c;
                                  newProduct.Inventory_Status__c = 'Owned';
                                  newProduct.Account_Purchased_From_For_Inventory__c = newOpportunity.Product__r.account__c;
                                  newProduct.Purchase_Date__c = system.today();
                                  newProduct.Unlist_Unit__c = true;
                                  newProduct.IsActive = true;
                                  newProduct.Zadoon_s_Final_Purchase_Price__c =newOpportunity.Product__r.Procurement_Offer_Amount__c;   
                                  newProduct.account__c = newAccount[0].id;
                                  lstProduct.add(newProduct);
                                  system.debug('newProduct:::'+newProduct);
                                  
                  
                              }*/
                       //}
                    
                    
					                    
                    //To send email
                    if(isValueChange(newOpportunity,oldOpportunity,'Is_Payment_Sent__c') && newOpportunity.Is_Payment_Sent__c==true
                       && String.IsNotBlank(newOpportunity.Buyer_Primary_Contact__c) && String.IsNotBlank(newOpportunity.Buyer_Primary_Contact__r.Email)){
                           //lstMessagingSingleEmailMessage.add(EmailEventHelper.handleSendEmailOnIs_Payment_SentUpdation(newOpportunity));
                       }
               
                    //getLastdateOftheMonth(System.today());
                   // todo : pls review paras yadav
                    /*Product2  unitToBeUpdate = new Product2();
                    unitToBeUpdate.Id = newOpportunity.Product__c;
                    unitToBeUpdate.IsActive = false;
                    unitToBeUpdate.Final_Sale_Price__c = newOpportunity.Total_Cost__c;
                    unitToBeUpdate.Sold_Deactivated_Date__c = System.today();
                    unitToBeUpdate.Unit_Stage__c = 'Zadoon Sold';    
                    
                    lstProduct.add(unitToBeUpdate);*/
                    
                    /***
                     * Updated By deepanshu for Unit Inspection Process to create task on Unit when 
                     * Triggers:  PO going to "offer acepted" stage 
                     * OR Sales opp going to "Client inspection requested" 
                     * OR Brokerage Sales Opp goes to "Pro Forma Sent" stage where we have not purchased from seller before
                     */
                    if(isValueChange(newOpportunity,oldOpportunity,'StageName') && mapNameVsUser.containsKey(System.Label.Office_Manager) && String.IsNotBlank(newOpportunity.Product__c)&&
                       (( newOpportunity.StageName=='Offer Accepted' && String.IsNotBlank(Opp_Rec_type_Dev_Name_procurement_opp_Id) && newOpportunity.RecordTypeId==Opp_Rec_type_Dev_Name_procurement_opp_Id)
                        ||( newOpportunity.StageName=='Pro Forma Sent' && String.IsNotBlank(Opp_Rec_Type_Broker_Sell_Id) && newOpportunity.RecordTypeId==Opp_Rec_Type_Broker_Sell_Id)
                        ||( newOpportunity.StageName=='Client Inspection Requested' && String.IsNotBlank(Opp_Rec_Type_Inventory_Sell_Id) && newOpportunity.RecordTypeId==Opp_Rec_Type_Inventory_Sell_Id))){
                            String Subject ='Queue-up inspection for the Unit.';
                            task newTask = new task();
                            newTask = CreateTask.createNewTask(Subject, 
                                                               newOpportunity.Id,
                                                               null, 
                                                               System.today(), 
                                                               mapNameVsUser.get(System.Label.Office_Manager).Id,
                                                               'New');
                            newTask.ZID__c= newOpportunity.Product__c;
                            lstTask.add(newTask);
                        }
                    
                    if(isValueChange(newOpportunity,oldOpportunity,'StageName') && newOpportunity.StageName=='Client Inspection Requested'
                       && newOpportunity.RecordTypeId==Opp_Rec_Type_Inventory_Sell_Id && mapNameVsUser.containsKey(System.Label.Office_Manager)){
                           String Subject = 'Client Inspection Requested to confirm all URTs are present and accurate!';
                           system.debug('Confirm all URTs are present and:::'+Subject);
                           task newTask = new task();
                           newTask = CreateTask.createNewTask(Subject, 
                                                              newOpportunity.id,
                                                              null, 
                                                              System.today(), 
                                                              mapNameVsUser.get(System.Label.Office_Manager).Id,
                                                              'New');
                           
                           lstTask.add(newTask);
                       }
                    if(isValueChange(newOpportunity,oldOpportunity,'StageName') && newOpportunity.StageName=='Received Buyers Wire'
                       && newOpportunity.RecordTypeId==Opp_Rec_Type_Broker_Sell_Id && mapNameVsUser.containsKey(System.Label.Office_Manager) ){
                           //Task for Melissa: “Pay {Unit.Account} for {Unit Name} and mark PO as won-brokered.  If PO does not exist, have VAs create one”
                           String subject = '';
                           If(String.IsNotEmpty(newOpportunity.Seller_Account__r.Name)){
                               subject +='Pay '+ newOpportunity.Seller_Account__r.Name;
                           }
                           If(String.IsNotEmpty(newOpportunity.Product__r.Name)){
                               subject +=' For '+ newOpportunity.Product__r.Name;
                           }
                           subject +=' and mark PO as won-brokered.  If PO does not exist, have VAs create one.';
                           task newTask = new task();
                           newTask = CreateTask.createNewTask(Subject, 
                                                              newOpportunity.id,
                                                              null, 
                                                              System.today(), 
                                                              mapNameVsUser.get(System.Label.Office_Manager).Id,
                                                              'New');
                           
                           lstTask.add(newTask);
                       }
                    
                  /*  if(newOpportunity.StageName=='Received Buyers Wire'
                       && newOpportunity.RecordTypeId==Opp_Rec_Type_Broker_Sell_Id &&
                      isValueChange(newOpportunity,oldOpportunity,'StageName')){
                           
                       }*/
                    
                    if(newOpportunity.HelloSign__HelloSign_Document_Statuses__r.size()>0 && isValueChange(newOpportunity,oldOpportunity,'StageName') && newOpportunity.StageName=='Client Inspection Requested'
                      && newOpportunity.RecordTypeId !=Opp_Rec_Type_Inventory_Sell_Id && newOpportunity.Buyer_Aggrement_Signed__c == false){
                         String Subject = 'Buyer Agreement is not signed.';
                           task newTask = new task();
                           newTask = CreateTask.createNewTask(Subject, 
                                                              newOpportunity.id,
                                                              null, 
                                                              System.today(), 
                                                              newOpportunity.OwnerId,
                                                              'New');
                          if(newTask != null){
                              lstTask.add(newTask); 
                          }
                    }
                    
                       if(newOpportunity.HelloSign__HelloSign_Document_Statuses__r.size()>0 && isValueChange(newOpportunity,oldOpportunity,'StageName') && newOpportunity.StageName=='Client Inspection Requested'
                      && newOpportunity.RecordTypeId !=Opp_Rec_Type_Inventory_Sell_Id && newOpportunity.Seller_Aggrement_signed__c == false){
                         String Subject = 'Seller Agreement is not signed.';
                           task newTask = new task();
                           newTask = CreateTask.createNewTask(Subject, 
                                                              newOpportunity.id,
                                                              null, 
                                                              System.today(), 
                                                              newOpportunity.OwnerId,
                                                              'New');
                          if(newTask != null){
                              lstTask.add(newTask); 
                          }
                    }
                    /*if((isValueChange(newOpportunity,oldOpportunity,'StageName') 
                        || isValueChange(newOpportunity,oldOpportunity,'Market_on_FB__c'))
                       && newOpportunity.StageName=='Proactive Brokerage' 
                       && newOpportunity.Market_on_FB__c==true &&
                       String.isNotBlank(newOpportunity.Product__c)){
                           string subject = 'Post that unit on FB marketplace and the 20 most relevant groups';
                           if(String.isNotBlank(newOpportunity.Product__r.Unit_Owner__c) && 
                              (newOpportunity.Product__r.Unit_Owner__r.Name == System.Label.Outside_East ||
                               newOpportunity.Product__r.Unit_Owner__r.Name == System.Label.Outside_West ) &&
                              mapNameVsUser.containsKey(System.Label.Inside_West)){
                                  task newTask = CreateTask.createNewTask(subject,newOpportunity.Product__c,
                                                                          null,System.today(),mapNameVsUser.get(System.Label.Inside_West).id,
                                                                          'New');
                                  
                                  lstTask.add(newTask);
                              }
                           else if( String.isNotBlank(newOpportunity.Product__r.Unit_Owner__c)){
                               task newTask = CreateTask.createNewTask(subject,newOpportunity.Product__c,
                                                                       null,System.today(),newOpportunity.Product__r.Unit_Owner__c,
                                                                       'New');
                               lstTask.add(newTask); 
                           }
                       }*/
                    
                    
                    //lstProduct.add(newProduct);
                    lstOFOpportunityToUpdate.add(newOpp);
                    system.debug('lstOFOpportunityToUpdate:::'+lstOFOpportunityToUpdate);
                    if((isValueChange(newOpportunity,oldOpportunity,'StageName')||isValueChange(newOpportunity,oldOpportunity,'Invoice_signed__c') ) && newOpportunity.StageName == 'Pro Forma Sent' &&
                       newOpportunity.Invoice_signed__c == true &&
                              mapOfIdVsContentDecoumentLink.containsKey(newOpportunity.Id)){
                                   List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                           
                                  system.debug('enter in mail');
                                  for(ContentDocumentLink eachContentDocumentLink :mapOfIdVsContentDecoumentLink.get(newOpportunity.Id)){
                                      Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                                       system.debug('enter in mail'+(mapOfIdVsContentVersion.get(eachContentDocumentLink.ContentDocumentId)));
                                       system.debug('enter in mail'+eachContentDocumentLink.ContentDocumentId);
                                      emailAttachment.setFileName(mapOfIdVsContentVersion.get(eachContentDocumentLink.ContentDocumentId).Title);
                                      emailAttachment.setBody(mapOfIdVsContentVersion.get(eachContentDocumentLink.ContentDocumentId).VersionData);
                                      attachments.add(emailAttachment);
                                  }
                        
                        Messaging.SingleEmailMessage email = 
                        getAttachements(newOpportunity.Id,mapofStringVsEmailTemplate.get(System.Label.Zadoon_Handling_freight_Email).id, newOpportunity.Buyer_Contact_Email__c, newOpportunity.Buyer_Primary_Contact__c);
					
                        email.setFileAttachments(attachments);
                        email.setSaveAsActivity(true);
                        
                        lstEmailWithAttachements.add(email);
                        opportunity eachOpp1 = new opportunity();
                        eachOpp1.id = newOpportunity.id;
                        eachOpp1.StageName = 'Waiting for Buyer\'s Wire';
                        lstOppToUpdate.add(eachOpp1);
                    }
                    system.debug('Document_Statuses__r.size():::'+newOpportunity.HelloSign__HelloSign_Document_Statuses__r.size());
                    if(newOpportunity.HelloSign__HelloSign_Document_Statuses__r.size()==0 && isValueChange(newOpportunity,oldOpportunity,'StageName') 
                       && newOpportunity.StageName=='Client Inspection Requested'
                      && newOpportunity.RecordTypeId ==Opp_Rec_Type_Broker_Sell_Id ){
                        String Subject = 'Send Buyer and seller agreement ';
                        task newTask = new task();
                        newTask = CreateTask.createNewTask(Subject, 
                                                           newOpportunity.id,
                                                           null, 
                                                           System.today(), 
                                                           newOpportunity.OwnerId,
                                                           'New');
                        if(newTask != null){
                            lstTask.add(newTask); 
                        }
                    }
                 
                }
            
            }
            if(lstMessagingSingleEmailMessage!=null && !lstMessagingSingleEmailMessage.isEmpty()){
                system.debug('lstMessagingSingleEmailMessage:::'+lstMessagingSingleEmailMessage);
                Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(lstMessagingSingleEmailMessage);
                system.debug('sendResults::'+sendResults);
            }
            if(lstMessage != null && !lstMessage.isEmpty()){
                Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(lstMessage);
                system.debug('sendResults::'+sendResults);
                system.debug('Email is send:::');
            }
            
            
            if(lstOppToUpdate != null && !lstOppToUpdate.isEmpty()){
                system.debug('lstOFOppToUpdate88:::'+lstOppToUpdate);
                update lstOppToUpdate;
                system.debug('lstOFOppToUpdate:::'+lstOppToUpdate);
            }
            
            if(lstAccountToUpdate != null && !lstAccountToUpdate.isEmpty()){
                system.debug('lstAccountToUpdatebefore:::'+lstAccountToUpdate);
                update lstAccountToUpdate;
                system.debug('lstAccountToUpdateAfter:::'+lstAccountToUpdate);
            }
            /*if(lstOFUnitToUpdate != null && !lstOFUnitToUpdate.isEmpty()){
update lstOFUnitToUpdate;
system.debug('lstOFUnitToUpdate:::'+lstOFUnitToUpdate);
}*/
            /* if(lstTaskToInsert!=null && !lstTaskToInsert.isEmpty()){
insert lstTaskToInsert;
system.debug('lstTaskToInsert after insert:::'+lstTaskToInsert);
}*/
            /*
* This Part of code is used to create tasks for the Opp Sales Process and uppdated by Deepanshu on 28/08/2023
*/
            /*system.debug('lstProduct:::'+lstProduct);
            if(lstProduct !=null && !lstProduct.isEmpty()){
                system.debug('lstProduct:::'+lstProduct);
                //update lstProduct;
            }*/
            
            if(mapOfIdVsProduct.values() != null && !mapOfIdVsProduct.values().isEmpty()){
                system.debug('mapOfIdVsProduct.values():::'+mapOfIdVsProduct.values());
                update mapOfIdVsProduct.values();
                system.debug('mapOfIdVsProduct.values():::'+mapOfIdVsProduct.values());
            }

            
            
            if(lstTask!=null && !lstTask.isEmpty()){
                system.debug('lstTask:::'+lstTask);
                Insert lstTask;
                system.debug('lstTask:::'+lstTask);
            }
            if(lstOFOpportunityToUpdate !=null && !lstOFOpportunityToUpdate.isEmpty()){
                system.debug('lstOFOpportunityToUpdate:::'+lstOFOpportunityToUpdate);
                //update lstOFOpportunityToUpdate;
                 system.debug('lstOFOpportunityToUpdate:::'+lstOFOpportunityToUpdate);
            }
            /*if(lstProduct2!=null && !lstProduct2.isEmpty()){
update lstProduct2;
}*/
            if(setUnitId!=null && !setUnitId.isEmpty()){
                updateUnitInvolved(setUnitId);
            }
            
            if(setOfOpportunity!=null && !setOfOpportunity.isempty()){
                list<Opportunity> lstOpportunity = new list<Opportunity>();
                lstOpportunity.addAll(setOfOpportunity);
                //It will update the no of lead under that unit.
                CalculateNoOfOpenOpportunity(lstOpportunity,True);
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
            
            
            
            if(lstEmailWithAttachements != null && !lstEmailWithAttachements.IsEmpty()){
                system.debug('lstEmailWithAttachements:::'+lstEmailWithAttachements);
                Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(lstEmailWithAttachements);
            }
        }
    }                                    
    
    private static Boolean hasRecordTypeChanged(
        Opportunity newOpportunity, Opportunity oldOpportunity
    ){
        return hasValueChanged(
            newOpportunity.RecordTypeId,
            oldOpportunity.RecordTypeId
        );
    }
    private static Boolean hasStageChanged(
        Opportunity newOpportunity, Opportunity oldOpportunity
    ){
        return hasValueChanged(
            newOpportunity.StageName,
            oldOpportunity.StageName
        );
    }
       private static Boolean hasCategoryChanged(
        Opportunity newOpportunity, Opportunity oldOpportunity
    ){
        return hasValueChanged(
            newOpportunity.ForecastCategory,
            oldOpportunity.ForecastCategory
        );
    }
    private static Boolean hasUnitChanged(
        Opportunity newOpportunity, Opportunity oldOpportunity
    ){
        return hasValueChanged(
            newOpportunity.Product__c,
            oldOpportunity.Product__c
        );
    }
    private static Boolean hasValueChanged(Object newValue, Object oldValue){
        return newValue != oldValue;
    }
    
    //TO check the Field Updates 
    private static Boolean isValueChange(sObject newValue, sObject oldValue,String FieldName){
        return newValue.get(FieldName) != oldValue.get(FieldName);
    }
    
    //Check 'Unit Involved in an Active Opportunity' when it has related sales opportunities whose stage is not equal to Closed Lost 
    //and unit is active
    private static void updateUnitInvolved (set<Id> setOfUnitId){
        List<Product2> lstProduct2 ;
        list<Product2> lstProduct2ToUpdate = new list<Product2>();
        list<RecordType> lstRecordType = [SELECT id, DeveloperName 
                                          FROM RecordType 
                                          WHERE DeveloperName =: Label.Opp_Rec_Type_Broker_Sell 
                                          OR DeveloperName =: Label.Opp_Rec_Type_Inventory_Sell  ];
        if(setOfUnitId!= null && !setOfUnitId.isEmpty()){
            lstProduct2 = [SELECT Id ,isActive,
                           Unit_Involved_in_an_Active_Opportunity__c, 
                           (SELECT id, StageName, RecordTypeId 
                            FROM Opportunities__r 
                            WHERE StageName != 'Closed Lost' AND RecordTypeId In : lstRecordType   ) 
                           FROM Product2 
                           WHERE ID IN : setOfUnitId AND isActive = true];
        }
        if(lstProduct2!=null && !lstProduct2.isEmpty()){
            for(Product2 eachProduct2 : lstProduct2){
                if(eachProduct2.Opportunities__r != null && 
                   !eachProduct2.Opportunities__r.isEmpty() && 
                   eachProduct2.Unit_Involved_in_an_Active_Opportunity__c != True){
                       eachProduct2.Unit_Involved_in_an_Active_Opportunity__c = true;
                       lstProduct2ToUpdate.add(eachProduct2);
                   }
            }
            if(lstProduct2ToUpdate!=null && !lstProduct2ToUpdate.isEmpty()){
                //update lstProduct2ToUpdate;
            }
        }
    }
    
    private static date getLastdateOftheMonth(date giveDate){
        Integer numberOfDays = Date.daysInMonth(giveDate.year(), giveDate.month());
        Date lastDayOfMonth = Date.newInstance(giveDate.year(), giveDate.month(), numberOfDays);
        return lastDayOfMonth;
    }
    
    
    private static Messaging.SingleEmailMessage emailToSeller(string oppID,string OwnerEmailId ,string sellerEmail,string sendFrom,string targetObject,string emailTempID){
        system.debug('oppID:::'+oppID);
        system.debug('OwnerEmailId:::'+OwnerEmailId);
        system.debug('sellerEmail:::'+sellerEmail);
        system.debug('emailTempID::'+emailTempID);
        system.debug('email to seller');
        /*EmailTemplate emailtemp = [SELECT Id, Name 
                                   FROM EmailTemplate 
                                   where name = 'Purchase route email to seller' 
                                   Limit 1];*/
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(string.isnotblank(emailTempID)){
            mail.setTemplateID(emailTempID);
            mail.setTargetObjectId(targetObject);
            mail.setWhatId(oppID); 
            mail.toAddresses = new String[] {sellerEmail};
                mail.ccAddresses = new String[] {OwnerEmailId};     
            mail.setOrgWideEmailAddressId(sendFrom); //This will help us to send email from specific user
            
        }
        return mail;
        /*Messaging.SingleEmailMessage[] messages = new   
            List<Messaging.SingleEmailMessage> {mail};
                Messaging.SendEmailResult[] results =
                Messaging.sendEmail(messages);
        system.debug('email send:::');*/
    }
    //string OwnerEmailIdInCC ,string ccToManager, String CCToCOO
    //emailToBuyer(newOpportunity.Contact_Email__c,mapIdVsUser.get(newOpportunity.OwnerId).email,newOpportunity.id,newOpportunity.Primary_Contact__c);
    private static Messaging.SingleEmailMessage emailToBuyer(string sendTo,list<string> lstEmailToCC, string oppId,string targetObject,string emailTempID){
        system.debug('oppID:::'+oppID);
        system.debug('emailTempID::'+emailTempID);
        list<String> lstEmail = new List<String>();
        //system.debug('OwnerEmailId:::'+OwnerEmailIdInCC);
        system.debug('email to seller');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(string.isnotblank(emailTempID)){
            mail.setTemplateID(emailTempID);
            mail.setTargetObjectId(targetObject);
            mail.setWhatId(oppID); 
            mail.toAddresses = new String[] {sendTo};
                mail.setCcAddresses(lstEmailToCC);
        }
        return mail;
        /*Messaging.SingleEmailMessage[] messages = new   
            List<Messaging.SingleEmailMessage> {mail};
                Messaging.SendEmailResult[] results =
                Messaging.sendEmail(messages);
        system.debug('email send:::');*/
    }
    
    private static Messaging.SingleEmailMessage getAttachements(string OppId,string emailTempID,string sendTo, string targetObject){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(string.isnotblank(emailTempID)){
            mail.setTemplateID(emailTempID);
            mail.setTargetObjectId(targetObject);
            mail.setWhatId(oppID); 
            mail.toAddresses = new String[] {sendTo};
             //   mail.setFileAttachments(attachments);
        }
        return mail;
                
    }
}