@isTest
public class CustomLookupControllerTest {
    @TestSetup
    static void makeData(){
        Equipment__c equipment = new Equipment__c();
        equipment.Name = 'Test Equipment';
        equipment.On_Off_Highway__c = 'On Highway';
        equipment.MT_Inventory_Type__c = 'Trailers';
        insert equipment;
    }

    @isTest
    public static void test_fetchRecords(){
        Test.startTest();
        List<CustomLookupController.RecordsData> recordDataList = CustomLookupController.fetchRecords('Equipment__c', 'Model__c', 'Test', '');
        Test.stopTest();
        System.assert(recordDataList.size() > 0);
    }

    @isTest
    public static void test_fetchRecords_failure(){
        Test.startTest();
        List<CustomLookupController.RecordsData> recordDataList;
        String exceptionMessage = '';
        try{
            recordDataList = CustomLookupController.fetchRecords('Equipmen', 'Name', 'Test', '');
        }catch(Exception err){
            exceptionMessage = err.getMessage();
        }
        Test.stopTest();
        System.assert(String.isNotBlank(exceptionMessage));
    }
}