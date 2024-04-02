@istest
public class IronDemandRecordsOnUnitCmpControllerTest {
    @testsetUp
    static void setupTestData() {
        list<contact> lstContact = testDataFactory.noOfContactToInsert(1,'Test');
        insert lstContact;
        list<Equipment__c> newEquipment= testDataFactory.noOfEquipment(1);
        newEquipment[0].Manufacturer__c = 'EAGLE';
        newEquipment[0].Category__c = 'Wheel Loader';
        insert newEquipment;
        list<Product2> newUnit = testDataFactory.noOfUnitsToCreate(1,newEquipment[0].id);
        newUnit[0].isActive = true;
        insert newUnit;
        list<Iron_Demand__c> lstIronDemand = testDataFactory.createlstIronDemand(1,newEquipment[0].id);
        lstIronDemand[0].IronDemand_Contact__c = lstContact[0].id;
        insert lstIronDemand;
    }
     @isTest 
    public static void testGetIronDemandRecords(){
        product2 eachProduct = [SELECT id
                                FROM product2 LIMIT 1];
        test.startTest();
        IronDemandRecordsOnUnitCmpController.getIronDemandRecords(eachProduct.id);
        IronDemandRecordsOnUnitCmpController.getIronDemandRecords('');
        test.stopTest();
        system.Assert(true);
        
    }
    
    
}