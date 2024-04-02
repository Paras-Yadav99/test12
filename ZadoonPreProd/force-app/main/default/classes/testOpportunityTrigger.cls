@isTest public class testOpportunityTrigger {
 @isTest  public static void OpportunityTriggerHandlerAfterUnDeleteTest() {
        /*list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
       // insert lstProduct;*/
       // 
       user u = [SELECT Id from user where profile.Name='System Administrator' limit 1];
     //System.runAs(u) { 
         Product2 newUnit = new Product2();
            //newUnit.equipment__c=newEquipment.id;
            newUnit.Name = 'test';
            
               // newUnit.Account__c = newAccount.Id;
            
            
            newUnit.IsActive = true ;
           	newUnit.Purchase_Date__c= System.today().addDays(-180) ;
            newUnit.Inventory_Status__c ='Brokerage';   //Brokerage
            insert newUnit;
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
       // Update standardPricebook;
    // }
		
    
        
    }
    

}