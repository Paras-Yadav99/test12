@isTest 
public class inspectionReportMainControllerTest {
    @isTest public static void testInspectionReportMainController() {
        list<Inspection_Report_Header__c> lstInspectionReportHeader = TestDataFactory.createInspectionReportHeader(1,'Backhoe','List',1);
        insert lstInspectionReportHeader;
        
        list<Inspection_Report_Header_Line_Item__c> lstInspectionReportHeaderLineItem = 
                                                                        TestDataFactory.createInspectionReportHeaderLineItem(1,
                                                                                                                        lstInspectionReportHeader[0].id,
                                                                                                                        'Picklist',
                                                                                                                        'Excellent;Fair;Operable, needs work;Inoperable');
 
        insert lstInspectionReportHeaderLineItem;  
         
        list<Inspection_Report_Header__c> lstInspectionReportHeader1 = TestDataFactory.createInspectionReportHeader(1,'Backhoe','Photo',2);
        insert lstInspectionReportHeader1;
        list<Inspection_Report_Header_Line_Item__c> lstInspectionReportHeaderLineItem1 = 
                                                                        TestDataFactory.createInspectionReportHeaderLineItem(1,
                                                                                                                        lstInspectionReportHeader1[0].id,
                                                                                                                        '',
                                                                                                                        '');

        insert lstInspectionReportHeaderLineItem1;

        list<Equipment__c> lstEquipment = TestDataFactory.noOfEquipment(1);                    
        insert lstEquipment;                                                                                            
        list<Product2> lstProduct2 = TestDataFactory.noOfUnitsToCreate(1,lstEquipment[0].id) ;
        insert lstProduct2;
        
        list<Contact> lstContact= TestDataFactory.noOfContactToInsert(1,'test');
        insert lstContact;
        
        test.startTest();
        inspectionReportMainController.setupLineItems(lstInspectionReportHeaderLineItem);
        inspectionReportMainController.getIntialData(lstProduct2[0].id);
        
        inspectionReportMainController.createIntialData(lstProduct2[0].id);
        
        test.stopTest();

    }
    @isTest public static void testInspectionReportMainController1() {
        List<Inspection_Report__c> lstInspectRecord = TestDataFactory.InspectionReportToInsert(1);
        insert lstInspectRecord;
        
        blob file=  Blob.valueOf('sample text');
        
        accWrapper newaccWrapper = new accWrapper();
        newaccWrapper.fileName = 'Test';
        newaccWrapper.Base64 = +file ;
        
        string fileToUpload = JSON.serialize(newaccWrapper);
        test.startTest();
        inspectionReportMainController.uploadFile(fileToUpload,lstInspectRecord[0].id);
        inspectionReportMainController.getIntialData(lstInspectRecord[0].id);
       
        test.stopTest();
    }
    public class accWrapper{
        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public blob Base64;
    }
}