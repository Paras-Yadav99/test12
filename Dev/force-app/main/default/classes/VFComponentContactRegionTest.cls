@isTest (seeAllData=true)
private class VFComponentContactRegionTest {

    static testMethod void VFComponentContactContactRegionTest() 
    {

/* Create Contact */


        Test.startTest();
        
        VFComponentContactRegion VFContactRegion = new VFComponentContactRegion();
        
        VFContactRegion.thisContactRegionString = 'Account;darryl seller jung;Contact;Darryl Sell Account;OWA;Collin Magliolo<contactus@zadoon.com>;ClientType;Dealer;ClientRegion;U.S.;Email Template;Monthly Check In';
        
        
        VFContactRegion.getThisContactRegion();
        
        Test.stopTest();
        
    }
}