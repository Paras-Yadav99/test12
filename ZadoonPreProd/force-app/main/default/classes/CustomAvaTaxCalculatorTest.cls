@isTest 
public class CustomAvaTaxCalculatorTest {
	//SELECT Id, Account__c, Sales_Tax__c, Shipping_City__c, Shipping_Country__c, Shipping_Postal_Code__c, 
	//Shipping_State__c, Shipping_Street__c, Status__c, Opportunity__c FROM Custom_AvaTax__c
    @isTest public static void testCustomAvaTaxCalculator(){
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,'company');
        insert lstAccount;
        Custom_AvaTax__c newCustomAvaTax = new Custom_AvaTax__c();
        newCustomAvaTax.Shipping_City__c = 'Denver';
            newCustomAvaTax.Shipping_Country__c = 'USA';
            newCustomAvaTax.Shipping_Postal_Code__c= '80202';
            newCustomAvaTax.Shipping_State__c = 'Colorado';
            newCustomAvaTax.Shipping_Street__c = '1125 17th St';
            newCustomAvaTax.Account__c = lstAccount[0].id;
        insert newCustomAvaTax;
        //SELECT Id, Name, Amount__c, Custom_AvaTax__c, Tax__c, Quantity__c, Unit__c FROM AvaTax_Line_Item__c
        //
        list<Equipment__c> lstEquipment = TestDataFactory.noOfEquipment(1);
       insert lstEquipment;
       list<Product2> lstProduct = TestDataFactory.noOfUnitsToCreate(1,lstEquipment[0].id);
       lstProduct[0].isActive = false;
       lstProduct[0].Unit_Stage__c = 'Reviewing';
      // lstProduct[0].On_Zadoon_partner_yard1__c =  lstYards[0].id;
       insert lstProduct;
        AvaTax_Line_Item__c newAvaTaxLineItem = new AvaTax_Line_Item__c ();
        newAvaTaxLineItem.Name = 'Tesrt';
        newAvaTaxLineItem.Quantity__c = '1';
        newAvaTaxLineItem.Amount__c = 100;
        newAvaTaxLineItem.Unit__c = lstProduct[0].id;
        insert newAvaTaxLineItem;
        
        set<Id> setAvataxId = new set<Id>();
        setAvataxId.add(newCustomAvaTax.Id);
        
       /* PageReference pageRef = Page.AvaTaxCalculator;
        pageRef.getParameters().put('id', newCustomAvaTax.Id);
        system.debug('pageRef:::'+pageRef);
        //Test.setCurrentPage(pageRef);
         CustomAvaTaxCalculator.AvaTaxId= newCustomAvaTax.id;
        CustomAvaTaxCalculator creditNoteTaxCalc = new CustomAvaTaxCalculator();
        */
        test.starttest();
        Database.executeBatch(new CalculateCustomAvaTaxBatchClass(setAvataxId), 1);
       // creditNoteTaxCalc.calculateTaxButton();
        test.StopTest();
    }
}