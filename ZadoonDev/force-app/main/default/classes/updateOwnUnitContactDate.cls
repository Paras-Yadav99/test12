global class updateOwnUnitContactDate Implements Schedulable {

    List<Product2> productToUpdate;

    global void execute(SchedulableContext sc) {
      
      
        // Update account Acme2.
        productToUpdate = 
            [SELECT Id, Name, Last_Equipment_Status_Confirmation__c FROM Product2 
             WHERE Account__r.Name='Zadoon, LLC' AND Inventory_Status__c = 'Owned' ];
        // Update the billing city.
        
        for(Product2 prod :productToUpdate){
            prod.Last_Equipment_Status_Confirmation__c = Date.today();
        }
        
        // Make the update call.
        update productToUpdate;

      
    }

}