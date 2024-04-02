public with sharing class ProductTriggerHelper {
    
    public class myException extends Exception {}
    
    /*public static void createPriceBookEntry(List < Product2 > productList){
        List < PricebookEntry > pbEntry = new List < PricebookEntry > ();
        List<sObject> pb = [select ID from Pricebook2 where IsStandard = TRUE LIMIT 1];
        
        for (Product2 newProduct: productList) {
            if(pb != null && pb.size() > 0){
                pbEntry.add(new PricebookEntry(Pricebook2Id=pb[0].ID,Product2Id=newProduct.ID, 
                                               UnitPrice=0.00, IsActive=TRUE, 
                                               UseStandardPrice=FALSE));
            }
        }
        if(pbEntry.size() >0 ) insert pbEntry;
    }*/
    
    // populate Equipment model to unit model
    public static void populateEquipmentModel( List< Product2 > newList ) {
        Map< ID, Product2 > productMap = new Map< ID, Product2 >([Select id,Model_Unit__c,equipment__r.Model_Equipment__c From Product2 Where ID IN : newList]);
        for( Product2 unit : newList) {
            if( productMap.containsKey(unit.id) && productMap.get(unit.id).equipment__r.Model_Equipment__c != null)
                unit.Model_Unit__c = productMap.get(unit.id).equipment__r.Model_Equipment__c;
        }
    }
    
    /* 1. This method is used to create Iron Demand unit records whenever units/products created/updated in the org.
* 2. Unlink existing iron demand units under units and link new iron demand units if any iron demand found with matching units.
* 3. Remove iron demand units under unit whenever unit deactivated.
*/
    public static void createMatchingIronDemandUnits( List <Product2 > newList, Map< Id, Product2 > oldMap, boolean isUpdate, boolean isInsert) {
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
            system.debug('unitIdSet---->'+unitIdSet);
            
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
    public static void createMatchingIronDemandUnits1( List <Product2 > newList, boolean isUpdate) {
        try {
            Set< String > categorySet = new Set< String > ();
            Set< String > makeSet = new Set< String > ();
            Set< String > modelSet = new Set< String > ();
            set< String > yearSet = new Set< String > ();
            //Set< ID > unitIdSet = new Set< ID > ();
            //Set< ID > unitDeleteSet = new Set< ID > ();
            for ( Product2 pro : newList ) {
                if(pro.IsActive) {
                    //if ( isUpdate ) unitDeleteSet.add(pro.id);
                    if ( String.isNotBlank(pro.category__c)) categorySet.add(pro.category__c);
                    if ( String.isNotBlank(pro.Make__c) ) 	makeSet.add(pro.Make__c);
                    if ( String.isNotBlank(pro.Model__c) )  modelSet.add(pro.Model__c);
                    if ( String.isNotBlank(pro.Year__c) )   yearSet.add(pro.Year__c);
                } /*else if( !pro.IsActive && isUpdate ) {
                    unitIdSet.add(pro.id);
                }*/
            }
            //system.debug('unitIdSet---->'+unitIdSet);
            
            // delete all the existing iron demand units from unit whenever units deactivated.
            /*if( unitIdSet.size() > 0) { 
                List< Iron_Demand_Unit__c > IronDemand_Unit = [SELECT Id FROM Iron_Demand_Unit__c WHERE Unit__c IN :unitIdSet];
                if( IronDemand_Unit != null && IronDemand_Unit.size() > 0) delete IronDemand_Unit;
            }*/
            
            // delete existing iron demand units which are created through automtion(trigger) whenever unit updated.
            /*if(unitDeleteSet.size() > 0){
                List< Iron_Demand_Unit__c > IronDemand_UnitDelete = [SELECT Id FROM Iron_Demand_Unit__c WHERE Unit__c IN :unitDeleteSet AND Automation__c=true];
                if( IronDemand_UnitDelete != null && IronDemand_UnitDelete.size() > 0) delete IronDemand_UnitDelete;
            }*/
            
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
}