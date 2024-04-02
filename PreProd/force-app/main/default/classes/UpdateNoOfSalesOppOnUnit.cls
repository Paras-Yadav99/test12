public class UpdateNoOfSalesOppOnUnit implements Database.Batchable<sObject> {
	public Database.QueryLocator Start(DataBase.BatchableContext dbc){
        String query ='SELECT id, name, ';
        query +='CreatedAt__c,Number_of_Sales_Opportunities__c, ';
        query +=' (SELECT id, Name  FROM Opportunities__r WHERE ';
        query +='RecordType.Developername =\''+label.Opp_Rec_Type_Inventory_Sell +'\' ';
         query += ' OR RecordType.Developername = \''+ label.Opp_Rec_Type_Broker_Sell + '\'' + ') ';
        query +=' FROM Product2 ';
        
         return Database.getQueryLocator(query);
    }
    public void Execute (Database.BatchableContext dbc , list<Product2>lstProduct2){
        map<id,list<Lead>> mapOfUnitIdVsListOfSalesOpp = new map <id,list<Lead>>();
        list<Product2> lstProduct2Update = new list<Product2>();
  		system.debug('lstOpportunity:'+lstProduct2);
        if(lstProduct2!=null && !lstProduct2.isEmpty()){
            for(Product2 eachUnit : lstProduct2){
                    if(eachUnit.Opportunities__r!=null && !eachUnit.Opportunities__r.isEmpty()){
                        eachUnit.Number_of_Sales_Opportunities__c = eachUnit.Opportunities__r.Size();
                        lstProduct2Update.add(eachUnit);
                    }
                    
                    
                }
            if(lstProduct2Update != null && lstProduct2Update.size()>0){    
                system.debug('lstProduct2'+lstProduct2Update);
                update lstProduct2Update;
                
            }
        }
    }
    public void finish(Database.BatchableContext dbc){
    }
}