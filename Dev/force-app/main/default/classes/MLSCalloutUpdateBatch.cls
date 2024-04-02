public class MLSCalloutUpdateBatch implements database.Batchable<sObject>, Database.AllowsCallouts{
    List<Id> unitIds;
    public MLSCalloutUpdateBatch(List<Id> unitIds) {
        this.unitIds = unitIds;
    }

    public database.QueryLocator start(database.BatchableContext bc){
        return Database.getQueryLocator(
            [
                SELECT Id,  Category__c, Model__c, Is_Listed_On_MLS__c, Manufacturer__c, Year__c, Old_SF_Unit_Details__c, IsActive, Starting_Advertised_Retail_Price__c, 
                Rental_Unit__c, Daily_Rental_Rate__c, Weekly_Rental_Rate__c, Monthly_Rental_Rate__c, Hour__c, Mileage__c, 
                VIN__c, ZID__c, Serial_Number__c, MT_Vague_Display_Location_Name__c, Displayed_Vague_Location__c, Storage_Country__c, MT_Location_Vague_Postal_Code__c, 
                Google_Drive_LInk__c, Google_Drive_Videos_Link__c, Storage_City__c FROM Product2 
                WHERE Id IN :unitIds AND MLS_Number__c != null
                ORDER BY CreatedDate
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Product2> scope){

        MLSCallout.updateInventory(new Map<Id, Product2>(scope).keySet());
        
    }

    public void finish(Database.BatchableContext bc){
        
    }
}