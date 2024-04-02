@isTest
public class BatchToUpdateAccountBasedOnOppTest {
@isTest
    public static void testBatchToUpdateUnit(){
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1, 'company');
        insert lstAccount;
        list<Equipment__c> lstEquipment= TestDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
        insert lstProduct;
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
        Id oppRecordTypeProcId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Procurement Opportunity').getRecordTypeId();
        lstOpportunity[0].stageName = 'Closed Won';
        lstOpportunity[0].RecordTypeId = oppRecordTypeProcId;
        insert lstOpportunity;
        list<Account> lstNewAccount = TestDataFactory.noOfAccountToInsert(1, 'company');
        insert lstNewAccount;
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Inventory Sell').getRecordTypeId();
        list<Opportunity> lstNewOpportunity = testDataFactory.createOpportunity(1, lstNewAccount[0].id, lstProduct[0].id);
        lstNewOpportunity[0].Seller_Account__c = lstNewAccount[0].id;
        lstNewOpportunity[0].RecordTypeId = oppRecordTypeId;
        lstNewOpportunity[0].stageName = 'Closed Won';
        insert lstNewOpportunity;
        BatchToUpdateAccountBasedOnOpp newInstance = new BatchToUpdateAccountBasedOnOpp();
        test.startTest();
       	
        database.executeBatch(newInstance);
        test.stopTest();    
    }
}