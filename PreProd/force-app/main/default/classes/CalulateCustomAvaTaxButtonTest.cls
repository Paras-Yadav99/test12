@isTest 
public class CalulateCustomAvaTaxButtonTest {
     @testSetup
    public static void CreateTestData(){
        
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        for(Account eachacc : lstAccount){
            eachacc.BillingCity ='Tyler';
            eachacc.BillingCountry ='United States';
            eachacc.BillingPostalCode ='75701';
            eachacc.BillingState ='Texas';
            eachacc.BillingStreet ='1910 East Southeast Loop 323';
        }
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        lstEquipment[0].Manufacturer__c ='Stellar';
        lstEquipment[0].On_Off_Highway__c = 'Off Highway';
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
        for(Product2 eachProduct2 : lstProduct){
            eachProduct2.Serial_Number__c = '123456';
        }
        INSERT lstProduct;
		list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
                    lstOpportunity[0].Pro_Forma_Price_Sent__c = 1232;

        insert lstOpportunity;
    }
    @isTest
    public static void testCalulateCustomAvaTaxButton(){
        map<id,opportunity> mapOfOpp = new map<id,opportunity>([SELECT Id,WTB_Date__c,name,WTB_Priority__c
                                    FROM opportunity]);
        for(opportunity eaxhOpp : mapOfOpp.Values()){
            eaxhOpp.Pro_Forma_Shipping_Cost__c = 123;
            eaxhOpp.Freight_Option__c ='Zadoon';
            eaxhOpp.Shipping_City__c= 'Rewari';
            eaxhOpp.Shipping_Street__c = 'afs';
            eaxhOpp.Shipping_Postal_Code__c = '23643';
            eaxhOpp.Shipping_State__c= 'asga';
            eaxhOpp.Shipping_Country__c= 'asga';
        }
        UPDATE mapOfOpp.Values();
        List<Id> listId = new List<Id>(mapOfOpp.KeySet());
        test.startTest();
        CalulateCustomAvaTaxButton.sendEmailtoUserRequirementContact(listId);
        test.StopTest();
    }
    @isTest
    public static void testCalulateCustomAvaTaxButton1(){
        map<id,opportunity> mapOfOpp = new map<id,opportunity>([SELECT Id,WTB_Date__c,name,WTB_Priority__c
                                    FROM opportunity]);
        for(opportunity eaxhOpp : mapOfOpp.Values()){
            eaxhOpp.Pro_Forma_Shipping_Cost__c = 123;
            eaxhOpp.Freight_Option__c ='Buyer';
        }
        UPDATE mapOfOpp.Values();                          
        List<Id> listId = new List<Id>(mapOfOpp.KeySet());
        test.startTest();
        CalulateCustomAvaTaxButton.sendEmailtoUserRequirementContact(listId);
        test.StopTest();
    }
}