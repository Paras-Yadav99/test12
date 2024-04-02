public class UpdateMonthlyUserDetailsForOppController {
    public static void updateMonthUserDetails(list<Opportunity>lstOpportunity,
                                              list<Monthly_Goal_For_User__c>lstMonthlyGoalForUser,
                                              map<String,id> mapOfRecordTypeDeveloperNameVsId 
                                             ){
                                                 
                                                 string RecTypeInventorySell = system.label.Opp_Rec_Type_Inventory_Sell;
                                                 string RecTypeBrokerSell = system.label.Opp_Rec_Type_Broker_Sell;
                                                 string RecTypeProcurement = system.label.Opp_Rec_type_Dev_Name_procurement_opp;      
                                                 map<String,list<Opportunity>> mapOfUserCloseMonthYearVsLstSalesOpp = new map<String,list<Opportunity>>(); 
                                                 map<String,List<Opportunity>> mapOfUnitOwnerOwnedCloseMonthYearVsLstSalesOpp = new map<String,list<Opportunity>>();
                                                 map<String,List<Opportunity>> mapOfUnitOwnerUnOwnedCloseMonthYearVsLstSalesOpp = new map<String,list<Opportunity>>();  
                                                 map<String,List<Opportunity>> mapOfOppOwneVsLstSalesOpp = new map<String,list<Opportunity>>();
                                                  map<String,List<Opportunity>> mapOfOppOwneVsLstProcOpp = new map<String,list<Opportunity>>();
                                                 if(lstOpportunity!=null && !lstOpportunity.isEmpty()){
                                                     for(Opportunity eachOpportunity : lstOpportunity){
                                                         DateTime eachOpportunityCreatedDate = eachOpportunity.CreatedDate;
                                                         string UserCreatedMonthYear = eachOpportunity.OwnerId + eachOpportunityCreatedDate.format( 'MMMM' ) + (eachOpportunityCreatedDate).Year();
                                                         if((string.isNotBlank(RecTypeInventorySell) && mapOfRecordTypeDeveloperNameVsId.containsKey(RecTypeInventorySell)&&
                                                                    mapOfRecordTypeDeveloperNameVsId.get(RecTypeInventorySell) == eachOpportunity.RecordTypeId ) ||
                                                                   (string.isNotBlank(RecTypeBrokerSell) && mapOfRecordTypeDeveloperNameVsId.containsKey(RecTypeBrokerSell) &&
                                                                    mapOfRecordTypeDeveloperNameVsId.get(RecTypeBrokerSell) == eachOpportunity.RecordTypeId )){
                                                             			/*Date d = eachOpportunity.CreatedDate;
                                                                        Integer y = d.year();
                                                                        Integer m = d.month();
                                                                        Integer day = d.day();*/
                                                                        if(!mapOfOppOwneVsLstSalesOpp.containsKey(UserCreatedMonthYear)){
                                                                            mapOfOppOwneVsLstSalesOpp.put(UserCreatedMonthYear,new list<Opportunity>());
                                                                        } mapOfOppOwneVsLstSalesOpp.get(UserCreatedMonthYear).add(eachOpportunity);
                                                                    }else if(string.isNotBlank(RecTypeProcurement) &&
                                                                            mapOfRecordTypeDeveloperNameVsId.get(RecTypeProcurement) == eachOpportunity.RecordTypeId)
                                                                    {
                                                                        if(!mapOfOppOwneVsLstProcOpp.containsKey(UserCreatedMonthYear)){
                                                                            mapOfOppOwneVsLstProcOpp.put(UserCreatedMonthYear,new list<Opportunity>());
                                                                        } mapOfOppOwneVsLstProcOpp.get(UserCreatedMonthYear).add(eachOpportunity);
                                                                    }
                                                         if(eachOpportunity.CloseDate!=null && 
                                                            eachOpportunity.ForecastCategoryName == 'Closed' ){
                                                                Date d = eachOpportunity.CloseDate;
                                                                Integer y = d.year();
                                                                Integer m = d.month();
                                                                Integer day = d.day();
                                                                DateTime eachOpportunityCloseDate = DateTime.newInstance(y,m,day);
                                                                
                                                                if((string.isNotBlank(RecTypeInventorySell) && mapOfRecordTypeDeveloperNameVsId.containsKey(RecTypeInventorySell)&&
                                                                    mapOfRecordTypeDeveloperNameVsId.get(RecTypeInventorySell) == eachOpportunity.RecordTypeId ) ||
                                                                   (string.isNotBlank(RecTypeBrokerSell) && mapOfRecordTypeDeveloperNameVsId.containsKey(RecTypeBrokerSell) &&
                                                                    mapOfRecordTypeDeveloperNameVsId.get(RecTypeBrokerSell) == eachOpportunity.RecordTypeId )){                
                                                                        
                                                                        
                                                                        string UserCloseMonthYear = eachOpportunity.OwnerId + eachOpportunityCloseDate.format( 'MMMM' ) + (eachOpportunityCloseDate).Year();
                                                                        //Calculate Gross Profit
                                                                        if(!mapOfUserCloseMonthYearVsLstSalesOpp.containsKey(UserCloseMonthYear)){
                                                                            mapOfUserCloseMonthYearVsLstSalesOpp.put(UserCloseMonthYear,new list<Opportunity>());
                                                                        }  
                                                                        mapOfUserCloseMonthYearVsLstSalesOpp.get(UserCloseMonthYear).add(eachOpportunity);
                                                                        
                                                                        //For Calculating Realized GP(Owned) , Realized GP(UnOwned), Unit Brokered 
                                                                        if(string.isNotBlank(eachOpportunity.Product__r.Unit_Owner__c) &&
                                                                           string.isNotBlank(eachOpportunity.Product__r.Inventory_Status__c )
                                                                           ){
                                                                                string OppUnitOwnerCloseMonthYear = eachOpportunity.Product__r.Unit_Owner__c + eachOpportunityCloseDate.format( 'MMMM' ) + (eachOpportunityCloseDate).Year();
                                                                                if(eachOpportunity.Product__r.Inventory_Status__c == 'Owned' ){
                                                                                    if(!mapOfUnitOwnerOwnedCloseMonthYearVsLstSalesOpp.containsKey(OppUnitOwnerCloseMonthYear)){
                                                                                        mapOfUnitOwnerOwnedCloseMonthYearVsLstSalesOpp.put(OppUnitOwnerCloseMonthYear,new list<Opportunity>());
                                                                                    }  
                                                                                    mapOfUnitOwnerOwnedCloseMonthYearVsLstSalesOpp.get(OppUnitOwnerCloseMonthYear).add(eachOpportunity);
                                                                                }else{
                                                                                    if(!mapOfUnitOwnerUnOwnedCloseMonthYearVsLstSalesOpp.containsKey(OppUnitOwnerCloseMonthYear)){
                                                                                    mapOfUnitOwnerUnOwnedCloseMonthYearVsLstSalesOpp.put(OppUnitOwnerCloseMonthYear,new list<Opportunity>());
                                                                                }  
                                                                                mapOfUnitOwnerUnOwnedCloseMonthYearVsLstSalesOpp.get(OppUnitOwnerCloseMonthYear).add(eachOpportunity);
                                                                            }
                                                                        }
                                                                    }
                                                            }
                                                         
                                                     }
                                                 }
                                                 
                                                 if(lstMonthlyGoalForUser!=null && !lstMonthlyGoalForUser.isEmpty()){
                                                     for(Monthly_Goal_For_User__c eachMonthlyGoalForUser : lstMonthlyGoalForUser){
                                                         String UserMonthYearKey =  +eachMonthlyGoalForUser.User__c +eachMonthlyGoalForUser.Month__c +eachMonthlyGoalForUser.Year__c ;
                                                         decimal grossProfit = 0;
                                                         decimal TotalProFormaCost=0;
                                                         decimal revenue=0;
                                                         decimal grossProfitOwned = 0 ;
                                                         decimal grossProfitUnOwned = 0 ;
                                                         integer NoOfSalesOppCreated = 0;
                                                         integer NoOfSalesOppWon =0;
                                                         integer NoOfProcuretmentOppCreated = 0;
                                                         integer NoOfProcuretmentOppWonBrokered = 0;
                                                         //No of Sales Lead Updated
                                                          if(mapOfOppOwneVsLstSalesOpp.containsKey(UserMonthYearKey)&&
                                                            mapOfOppOwneVsLstSalesOpp.get(UserMonthYearKey)!=null && 
                                                            !mapOfOppOwneVsLstSalesOpp.get(UserMonthYearKey).isEmpty()){
                                                                NoOfSalesOppCreated = mapOfOppOwneVsLstSalesOpp.get(UserMonthYearKey).Size();
                                                                //NoOfSalesOppCreated = lstOpp.Size();
                                                            }
                                                         eachMonthlyGoalForUser.Number_of_New_Sales_Opps__c = NoOfSalesOppCreated;
                                                         //No of Procuretment Opp Created
                                                          if(mapOfOppOwneVsLstProcOpp.containsKey(UserMonthYearKey)&&
                                                            mapOfOppOwneVsLstProcOpp.get(UserMonthYearKey)!=null && 
                                                            !mapOfOppOwneVsLstProcOpp.get(UserMonthYearKey).isEmpty()){
                                                                NoOfProcuretmentOppCreated = mapOfOppOwneVsLstProcOpp.get(UserMonthYearKey).Size();
                                                                for(opportunity eachOpp : mapOfOppOwneVsLstProcOpp.get(UserMonthYearKey)){
                                                                    /*if(eachOpp.StageName = ''){
                                                                       NoOfProcuretmentOppWonBrokered += 1; 
                                                                    }*/
                                                                }
                                                            }
                                                         eachMonthlyGoalForUser.Number_of_New_Procurement_Opps__c = NoOfProcuretmentOppCreated;
                                                         //Update Gross Profit, Revenue, Deal Closed
                                                         if(mapOfUserCloseMonthYearVsLstSalesOpp.containsKey(UserMonthYearKey)&&
                                                            mapOfUserCloseMonthYearVsLstSalesOpp.get(UserMonthYearKey)!=null && 
                                                            !mapOfUserCloseMonthYearVsLstSalesOpp.get(UserMonthYearKey).isEmpty()){
                                                                NoOfSalesOppWon = mapOfUserCloseMonthYearVsLstSalesOpp.get(UserMonthYearKey).Size();
                                                                for(Opportunity eachOpportunity : mapOfUserCloseMonthYearVsLstSalesOpp.get(UserMonthYearKey)){
                                                                    
                                                                    if(eachOpportunity.Amount!=null){
                                                                        grossProfit += eachOpportunity.Amount;
                                                                    }
                                                                    /*if(eachOpportunity.Pro_Forma_Shipping_Cost__c == null ){
                                                                    if(eachOpportunity.Pro_Forma_Price_Sent__c != null){
                                                                    TotalProFormaCost = eachOpportunity.Pro_Forma_Price_Sent__c; 
                                                                    }
                                                                    
                                                                    }else{
                                                                    TotalProFormaCost = eachOpportunity.Pro_Forma_Price_Sent__c + eachOpportunity.Pro_Forma_Shipping_Cost__c + 
                                                                    eachOpportunity.Port_ready_fee_intl_port_freight_only__c ;
                                                                    }*/
                                                                    if(eachOpportunity.Total_Cost__c >= eachOpportunity.Zadoon_s_Final_Sale_Price__c){
                                                                        if(eachOpportunity.Total_Cost__c != null){
                                                                            revenue += eachOpportunity.Total_Cost__c;
                                                                        }
                                                                        
                                                                    }else {
                                                                        if(eachOpportunity.Zadoon_s_Final_Sale_Price__c != null){
                                                                            revenue += eachOpportunity.Zadoon_s_Final_Sale_Price__c;
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                
                                                                eachMonthlyGoalForUser.Gross_Profit__c +=grossProfit;
                                                                eachMonthlyGoalForUser.Revenue__c += revenue;
                                                                eachMonthlyGoalForUser.Deals_Closed__c += mapOfUserCloseMonthYearVsLstSalesOpp.get(UserMonthYearKey).size();
                                                                
                                                            }
                                                         	eachMonthlyGoalForUser.Number_of_Won_Sales_Opps__c = NoOfSalesOppWon;
                                                         //Update Realized GP(Owned) , Realized GP(UnOwned), Unit Brokered
                                                         
                                                         if(mapOfUnitOwnerOwnedCloseMonthYearVsLstSalesOpp.containsKey(UserMonthYearKey)&&
                                                            mapOfUnitOwnerOwnedCloseMonthYearVsLstSalesOpp.get(UserMonthYearKey)!=null && 
                                                            !mapOfUnitOwnerOwnedCloseMonthYearVsLstSalesOpp.get(UserMonthYearKey).isEmpty()){   
                                                                for(Opportunity eachOpportunity : mapOfUnitOwnerOwnedCloseMonthYearVsLstSalesOpp.get(UserMonthYearKey)){
                                                                    
                                                                    if(eachOpportunity.Amount!=null){
                                                                        grossProfitOwned += eachOpportunity.Amount;
                                                                    }
                                                                }
                                                                eachMonthlyGoalForUser.Realized_Gross_Profit_Owned_Units__c += grossProfitOwned;
                                                                
                                                            }
                                                         //Update Realized GP(UnOwned), Unit Brokered
                                                         if(mapOfUnitOwnerUnOwnedCloseMonthYearVsLstSalesOpp.containsKey(UserMonthYearKey)&&
                                                            mapOfUnitOwnerUnOwnedCloseMonthYearVsLstSalesOpp.get(UserMonthYearKey)!=null && 
                                                            !mapOfUnitOwnerUnOwnedCloseMonthYearVsLstSalesOpp.get(UserMonthYearKey).isEmpty()){   
                                                                for(Opportunity eachOpportunity : mapOfUnitOwnerUnOwnedCloseMonthYearVsLstSalesOpp.get(UserMonthYearKey)){
                                                                    
                                                                    if(eachOpportunity.Amount!=null){
                                                                        grossProfitUnOwned += eachOpportunity.Amount;
                                                                    }
                                                                }
                                                                eachMonthlyGoalForUser.Realized_Gross_Profit_Brokered_Units__c += grossProfitUnOwned;
                                                                eachMonthlyGoalForUser.Units_Brokered__c += mapOfUnitOwnerUnOwnedCloseMonthYearVsLstSalesOpp.get(UserMonthYearKey).size();
                                                                
                                                            }
                                                         
                                                     }
                                                     
                                                 } 
                                             }
}