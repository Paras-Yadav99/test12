public class UpdateNoOfCasesOnUnit implements Database.Batchable<sObject> {
	public Database.QueryLocator Start(DataBase.BatchableContext dbc){
        String query ='SELECT id, name, ';
        query +='CreatedAt__c,Number_of_cases__c, ';
        query +=' (SELECT id, UnitCase__c  FROM Cases__r ) ';
        
        query +=' FROM Product2 ';
        
         return Database.getQueryLocator(query);
    }
    public void Execute (Database.BatchableContext dbc , list<Product2>lstProduct2){
        
        list<Product2> lstProduct2Update = new list<Product2>();
  		system.debug('lstOpportunity:'+lstProduct2);
        if(lstProduct2!=null && !lstProduct2.isEmpty()){
            for(Product2 eachUnit : lstProduct2){
                    if(eachUnit.Opportunities__r!=null && !eachUnit.Opportunities__r.isEmpty()){
                        eachUnit.Number_of_cases__c = eachUnit.Opportunities__r.Size();
                        lstProduct2Update.Add(eachUnit);
                    }
            }
        }
        
        if(lstProduct2Update != null && lstProduct2Update.size()>0){    
                system.debug('lstProduct2'+lstProduct2Update);
                update lstProduct2Update;
                
            }
        
    }
    public void finish(Database.BatchableContext dbc){
    }
}