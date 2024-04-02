@isTest
public class UnitRelatedTransactionTrigger_Test {
    
    @testSetup static void setup() {
        Account acc = TestDataFactory.createAccount(true);
        Model__c model = TestDataFactory.createModel(true);
        Equipment__c equip = TestDataFactory.createEquipment(true, model.Id);
        product2 unit = TestDataFactory.createUnit(true, model.Id, Equip.Id);
        Opportunity opp = TestDataFactory.createOpportunity(true,acc.id,unit.id);
        Unit_Related_Transaction__c unitTransaction = TestDataFactory.createUnitRelated(true,opp.id,unit.id);
    }
    
    static testMethod void testTrigger1() {
        Model__c model = TestDataFactory.createModel(true);
        Equipment__c equip = TestDataFactory.createEquipment(true, model.Id);
        product2 pro = TestDataFactory.createUnit(true, model.Id, Equip.Id);
        List<Unit_Related_Transaction__c> unit = [Select id,Transaction_Type__c,Product__c From Unit_Related_Transaction__c Where Transaction_Type__c ='Expense' LIMIT 1];
        if( unit != null ) {
            unit[0].Product__c = pro.id;
            unit[0].Transaction_Type__c = 'Income';
            update unit;
        }
    }
    
    static testMethod void testTrigger2() {
        List<Unit_Related_Transaction__c> unit = [Select id,Transaction_Type__c,Product__c From Unit_Related_Transaction__c Where Transaction_Type__c ='Expense' LIMIT 1];
        if( unit != null ) {
            delete unit;
        }
    }
}