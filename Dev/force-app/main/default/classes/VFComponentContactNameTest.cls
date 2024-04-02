@isTest (seeAllData=true)
private class VFComponentContactNameTest {

    static testMethod void VFComponentContactNameTest() 
    {

/* Create Contact */


        Test.startTest();
        
        VFComponentContactName VFContactName = new VFComponentContactName();
        
        VFContactName.thisContactString = 'Account;darryl seller jung;Contact;Darryl Sell Account;OWA;Collin Magliolo<contactus@zadoon.com>';
                
        
        system.debug(VFContactName.thisContactString);
        VFContactName.getThisContact();
        
        Test.stopTest();
        
    }
}