//This Class is used to handle Unit trigger update Ashynchorniously
public class UnitTriggerFutureHandler {
    
    @future(callOut = true)
    public static void handelUnitFutureAfterUpdate(string WrappedData, set<Id> setOfProduct2Id,set<Id> setOfUserId,set<String>setMonthName, set<integer>setYearNum){
        
        Wrapper newWrapper = (Wrapper)JSON.deserialize(WrappedData, Wrapper.class);
        
        Map<Id, Product2> oldProduct2Map = newWrapper.oldProduct2Map;
        Map<Id, Product2> newProduct2Map = newWrapper.newProduct2Map;
        list<Product2> lstProduct2Updated = newWrapper.triggerNew;//triggerNew
        list<Product2> lstUnitsToInsert = new list<Product2>();
        list<Product2> lstUnitsToDelete = new list<Product2>();
        Map<Id, Product2>  mapIdUnitsToInsert = new Map<Id, Product2> ();
        Map<Id, Product2>  mapIdUnitsToDelete = new Map<Id, Product2> ();
        //To Set Opportunity Data
        /*
string RecTypeInventorySell = system.label.Opportunity_Rec_Type_Inventory_Sell;
string RecTypeBrokerSell = system.label.Opp_Rec_Type_Broker_Sell;
string RecTypeProcurement = system.label.Opp_Rec_type_Dev_Name_procurement_opp;
list<RecordType> lstRecordType =[SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Opportunity'];
map<String,id> mapOfRecordTypeDeveloperNameVsId = new map<String,id>();
if(lstRecordType!=null && !lstRecordType.isEmpty()){
for(RecordType eachRecordType : lstRecordType){
mapOfRecordTypeDeveloperNameVsId.put(eachRecordType.DeveloperName,eachRecordType.Id);
}
}*/
        string RecTypeInventorySell = system.label.Opp_Rec_Type_Inventory_Sell;
        string RecTypeBrokerSell = system.label.Opp_Rec_Type_Broker_Sell;
        string RecTypeProcurement = system.label.Opp_Rec_type_Dev_Name_procurement_opp;
        Set<Id>setOfOppRecTypeId = new set<id>();
        list<string> lstDeveloperNameOfRecordType = new list<string>();
        if(string.isNotBlank(label.Opp_Rec_Type_Broker_Sell)){
            lstDeveloperNameOfRecordType.add(label.Opp_Rec_Type_Broker_Sell);
        }
        if(string.isNotBlank(label.Opp_Rec_Type_Inventory_Sell)){
            lstDeveloperNameOfRecordType.add(label.Opp_Rec_Type_Inventory_Sell);
        }
        if(string.isNotBlank(label.Opp_Rec_type_Dev_Name_procurement_opp)){
            lstDeveloperNameOfRecordType.add(label.Opp_Rec_type_Dev_Name_procurement_opp);
        }
        list<RecordType> lstRecordType =[SELECT Id, DeveloperName, Name 
                                         FROM RecordType
                                         WHERE DeveloperName IN : lstDeveloperNameOfRecordType ]; 
        map<String,id> mapOfRecordTypeDeveloperNameVsId = new map<String,id>();
        
        if(lstRecordType!=null && !lstRecordType.IsEmpty()){
            for(RecordType eachRecType : lstRecordType){
                mapOfRecordTypeDeveloperNameVsId.put(eachRecType.DeveloperName,eachRecType.Id);
                setOfOppRecTypeId.add(eachRecType.Id);
            }
        }
        
        
        list<Monthly_Goal_For_User__c>lstMonthlyGoalForUser;
        //map<id,Monthly_Goal_For_User__c> mapIdMonthlyGoalForUserToUpdate = new map<id,Monthly_Goal_For_User__c> ();
        
        Map<String,list<Product2>> mapYearMonthsUserIdLstUnitsAdded = new Map<String,list<Product2>>();
        Map<String,list<Product2>> mapYearMonthsUserIdLstUnitsRemoved = new Map<String,list<Product2>>();
        Map<String,list<Product2>> mapYearMonthsUserIdLstUnitsOwnedAdded= new Map<String,list<Product2>>();
        Map<String,list<Product2>> mapYearMonthsUserIdLstUnitsOwnedRemoved= new Map<String,list<Product2>>();
        Map<String,list<Product2>> mapYearMonthsUserIdLstUnitsBrockeredAdded= new Map<String,list<Product2>>();
        Map<String,list<Product2>> mapYearMonthsUserIdLstUnitsBrockeredRemoved= new Map<String,list<Product2>>();
        Map<String,list<Opportunity>>mapYearMonthsUserIdLstUnitsPOsCreateAdded = new Map<String,list<Opportunity>>();
        Map<String,list<Opportunity>>mapYearMonthsUserIdLstUnitsPOsCreateRemoved = new Map<String,list<Opportunity>>();
        Map<String,decimal>mapYearMonthsUserIdRealizedGPOwnedAdded = new Map<String,decimal>();
        Map<String,decimal>mapYearMonthsUserIdRealizedGPOwnedRemoved = new Map<String,decimal>();
        Map<String,decimal>mapYearMonthsUserIdRealizedGPUnOwnedAdded = new Map<String,decimal>();
        Map<String,decimal>mapYearMonthsUserIdRealizedGPUnOwnedRemoved = new Map<String,decimal>();
        //
        
        
        //// ////
        System.debug('setOfUserId'+setOfUserId);
        if(setOfProduct2Id!=null && !setOfProduct2Id.isEmpty()){
            lstProduct2Updated = [SELECT Id, Account__c, Account__r.Name,CreatedDate,Unit_Purchase_Age__c,Purchase_Date__c,CreatedAt__c,
                                  Potential_Gross_Profit__c,Inventory_Status__c,Zadoon_s_Final_Purchase_Price__c,Unit_Owner__c,
                                  (SELECT Id,ForecastCategoryName,Pro_Forma_Shipping_Cost__c,
                                   Pro_Forma_Price_Sent__c,Port_ready_fee_intl_port_freight_only__c,
                                   CloseDate,Zadoon_s_Final_Sale_Price__c,Total_Cost__c ,Amount,RecordTypeId,
                                   Product__r.Unit_Owner__c, Product__r.Inventory_Status__c,Product__r.CreatedAt__c
                                   FROM Opportunities__r WHERE RecordTypeId IN: setOfOppRecTypeId)
                                  FROM Product2 Where id IN : setOfProduct2Id ];
        }
        System.debug('lstProduct2Updated : : :'+lstProduct2Updated);
        if(setOfUserId!=null && !setOfUserId.isEmpty()){
            //list<Product2> lstProduct2Updated = newWrapper.triggerNew;//triggerNew
            lstMonthlyGoalForUser= [SELECT Id, User__c, Units_Purchased__c, Owned_Units_Purchase_Age__c, Units_Brokered__c, Units_Added__c, 
                                    Total_Units_Purchared_or_Brokered__c, Total_Actual_Gross_Profit_Procured__c,Cost_of_Goods__c,
                                    Realized_Gross_Profit_Owned_Units__c,Realized_Gross_Profit_Brokered_Units__c, POs_Created__c,
                                    Potential_Gross_Profit_Owned_Units__c ,Year__c,Month__c
                                    FROM Monthly_Goal_For_User__c 
                                    WHERE Month__c IN: setMonthName AND Year__c IN: setYearNum
                                    AND User__c IN : setOfUserId  ];
            System.debug('lstMonthlyGoalForUser : ::'+lstMonthlyGoalForUser);
            
            System.debug('lstMonthlyGoalForUser Size : ::'+lstMonthlyGoalForUser.size());
        }
        
        
        //Fill Data
        if(lstProduct2Updated!=null && !lstProduct2Updated.isEmpty()){
            for(Product2 eachProduct2 : lstProduct2Updated ){
                DateTime eachProduct2Purchase_Date;
                DateTime eachProduct2OldPurchase_Date;
                DateTime eachProduct2CreatedAt;
                // if(string.isNotBlank(eachProduct2.Unit_Owner__c)){
                if(newProduct2Map.get(eachproduct2.Id).CreatedAt__c!=Null){
                    Date d = newProduct2Map.get(eachproduct2.Id).CreatedAt__c;
                    Integer y = d.year();
                    Integer m = d.month();
                    Integer day = d.day();
                    eachProduct2CreatedAt = DateTime.newInstance(y,m,day);
                    
                    
                }
                if(newProduct2Map.get(eachproduct2.Id).Purchase_Date__c!=Null){
                    
                    
                    Date d = newProduct2Map.get(eachproduct2.Id).Purchase_Date__c;
                    Integer y = d.year();
                    Integer m = d.month();
                    Integer day = d.day();
                    eachProduct2Purchase_Date = DateTime.newInstance(y,m,day);
                }
                if(oldProduct2Map.get(eachproduct2.Id).Purchase_Date__c!=Null){
                    
                    Date d = oldProduct2Map.get(eachproduct2.Id).Purchase_Date__c;
                    Integer y = d.year();
                    Integer m = d.month();
                    Integer day = d.day();
                    eachProduct2OldPurchase_Date = DateTime.newInstance(y,m,day);
                }
                //For new Owned Units
                String YearMonthKeyNewOwner ='';
                String YearMonthKeyNewOwnerOwnedUnitsPurchase_Date = '';
                String YearMonthKeyOldOwnerOwnedUnitsPurchase_Date = ''; 
                
                //CheckFor Date
                if(eachProduct2Purchase_Date!=null ){
                    YearMonthKeyNewOwnerOwnedUnitsPurchase_Date = (eachProduct2Purchase_Date).Year()+'&&'+(eachProduct2Purchase_Date).format( 'MMMM' )+'&&'+newProduct2Map.get(eachproduct2.Id).Unit_Owner__c;
                }
                if(eachProduct2OldPurchase_Date!=Null){
                    YearMonthKeyOldOwnerOwnedUnitsPurchase_Date = (eachProduct2OldPurchase_Date).Year()+'&&'+(eachProduct2OldPurchase_Date).format( 'MMMM' )+'&&'+oldProduct2Map.get(eachproduct2.Id).Unit_Owner__c; 
                    
                }
                if(YearMonthKeyNewOwner!=null){
                    YearMonthKeyNewOwner = (eachProduct2CreatedAt).Year()+'&&'+(eachProduct2CreatedAt).format( 'MMMM' )+'&&'+newProduct2Map.get(eachproduct2.Id).Unit_Owner__c;
                }
                //TODO : Null Check Missing for Unit Owner/////Done
                //if Unit Owner is Changed
                if(oldProduct2Map.get(eachproduct2.Id).Unit_Owner__c != newProduct2Map.get(eachproduct2.Id).Unit_Owner__c){
                    if(oldProduct2Map.get(eachproduct2.Id).Unit_Owner__c !=null && newProduct2Map.get(eachproduct2.Id).Unit_Owner__c!=null){
                        String YearMonthKeyOldOwner = (eachProduct2CreatedAt).Year()+'&&'+(eachProduct2CreatedAt).format( 'MMMM' )+'&&'+oldProduct2Map.get(eachproduct2.Id).Unit_Owner__c;
                        
                        if(!mapYearMonthsUserIdLstUnitsAdded.containsKey(YearMonthKeyNewOwner)){
                            mapYearMonthsUserIdLstUnitsAdded.put(YearMonthKeyNewOwner,new list<Product2>());
                            
                        }//YearMonthKeyNewOwner ,YearMonthKeyOldOwner  
                        if(!mapYearMonthsUserIdLstUnitsRemoved.containsKey(YearMonthKeyOldOwner)){
                            mapYearMonthsUserIdLstUnitsRemoved.put(YearMonthKeyOldOwner,new list<Product2>());
                            
                        }
                        If(eachproduct2.Opportunities__r!=Null && ! eachproduct2.Opportunities__r.IsEmpty()){
                            For(Opportunity eachOpportunity : eachproduct2.Opportunities__r){
                                if((string.isNotBlank(RecTypeProcurement) &&
                                    mapOfRecordTypeDeveloperNameVsId.get(RecTypeProcurement) == eachOpportunity.RecordTypeId )){
                                        if(!mapYearMonthsUserIdLstUnitsPOsCreateAdded.containsKey(YearMonthKeyNewOwner)){
                                            mapYearMonthsUserIdLstUnitsPOsCreateAdded.put(YearMonthKeyNewOwner,new list<Opportunity>());
                                            
                                        }//YearMonthKeyNewOwner ,YearMonthKeyOldOwner  
                                        if(!mapYearMonthsUserIdLstUnitsPOsCreateRemoved.containsKey(YearMonthKeyOldOwner)){
                                            mapYearMonthsUserIdLstUnitsPOsCreateRemoved.put(YearMonthKeyOldOwner,new list<Opportunity>());
                                            
                                        }
                                        
                                        //To remove from Number Of Opp
                                        mapYearMonthsUserIdLstUnitsPOsCreateAdded.get(YearMonthKeyOldOwner).add(eachOpportunity);
                                        //To add from Number Of Opp
                                        mapYearMonthsUserIdLstUnitsPOsCreateRemoved.get(YearMonthKeyNewOwner).add(eachOpportunity);
                                        
                                    } 
                                if(eachOpportunity.CloseDate!=null && 
                                   eachOpportunity.ForecastCategoryName == 'Closed' ){
                                       Date d = eachOpportunity.CloseDate;
                                       Integer y = d.year();
                                       Integer m = d.month();
                                       Integer day = d.day();
                                       DateTime eachOpportunityCloseDate = DateTime.newInstance(y,m,day);
                                       setMonthName.add((eachOpportunityCloseDate).format( 'MMMM' ));
                                       setYearNum.add((eachOpportunityCloseDate).Year()); 
                                       if((string.isNotBlank(RecTypeInventorySell) && mapOfRecordTypeDeveloperNameVsId.containsKey(RecTypeInventorySell)&&
                                           mapOfRecordTypeDeveloperNameVsId.get(RecTypeInventorySell) == eachOpportunity.RecordTypeId ) ||
                                          (string.isNotBlank(RecTypeBrokerSell) && mapOfRecordTypeDeveloperNameVsId.containsKey(RecTypeBrokerSell) &&
                                           mapOfRecordTypeDeveloperNameVsId.get(RecTypeBrokerSell) == eachOpportunity.RecordTypeId )){                
                                               
                                               
                                               string UserCloseMonthYear = eachOpportunity.OwnerId + eachOpportunityCloseDate.format( 'MMMM' ) + (eachOpportunityCloseDate).Year();
                                               //Calculate Gross Profit
                                           }
                                   }
                            }
                        }
                        //To remove from Units
                        mapYearMonthsUserIdLstUnitsRemoved.get(YearMonthKeyOldOwner).add(oldProduct2Map.get(eachproduct2.Id));
                        //To add from Units
                        mapYearMonthsUserIdLstUnitsAdded.get(YearMonthKeyNewOwner).add(newProduct2Map.get(eachproduct2.Id));
                        //done                       
                        if(string.isNotBlank(eachProduct2.Inventory_Status__c)){
                            //if Invetory Status is Changed
                            if(oldProduct2Map.get(eachproduct2.Id).Inventory_Status__c != newProduct2Map.get(eachproduct2.Id).Inventory_Status__c){
                                if(newProduct2Map.get(eachproduct2.Id).Inventory_Status__c == 'Owned'  && string.isNotBlank(eachProduct2.Account__c) && eachProduct2.Account__r.Name =='Zadoon, LLC' ){
                                    //If Status is changed to Owned
                                    if(!mapYearMonthsUserIdLstUnitsOwnedAdded.containsKey(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date)){
                                        mapYearMonthsUserIdLstUnitsOwnedAdded.put(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                    }
                                    if(!mapYearMonthsUserIdLstUnitsBrockeredRemoved.containsKey(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date)){
                                        mapYearMonthsUserIdLstUnitsBrockeredRemoved.put(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                    }
                                    mapYearMonthsUserIdLstUnitsBrockeredRemoved.get(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date).add(oldProduct2Map.get(eachproduct2.Id));
                                    mapYearMonthsUserIdLstUnitsOwnedAdded.get(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date).add(newProduct2Map.get(eachproduct2.Id));
                                    
                                }else if(newProduct2Map.get(eachproduct2.Id).Inventory_Status__c != 'Owned'){//&& eachProduct2.Account__r.Name !='Zadoon, LLC'){
                                    //If Status is changed owned to not Owned
                                    if(!mapYearMonthsUserIdLstUnitsBrockeredAdded.containsKey(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date)){
                                        mapYearMonthsUserIdLstUnitsBrockeredAdded.put(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                    }
                                    if(!mapYearMonthsUserIdLstUnitsOwnedRemoved.containsKey(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date)){
                                        mapYearMonthsUserIdLstUnitsOwnedRemoved.put(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                    }
                                    mapYearMonthsUserIdLstUnitsOwnedRemoved.get(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date).add(oldProduct2Map.get(eachproduct2.Id));
                                    mapYearMonthsUserIdLstUnitsBrockeredAdded.get(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date).add(newProduct2Map.get(eachproduct2.Id));
                                }
                                //////////////////////////////////////////// IF Inventory Sataus is not changed
                            }else if(oldProduct2Map.get(eachproduct2.Id).Inventory_Status__c == newProduct2Map.get(eachproduct2.Id).Inventory_Status__c && 
                                     newProduct2Map.get(eachproduct2.Id).Inventory_Status__c == 'Owned'){
                                         
                                         if(!mapYearMonthsUserIdLstUnitsOwnedAdded.containsKey(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date)){
                                             mapYearMonthsUserIdLstUnitsOwnedAdded.put(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                             
                                         }
                                         if(!mapYearMonthsUserIdLstUnitsOwnedRemoved.containsKey(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date)){
                                             mapYearMonthsUserIdLstUnitsOwnedRemoved.put(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                             
                                         }
                                         mapYearMonthsUserIdLstUnitsOwnedRemoved.get(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date).add(oldProduct2Map.get(eachproduct2.Id));
                                         mapYearMonthsUserIdLstUnitsOwnedAdded.get(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date).add(newProduct2Map.get(eachproduct2.Id));
                                         
                                     }else{//if status is not owned
                                         if(!mapYearMonthsUserIdLstUnitsBrockeredAdded.containsKey(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date)){
                                             mapYearMonthsUserIdLstUnitsBrockeredAdded.put(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                             
                                         }
                                         if(!mapYearMonthsUserIdLstUnitsBrockeredRemoved.containsKey(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date)){
                                             mapYearMonthsUserIdLstUnitsBrockeredRemoved.put(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                             
                                         }
                                         mapYearMonthsUserIdLstUnitsBrockeredRemoved.get(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date).add(oldProduct2Map.get(eachproduct2.Id));
                                         mapYearMonthsUserIdLstUnitsBrockeredAdded.get(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date).add(newProduct2Map.get(eachproduct2.Id));
                                     }
                        }
                        //Add elseif Unit owner cahang
                    }else if(oldProduct2Map.get(eachproduct2.Id).Unit_Owner__c ==null && newProduct2Map.get(eachproduct2.Id).Unit_Owner__c!=null){
                        lstUnitsToInsert.add(newProduct2Map.get(eachproduct2.Id));
                        mapIdUnitsToInsert.put(eachproduct2.Id,newProduct2Map.get(eachproduct2.Id));
                    }else{
                        lstUnitsToDelete.add(newProduct2Map.get(eachproduct2.Id));
                        mapIdUnitsToDelete.put(eachproduct2.Id,newProduct2Map.get(eachproduct2.Id));
                    }
                    
                }// Add else Here 
                else{
                    //only if Status is changged  \
                    //TODO : Remove unit owner condition//DONE
                    if(oldProduct2Map.get(eachproduct2.Id).Inventory_Status__c != newProduct2Map.get(eachproduct2.Id).Inventory_Status__c ){
                        if(newProduct2Map.get(eachproduct2.Id).Inventory_Status__c == 'Owned' && eachProduct2.Account__r.Name =='Zadoon, LLC'){
                            //If Status is changed to Owned
                            System.debug('Changed from UnOwned to owned');
                            if(!mapYearMonthsUserIdLstUnitsOwnedAdded.containsKey(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date)){
                                mapYearMonthsUserIdLstUnitsOwnedAdded.put(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                            }
                            if(!mapYearMonthsUserIdLstUnitsBrockeredRemoved.containsKey(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date)){
                                mapYearMonthsUserIdLstUnitsBrockeredRemoved.put(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                            }
                            mapYearMonthsUserIdLstUnitsBrockeredRemoved.get(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date).add(oldProduct2Map.get(eachproduct2.Id));
                            mapYearMonthsUserIdLstUnitsOwnedAdded.get(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date).add(newProduct2Map.get(eachproduct2.Id));
                            
                        }else if(newProduct2Map.get(eachproduct2.Id).Inventory_Status__c != 'Owned' && string.isNotBlank(eachProduct2.Account__c) && eachProduct2.Account__r.Name !='Zadoon, LLC'  && 
                                 oldProduct2Map.get(eachproduct2.Id).Unit_Owner__c == newProduct2Map.get(eachproduct2.Id).Unit_Owner__c){ //&& eachProduct2.Account__r.Name =='Zadoon, LLC'
                                     //If Status is changed owned to not Owned
                                     System.debug('Changed from Owned to unowned');
                                     if(!mapYearMonthsUserIdLstUnitsBrockeredAdded.containsKey(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date)){
                                         mapYearMonthsUserIdLstUnitsBrockeredAdded.put(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                     }
                                     if(!mapYearMonthsUserIdLstUnitsOwnedRemoved.containsKey(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date)){
                                         mapYearMonthsUserIdLstUnitsOwnedRemoved.put(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                     }
                                     mapYearMonthsUserIdLstUnitsOwnedRemoved.get(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date).add(oldProduct2Map.get(eachproduct2.Id));
                                     mapYearMonthsUserIdLstUnitsBrockeredAdded.get(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date).add(newProduct2Map.get(eachproduct2.Id));
                                     
                                 }
                    }
                    
                    // // // // If Purchase_Date__c Changes 
                    
                    else if(oldProduct2Map.get(eachproduct2.Id).Purchase_Date__c != newProduct2Map.get(eachproduct2.Id).Purchase_Date__c ){ 
                        //If Old and new both have Purchase date 
                        if(oldProduct2Map.get(eachproduct2.Id).Purchase_Date__c !=null && newProduct2Map.get(eachproduct2.Id).Purchase_Date__c!=null ){
                            if( string.isNotBlank(eachProduct2.Account__c) && eachproduct2.Inventory_Status__c == 'Owned' && 
                               eachProduct2.Account__r.Name =='Zadoon, LLC'  ){
                                   System.debug('Changed from UnOwned to owned');
                                   if(!mapYearMonthsUserIdLstUnitsOwnedAdded.containsKey(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date)){
                                       mapYearMonthsUserIdLstUnitsOwnedAdded.put(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                       
                                   }
                                   if(!mapYearMonthsUserIdLstUnitsOwnedRemoved.containsKey(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date)){
                                       mapYearMonthsUserIdLstUnitsOwnedRemoved.put(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                       
                                   }
                                   mapYearMonthsUserIdLstUnitsOwnedRemoved.get(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date).add(oldProduct2Map.get(eachproduct2.Id));
                                   mapYearMonthsUserIdLstUnitsOwnedAdded.get(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date).add(newProduct2Map.get(eachproduct2.Id));
                                   
                               }else{//if status is not owned
                                   if(!mapYearMonthsUserIdLstUnitsBrockeredAdded.containsKey(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date)){
                                       mapYearMonthsUserIdLstUnitsBrockeredAdded.put(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                       
                                   }
                                   if(!mapYearMonthsUserIdLstUnitsBrockeredRemoved.containsKey(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date)){
                                       mapYearMonthsUserIdLstUnitsBrockeredRemoved.put(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                       
                                   }
                                   mapYearMonthsUserIdLstUnitsBrockeredRemoved.get(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date).add(oldProduct2Map.get(eachproduct2.Id));
                                   mapYearMonthsUserIdLstUnitsBrockeredAdded.get(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date).add(newProduct2Map.get(eachproduct2.Id));
                               }
                        }else if(oldProduct2Map.get(eachproduct2.Id).Purchase_Date__c ==null && newProduct2Map.get(eachproduct2.Id).Purchase_Date__c!=null ){
                            lstUnitsToInsert.add(newProduct2Map.get(eachproduct2.Id));
                            mapIdUnitsToInsert.put(eachproduct2.Id,newProduct2Map.get(eachproduct2.Id));
                        }else{
                            lstUnitsToDelete.add(newProduct2Map.get(eachproduct2.Id));
                            mapIdUnitsToDelete.put(eachproduct2.Id,newProduct2Map.get(eachproduct2.Id));
                        }
                        
                        //// ////// // // IF ZADOON'S FINAL PRICE IS CHANGED
                        
                    }else if(oldProduct2Map.get(eachproduct2.Id).Zadoon_s_Final_Purchase_Price__c != newProduct2Map.get(eachproduct2.Id).Zadoon_s_Final_Purchase_Price__c ){ 
                        if( string.isNotBlank(eachProduct2.Account__c) && eachproduct2.Inventory_Status__c == 'Owned' && 
                           eachProduct2.Account__r.Name =='Zadoon, LLC'  ){
                               System.debug('Changed from UnOwned to owned');
                               if(!mapYearMonthsUserIdLstUnitsOwnedAdded.containsKey(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date)){
                                   mapYearMonthsUserIdLstUnitsOwnedAdded.put(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                   
                               }
                               if(!mapYearMonthsUserIdLstUnitsOwnedRemoved.containsKey(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date)){
                                   mapYearMonthsUserIdLstUnitsOwnedRemoved.put(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                   
                               }
                               mapYearMonthsUserIdLstUnitsOwnedRemoved.get(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date).add(oldProduct2Map.get(eachproduct2.Id));
                               mapYearMonthsUserIdLstUnitsOwnedAdded.get(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date).add(newProduct2Map.get(eachproduct2.Id));
                               
                           }else{//if status is not owned
                               if(!mapYearMonthsUserIdLstUnitsBrockeredAdded.containsKey(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date)){
                                   mapYearMonthsUserIdLstUnitsBrockeredAdded.put(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                   
                               }
                               if(!mapYearMonthsUserIdLstUnitsBrockeredRemoved.containsKey(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date)){
                                   mapYearMonthsUserIdLstUnitsBrockeredRemoved.put(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                   
                               }
                               mapYearMonthsUserIdLstUnitsBrockeredRemoved.get(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date).add(oldProduct2Map.get(eachproduct2.Id));
                               mapYearMonthsUserIdLstUnitsBrockeredAdded.get(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date).add(newProduct2Map.get(eachproduct2.Id));
                           }
                    }//////////IF amont IS CHANGED
                    else if(oldProduct2Map.get(eachproduct2.Id).Potential_Gross_Profit__c != newProduct2Map.get(eachproduct2.Id).Potential_Gross_Profit__c ){ 
                        if( string.isNotBlank(eachProduct2.Account__c) && eachproduct2.Inventory_Status__c == 'Owned' && 
                           eachProduct2.Account__r.Name =='Zadoon, LLC'  ){
                               System.debug('Changed from UnOwned to owned');
                               if(!mapYearMonthsUserIdLstUnitsOwnedAdded.containsKey(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date)){
                                   mapYearMonthsUserIdLstUnitsOwnedAdded.put(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                   
                               }
                               if(!mapYearMonthsUserIdLstUnitsOwnedRemoved.containsKey(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date)){
                                   mapYearMonthsUserIdLstUnitsOwnedRemoved.put(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                   
                               }
                               mapYearMonthsUserIdLstUnitsOwnedRemoved.get(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date).add(oldProduct2Map.get(eachproduct2.Id));
                               mapYearMonthsUserIdLstUnitsOwnedAdded.get(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date).add(newProduct2Map.get(eachproduct2.Id));
                               
                           }else{//if status is not owned
                               if(!mapYearMonthsUserIdLstUnitsBrockeredAdded.containsKey(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date)){
                                   mapYearMonthsUserIdLstUnitsBrockeredAdded.put(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                   
                               }
                               if(!mapYearMonthsUserIdLstUnitsBrockeredRemoved.containsKey(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date)){
                                   mapYearMonthsUserIdLstUnitsBrockeredRemoved.put(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date,new list<Product2>());
                                   
                               }
                               mapYearMonthsUserIdLstUnitsBrockeredRemoved.get(YearMonthKeyOldOwnerOwnedUnitsPurchase_Date).add(oldProduct2Map.get(eachproduct2.Id));
                               mapYearMonthsUserIdLstUnitsBrockeredAdded.get(YearMonthKeyNewOwnerOwnedUnitsPurchase_Date).add(newProduct2Map.get(eachproduct2.Id));
                           }
                        //  }
                    }
                }
            }
        }
        
        
        
        if(lstMonthlyGoalForUser!=null && !lstMonthlyGoalForUser.isEmpty()){
            for(Monthly_Goal_For_User__c eachMonthlyGoalForUser : lstMonthlyGoalForUser){
                
                String YearMonthUserKey = eachMonthlyGoalForUser.Year__c+'&&'+eachMonthlyGoalForUser.Month__c +'&&'+eachMonthlyGoalForUser.User__c;
                
                if(mapYearMonthsUserIdLstUnitsAdded.containsKey(YearMonthUserKey)&&
                   mapYearMonthsUserIdLstUnitsAdded.get(YearMonthUserKey)!=null &&
                   !mapYearMonthsUserIdLstUnitsAdded.get(YearMonthUserKey).isEmpty() ){
                       eachMonthlyGoalForUser.Units_Added__c  += mapYearMonthsUserIdLstUnitsAdded.get(YearMonthUserKey).size();
                   }
                
                
                if(mapYearMonthsUserIdLstUnitsRemoved.containsKey(YearMonthUserKey)&&
                   mapYearMonthsUserIdLstUnitsRemoved.get(YearMonthUserKey)!=null &&
                   !mapYearMonthsUserIdLstUnitsRemoved.get(YearMonthUserKey).isEmpty() ){
                       eachMonthlyGoalForUser.Units_Added__c  -= mapYearMonthsUserIdLstUnitsRemoved.get(YearMonthUserKey).size();
                   }
                // To replace POs Created 
                if(mapYearMonthsUserIdLstUnitsPOsCreateAdded.containsKey(YearMonthUserKey)&&
                   mapYearMonthsUserIdLstUnitsPOsCreateAdded.get(YearMonthUserKey)!=null &&
                   !mapYearMonthsUserIdLstUnitsPOsCreateAdded.get(YearMonthUserKey).isEmpty() ){
                       eachMonthlyGoalForUser.POs_Created__c  += mapYearMonthsUserIdLstUnitsPOsCreateAdded.get(YearMonthUserKey).size();
                   }
                
                
                if(mapYearMonthsUserIdLstUnitsPOsCreateRemoved.containsKey(YearMonthUserKey)&&
                   mapYearMonthsUserIdLstUnitsPOsCreateRemoved.get(YearMonthUserKey)!=null &&
                   !mapYearMonthsUserIdLstUnitsPOsCreateRemoved.get(YearMonthUserKey).isEmpty() ){
                       eachMonthlyGoalForUser.POs_Created__c  -= mapYearMonthsUserIdLstUnitsPOsCreateRemoved.get(YearMonthUserKey).size();
                   }
                
                
                if(mapYearMonthsUserIdLstUnitsBrockeredAdded.containsKey(YearMonthUserKey)&&
                   mapYearMonthsUserIdLstUnitsBrockeredAdded.get(YearMonthUserKey)!=null &&
                   !mapYearMonthsUserIdLstUnitsBrockeredAdded.get(YearMonthUserKey).isEmpty() ){
                       //eachMonthlyGoalForUser.Units_Brokered__c  += mapYearMonthsUserIdLstUnitsBrockeredAdded.get(YearMonthUserKey).size();
                       decimal totalOwned_Units_CostOfGoods = 0;
                       for(Product2 eachProduct2 : mapYearMonthsUserIdLstUnitsBrockeredAdded.get(YearMonthUserKey)){
                           
                           if(eachProduct2.Zadoon_s_Final_Purchase_Price__c!=null && eachProduct2.Zadoon_s_Final_Purchase_Price__c>0){
                               totalOwned_Units_CostOfGoods += eachProduct2.Zadoon_s_Final_Purchase_Price__c;
                           }
                       }
                       if(eachMonthlyGoalForUser.Cost_of_Goods__c!=null){
                           eachMonthlyGoalForUser.Cost_of_Goods__c += totalOwned_Units_CostOfGoods;
                       }else{
                           eachMonthlyGoalForUser.Cost_of_Goods__c = totalOwned_Units_CostOfGoods;
                       }
                   }
                
                
                if(mapYearMonthsUserIdLstUnitsBrockeredRemoved.containsKey(YearMonthUserKey)&&
                   mapYearMonthsUserIdLstUnitsBrockeredRemoved.get(YearMonthUserKey)!=null &&
                   !mapYearMonthsUserIdLstUnitsBrockeredRemoved.get(YearMonthUserKey).isEmpty() ){
                       //eachMonthlyGoalForUser.Units_Brokered__c  -= mapYearMonthsUserIdLstUnitsBrockeredRemoved.get(YearMonthUserKey).size();
                       decimal totalOwned_Units_CostOfGoods = 0;
                       for(Product2 eachProduct2 : mapYearMonthsUserIdLstUnitsBrockeredRemoved.get(YearMonthUserKey)){
                           
                           if(eachProduct2.Zadoon_s_Final_Purchase_Price__c!=null && eachProduct2.Zadoon_s_Final_Purchase_Price__c>0){
                               totalOwned_Units_CostOfGoods += eachProduct2.Zadoon_s_Final_Purchase_Price__c;
                           }
                       }
                       if(eachMonthlyGoalForUser.Cost_of_Goods__c!=null){
                           eachMonthlyGoalForUser.Cost_of_Goods__c -= totalOwned_Units_CostOfGoods;
                       }else{
                           eachMonthlyGoalForUser.Cost_of_Goods__c = totalOwned_Units_CostOfGoods;
                       }
                   }
                
                if(mapYearMonthsUserIdLstUnitsOwnedAdded.containsKey(YearMonthUserKey)&&
                   mapYearMonthsUserIdLstUnitsOwnedAdded.get(YearMonthUserKey)!=null &&
                   !mapYearMonthsUserIdLstUnitsOwnedAdded.get(YearMonthUserKey).isEmpty() ){
                       eachMonthlyGoalForUser.Units_Purchased__c  += mapYearMonthsUserIdLstUnitsOwnedAdded.get(YearMonthUserKey).size();
                       decimal totalPotentialGrossProfit = 0 ;//Owned_Units_Purchase_Age__c
                       decimal totalOwned_Units_Purchase_Age = 0 ;
                       decimal totalOwned_Units_CostOfGoods = 0;
                       for(Product2 eachProduct2 : mapYearMonthsUserIdLstUnitsOwnedAdded.get(YearMonthUserKey)){
                           if(eachProduct2.Potential_Gross_Profit__c !=null){
                               totalPotentialGrossProfit += eachProduct2.Potential_Gross_Profit__c;
                               totalOwned_Units_Purchase_Age += eachProduct2.Unit_Purchase_Age__c;
                           }
                           if(eachProduct2.Zadoon_s_Final_Purchase_Price__c!=null && eachProduct2.Zadoon_s_Final_Purchase_Price__c>0){
                               totalOwned_Units_CostOfGoods += eachProduct2.Zadoon_s_Final_Purchase_Price__c;
                           }
                       }
                       if(eachMonthlyGoalForUser.Potential_Gross_Profit_Owned_Units__c!=null){
                           eachMonthlyGoalForUser.Potential_Gross_Profit_Owned_Units__c += totalPotentialGrossProfit;
                       }else{
                           eachMonthlyGoalForUser.Potential_Gross_Profit_Owned_Units__c = totalPotentialGrossProfit;
                       }
                       /// //// //// 
                       if(eachMonthlyGoalForUser.Owned_Units_Purchase_Age__c!=null){
                           eachMonthlyGoalForUser.Owned_Units_Purchase_Age__c += totalOwned_Units_Purchase_Age;
                       }else{
                           eachMonthlyGoalForUser.Owned_Units_Purchase_Age__c = totalOwned_Units_Purchase_Age;
                       }
                       if(eachMonthlyGoalForUser.Cost_of_Goods__c!=null){
                           eachMonthlyGoalForUser.Cost_of_Goods__c += totalOwned_Units_CostOfGoods;
                       }else{
                           eachMonthlyGoalForUser.Cost_of_Goods__c = totalOwned_Units_CostOfGoods;
                       }
                   }
                
                if(mapYearMonthsUserIdLstUnitsOwnedRemoved.containsKey(YearMonthUserKey)&&
                   mapYearMonthsUserIdLstUnitsOwnedRemoved.get(YearMonthUserKey)!=null &&
                   !mapYearMonthsUserIdLstUnitsOwnedRemoved.get(YearMonthUserKey).isEmpty() ){
                       eachMonthlyGoalForUser.Units_Purchased__c  -= mapYearMonthsUserIdLstUnitsOwnedRemoved.get(YearMonthUserKey).size();
                       decimal totalPotentialGrossProfit = 0 ;
                       decimal totalOwned_Units_Purchase_Age = 0 ;
                       decimal totalOwned_Units_CostOfGoods = 0 ;
                       for(Product2 eachProduct2 : mapYearMonthsUserIdLstUnitsOwnedRemoved.get(YearMonthUserKey)){
                           if(eachProduct2.Potential_Gross_Profit__c !=null){
                               totalPotentialGrossProfit += eachProduct2.Potential_Gross_Profit__c;
                               totalOwned_Units_Purchase_Age += eachProduct2.Unit_Purchase_Age__c;
                           }
                           if(eachProduct2.Zadoon_s_Final_Purchase_Price__c!=null && eachProduct2.Zadoon_s_Final_Purchase_Price__c>0){
                               totalOwned_Units_CostOfGoods += eachProduct2.Zadoon_s_Final_Purchase_Price__c;
                           }
                       }
                       if(eachMonthlyGoalForUser.Potential_Gross_Profit_Owned_Units__c  !=null){
                           eachMonthlyGoalForUser.Potential_Gross_Profit_Owned_Units__c = totalPotentialGrossProfit;
                       }else{
                           eachMonthlyGoalForUser.Potential_Gross_Profit_Owned_Units__c -= totalPotentialGrossProfit;
                       }
                       if(eachMonthlyGoalForUser.Owned_Units_Purchase_Age__c  !=null){
                           eachMonthlyGoalForUser.Owned_Units_Purchase_Age__c -= totalOwned_Units_Purchase_Age;
                       }else{
                           eachMonthlyGoalForUser.Owned_Units_Purchase_Age__c = totalOwned_Units_Purchase_Age;
                       }
                       if(eachMonthlyGoalForUser.Cost_of_Goods__c!=null){
                           eachMonthlyGoalForUser.Cost_of_Goods__c -= totalOwned_Units_CostOfGoods;
                       }else{
                           eachMonthlyGoalForUser.Cost_of_Goods__c = totalOwned_Units_CostOfGoods;
                       }
                   }
                
                //Put eachMonthlyGoalForUser to map to update
                //mapIdMonthlyGoalForUserToUpdate.put(eachMonthlyGoalForUser.id,eachMonthlyGoalForUser);
                
            }
        }
        
        //update MonthlyGoalForUser
        if(lstMonthlyGoalForUser!=null && !lstMonthlyGoalForUser.isEmpty()){
            update lstMonthlyGoalForUser;
            System.debug('After Update Valuse : : :'+lstMonthlyGoalForUser);
        }
        // IF Old Map have Null unit Owner or Purchase Date
        if(lstUnitsToInsert!=null && !lstUnitsToInsert.isEmpty() && mapIdUnitsToInsert.Values()!=null && !mapIdUnitsToInsert.Values().isEmpty()){
            //UnitTriggerHandler.handleAfterUndelete(lstUnitsToInsert,mapIdUnitsToInsert);
            System.debug('After Update Valuse To Insert: : :'+lstUnitsToInsert);
        }
        // IF New Map have Null unit Owner or Purchase Date
        if(lstUnitsToDelete!=null && !lstUnitsToInsert.isEmpty() && mapIdUnitsToDelete.Values()!=null && !mapIdUnitsToDelete.Values().isEmpty()){
            //UnitTriggerHandler.handleafterDelete(lstUnitsToDelete,mapIdUnitsToDelete);
            System.debug('After Update Valuse To Dlete: : :'+lstUnitsToDelete);
        }
        
    }
    //Method to handle Opp in Map
    private static Map<String,decimal> handelAddOppAmountInMaps(Opportunity eachOpportunity,Map<String,decimal> mapYearMonthsUserIdDeciaml , String KeyForMap){
        
        decimal totalGP=0.0;
        if(mapYearMonthsUserIdDeciaml.containsKey(KeyForMap)&&
           mapYearMonthsUserIdDeciaml.get(KeyForMap)!=null){
               totalGP=mapYearMonthsUserIdDeciaml.get(KeyForMap)+eachOpportunity.Amount;
               mapYearMonthsUserIdDeciaml.put(KeyForMap,totalGP);
           }else{
             mapYearMonthsUserIdDeciaml.put(KeyForMap,eachOpportunity.Amount);  
           }
        return mapYearMonthsUserIdDeciaml;
    }
    
    /*public static decimal getNewPotentialGrossProfit(Product2 eachProduct,Map<Id, Product2> newProduct2Map,Map<Id, Product2> oldProduct2Map){
//if(isblank(Final_Sale_Price__c ),Bottom_Sales_Price__c - Display_Lowest_Purchase_Price__c - Total_Expenses__c + Unit_Transaction_Income_Total__c , Final_Sale_Price__c - Display_Lowest_Purchase_Price__c - Total_Expenses__c + Unit_Transaction_Income_Total__c )
decimal totalCalculatedData = 0;
if(newProduct2Map.get(eachProduct.id).Bottom_Sales_Price__c ==null){
// newProduct2Map.get(eachProduct.id).Bottom_Sales_Price__c = 0;
}
if(newProduct2Map.get(eachProduct.id).Final_Sale_Price__c!=null){
totalCalculatedData = newProduct2Map.get(eachProduct.id).Final_Sale_Price__c - newProduct2Map.get(eachProduct.id).Display_Lowest_Purchase_Price__c - newProduct2Map.get(eachProduct.id).Total_Expenses__c + newProduct2Map.get(eachProduct.id).Unit_Transaction_Income_Total__c;
}else{
totalCalculatedData = newProduct2Map.get(eachProduct.id).Bottom_Sales_Price__c - newProduct2Map.get(eachProduct.id).Display_Lowest_Purchase_Price__c - newProduct2Map.get(eachProduct.id).Total_Expenses__c + newProduct2Map.get(eachProduct.id).Unit_Transaction_Income_Total__c; 
}
return totalCalculatedData;
}

public static decimal getOldPotentialGrossProfit(Product2 eachProduct,Map<Id, Product2> newProduct2Map,Map<Id, Product2> oldProduct2Map){
//if(isblank(Final_Sale_Price__c ),Bottom_Sales_Price__c - Display_Lowest_Purchase_Price__c - Total_Expenses__c + Unit_Transaction_Income_Total__c , Final_Sale_Price__c - Display_Lowest_Purchase_Price__c - Total_Expenses__c + Unit_Transaction_Income_Total__c )
decimal totalCalculatedData = 0;
if(oldProduct2Map.get(eachProduct.id).Final_Sale_Price__c!=null){
totalCalculatedData = oldProduct2Map.get(eachProduct.id).Final_Sale_Price__c - oldProduct2Map.get(eachProduct.id).Display_Lowest_Purchase_Price__c - oldProduct2Map.get(eachProduct.id).Total_Expenses__c + oldProduct2Map.get(eachProduct.id).Unit_Transaction_Income_Total__c;
}else{
totalCalculatedData = oldProduct2Map.get(eachProduct.id).Bottom_Sales_Price__c - oldProduct2Map.get(eachProduct.id).Display_Lowest_Purchase_Price__c - oldProduct2Map.get(eachProduct.id).Total_Expenses__c + oldProduct2Map.get(eachProduct.id).Unit_Transaction_Income_Total__c; 
}
return totalCalculatedData;
}*/
    
    class Wrapper{
        public list<Product2> triggerNew;
        public Map<Id, Product2> newProduct2Map;
        public Map<Id, Product2> oldProduct2Map;
        
        Wrapper(list<Product2> triggerNew,Map<Id, Product2> newProduct2Map,Map<Id, Product2> oldProduct2Map){
            this.triggerNew = triggerNew;
            this.newProduct2Map = newProduct2Map;
            this.oldProduct2Map = oldProduct2Map;
        }
    }
    
}