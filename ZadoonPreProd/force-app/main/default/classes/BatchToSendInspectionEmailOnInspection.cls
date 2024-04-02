/*
This Batch Class is used to send the Inspection Email to the Inspector CC: Melissa on the Day of inspection.
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          16-Aug-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/
public class BatchToSendInspectionEmailOnInspection implements Database.Batchable<sObject> {
    
    public Database.QueryLocator Start(DataBase.BatchableContext dbc){
        //String Opp_Rec_type_Dev_Name_procurement_opp =System.Label.Opp_Rec_type_Dev_Name_procurement_opp;
        // get query from controller
        Date today = System.today();
        String query = 'SELECT Id, Name, Inspecion_Status__c, Inspecion_Account__c, Inspection_Inspector__c,'+
            'Inspection_Inspector__r.Name, Inspection_Inspector__r.Email, Unit__c,Unit__r.make__c,Unit__r.Year__c,'+
            'Unit__r.model__c,Unit__r.Storage_City__c,Unit__r.Storage_State__c,Unit__r.Manufacturer__c,'+
            '  Quote_Amount__c, Inspection_Date__c FROM Unit_Inspection__c '+
            'WHERE Inspection_Date__c = :today';

        system.debug(Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
        
    } 
    public void Execute (Database.BatchableContext dbc , list<Unit_Inspection__c>lstUnitInspections){
  		system.debug('lstUnits:'+lstUnitInspections);
        if(lstUnitInspections!=null && !lstUnitInspections.isEmpty()){
        	BatchToSendInsEmailOnInsDayCtrl.handleExecution(lstUnitInspections);
        }
    }
        public void finish(Database.BatchableContext dbc){
            system.debug('Success : Ispection Emails are send Successfull!!');
        }
    }