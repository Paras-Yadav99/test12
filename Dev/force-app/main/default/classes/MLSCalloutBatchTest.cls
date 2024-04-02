@isTest
public class MLSCalloutBatchTest {
    @isTest
    static void testMethod1(){
        Test.setMock(HttpCalloutMock.class, new MLSCalloutMock());
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;

        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].My_Little_Salesman_Listing__c = 'Advertise';
        insert lstOfProductToAdd;
    }

    @isTest
    static void testMethod2(){
        Test.setMock(HttpCalloutMock.class, new MLSCalloutMock());
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;

        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].My_Little_Salesman_Listing__c = 'Advertise';
        lstOfProductToAdd[0].MLS_Number__c = 29082562;
        lstOfProductToAdd[0].Google_Drive_LInk__c = 'https://drive.google.com/drive/u/0/folders/1hYHhO9vtR9fe4yjTGl-o0PhFm4qoixZM';
        lstOfProductToAdd[0].MLS_Number__c = 29082562;
        insert lstOfProductToAdd;

        Test.startTest();
        MLSCalloutDeleteBatch obj = new MLSCalloutDeleteBatch(new List<Integer>{Integer.valueOf(lstOfProductToAdd[0].MLS_Number__c)});
        Database.executeBatch(obj);
        MLSCalloutHelper.items items = new MLSCalloutHelper.items();
        items.alternateLink = 'test';
        items.webContentLink = 'test';
        items.owners = new List<MLSCalloutHelper.owners>();
        Test.stopTest();

    }

    @isTest
    static void testMethod3(){
        Test.setMock(HttpCalloutMock.class, new MLSCalloutMock());
        list<Equipment__c> lstToAdd = TestDataFactory.noOfEquipment(1);
        insert lstToAdd;

        list<Product2> lstOfProductToAdd = TestDaTaFactory.noOfUnitsToCreate(1,lstToAdd[0].id);
        lstOfProductToAdd[0].My_Little_Salesman_Listing__c = 'Advertise';
        lstOfProductToAdd[0].MLS_Number__c = 29082562;
        insert lstOfProductToAdd;

        Test.startTest();
        MLSCalloutUpdateBatch obj = new MLSCalloutUpdateBatch(new List<Id>{lstOfProductToAdd[0].Id});
        Database.executeBatch(obj);
        Test.stopTest();
    }
}