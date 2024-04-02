public class thisContactPageIronDemandBaseMatch {

    // based on thisIronDemandUnitContacts 

    public Id thisContactId {get;set;}
 
    //a list to hold this opps zids
    public List<Product2> thisContactZids = new List<Product2>();
   
    public id ContactAccountId;
    
    //get the zids into the list
    public List<Product2> getThisContactZids() {
            
        Set<Id> elist = new Set<Id>();
        Set<String> blist = new Set<String>();
        Set<String> clist = new Set<String>(); // category list
        Set<Id> zlist = new Set<Id>();
        
        Datetime d = System.today() - 1;
        
        for(List<Iron_Demand__c> thisContactEquipmentIDs  : [SELECT IronDemand_Iron__c, IronDemand_Iron__r.Base_New__c, IronDemand_Iron__r.category__c  From Iron_Demand__c WHERE IronDemand_Contact__c = :thisContactId AND IsActive__c = true]) {
            for(Iron_Demand__c thisContactEquipmentIDs2 : thisContactEquipmentIDs) {
                elist.add(thisContactEquipmentIDs2.IronDemand_Iron__c);
                blist.add(thisContactEquipmentIDs2.IronDemand_Iron__r.Base_New__c);
                clist.add(thisContactEquipmentIDs2.IronDemand_Iron__r.category__c);
            }
        
        }
        
        for(List<Contact> accid : [SELECT Id, AccountId FROM Contact WHERE Id = :thisContactId Limit 1]) {
           for(Contact accid2 : accid)
               ContactAccountId = accid2.AccountId;   
        }
          
       
        for(List<Product2> thisContactZids : [Select Id, ProductCode, Base__c, Account__r.Id, Unit_Stage__c
                                                   
                                                 From Product2 
                                                    WHERE equipment__c NOT IN :elist AND IsActive = true
                                                    AND Base__c IN :blist 
                                                    AND equipment__r.category__c IN :clist
                                                    AND Unit_Stage__c NOT IN ('Sold', 'Inactive', 'Signed', 'Do Not Market', 'Invoice Signed', 'Delivering' )]) {
                                                    
             for(Product2 thisContactZids2 : thisContactZids) {
              

                    If(ContactAccountId != thisContactZids2.Account__r.Id )  { 
                        system.debug('in here5');
                        zlist.add(thisContactZids2.Id);
                    }
                 
              }
              
              System.debug(thisContactZids);
              System.debug(zlist);
           
        }
        
        system.debug(zlist);       

        
        List<Product2> thisContactZids3 = [Select Number_of_Images_in_Google_Drive__c, Old_SF_Unit_Details__c, Google_Drive_Link__c, Hour__c, ProductCode,
                                Name, category__c, equipment__c, Starting_Advertised_Retail_Price__c, Displayed_Vague_Location__c,  
                                Year__c, Manufacturer__c, model__c, base__c, Options_Included__c, Mileage__c,
                                Attachments_Included__c, Serial_Number__c, Display_Price__c, Google_Drive_Videos_Link__c, Number_of_Videos_in_Google_Drive__c     FROM Product2 P1 
                            WHERE Id IN :zlist AND IsActive= true];
       
        
        return thisContactZids3;   
       
        
    }


    
}