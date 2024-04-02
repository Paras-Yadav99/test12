public class thisContactPageIronDemandOppMatch {
  
  public Id thisContactId {get;set;}

  //a list to hold this opps zids
  public List<Product2> thisContactZids = new List<Product2>();
  
  public id ContactAccountId;
  
  //get the zids into the list
  public List<Product2> getThisContactZids() {

    
    Set<Id> zlist = new Set<Id>();
    
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
                zlist.add(oli.Product2Id); 
            }
          }
      }
        
      System.debug(thisContactZids);

      
    }
    
    system.debug('zlist ' + zlist);       

    
    List<Product2> thisContactZidsFinal = [Select Number_of_Images_in_Google_Drive__c, Old_SF_Unit_Details__c, Google_Drive_Link__c, Hour__c, ProductCode,
                                Name, category__c, equipment__c, Starting_Advertised_Retail_Price__c, Displayed_Vague_Location__c, 
                                Year__c, Manufacturer__c, model__c, base__c, Options_Included__c, Mileage__c,  
                                Attachments_Included__c, Serial_Number__c, Display_Price__c, Google_Drive_Videos_Link__c, Number_of_Videos_in_Google_Drive__c  FROM Product2 P1 
                            WHERE Id IN :zlist AND IsActive= true];
   
    return thisContactZidsFinal;

  }  
}