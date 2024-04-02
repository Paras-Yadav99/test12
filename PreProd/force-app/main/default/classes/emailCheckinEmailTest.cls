@isTest (seeAllData=true)
private class emailCheckinEmailTest {
/* 
    static testMethod void emailCheckinEmailTest() 
    {


        
        //  Create Account 
        Account account = new Account(Name='Test Account');
        insert account;
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', Base__c = 'Darryl Test Model', Name = 'Test Equipment');
        insert equipment;
        
        // Create Unit 
        Product2 ZIDs = new Product2(name='test product', equipment__c = equipment.Id, account__c =account.id, CreatedAt__c = Date.today().addDays(-30));
        insert ZIDs;
 
        // Create Contact 
        Contact clist = new Contact(LastName='ContTest1', email='djung@atlassoftwaregroup.com', AccountId = account.Id, Primary_Contact__c = true);
        insert clist;
        
        account.Primary_Contact__c = clist.id;
        update account;
        
        
               Test.startTest();
               
        String sch = '0 0 1 * * ?';
        
        emailCheckinEmail sch1 = new emailCheckinEmail();
        
        system.schedule('Daily Send Checkin Emails', sch, sch1 );

        
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 13), 1);  
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 13), date.newinstance(2017, 7, 1), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 2), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 1), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 3), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 4), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 5), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 6), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 7), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 8), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 9), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 10), 0);
      emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 11), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 12), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 14), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 15), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 16), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 17), 0);        
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 18), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 19), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 20), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 21), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 22), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 23), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 24), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 25), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 26), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 27), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 28), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 29), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 30), 0);
        emailCheckinEmail.EmailCheckinMethod(date.newinstance(2017, 7, 1), date.newinstance(2017, 7, 31), 0);
  
        Test.stopTest();
        
    }
*/
}