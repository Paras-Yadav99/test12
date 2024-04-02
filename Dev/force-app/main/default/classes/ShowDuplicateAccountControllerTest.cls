/*
* This Class is used to Test "UsageProductTrackerTableController".
*/
@isTest
public class ShowDuplicateAccountControllerTest {

    @isTest
    static void testGetUsageProductTracker_Success() {
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(2,'TestKizzy');
        insert lstAccount;
        Test.startTest();
        // Call the method to test
        ShowDuplicateAccountController.AuraResponse response = ShowDuplicateAccountController.getDuplicateAccounts(lstAccount[0].Id);
        Test.stopTest();

        // Assert the response
        System.assertEquals(true, response.isSuccess);
        System.assertEquals('SUCCESS', response.message);
        System.assertNotEquals(null, response.response);

    }

    @isTest
    static void testGetUsageProductTracker_Error() {
        Test.startTest();
        // Call the method to test with empty recordId
        ShowDuplicateAccountController.AuraResponse response = ShowDuplicateAccountController.getDuplicateAccounts(null);
        Test.stopTest();

        // Assert the error response
        System.assertEquals(false, response.isSuccess);
        System.assertEquals('ERROR', response.message);
        System.assertEquals('RecordId Not found!', response.response);
    }
      @isTest
    static void testGetUsageProductTracker_Catch() {
        String key = 'aAD530000004Test';
        Test.startTest();
        // Call the method to test with incorrect recordId
        ShowDuplicateAccountController.AuraResponse response = ShowDuplicateAccountController.getDuplicateAccounts(key);
        Test.stopTest();

        // Assert the error response
        System.assertEquals(false, response.isSuccess);
        System.assertEquals('ERROR', response.message);
    }
}