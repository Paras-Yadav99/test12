public with sharing class thisIronDemandZIDtoContact {


    public Id thisIronDemandId {get;set;}
    public Id thisAccountId {get;set;}
    public Id thisContactId {get;set;}
   
    //a list to hold this opps zids
    public List<Product2> thisIronDemandZidstoContact = new List<Product2>();
    
    //get the zids into the list
    public List<Product2> getThisIronDemandZidsToContact() {
        //criteria for contact
        
        Set<Id> zlist = new Set<Id>();
        Set <Id> opplist = new Set<Id>();
        
        for(List<Opportunity> thisContactOpportunities : [Select o.Name,
                                                 (Select Product2.Name From OpportunityLineItems) 
                                             From Opportunity o 
                                             Where Buyer_Primary_Contact__c = :thisContactId]) {
    

      system.debug(thisContactOpportunities);
                                                
      for(Opportunity thisContactOpportunity : thisContactOpportunities) {
          
         
      
         system.debug('Opportunity Line Items' +  thisContactOpportunity.OpportunityLineItems);
        
          for(List<OpportunityLineItem> OppLineItem : thisContactOpportunity.OpportunityLineItems) {
 
            for(OpportunityLineItem oli : OppLineItem) {
              
                system.debug('Oli' + oli.Product2Id);
                opplist.add(oli.Product2Id); 
            }
          }
      }
        

      
    }
    
    system.debug('opplist ' + opplist);     
        
        thisIronDemandZidstoContact =  [
            Select Display_Price__c, ProductCode, MT_Live_Advertised__c, 
                    Number_of_Images_in_Google_Drive__c, MT_Vague_Location_Name__c, 
                    Old_SF_Unit_Details__c, Google_Drive_Link__c, Hour__c, Name, category__c, 
                    equipment__c, Starting_Advertised_Retail_Price__c, Displayed_Vague_Location__c, 
                    Manufacturer__c, model__c, Base__c, year__c, Options_Included__c, 
                    Attachments_Included__c, Google_Drive_Videos_Link__c, Number_of_Videos_in_Google_Drive__c   
                FROM Product2  
                WHERE equipment__c = :thisIronDemandId 
                    AND account__c != :thisAccountId AND UNIT_STAGE__C 
                    NOT IN ('Sold', 'Inactive', 'Signed', 'Do Not Market', 'Invoice Signed', 'Delivering' ) 
                    AND ISACTIVE = TRUE AND Id NOT IN :opplist];  
        return thisIronDemandZidstoContact;    
    }
    
}