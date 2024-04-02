public class thisIronDemandBaseUnitContacts {
 
    // based on thisIronDemandUnitContacts 

    public Id thisContactId {get;set;}
 
    //a list to hold this opps zids
    public List<Product2> thisContactZids = new List<Product2>();
   
    public id ContactAccountId;
    
    //get the zids into the list
    public List<Product2> getThisContactZids() {
            
        Set<Id> elist = new Set<Id>();
        Set<String> blist = new Set<String>();
        Set<Id> zlist = new Set<Id>();
        Set<String> clist = new Set<String>(); // category list
        
        Datetime d = System.today() - 1;
        
        for(List<Iron_Demand__c> thisContactEquipmentIDs  : [SELECT IronDemand_Iron__c, IronDemand_Iron__r.Base_New__c, IronDemand_Iron__r.category__c From Iron_Demand__c WHERE IronDemand_Contact__c = :thisContactId AND IsActive__c = true]) {
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
          
       
        for(List<Product2> thisContactZids : [Select Id, ProductCode, Base__c, Account__r.Id, 
                                                    (SELECT Product2Id, NewValue, CreatedDate from Histories 
                                                    WHERE CreatedDate >= :d) 
                                                 From Product2 
                                                    WHERE LastModifiedDate >= :d 
                                                    AND equipment__r.category__c IN :clist
                                                    AND equipment__c NOT IN :elist AND IsActive = true
                                                    AND Base__c IN :blist]) {
                                                    
             for(Product2 thisContactZids2 : thisContactZids) {
              
              // array of Histories
              Product2History[] P2H = thisContactZids2.Histories;
              if(P2H != null && P2H.size() > 0) {
                  system.debug('in here7');
                  for(Product2History P2H2 : P2H) {
                    system.debug('in here6');
                    system.debug(P2H2);
                    system.debug(P2H2.Product2Id);
                    If(ContactAccountId != thisContactZids2.Account__r.Id && (P2H2.NewValue == 'Advertising' || P2H2.NewValue == 'Keep Only for Iron Demand'  )  && date.valueOf(P2H2.CreatedDate.format('yyyy-MM-dd', 'PST')) < system.today() )  { 
                        system.debug('in here5');
                        zlist.add(P2H2.Product2Id);
                    }
                  }
              }
              
              System.debug(thisContactZids2);
              System.debug(zlist);
            } 
        }
        
        system.debug(zlist);       

        
        List<Product2> thisContactZids3 = [Select Number_of_Images_in_Google_Drive__c, Old_SF_Unit_Details__c, Google_Drive_Link__c, Hour__c, ProductCode,
                                Name, category__c, equipment__c, Starting_Advertised_Retail_Price__c, Unit_Stage__c, 
                                Year__c, Manufacturer__c, model__c, Base__c, Options_Included__c, Mileage__c, Displayed_Vague_Location__c, 
                                Serial_Number__c, Display_Price__c, Google_Drive_Videos_Link__c, Number_of_Videos_in_Google_Drive__c     FROM Product2 P1 
                            WHERE Id IN :zlist AND IsActive= true];
       
        
        return thisContactZids3;   
       
        
    }
    
    
}