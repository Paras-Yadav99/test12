public class thisContactEquipmentMatchController {

    public Id thisContactId {get;set;}
   
    //a list to hold this opps zids
    public List<Product2> thisContactZids = new List<Product2>();
    
    //get the zids into the list
    public List<Product2> getThisContactZids() {
        //criteria for contact
        thisContactZids = [Select Old_SF_Unit_Details__c, Google_Drive_Link__c, Hour__c, Name, category__c, equipment__c, Starting_Advertised_Retail_Price__c, Manufacturer__c, model__c, base__c, year__c, Options_Included__c  FROM Product2  WHERE equipment__c IN (SELECT IronDemand_Iron__c FROM Iron_Demand__c WHERE IronDemand_Contact__c = :thisContactId)              
];  
        return thisContactZids;    
    }

}