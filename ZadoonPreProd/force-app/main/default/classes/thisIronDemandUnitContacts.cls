public class thisIronDemandUnitContacts {

  public Id thisContactId {get;set;}

  //a list to hold this opps zids
  public List<Product2> thisContactZids = new List<Product2>();
  
  public id ContactAccountId;
  
  //get the zids into the list
  public List<Product2> getThisContactZids() {
          
    Map<Id, List<Iron_Demand__c>> IDParameters = new Map<Id, List<Iron_Demand__c>>();
    Set<Id> elist = new Set<Id>();
    Set<Id> zlist = new Set<Id>();
    
    Datetime d = System.today() - 1;

    for(List<Iron_Demand__c> thisContactEquipmentIDs  : [SELECT IronDemand_Iron__c, Max_Hours__c, Max_Price__c, Max_Year__c, Min_Year__c From Iron_Demand__c WHERE IronDemand_Contact__c = :thisContactId AND IsActive__c = true]) {
      for(Iron_Demand__c thisContactEquipmentIDs2 : thisContactEquipmentIDs) {
           
        if (IDParameters.containsKey(thisContactEquipmentIDs2.IronDemand_Iron__c)){

          IDParameters.get(thisContactEquipmentIDs2.IronDemand_Iron__c).add(new Iron_Demand__c( 
              id = thisContactEquipmentIDs2.Id, 
              IronDemand_Iron__c = thisContactEquipmentIDs2.IronDemand_Iron__c,
              Max_Hours__c = thisContactEquipmentIDs2.Max_Hours__c, 
              Max_Price__c = thisContactEquipmentIDs2.Max_Price__c, 
              Max_Year__c = thisContactEquipmentIDs2.Max_Year__c, 
              Min_Year__c = thisContactEquipmentIDs2.Min_Year__c));
      
        }
        else {
          IDParameters.put(thisContactEquipmentIDs2.IronDemand_Iron__c, new  List <Iron_Demand__c>{});
          IDParameters.get(thisContactEquipmentIDs2.IronDemand_Iron__c).add(new Iron_Demand__c( 
                  id = thisContactEquipmentIDs2.Id, 
                  IronDemand_Iron__c = thisContactEquipmentIDs2.IronDemand_Iron__c,
                  Max_Hours__c = thisContactEquipmentIDs2.Max_Hours__c, 
                  Max_Price__c = thisContactEquipmentIDs2.Max_Price__c, 
                  Max_Year__c = thisContactEquipmentIDs2.Max_Year__c, 
                  Min_Year__c = thisContactEquipmentIDs2.Min_Year__c));

        }
        
        elist.add(thisContactEquipmentIDs2.IronDemand_Iron__c);   
      }
    
    }
    
    system.debug('elist: ' + elist);
    system.debug('IDParameters: ' + IDParameters);


    for(List<Contact> accid : [SELECT Id, AccountId FROM Contact WHERE Id = :thisContactId Limit 1]) {
       for(Contact accid2 : accid)
           ContactAccountId = accid2.AccountId;   
    }
    
    for(List<Product2> thisContactZids : [Select Id, ProductCode, Product2.Account__r.Id,
                                                (SELECT Product2Id, NewValue, CreatedDate from Histories 
                                                WHERE CreatedDate >= :d) 
                                             From Product2 
                                                WHERE LastModifiedDate >= :d 
                                                AND equipment__c IN :elist AND IsActive = true]) {
     
      for(Product2 thisContactZids2 : thisContactZids) {
      
        // array of Histories
        Product2History[] P2H = thisContactZids2.Histories;
        if(P2H != null && P2H.size() > 0) {
            system.debug('in here7');
            for(Product2History P2H2 : P2H) {
              system.debug('in here6');
              system.debug(P2H2);
              system.debug(P2H2.Product2Id);
              
              If(ContactAccountId != thisContactZids2.Account__r.Id 
                      && (P2H2.NewValue == 'Advertising' || P2H2.NewValue == 'Keep Only for Iron Demand'   ) 
                     && date.valueOf(P2H2.CreatedDate.format('yyyy-MM-dd', 'PST')) < system.today() )  {
              
              
              
                system.debug('in here5');
                zlist.add(P2H2.Product2Id);
              }
            }
        }
        
        System.debug(thisContactZids2);

      } 
    }
    
    system.debug('zlist ' + zlist);       

    
    for(List<Product2> thisContactZids3 : [Select Number_of_Images_in_Google_Drive__c, Old_SF_Unit_Details__c, Google_Drive_Link__c, Hour__c, ProductCode,
                                Name, category__c, equipment__c, Starting_Advertised_Retail_Price__c, 
                                Year__c, Manufacturer__c, model__c, base__c, Options_Included__c,   
                                Attachments_Included__c, Serial_Number__c, Display_Price__c, Google_Drive_Videos_Link__c, Number_of_Videos_in_Google_Drive__c  FROM Product2 P1 
                            WHERE Id IN :zlist AND IsActive= true]) { 
   
      for(Product2 thisContactZids4 : thisContactZids3) {
        
          
        system.debug('product2: ' + thisContactZids4.Hour__c);
        system.debug('IDParameters: ' + IDParameters.get(thisContactZids4.equipment__c));
        
        for(Id id: IDParameters.keyset()){
          List<Iron_Demand__c> IDcounter = IDParameters.get(id);
          for(Iron_Demand__c a: IDcounter){
             if(a.IronDemand_Iron__c == thisContactZids4.equipment__c) {
                 if(!((a.Max_Hours__c == null || thisContactZids4.Hour__c == null || a.Max_Hours__c >= Integer.valueOf(thisContactZids4.Hour__c)) &&  
                    
                    ((thisContactZids4.Year__c == null) || 
                    (a.Min_Year__c == null && a.Max_Year__c == null) || 
                    (a.Max_Year__c == null && Integer.valueOf(a.Min_Year__c) <= Integer.valueOf(thisContactZids4.Year__c))  || 
                    (a.Min_Year__c == null && Integer.valueOf(a.Max_Year__c) >= Integer.valueOf(thisContactZids4.Year__c)) || 
                    (a.Min_Year__c != null && a.Max_Year__c != null && Integer.valueOf(a.Min_Year__c) <= Integer.valueOf(thisContactZids4.Year__c) && Integer.valueOf(a.Max_Year__c) >= Integer.valueOf(thisContactZids4.Year__c ))
                    ) 
                    
                      &&
                    ((thisContactZids4.Display_Price__c.equals('Call For Price') || a.Max_Price__c == null || ( a.Max_Price__c >= Integer.valueOf(thisContactZids4.Display_Price__c.remove('$').remove(','))))))) {
                    system.debug('ZID: ' + thisContactZids4.Id );
                    
                    /* if(!(a.Max_Hours__c == null || thisContactZids4.Hours__c == null ||  (a.Max_Hours__c >= Integer.valueOf(thisContactZids4.Hour__c))))
                    system.debug('Product2: ' + thisContactZids4.Hour__c + 
                                  ' ID Max Hours: ' + a.Max_Hours__c);
                    if(!(a.Min_Year__c == null || thisContactZids4.Year__c == null || (Integer.valueOf(a.Min_Year__c) >= Integer.valueOf(thisContactZids4.Year__c))))
                    system.debug('Product2:  ' + thisContactZids4.Year__c + 
                                  ' ID Min Year: ' + a.Min_Year__c);
                    if(!(a.Max_Year__c == null || thisContactZids4.Year__c == null || (Integer.valueOf(a.Max_Year__c) <= Integer.valueOf(thisContactZids4.Year__c))))
                    system.debug('Product2:  ' + thisContactZids4.Year__c + 
                                  ' ID Max Year: ' + a.Max_Year__c);
                    if(thisContactZids4.Display_Price__c != 'Call For Price') 
                    system.debug('Product2:  ' + Decimal.valueOf(thisContactZids4.Display_Price__c.remove('$').remove(',')) + 
                                  ' a.Max_Price__c: ' + a.Max_Price__c);
                    if(thisContactZids4.Display_Price__c.equals('Call For Price'))
                       system.debug('Call For Price');
                    if(!thisContactZids4.Display_Price__c.equals('Call For Price'))
                        system.debug('!Call For Price'); */        
    
                    zlist.remove(thisContactZids4.Id);
    
                }
            }
          }
        }
    

      }
      system.debug('zlist: ' + zlist); 
 

    }
    
    List<Product2> thisContactZidsFinal = [Select Number_of_Images_in_Google_Drive__c, Old_SF_Unit_Details__c, Google_Drive_Link__c, Hour__c, ProductCode,
                                Name, category__c, equipment__c, Starting_Advertised_Retail_Price__c, Unit_Stage__c, 
                                Year__c, Manufacturer__c, model__c, base__c, Options_Included__c, Mileage__c,  Displayed_Vague_Location__c, 
                                Attachments_Included__c, Serial_Number__c, Display_Price__c, Google_Drive_Videos_Link__c, Number_of_Videos_in_Google_Drive__c  FROM Product2 P1 
                            WHERE Id IN :zlist AND IsActive= true];
   
    return thisContactZidsFinal; 

 
  }  
}