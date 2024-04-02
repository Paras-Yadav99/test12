@isTest
public class CaseTriggerTest {
    @isTest public static void testAfterInsert(){
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
        insert lstProduct;
        list<Case> lstCase = testDataFactory.noOfCasesToInsert(1, lstProduct[0].id);
        
        test.startTest();
        insert lstCase;
        test.stopTest();
    }
    @isTest public static void testAfterUpdate(){
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(2, lstEquipment[0].id, lstAccount[0].id);
        insert lstProduct;
        list<Case> lstCase = testDataFactory.noOfCasesToInsert(1, lstProduct[0].id);
        insert lstCase;
        for(Case eachCase : lstCase){
            eachCase.UnitCase__c = lstProduct[1].id ;
        }
        test.startTest();
        update lstcase;
        test.stopTest();
    }
}