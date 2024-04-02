// Batch to Create task for the Units Which have any of market checkBox is Unchecked or having any null field for URLs

public class BatchCreateTaskonUnits implements Database.Batchable<sObject> {
    
    public Database.QueryLocator Start(DataBase.BatchableContext dbc){
        String Opp_Rec_type_Dev_Name_procurement_opp =System.Label.Opp_Rec_type_Dev_Name_procurement_opp;
        // get query from controller
        String query = 'SELECT Id,Name,Unit_Owner__c,Inventory_Status__c,'+  
                                  'Marketed_On_Mascus__c,Marketed_On_FB_Marketplace__c,Marketed_On_Construction_Equip_Guide__c, MT_Back_End_Link__c,'+ 
                                  'Marketed_On_Craigslist__c,Marketed_On_Machinio__c,Marketed_on_MT_incl_Crane_Trk__c,Marketed_On_MyLittleSalesman__c,'+ 
                                  'Marketed_On_Terrapoint__c,Marketed_On_TradeMachines__c,Marketed_On_Used_Equip_Guide__c,Marketed_On_LinkedIn__c,Marketed_On_Instagram__c,'+
                                  'Sourced_From_Link__c,FB_Marketplace_Live_Link__c,RentalYard_Link__c,LinkedIn_Post_Link__c,FB_Post_Link__c,Marketed_on_Facebook__c,'+ 
                                  'Mailchimp_Link__c,Craigslist_Live_Listing__c,Craigslist_Back_End_Link__c ,Equipment_Trader_Live_Link__c,MyLittleSalesman_Live_Link__c,'+ 
                                  'RitchieList_Live_Link__c,Mascus_Live_Link__c,Machinio_Live_Link__c,Override_Post_Construction_Equip_Gui__c, Override_Post_Craigslist__c,'+
                                  'Override_Post_FB_Marketplace__c, Override_Post_Fleet_Up_Marketplace__c, Override_Post_Instagram__c, Override_Post_GearFlow__c,'+
                                  'Override_Post_LinkedIn__c, Override_Post_MT_Crane_Truck__c, Override_Post_Machinio__c, Override_Post_Mascus__c,'+
                                  'Override_Post_MyLittleSalesman__c, Override_Post_Override_DNP_anywhere__c, Override_Post_Terrapoint__c, Override_Post_TradeMachines__c,'+
                                  'Override_Post_Used_Equip_Guide__c, Rock_Dirt_Live_Link__c,(SELECT Id, Name, RecordTypeId, StageName FROM Opportunities__r WHERE RecordType.DeveloperName =: Opp_Rec_type_Dev_Name_procurement_opp ) '+
                                  'FROM Product2 '+
                                  'WHERE '+' IsActive = true';

        system.debug('lst Units : '+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
        
    } 
    public void Execute (Database.BatchableContext dbc , list<Product2>lstUnits){
  		system.debug('lstUnits:'+lstUnits);
        if(lstUnits!=null && !lstUnits.isEmpty()){
        BatchCreateTaskOnUnitsController.handleExecution(lstUnits);
        }
    }
        public void finish(Database.BatchableContext dbc){
            system.debug('Success : Task Creation Success');
        }
    }