public class thisIronDemandCatchupEmail {

    public Id thisContactId {get;set;}
 
    //a list to hold this opps zids
    public List<Product2> thisContactZids = new List<Product2>();
   
    
    //get the zids into the list
    public List<Product2> getThisContactZids() {
            
        System.debug(thisContactId);    
            
        Set<Id> elist = new Set<Id>();
        Set<Id> zlist = new Set<Id>();
        for(List<Iron_Demand__c> thisContactEquipmentIDs  : [SELECT IronDemand_Iron__c From Iron_Demand__c WHERE IronDemand_Contact__c = :thisContactId]) {
            for(Iron_Demand__c thisContactEquipmentIDs2 : thisContactEquipmentIDs) {
                elist.add(thisContactEquipmentIDs2.IronDemand_Iron__c);
            }
        
        }
        
        System.debug(elist);
       
        for(List<Product2> thisContactZids : [Select Id, ProductCode, Unit_Stage__c
                                                     
                                                 From Product2 
                                                    WHERE equipment__c IN :elist AND IsActive = true]) {
             for(Product2 thisContactZids2 : thisContactZids) {
              
              
                    If(thisContactZids2.Unit_Stage__c == 'Advertising' || thisContactZids2.Unit_Stage__c == 'Keep Only for Iron Demand')  {

                        zlist.add(thisContactZids2.Id);
                    }
                  }
              }
              
              System.debug(zlist);
             
        
        
        System.debug(zlist);       

        
        List<Product2> thisContactZids3 = [Select Number_of_Images_in_Google_Drive__c, Old_SF_Unit_Details__c, Google_Drive_Link__c, Hour__c, ProductCode,
                                Name, category__c, equipment__c, Starting_Advertised_Retail_Price__c, 
                                Year__c, Manufacturer__c, model__c, base__c, Options_Included__c, 
                                Attachments_Included__c, Serial_Number__c, Display_Price__c, Google_Drive_Videos_Link__c, Number_of_Videos_in_Google_Drive__c  FROM Product2 P1 
                            WHERE Id IN :zlist AND IsActive= true];
       
        
        return thisContactZids3;   
       
        
    }
    
}