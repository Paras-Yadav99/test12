@isTest (seeAllData=true)
private class VFEmailSignatureTest {

    static testMethod void VFEmailSignatureTest() 
    {

/* Create Contact */


        Test.startTest();
        
        VFEmailSignature EmailSignature = new VFEmailSignature();
        
        EmailSignature.thisUserFirstName = 'Collin';
                
        
       
        EmailSignature.getThisUserInfo();
        
        Test.stopTest();
        
    }
}