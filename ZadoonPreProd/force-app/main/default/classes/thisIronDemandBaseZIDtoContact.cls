public with sharing class thisIronDemandBaseZIDtoContact {


    public Id thisIronDemandId {get;set;}
    public Id thisAccountId {get;set;}
   
    //a list to hold this opps zids
    public List<Product2> thisIronDemandBaseZIDtoContact = new List<Product2>();
    
    //get the zids into the list
    public List<Product2> getThisIronDemandBaseZidsToContact() {
       
        //criteria for contact
        
        Set<String> blist = new Set<String>();
        Set<String> clist = new Set<String>(); // category list

        for(List<Iron_Demand__c> thisContactEquipmentIDs  : [SELECT IronDemand_Iron__c, IronDemand_Iron__r.Base_New__c, IronDemand_Iron__r.category__c From Iron_Demand__c 
                                                                WHERE IronDemand_Iron__c = :thisIronDemandId 
                                                                AND IsActive__c = true]) {
            for(Iron_Demand__c thisContactEquipmentIDs2 : thisContactEquipmentIDs) {

                blist.add(thisContactEquipmentIDs2.IronDemand_Iron__r.Base_New__c);
                clist.add(thisContactEquipmentIDs2.IronDemand_Iron__r.category__c);
            }
        
        }
        
        
        thisIronDemandBaseZIDtoContact =  [
            Select Display_Price__c, ProductCode, MT_Live_Advertised__c, 
                    Number_of_Images_in_Google_Drive__c, MT_Vague_Location_Name__c, 
                    Old_SF_Unit_Details__c, Google_Drive_Link__c, Hour__c, Name, category__c, 
                    equipment__c, Starting_Advertised_Retail_Price__c, Displayed_Vague_Location__c, 
                    Manufacturer__c, model__c, base__c, year__c, Options_Included__c, 
                    Attachments_Included__c, Google_Drive_Videos_Link__c, Number_of_Videos_in_Google_Drive__c   
                FROM Product2  
                WHERE equipment__r.Base_New__c IN :blist 
                    AND equipment__r.category__c IN :clist
                    AND equipment__c != :thisIronDemandId 
                    AND account__c != :thisAccountId AND UNIT_STAGE__C 
                    NOT IN ('Sold', 'Inactive', 'Signed', 'Do Not Market', 'Invoice Signed', 'Delivering' ) 
                    AND ISACTIVE = TRUE
                    ];  
        return thisIronDemandBaseZIDtoContact;    
      
    }

}