@isTest (seeAllData=true)
private class updateOwnUnitContactDateTest {

    static testMethod void updateOwnUnitContactDateTest() 
    {

        Test.startTest();
        
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1); 
        String ss = String.valueOf(Datetime.now().second());
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        updateOwnUnitContactDate s = new updateOwnUnitContactDate(); 
        System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
                
        
        Test.stopTest();
        
    }

}