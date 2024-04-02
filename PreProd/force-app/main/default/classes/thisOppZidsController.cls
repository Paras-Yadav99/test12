public class thisOppZidsController {


    public Id thisOppId {get;set;}
   
    //a list to hold this opps zids
    public List<Product2> thisOppZids = new List<Product2>();
    
    //get the zids into the list
    public List<Product2> getThisOppZids() {
        //criteria for opps
        thisOppZids = [Select Google_Drive_LInk__c, Displayed_Vague_Location__c, Old_SF_Unit_Details__c, Final_Sale_Price__c, Name, Manufacturer__c, Model__c, Year__c, Options_Included__c, Attachments_Included__c, Hour__c FROM Product2 WHERE id IN (SELECT Product2id FROM OpportunityLineItem WHERE Opportunityid = :thisOppId)           
];  
        return thisOppZids;    
    }
    
}