@isTest
public class sendInspectionEmailControllerTest {
    @istest public static void testInspectionEmail(){
        list<Equipment__c> lstEquipment = TestDataFactory.noOfEquipment(1);                    
        insert lstEquipment;                                                                                            
        list<Product2> lstProduct2 = TestDataFactory.noOfUnitsToCreate(1,lstEquipment[0].id) ;
        insert lstProduct2;
        list<Inspection_Report__c> lstInspectionReport = TestDataFactory.InspectionReportToInsert(1) ;
         insert lstInspectionReport;
       	
		list<contact> lstContact1 = TestDataFactory.noOfContactToInsert(1,'fc'); 
        insert lstContact1;
        list<String> lstContactId = new list<String>();
        for(contact eachcontact : lstContact1 ){
            lstContactId.add(eachcontact.id);
        }
        list<string> lstId = new list<string>();
        test.startTest();
        sendInspectionEmailController.sendEmailToUser('paras.yadav@kizzyconsulting.com' ,lstProduct2[0].id, lstId);
        sendInspectionEmailController.sendEmailToUser('' ,lstProduct2[0].id,lstContactId);
        sendInspectionEmailController.sendEmailToUser('paras.yadav@kizzyconsulting.com' ,lstInspectionReport[0].id,lstContactId);
        //sendInspectionEmailController.sendEmailToUser('' ,lstProduct2[0].id,lstContactId);
        sendInspectionEmailController.getContactData('fc');
        sendInspectionEmailController.getUnitData(lstProduct2[0].id);
        
        sendInspectionEmailController.getUnitData('');
        test.stopTest();
    }
     @istest public static void testInspectionEmail1(){
         
         
         list<String> lstContactId = new list<String>();
         
         
     }
}