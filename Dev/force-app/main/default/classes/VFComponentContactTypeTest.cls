@isTest (seeAllData=true)
private class VFComponentContactTypeTest {

    static testMethod void VFComponentContactTypeTest() 
    {

        Test.startTest();
        
        VFComponentContactType ContactType = new VFComponentContactType();
        
        ContactType.thisContactTypeString = 'Account;darryl seller jung;Contact;Darryl Sell Account;OWA;Collin Magliolo<contactus@zadoon.com>;ClientType;Dealer;ClientRegion;U.S.;Email Template;Monthly Check In';
        
        
        ContactType.getThisContactType();
        
        Test.stopTest();
        
    }
}