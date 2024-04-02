@istest
public class ShowDuplicateRecordOnUnitTest {
    
    @istest
    public static void DuplicateRecordTest(){
        list<Equipment__c> lstEquipment = TestDataFactory.noOfEquipment(1);
        /*Equipment__c newEquipment = new Equipment__c();
        newEquipment.Name = 'Dozer';
        newEquipment.Manufacturer__c = 'smc';
        newEquipment.Base_Del__c = '50';
        newEquipment.Base_New__c = '60';
        newEquipment.On_Off_Highway__c = 'On Highway';
        newEquipment.MT_Inventory_Type__c = 'Trucks';
        insert newEquipment;
        */
        insert lstEquipment;
        
        list<product2> lstProduct = TestDataFactory.noOfUnitsToCreate(2,lstEquipment[0].id);
        insert lstProduct;
        /*
        product2 newProduct = new product2();
        newProduct.Name = 'Test';
        newProduct.Serial_Number__c = '45';
        newProduct.Year__c = '2020';
        newProduct.Make__c = '2021';
        newproduct.Hour__c = 3;
        newProduct.equipment__c = newEquipment.id;
        insert newProduct;
        
		product2 newProduct2 = new product2();
        newProduct2.Name = newProduct.Name;
        newProduct2.Serial_Number__c = newProduct.Serial_Number__c;
        newProduct2.Year__c = newProduct.Year__c;
        newProduct2.Make__c = newProduct.Make__c;
        newproduct2.Hour__c = newproduct.Hour__c;
        newProduct2.equipment__c = newEquipment.id;
        insert newProduct2;
*/
        system.Test.startTest();
        ShowDuplicateRecordOnUnitController.getUnitDuplicateRecord(lstProduct[0].Id);
       /* ShowDuplicateRecordOnUnitController.getDuplicateRecord(newProduct.Id);
        ShowDuplicateRecordOnUnitController.getUnitDuplicateRecord(JSON.serialize(newProduct.Id));
        */
        system.Test.stopTest();
		        
    }
}