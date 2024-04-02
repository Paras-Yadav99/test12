@isTest
public class CreateUnitsControllerTest {
    @TestSetup
    static void makeData(){
        Account acc = new Account();
        acc.name = 'Test Account';
        insert acc;

        Equipment__c equipment = new Equipment__c();
        equipment.Name = 'Test Equipment';
        equipment.On_Off_Highway__c = 'On Highway';
        equipment.MT_Inventory_Type__c = 'Trailers';
        insert equipment;
    }

    @isTest
    public static void test_saveUnits(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Equipment__c equipment = [SELECT Id FROM Equipment__c LIMIT 1];
        List<CreateUnitsController.unitWrapper> wrapperList = new List<CreateUnitsController.unitWrapper>();
        CreateUnitsController.unitWrapper wrapper = new CreateUnitsController.unitWrapper();
        CreateUnitsController.objWrapper accObjWrapper = new CreateUnitsController.objWrapper();
        CreateUnitsController.objWrapper equipObjWrapper = new CreateUnitsController.objWrapper();
        CreateUnitsController.objWrapper unitObjWrapper = new CreateUnitsController.objWrapper();
        unitObjWrapper.value = UserInfo.getUserId();
        accObjWrapper.value = acc.Id;
        equipObjWrapper.value = equipment.Id;
        wrapper.accObj = accObjWrapper;
        wrapper.userObj = unitObjWrapper;
        wrapper.year = '2022';
        wrapper.active = true;
        wrapper.storageState = 'Florida';
        wrapper.storageCity = 'Tallahassee';
        wrapper.equipObj = equipObjWrapper;
        wrapperList.add(wrapper);
        String strWrapper = JSON.serialize(wrapperList);
        Product2 unit = new Product2();
        List<CreateUnitsController.customValueWrapper> picklistWrapper = CreateUnitsController.pickListValueDynamically(unit, 'Unit_Stage__c');
        Test.startTest();
        List<Product2> unitList = CreateUnitsController.saveUnits(strWrapper);
        Test.stopTest();
        System.assert(unitList.size() > 0);
    }
}