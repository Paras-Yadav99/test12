public class CalculateCustomAvaTaxBatchClass implements Database.Batchable<SObject>, Database.AllowsCallouts  {
    private Set<Id> recordIds;

    // Constructor to accept a set of Ids as a parameter
    public CalculateCustomAvaTaxBatchClass(Set<Id> recordIds) {
        this.recordIds = recordIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Your query logic goes here using the set of Ids
        String query = 'SELECT Id, Name, Account__c, Sales_Tax__c, ';
        query += ' Shipping_City__c, Shipping_Country__c,';
        query += ' Shipping_Postal_Code__c, Shipping_State__c,';
        query += ' Shipping_Street__c, Status__c, Opportunity__c ';
        query += ' FROM Custom_AvaTax__c';
        query += ' WHERE ID IN : recordIds';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Custom_AvaTax__c> lstCustomAvaTax) {
        
        for (Custom_AvaTax__c eachCustomAvaTax : lstCustomAvaTax) {
            // Perform actions on each record
            CustomAvaTaxCalculator.AvaTaxId= eachCustomAvaTax.id;
            CustomAvaTaxCalculator.calculateTax();
        }
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('batch executed');
    }
}