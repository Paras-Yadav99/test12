@isTest (seeAllData=true)
private class VFComponentOrgWideEmailAddressTest {

    static testMethod void VFComponentOrgWideEmailAddressTest() 
    {

        Test.startTest();
        VFComponentOrgWideEmailAddress VFOWA = new VFComponentOrgWideEmailAddress();
        
        VFOWA.thisOWASender = 'Account;darryl seller jung;Contact;Darryl Sell Account;OWA;Collin Magliolo<contactus@zadoon.com>';
        
        VFOWA.getThisOWA();
        
        Test.stopTest();
        
    }
}