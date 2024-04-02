public with sharing class UnitRelatedTransactionTriggerHelper {
    
    public static void calculateRollupAmount( List< Unit_Related_Transaction__c > newList,List< Unit_Related_Transaction__c > oldList, Map< Id,Unit_Related_Transaction__c > oldMap, System.TriggerOperation triggerEvent ) {
        
        Set< ID > productIdSet = new Set< ID > ();
        
        try {
            switch on triggerEvent {
                
                when AFTER_INSERT, AFTER_UNDELETE, AFTER_UPDATE {
                    for ( Unit_Related_Transaction__c unitTransac : newList ) {
                        if( unitTransac.Product__c != null ) {
                            productIdSet.add( unitTransac.Product__c );
                        }
                        if( oldMap != null && unitTransac.Product__c != oldMap.get( unitTransac.id).Product__c ) {
                            productIdSet.add(oldMap.get( unitTransac.id).Product__c );
                        }
                    }
                }
                when AFTER_DELETE {
                    for ( Unit_Related_Transaction__c unitTransac : oldList ) {
                        if( unitTransac.Product__c != null )  productIdSet.add( unitTransac.Product__c );
                    }
                }
            }
            
            system.debug(' productIdSet =====>'+productIdSet);
            if( productIdSet.size() > 0 ) {
                List< Product2 > prodList = [Select Id,Unit_Transaction_Expense_Total__c,Total_Cost_to_Zadoon_sum__c,Total_Upcharge_Revenue_to_Zadoon_sum__c,Unit_Transaction_Income_Total__c,Total_Cost_to_Client_sum__c,
                                             (Select id,Amount__c,Transaction_Type__c,Total_Cost_to_Client__c,Pass_Cost_to_Client__c From Unit_Related_Transactions2__r
                                              WHERE Total_Cost_to_Client__c > 0 OR Amount__c > 0)
                                             From Product2 WHERE Id IN :productIdSet];
                
                system.debug(' prodList =====>'+prodList);
                for(Product2 unit : prodList) {
                    unit.Total_Cost_to_Client_sum__c = 0;
                    unit.Total_Cost_to_Zadoon_sum__c = 0;
                    unit.Total_Upcharge_Revenue_to_Zadoon_sum__c = 0;
                    unit.Unit_Transaction_Expense_Total__c = 0;
                    unit.Unit_Transaction_Income_Total__c = 0;
                    
                    if( unit.Unit_Related_Transactions2__r != null && unit.Unit_Related_Transactions2__r.size() > 0 ) {
                        for( Unit_Related_Transaction__c unitRansac : unit.Unit_Related_Transactions2__r ) {
                            if( unitRansac.Total_Cost_to_Client__c > 0 ) {
                                unit.Total_Cost_to_Client_sum__c += unitRansac.Total_Cost_to_Client__c ;
                            }
                            
                            if( unitRansac.Transaction_Type__c == 'Expense' && !unitRansac.Pass_Cost_to_Client__c && unitRansac.Amount__c > 0 ) {
                                unit.Total_Cost_to_Zadoon_sum__c += unitRansac.Amount__c;
                            }
                            
                            if( unitRansac.Transaction_Type__c == 'Income' && unitRansac.Amount__c > 0 ) {
                                unit.Total_Upcharge_Revenue_to_Zadoon_sum__c += unitRansac.Amount__c;
                            }
                            
                            if( unitRansac.Transaction_Type__c == 'Expense' && unitRansac.Amount__c > 0) {
                                unit.Unit_Transaction_Expense_Total__c += unitRansac.Amount__c;
                            }
                            
                            if( unitRansac.Transaction_Type__c == 'Income' && unitRansac.Amount__c > 0) {
                                unit.Unit_Transaction_Income_Total__c += unitRansac.Amount__c;
                            }
                        }
                    }
                }
                
                if( prodList != null && prodList.size() > 0) update prodList;
            }
        } catch ( Exception e ) {
            ApexPages.addMessages(e);
        }
    }
}