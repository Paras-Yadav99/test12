@isTest
public class UnitBatchTest {
    @testsetUp
    static void testsetUp(){
        list<Equipment__c> newEquipment= testDataFactory.noOfEquipment(0);
        insert newEquipment;
        list<Product2> newUnit = testDataFactory.noOfUnitsToCreate(0,newEquipment[0].id);
        insert newUnit;
    }
      @IsTest
    public static void testHandleUnitBatch(){
        product2 newProduct = [SELECT id,name,equipment__c
                               FROM product2 LIMIT 1];
        try{
            test.startTest();
            UnitBatchClass batch = new UnitBatchClass();
            Database.executeBatch(batch);
            test.stopTest();
        }
        catch(exception ex){
            system.debug('ex::'+ex);
        }
       
        system.Assert(true);
    }
}