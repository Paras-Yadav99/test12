public class CalculateCustomAvaTax {
	@future(callout=true)
    public static void executeAsyncCall(set<id> setCustomAvaTax) {
        list <Custom_AvaTax__c> lstCustomAvaTax = [SELECT Id, Name, Account__c, Sales_Tax__c, 
                                                   Shipping_City__c, Shipping_Country__c,
                                                   Shipping_Postal_Code__c, Shipping_State__c,
                                                   Shipping_Street__c, Status__c, Opportunity__c 
                                                   FROM Custom_AvaTax__c
                                                  WHERE ID IN : setCustomAvaTax];
        for(Custom_AvaTax__c eachCustomAvaTax : lstCustomAvaTax ){
                    CustomAvaTaxCalculator.AvaTaxId= eachCustomAvaTax.id;
                    CustomAvaTaxCalculator.calculateTax();
                }
    }
}