@isTest(seealldata=true )
private class thisOppZidsControllerTest {

    static testMethod void thisOppZidsControllerTest() 
    {

        Test.startTest();

        // Create Account 
        thisOppZidsController OppZid = new thisOppZidsController();
        OppZid.thisOppId = '0066A000002U0ot';
        
        OppZid.getThisOppZids();
        
        
        Test.stopTest();
        
    }
    
}