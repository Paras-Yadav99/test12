public class thisMassEmailEquipmentList {

    public Id thisEquipment {get;set;}
    public Id thisRecipientAccountId {get;set;}
 
    //a list to hold this opps zids
    public List<Product2> thisEquipmentZids = new List<Product2>();
   
    
    //get the zids into the list
    public List<Product2> getthisEquipmentZids() {
          
        List<Product2> thisEquipmentZids = new List<Product2>();
        
        thisEquipmentZids = [Select Number_of_Images_in_Google_Drive__c, Old_SF_Unit_Details__c, Google_Drive_Link__c, Hour__c, ProductCode,
                            Name, category__c, equipment__c, Starting_Advertised_Retail_Price__c, 
                            Year__c, Manufacturer__c, model__c, base__c, Options_Included__c, Mileage__c, 
                            Attachments_Included__c, Serial_Number__c, Display_Price__c, Google_Drive_Videos_Link__c, Number_of_Videos_in_Google_Drive__c   FROM Product2  
                        WHERE equipment__c = :thisEquipment AND IsActive= true AND Account__c != :thisRecipientAccountId];
         
        
        return thisEquipmentZids;   
       
        
    }
    
}