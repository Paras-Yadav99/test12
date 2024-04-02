public class MLSCalloutDeleteBatch implements database.Batchable<sObject>, Database.AllowsCallouts{
    List<Integer> listingIds;
    public MLSCalloutDeleteBatch(List<Integer> listingIds) {
        this.listingIds = listingIds;
    }

    public database.QueryLocator start(database.BatchableContext bc){
        return Database.getQueryLocator(
            [
                SELECT Id,  Category__c, Model__c, Is_Listed_On_MLS__c, Manufacturer__c, Year__c, Old_SF_Unit_Details__c, IsActive, Starting_Advertised_Retail_Price__c, 
                Rental_Unit__c, Daily_Rental_Rate__c, Weekly_Rental_Rate__c, Monthly_Rental_Rate__c, Hour__c, Mileage__c, 
                VIN__c, ZID__c, Serial_Number__c, MT_Vague_Display_Location_Name__c, Displayed_Vague_Location__c, Storage_Country__c, MT_Location_Vague_Postal_Code__c, 
                Google_Drive_LInk__c, Google_Drive_Videos_Link__c, Storage_City__c, MLS_Number__c FROM Product2 
                WHERE MLS_Number__c IN :listingIds AND MLS_Number__c != null
                ORDER BY CreatedDate
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Product2> scope){
        List<Integer> listingIds = new List<Integer>();
        for(Product2 unit : scope){
            listingIds.add(Integer.valueOf(unit.MLS_Number__c));
        }
        MLSCallout.deleteInventoryItem(listingIds);
    }

    public void finish(Database.BatchableContext bc){
        
    }
}