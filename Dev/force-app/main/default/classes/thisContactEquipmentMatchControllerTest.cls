@isTest(seealldata=true )
private class thisContactEquipmentMatchControllerTest {

    static testMethod void thisContactEquipmentMatchControllerTest() 
    {

        Test.startTest();

        // Create Account 
        thisContactEquipmentMatchController ContactEquipment = new thisContactEquipmentMatchController();
        ContactEquipment.thisContactId = '00Q6A000004ZU0S';
        
        ContactEquipment.getThisContactZids();
        
        
        Test.stopTest();
        
    }
    
}