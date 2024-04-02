public with sharing class IronDemandTriggerHelper {
    
    public class myException extends Exception {}
    
    
    /* 1. This method is used to create Iron Demand unit records whenever units/products created/updated in the org.
* 2. Unlink existing iron demand units under units and link new iron demand units if any iron demand found with matching units.
* 3. Remove iron demand units under unit whenever unit deactivated.
*/
    public static void createMatchingIronDemandUnits( List <Iron_Demand__c > newList, Map< Id, Iron_Demand__c > oldMap, boolean isUpdate, boolean isInsert) {
        system.debug('newList ====>'+newList);
        system.debug('isInsert:'+isInsert);
        system.debug('oldMap::'+oldMap);
        try {
            Set< String > categorySet = new Set< String > ();
            Set< String > makeSet = new Set< String > ();
            Set< String > modelSet = new Set< String > ();
            Set< ID > ironDemandIdSet = new Set< ID > ();
            Set< ID > ironDemandDeleteSet = new Set< ID > ();
            for ( Iron_Demand__c iron : newList ) {
                if(iron.isActive__c) {
                    if ( isUpdate ) ironDemandDeleteSet.add(iron.id);
                    if ( String.isNotBlank(iron.category__c)) categorySet.add(iron.category__c);
                    if ( String.isNotBlank(iron.Make__c) ) 	makeSet.add(iron.Make__c);
                    if ( String.isNotBlank(iron.Model__c) )  modelSet.add(iron.Model__c);
                } 
            }
            system.debug('ironDemandDeleteSet---->'+ironDemandDeleteSet);
           
            // delete existing iron demand units which are created through automtion(trigger) whenever iron demand updated.
            if( ironDemandDeleteSet.size() > 0 ){
                List< Iron_Demand_Unit__c > IronDemand_UnitDelete = [SELECT Id FROM Iron_Demand_Unit__c 
                                                                     WHERE Iron_Demand__c IN :ironDemandDeleteSet AND Automation__c=true];
                if( IronDemand_UnitDelete != null && IronDemand_UnitDelete.size() > 0) delete IronDemand_UnitDelete;
            }
            
            // logic to create iron demand units under iron demand and unit whenever matched Product found.
            
            String soql = 'SELECT Id,Starting_Advertised_Retail_Price__c,Hour__c,Year__c ';
               soql += ' FROM Product2 WHERE isActive = true AND Hour__c != NULL AND Starting_Advertised_Retail_Price__c != NULL ';
            if ( categorySet.size() > 0) soql += ' AND Category__c IN :categorySet ';
            if( makeSet.size() > 0) soql += ' AND Manufacturer__c IN :makeSet ';
            if( modelSet.size() > 0) soql += ' AND Model__c IN :modelSet ';
            List< Product2 > productList = database.query(soql);
            
            system.debug('productList====>'+productList);
            if( productList != null && productList.size() > 0) {
                Map< Id,  Iron_Demand_Unit__c > mapOfIronDemandUnit = new Map< Id , Iron_Demand_Unit__c >();
                for( Iron_Demand__c iron : newList ) {
                    if ( iron.isActive__c ) { 
                        for( Product2 pro : productList ) {
                            if( !mapOfIronDemandUnit.containsKey(pro.id) && pro.Hour__c <= iron.Max_Hours__c && pro.Starting_Advertised_Retail_Price__c <= iron.Max_Price__c && pro.Year__c >= iron.Min_Year__c && pro.Year__c <= iron.Max_Year__c) {
                                mapOfIronDemandUnit.put( pro.id, new Iron_Demand_Unit__c( Unit__c=pro.id, Iron_Demand__c=iron.id,Automation__c=true ) );
                            }
                        }
                    }
                }
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
}