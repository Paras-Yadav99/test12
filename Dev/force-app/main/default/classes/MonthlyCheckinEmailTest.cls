@isTest (seeAllData=true)
private class MonthlyCheckinEmailTest {

    static testMethod void MonthlyCheckinEmailTest() 
    {

        
        
               Test.startTest();
        
        // Create Account 
        Account account = new Account(Name='Test Account');
        insert account;
        
        
        Equipment__c equipment = new Equipment__c(Manufacturer__c = 'Darryl Test Make', On_Off_Highway__c = 'On Highway', Base_New__c = 'Darryl Test Model', Name = 'Test Equipment', MT_Inventory_Type__c = 'Trailers');
        insert equipment;
        
        // Create Unit 
        Product2 ZIDs = new Product2(name='test product', equipment__c = equipment.Id, account__c =account.id, CreatedAt__c = Date.today().addDays(-30));
        insert ZIDs;
 
        // Create Contact 
        Contact clist = new Contact(LastName='ContTest1', email='djung@atlassoftwaregroup.com', AccountId = account.Id, Primary_Contact__c = true);
        insert clist;
        
        account.Primary_Contact__c = clist.id;
        update account;

               
        String sch = '0 0 1 * * ?';
        
        MonthlyCheckinEmail sch1 = new MonthlyCheckinEmail();

        sch1.isTest = 0;
        
        sch1.startdt = null;
        sch1.enddt = null;
        sch1.GetMonthlyCheckinEmail();
        sch1.GetRecordPage();
        
        sch1.startdt = date.newinstance(2017, 7, 1);
        sch1.enddt = date.newinstance(2017,7,13);
        sch1.GetMonthlyCheckinEmail();
        
        sch1.isTest = 1;
        sch1.startdt = date.newinstance(2017, 7, 13);
        sch1.enddt = date.newinstance(2017,7,1);
        sch1.GetMonthlyCheckinEmail();  

        sch1.startdt = date.newinstance(2017, 7, 1);
        sch1.enddt = date.newinstance(2017,7,2);
        sch1.GetMonthlyCheckinEmail();  
        
        sch1.enddt = date.newinstance(2017,7,3);
        sch1.GetMonthlyCheckinEmail();  
        
        sch1.enddt = date.newinstance(2017,7,4);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,5);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,6);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,7);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,8);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,9);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,10);
        sch1.GetMonthlyCheckinEmail(); 

        sch1.enddt = date.newinstance(2017,7,11);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,12);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,13);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,14);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,15);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,16);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,17);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,18);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,19);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,20);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,21);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,22);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,23);
        sch1.GetMonthlyCheckinEmail(); 
        
        
        sch1.enddt = date.newinstance(2017,7,24);
        sch1.GetMonthlyCheckinEmail(); 
        
        
        sch1.enddt = date.newinstance(2017,7,25);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,26);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,27);
        sch1.GetMonthlyCheckinEmail(); 
        
        
        sch1.enddt = date.newinstance(2017,7,28);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,29);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,30);
        sch1.GetMonthlyCheckinEmail(); 
        
        sch1.enddt = date.newinstance(2017,7,31);
        sch1.GetMonthlyCheckinEmail(); 
        
  
        system.schedule('Daily Send Checkin Emails', sch, sch1 );   
                  
        Test.stopTest();
        
    }

}