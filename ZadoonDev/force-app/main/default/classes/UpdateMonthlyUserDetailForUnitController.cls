public class UpdateMonthlyUserDetailForUnitController {
    public static void updateMonthUserDetails(list<Product2>lstUnit,
                                              list<Monthly_Goal_For_User__c>lstMonthlyGoalForUser){
                                                  Map<String,list<Product2>> mapYearMonthsUserIdLstUnitsAdded = new Map<String,list<Product2>>();
                                                  Map<String,list<Product2>> mapYearMonthsUserIdLstUnitsOwnedAdded= new Map<String,list<Product2>>();
                                                  Map<String,list<Product2>> mapYearMonthsUserIdLstUnitPurchaseAdded= new Map<String,list<Product2>>();
                                                  Map<String,list<Product2>> mapPurchaseYearMonthsUserIdLstUnitsAdded= new Map<String,list<Product2>>();
                                                  Map<String,list<Product2>> mapPurchaseYearMonthsUserIdLstUnitPotentialGP= new Map<String,list<Product2>>();
                                                  Map<String,list<Product2>> mapPurchaseYearMonthsUserIdLstUnitsPurchased= new Map<String,list<Product2>>();
                                                  map<String,List<Product2>> mapOfUserCreateMonthYearVsLstProOpp = new map<String,list<Product2>>(); 
                                                  if(lstUnit!=null && !lstUnit.isEmpty()){
                                                      
                                                      for(Product2 eachProduct2 : lstUnit ){
                                                          String OwnerMonthYearKeyOwnedUnitsPurchase_Date ;
                                                          String OwnerMonthYearKey;
                                                          String OwnerMonthYearKeySold;
                                                          if(eachProduct2.Purchase_Date__c!=Null){
                                                              Date d = eachProduct2.Purchase_Date__c;
                                                              Integer y = d.year();
                                                              Integer m = d.month();
                                                              Integer day = d.day();
                                                              DateTime eachProduct2Purchase_Date = DateTime.newInstance(y,m,day);
                                                              OwnerMonthYearKeyOwnedUnitsPurchase_Date = eachProduct2.Unit_Owner__c + eachProduct2Purchase_Date.format( 'MMMM' ) +(eachProduct2Purchase_Date).Year();
                                                          }
                                                          if(eachProduct2.CreatedAt__c!=Null){ 
                                                              Date d = eachProduct2.CreatedAt__c;
                                                              Integer y = d.year();
                                                              Integer m = d.month();
                                                              Integer day = d.day();
                                                              DateTime eachProduct2CreatedAt = DateTime.newInstance(y,m,day);
                                                              OwnerMonthYearKey =  eachProduct2.Unit_Owner__c +eachProduct2CreatedAt.format( 'MMMM' ) + eachProduct2CreatedAt.Year();
                                                          }
                                                          if(eachProduct2.Sold_Deactivated_Date__c!=Null){ 
                                                              Date d = eachProduct2.Sold_Deactivated_Date__c;
                                                              Integer y = d.year();
                                                              Integer m = d.month();
                                                              Integer day = d.day();
                                                              DateTime eachProduct2SoldDeactivated = DateTime.newInstance(y,m,day);
                                                              OwnerMonthYearKeySold = eachProduct2.Unit_Owner__c + eachProduct2SoldDeactivated.format( 'MMMM' ) +eachProduct2SoldDeactivated.Year();
                                                          }
                                                          // alcute no of unit added
                                                          if(!mapYearMonthsUserIdLstUnitsAdded.containsKey(OwnerMonthYearKey)){
                                                              mapYearMonthsUserIdLstUnitsAdded.put(OwnerMonthYearKey,new list<Product2>());
                                                              
                                                          }
                                                          mapYearMonthsUserIdLstUnitsAdded.get(OwnerMonthYearKey).add(eachProduct2);
                                                          //calculate Units Owned turn rate 
                                                          if(string.isNotBlank(eachProduct2.Inventory_Status__c) && 
                                                             eachProduct2.Inventory_Status__c == 'Owned' && 
															 string.isNotBlank(OwnerMonthYearKeySold)){ //&& string.isNotBlank(eachProduct2.Account__c)){
                                                              
                                                              if(!mapYearMonthsUserIdLstUnitsOwnedAdded.containsKey(OwnerMonthYearKeySold)){
                                                                  mapYearMonthsUserIdLstUnitsOwnedAdded.put(OwnerMonthYearKeySold,new list<Product2>());
                                                              }
                                                              mapYearMonthsUserIdLstUnitsOwnedAdded.get(OwnerMonthYearKeySold).add(eachProduct2);
                                                              
                                                          }
                                                          //calculate Cost of goods
                                                          if(eachProduct2.Zadoon_s_Final_Purchase_Price__c != null && string.isNotBlank(OwnerMonthYearKeyOwnedUnitsPurchase_Date) ){
                                                              
                                                              if(!mapPurchaseYearMonthsUserIdLstUnitsAdded.containsKey(OwnerMonthYearKeyOwnedUnitsPurchase_Date)){
                                                                  mapPurchaseYearMonthsUserIdLstUnitsAdded.put(OwnerMonthYearKeyOwnedUnitsPurchase_Date,new list<Product2>());
                                                                  
                                                              }
                                                              mapPurchaseYearMonthsUserIdLstUnitsAdded.get(OwnerMonthYearKeyOwnedUnitsPurchase_Date).add(eachProduct2);
                                                          }
                                                          //calculate Potential GP (Owned Units)
                                                          if(eachProduct2.Potential_Gross_Profit__c != null &&
                                                             string.isNotBlank(OwnerMonthYearKeyOwnedUnitsPurchase_Date) &&
                                                            eachProduct2.IsActive == true){
                                                              
                                                              if(!mapPurchaseYearMonthsUserIdLstUnitPotentialGP.containsKey(OwnerMonthYearKeyOwnedUnitsPurchase_Date)){
                                                                  mapPurchaseYearMonthsUserIdLstUnitPotentialGP.put(OwnerMonthYearKeyOwnedUnitsPurchase_Date,new list<Product2>());
                                                                  
                                                              }
                                                              mapPurchaseYearMonthsUserIdLstUnitPotentialGP.get(OwnerMonthYearKeyOwnedUnitsPurchase_Date).add(eachProduct2);
                                                          }
                                                          //calculate Units Purchased
                                                          if(string.isNotBlank(OwnerMonthYearKeyOwnedUnitsPurchase_Date) ){
                                                              
                                                              if(!mapPurchaseYearMonthsUserIdLstUnitsPurchased.containsKey(OwnerMonthYearKeyOwnedUnitsPurchase_Date)){
                                                                  mapPurchaseYearMonthsUserIdLstUnitsPurchased.put(OwnerMonthYearKeyOwnedUnitsPurchase_Date,new list<Product2>());
                                                                  
                                                              }
                                                              mapPurchaseYearMonthsUserIdLstUnitsPurchased.get(OwnerMonthYearKeyOwnedUnitsPurchase_Date).add(eachProduct2);
                                                          }
                                                          //Calculate No Of Procuretment opp created
                                                          
                                                          if(eachProduct2.Opportunities__r !=null && !eachProduct2.Opportunities__r.isEmpty()){
                                                              if(!mapOfUserCreateMonthYearVsLstProOpp.containsKey(OwnerMonthYearKey)){
                                                                     mapOfUserCreateMonthYearVsLstProOpp.put(OwnerMonthYearKey,new list<Product2>());
                                                                 }  
                                                                 mapOfUserCreateMonthYearVsLstProOpp.get(OwnerMonthYearKey).add(eachProduct2);
                                                          }
                                                          
                                                      }	
                                                      
                                                  }
                                                  if(lstMonthlyGoalForUser!=null && !lstMonthlyGoalForUser.isEmpty()){
                                                      for(Monthly_Goal_For_User__c eachMonthlyGoalForUser : lstMonthlyGoalForUser){
                                                          String UserMonthYearKey = eachMonthlyGoalForUser.User__c +eachMonthlyGoalForUser.Month__c + eachMonthlyGoalForUser.Year__c;
                                                          //calculate no of Units_Added
                                                          if(mapYearMonthsUserIdLstUnitsAdded.containsKey(UserMonthYearKey)&&
                                                             mapYearMonthsUserIdLstUnitsAdded.get(UserMonthYearKey)!=null &&
                                                             !mapYearMonthsUserIdLstUnitsAdded.get(UserMonthYearKey).isEmpty() ){
                                                                 eachMonthlyGoalForUser.Units_Added__c  += mapYearMonthsUserIdLstUnitsAdded.get(UserMonthYearKey).size();
                                                             }
                                                          //calculate Units Purchased
                                                          if(mapPurchaseYearMonthsUserIdLstUnitsPurchased.containsKey(UserMonthYearKey)&&
                                                             mapPurchaseYearMonthsUserIdLstUnitsPurchased.get(UserMonthYearKey)!=null &&
                                                             !mapPurchaseYearMonthsUserIdLstUnitsPurchased.get(UserMonthYearKey).isEmpty() ){
                                                                 eachMonthlyGoalForUser.Units_Purchased__c  += mapPurchaseYearMonthsUserIdLstUnitsPurchased.get(UserMonthYearKey).size();
                                                             }
                                                          
                                                          //calculate Potential GP (Owned Units)
                                                          if( mapPurchaseYearMonthsUserIdLstUnitPotentialGP.containsKey(UserMonthYearKey)&&
                                                             mapPurchaseYearMonthsUserIdLstUnitPotentialGP.get(UserMonthYearKey)!=null &&
                                                             !mapPurchaseYearMonthsUserIdLstUnitPotentialGP.get(UserMonthYearKey).isEmpty() ){
                                                                 decimal totalPotentialGrossProfit = 0 ;
                                                                 for(Product2 eachProduct2 : mapPurchaseYearMonthsUserIdLstUnitPotentialGP.get(UserMonthYearKey)){
                                                             		//if(eachProduct2.Potential_Gross_Profit__c!=null && eachProduct2.Potential_Gross_Profit__c>0){
                                                                         totalPotentialGrossProfit += eachProduct2.Potential_Gross_Profit__c;
                                                                     //}
                                                                 }
                                                                 eachMonthlyGoalForUser.Potential_Gross_Profit_Owned_Units__c += totalPotentialGrossProfit;
                                                             }
                                                          //To Calculate cost of goods
                                                          if( mapPurchaseYearMonthsUserIdLstUnitsAdded.containsKey(UserMonthYearKey)&&
                                                             mapPurchaseYearMonthsUserIdLstUnitsAdded.get(UserMonthYearKey)!=null &&
                                                             !mapPurchaseYearMonthsUserIdLstUnitsAdded.get(UserMonthYearKey).isEmpty() ){
                                                                 decimal totalOwned_Units_CostOfGoods = 0;
                                                                 for(Product2 eachProduct2 : mapPurchaseYearMonthsUserIdLstUnitsAdded.get(UserMonthYearKey)){
                                                             		//if(eachProduct2.Zadoon_s_Final_Purchase_Price__c!=null && eachProduct2.Zadoon_s_Final_Purchase_Price__c>0){
                                                                         totalOwned_Units_CostOfGoods += eachProduct2.Zadoon_s_Final_Purchase_Price__c;
                                                                     //}
                                                                 }
                                                                 eachMonthlyGoalForUser.Cost_of_Goods__c += totalOwned_Units_CostOfGoods;
                                                             }
                                                          //calulate Units Owned turn rate 
                                                          if( mapYearMonthsUserIdLstUnitsOwnedAdded.containsKey(UserMonthYearKey)&&
                                                             mapYearMonthsUserIdLstUnitsOwnedAdded.get(UserMonthYearKey)!=null &&
                                                             !mapYearMonthsUserIdLstUnitsOwnedAdded.get(UserMonthYearKey).isEmpty() ){
                                                                 eachMonthlyGoalForUser.Unit_Owned__c  += mapYearMonthsUserIdLstUnitsOwnedAdded.get(UserMonthYearKey).size();
                                                                 decimal totalOwned_Units_Purchase_Age = 0 ;
                                                                 for(Product2 eachProduct2 : mapYearMonthsUserIdLstUnitsOwnedAdded.get(UserMonthYearKey)){
                                                                     
                                                                     if(eachProduct2.Days_to_Turn__c !=null){
                                                                         totalOwned_Units_Purchase_Age += eachProduct2.Days_to_Turn__c;
                                                                     }
                                                                     
                                                                 }
                                                                 eachMonthlyGoalForUser.Owned_Units_Purchase_Age__c += totalOwned_Units_Purchase_Age;
                                                             }
                                                          //Calculate No Of Procuretment opp created
                                                          if( mapOfUserCreateMonthYearVsLstProOpp.containsKey(UserMonthYearKey)&&
                                                             mapOfUserCreateMonthYearVsLstProOpp.get(UserMonthYearKey)!=null &&
                                                             !mapOfUserCreateMonthYearVsLstProOpp.get(UserMonthYearKey).isEmpty() ){
                                                                 eachMonthlyGoalForUser.POs_Created__c += mapOfUserCreateMonthYearVsLstProOpp.get(UserMonthYearKey).size();
                                                             }
                                                         
                                                      }
                                                  }
                                                  
                                              }
    
}