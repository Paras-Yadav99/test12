@isTest
public class ConvertCaseToLeadsBatchTest {
    @isTest
    public static void tstMethod1(){

        Contact con = new Contact(
        	LastName = 'Test Contact',
            Email = 'Test@email.com',
            MailingPostalCode = '123',
            MailingCountry = 'United States',
            MailingState = 'California'
        );
        insert con;
        
        Case caseObj = new Case();
        caseObj.ContactId = con.Id;
        caseObj.Description = 'Test Desc';
        caseObj.Subject = 'Test Subject';
        caseObj.Status = 'New';
        caseObj.Origin = 'Email';
        caseObj.SuppliedName = 'Test Name';


        insert caseObj;

        Test.startTest();
        Database.executeBatch(new ConvertCaseToLeadsBatch());
        Test.stopTest();
        caseObj = [SELECT Id, Is_Processed__c FROM Case LIMIT 1];
        System.assertEquals(true, caseObj.Is_Processed__c);
    }
}