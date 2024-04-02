global class BatchToDeleteInspectionReport implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Status__c FROM Inspection_Report__c where Status__c !="Submitted"';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Inspection_Report__c> inspectionReportList) {
        
        if(inspectionReportList.size() >0){
            delete inspectionReportList;


        }
        
        
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}