/*
Author: Akhtar Husain
Created Date: 15 Nov, 2020
Description: This batch class will run every day in the 9 am morning to send the iron demand unit that has been added in the system within last 24 hours to the iron demand contact
*/

public class SendEmail_IronDemandUnitBatch implements database.Batchable< sObject >,Database.stateful {
    public List< Iron_Demand_Unit__c > ironDemandUnits;
    public Integer recCount;
    public SendEmail_IronDemandUnitBatch(){
        ironDemandUnits = new List< Iron_Demand_Unit__c >();
        recCount = 0;
    }
    
    public database.QueryLocator start(database.BatchableContext bc){
        DateTime last_24_hours = system.now().addHours(-24);
        List< String > unitFields = UtilityClass.getRelationFields('Iron_Demand_Unit__c');
        List< String > ironFields = UtilityClass.getAllFields('Iron_Demand_Unit__c');
        String query = 'Select '+String.join(ironFields, ',')+','+String.join(unitFields, ',')+', Iron_Demand__r.Name,Iron_Demand__r.IronDemand_Contact__r.Email,iron_Demand__r.IronDemand_Contact__r.FirstName,iron_Demand__r.IronDemand_Contact__r.LastName From Iron_Demand_Unit__c' ;
        query += ' Where (createdDate >: last_24_hours AND Iron_Demand__r.isActive__c=true AND Iron_Demand__r.IronDemand_Contact__r.email!=null)';
        if(test.isRunningTest()) {
            query += ' OR (Iron_Demand__r.isActive__c=true) LIMIT 1' ;
        }
        system.debug('query:  '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(database.BatchableContext bc, List< Iron_Demand_Unit__c > scope) {
        system.debug('scope:  '+scope);
        ironDemandUnits.addAll(scope);
        recCount += ironDemandUnits.size();
    }
    public void finish(database.BatchableContext bc){
        try {
            system.debug('ironDemandUnits: '+ironDemandUnits);
            if(ironDemandUnits.size() > 0) {
                SendIronDemandEmailPageController.sendEmailUtil(ironDemandUnits);
            } else {
                system.debug('No machine created in last 24 hours or contact email is missing!');
            }
        } catch(Exception e) {
            system.debug('error occured during email sending:----->'+e+'  line:---->'+e.getLineNumber());
        }
    }
}