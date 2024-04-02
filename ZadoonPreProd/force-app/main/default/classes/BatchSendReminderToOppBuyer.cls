public class BatchSendReminderToOppBuyer implements Database.Batchable<sObject> {
    
    public Database.QueryLocator Start(DataBase.BatchableContext dbc){
        Date YesterDay = System.today().addDays(-1);
        String newValue = 'Waiting for Buyer\'s Wire';
        
        String query = 'SELECT Id, Field, DataType, OldValue, NewValue, CreatedDate, OpportunityId, ' +
            'Opportunity.OwnerId, Opportunity.Owner.Email, Opportunity.Buyer_Contact_Email__c, ' +
            'Opportunity.Primary_Contact_First_Name__c ' +
            'FROM OpportunityFieldHistory ' +
            'WHERE CreatedDate <= ' + YesterDay.year() + '-' + YesterDay.month() + '-' + YesterDay.day() + 'T00:00:00Z ' +
            'AND Field = \'StageName\' AND NewValue = newValue' +  // Assuming 'stagename' is the API name of the field
            'ORDER BY CreatedDate DESC ';
        
        System.debug(Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
        
    } 
    public void Execute (Database.BatchableContext dbc , list<OpportunityFieldHistory>lstUnitInspections){
  		system.debug('lstUnits:'+lstUnitInspections);
        if(lstUnitInspections!=null && !lstUnitInspections.isEmpty()){
        	BatchSendReminderToOppBuyerCtrl.handleExecution(lstUnitInspections);
        }
    }
        public void finish(Database.BatchableContext dbc){
            system.debug('Success : Reminder Emails are send Successfull!!');
        }
    
    
    
    }