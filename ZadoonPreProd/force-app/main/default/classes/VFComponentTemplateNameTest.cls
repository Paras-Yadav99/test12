@isTest (seeAllData=true)
private class VFComponentTemplateNameTest {

    static testMethod void VFComponentTemplateNameTest() 
    {

        Test.startTest();
        
        VFComponentTemplateName TemplateName = new VFComponentTemplateName();
        
        TemplateName.thisTemplateString = 'Account;darryl seller jung;Contact;Darryl Sell Account;OWA;Collin Magliolo<contactus@zadoon.com>;ClientType;Dealer;ClientRegion;U.S.;Email Template;Monthly Check In';
        
        
        TemplateName.getThisTemplate();
        
        Test.stopTest();
        
    }
}