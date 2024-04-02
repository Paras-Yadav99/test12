@isTest
public class CustomLeadConvertControllerTest {
    @isTest public static void testLeadConvertController(){
        list<Lead> lstLead = TestDataFactory.noOfLeadToInsert(1,'24241412414');
        insert lstLead;
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(1,lstLead[0].Company);
        insert lstAccount;
        list<contact>lstContact = TestDataFactory.noOfContactToInsert(1,lstLead[0].LastName);
        insert lstContact;
        test.startTest();
        CustomLeadConvertController.leadConvertController(lstLead[0].id);
        list<string> lstClientRegion = new list<string>{'Africa'};
        list<string> lstAuthorizedDealerFor = new list<string>{'Advance'};
        CustomLeadConvertController.createAccount('company','ClientType',lstClientRegion , lstAuthorizedDealerFor,'435467473');
        CustomLeadConvertController.createContact( 'firstName','lastName', lstAccount[0].id, '2435465');
        CustomLeadConvertController.getAccountData('Kizzy123');
        CustomLeadConvertController.getContactData('Test');
        CustomLeadConvertController.leadConverter(lstLead[0].id,lstAccount[0].id,lstContact[0].id);
        test.stopTest();
     }
    @isTest public static void testLeadConvertController1(){
        list<Lead> lstLead = TestDataFactory.noOfLeadToInsert(1,'24241412414');
        insert lstLead;
        list<Account> lstAccount = TestDataFactory.noOfAccountToInsert(3,lstLead[0].Company);
        insert lstAccount;
        list<contact>lstContact = TestDataFactory.noOfContactToInsert(2,lstLead[0].LastName);
        insert lstContact;
        test.startTest();
        CustomLeadConvertController.leadConvertController(lstLead[0].id);
        test.stopTest();
     }
}