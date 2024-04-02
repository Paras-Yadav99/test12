@isTest (seeAllData=true)
private class VFComponentAccountNameTest {

    static testMethod void VFComponentAccountNameTest() 
    {

/* Create Contact */


        Test.startTest();
        
        
        
        VFComponentAccountName VFAccountName = new VFComponentAccountName();
        
        VFAccountName.thisAccountString = 'Account;darryl seller jung;Contact;Darryl Sell Account;OWA;Collin Magliolo<contactus@zadoon.com>';
        
        system.debug(VFAccountName.thisAccountString);
        VFAccountName.getThisAccount();
        
        Test.stopTest();
        
    }
}