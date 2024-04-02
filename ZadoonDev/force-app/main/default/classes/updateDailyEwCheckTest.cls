@isTest (seeAllData=true)
private class updateDailyEwCheckTest {

    static testMethod void updateDailyEwCheckTest() 
    {

        Test.startTest();
        
       
        String sch = '0 0 1 * * ?';
        
        updateDailyEwCheck sch2 = new updateDailyEwCheck();
        
      
        
        system.schedule('Update EW Price Check', sch, sch2 );
        
                

        
        Test.stopTest();
        
    }

}