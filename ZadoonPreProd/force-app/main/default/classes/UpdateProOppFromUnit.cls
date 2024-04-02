public class UpdateProOppFromUnit implements database.Batchable<sObject>{
	public Database.QueryLocator Start(DataBase.BatchableContext bc){
		String query = 'SELECT Id,Iron_Connect_listing__c, Starting_Advertised_Retail_Price__c,';
                     query += '             Old_SF_Unit_Details__c,Confidential_Information_Notes__c,Inventory_Status__c,';
                     query += '            (SELECT Id, Name, Iron_Connect_listing__c , Starting_Advertised_Retail_Price__c,';
                    query += '             Confidential_Information_Notes__c,Unit_Details__c,recordTypeId,recordType.DeveloperName';
                      query += '            FROM Opportunities__r ';
                      query += '            WHERE recordTypeId =\'0123u0000019nWbAAI\') FROM Product2';
        return Database.getQueryLocator(query);
    }
    public void Execute (Database.BatchableContext dbc , list<Product2>lstUnit){
        list<Opportunity>lstOpportunity = new list<Opportunity>();
        system.debug('lstUnit:'+lstUnit);
        if(lstUnit!=null && !lstUnit.isEmpty()){
            for(Product2 eachUnit : lstUnit){
                if(eachUnit.Opportunities__r!=null && !eachUnit.Opportunities__r.isEmpty()){
                    for(Opportunity eachOpportunity : eachUnit.Opportunities__r){
                        eachOpportunity.Starting_Advertised_Retail_Price__c = eachUnit.Starting_Advertised_Retail_Price__c;
                        eachOpportunity.Confidential_Information_Notes__c = eachUnit.Confidential_Information_Notes__c;
                        eachOpportunity.Unit_Details__c = eachUnit.Old_SF_Unit_Details__c;
                        lstOpportunity.add(eachOpportunity);
                    }
                }
            }
            if(lstOpportunity!=null && !lstOpportunity.isEmpty()){
                 update lstOpportunity;
            }
           
        }
    }
    public void finish(Database.BatchableContext dbc){
        system.debug('Success : Task Creation Success');
    }
}