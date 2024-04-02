public class thisZIDsforAccountControllerLeads {

    public Id thisLeadId {get;set;}
 
    //a list to hold this opps zids
    public List<Product2> thisAccountZids = new List<Product2>();
   
    
    //get the zids into the list
    public List<Product2> getThisAccountZids() {
        
                        
        thisAccountZids = [Select Old_SF_Unit_Details__c, Google_Drive_Link__c, Hour__c, ProductCode,
                                Name, category__c, equipment__c, Starting_Advertised_Retail_Price__c, Number_of_Videos_in_Google_Drive__c, 
                                Year__c, Manufacturer__c, model__c, base__c, Options_Included__c, Number_of_Images_in_Google_Drive__c,
                                 Sellers_Most_Recent_Bottom_Price_Text__c,   
                                On_or_Off_Highway__c, Serial_Number__c, Mileage__c, Display_Price__c, VIN__c, Display_Lowest_Purchase_Price__c   FROM Product2 P1 
                            WHERE Lead_Unit_Owner__c = :thisLeadId AND IsActive= true];
        
        return thisAccountZids;    
    }
    
}