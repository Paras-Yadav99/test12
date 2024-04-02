global class DailyIronDemandMatchingEmail4 implements Database.Batchable<sObject> {
    /**
        * Webkul Software.
        *
        * @category  Webkul
        * @author    Webkul
        * @copyright Copyright (c) 2010-2016 Webkul Software Private Limited (https://webkul.com)
        * @license   https://store.webkul.com/license.html
    */
    
    public integer newZid;   
    public Set<String> EmailString;
    public List<String> bodies = new List<String>();
    public boolean DailyIronDemandMatchingEmail_Production {get; set;}
    public Map<Id, Id> AccountIDMap = new Map<Id, Id>();
    public Map<Id, String> ContactName = new Map<Id, String>(); 
    public Map<Id, String> AccountName = new Map<Id, String>();  
    public boolean display{get; set;}
    public String OWASender; 

    public DailyIronDemandMatchingEmail4() {
         display = false;
    }
    
    Public PageReference GetRecordPage(){
    
        display = true;
        DailyIronDemandMatchingEmail_Production = false;
        GetDailyIDMatchingEmail4();
    
       return null;   
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        system.debug('in here jan 26 - 2');
        Datetime d = System.today() - 1;
         
        String query = 'SELECT Id, Product2Id, OldValue, NewValue, Product2.Account__c, Product2.Hour__c, Product2.Year__c, Product2.Display_Price__c, IsDeleted, Field, CreatedDate, CreatedById, Product2.Base__c, CreatedBy.Name, Product2.equipment__c from Product2History  WHERE CreatedDate >=  :d AND Field = \'Unit_Stage__c\' AND Product2.isActive = true';
     
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Product2History> phlist) {
        
        DailyIronDemandMatchingEmail_Production = true;
        GetDailyIDMatchingEmail4();
    
        
    }
    
    
     
    Public List<Messaging.SingleEmailMessage> GetDailyIDMatchingEmail4(){
        
        system.debug('in here jan 26 - 2');
        Datetime d = System.today() - 1;
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
         
        for(List<Product2History> phlist : [SELECT Id, Product2Id, OldValue, NewValue, 
                    Product2.Account__c, Product2.Hour__c, Product2.Year__c, Product2.Display_Price__c, 
                    IsDeleted, Field, CreatedDate, CreatedById, Product2.Base__c, CreatedBy.Name, 
                    Product2.equipment__c from Product2History  
                WHERE CreatedDate >=  :d 
                    AND Field = 'Unit_Stage__c' 
                    AND Product2.isActive = true]) {
        
        Set<Id> elist = new Set<Id>();
        Set<Id> clist = new Set<Id>();
        Map<id,List<Product2>> equipmentunitmap = new Map<id,List<Product2>>();    
        Integer newEquipment = 1; 
        Integer newID = 1;
        Map<id,List<equipment__c>> clistEquip = new Map<id,List<equipment__c>>(); 
        Map<id,List<Product2>> clistZID = new Map<id,List<Product2>>();
        Map<id,List<Iron_Demand__c>> clistID = new Map<id,List<Iron_Demand__c>>();
        Map<id, String> clistZIDstring = new Map<id, String>(); 
        

           
        // process each batch of records
        
        
      
            for(Product2History phlist2 : phlist)
            {        
              newZid = 1;
              system.debug('phlist2' + phlist2);
              system.debug('date ' + date.valueOf(phlist2.CreatedDate.format('yyyy-MM-dd', 'PST')));
              if(date.valueOf(phlist2.CreatedDate.format('yyyy-MM-dd', 'PST')) >= system.today().AddDays(-1) && date.valueOf(phlist2.CreatedDate.format('yyyy-MM-dd', 'PST')) < system.today() && ( phlist2.NewValue == 'Advertising' || phlist2.NewValue == 'Keep Only for Iron Demand'  )) {  
                elist.add(phlist2.Product2.equipment__c); // adds unique equipment id to set
                system.debug(phlist2.Product2.equipment__c);
                
                if (equipmentunitmap.containsKey(phlist2.Product2.equipment__c)){
                  system.debug('map' + equipmentunitmap.get(phlist2.Product2.equipment__c) + ' product2 ' + phlist2.Product2Id);
                  for(Product2 i : equipmentunitmap.get(phlist2.Product2.equipment__c) ) {
                      system.debug('i' + i.Id + ' product2 ' + phlist2.Product2Id);
                      if(i.Id == phlist2.Product2Id ) {
                          newZid = 0;  
                          break;
                      }
                  }
                  if(newZid == 1)
                      equipmentunitmap.get(phlist2.Product2.equipment__c).add(new Product2( id = phlist2.Product2Id, Account__c = phlist2.Product2.Account__c, Hour__c = phlist2.Product2.Hour__c, Year__c = phlist2.Product2.Year__c, ApexValue__c = phlist2.Product2.Display_Price__c));
                  
                }
                else {
                  equipmentunitmap.put(phlist2.Product2.equipment__c, new  List <Product2>{});
                  equipmentunitmap.get(phlist2.Product2.equipment__c).add(new Product2( id = phlist2.Product2Id, Account__c = phlist2.Product2.Account__c, Hour__c = phlist2.Product2.Hour__c, Year__c = phlist2.Product2.Year__c, ApexValue__c = phlist2.Product2.Display_Price__c));
    
                }
                
              }
            }
            
            system.debug('equipmentunitmap' + equipmentunitmap);
            
            system.debug('in here2');
            
            // need to get contacts w/ iron demand for equipment id
            
            for(List<Iron_Demand__c> idlist : [SELECT IronDemand_Contact__c, IronDemand_Contact__r.Name, IronDemand_Iron__c,
                                                    IronDemand_Contact__r.Account.Name, IronDemand_Contact__r.Account.Id,
                                                    Max_Hours__c, Max_Price__c, Max_Year__c, Min_Year__c
                                                From Iron_Demand__c 
                                                WHERE IronDemand_Iron__c IN :elist 
                                                    AND IsActive__c = true
                                                    AND IronDemand_Contact__r.Account.Not_A_Client_We_Want_To_Do_Business_With__c = false]) {
               for(Iron_demand__c idlist2 : idlist) {
                   
                   newEquipment = 1;
                   newID = 1;
                   
                   if (clistEquip.containsKey(idlist2.IronDemand_Contact__c)){
                      for(equipment__c i : clistEquip.get(idlist2.IronDemand_Contact__c) ) {
                          system.debug('i' + i.Id + ' equipment__c ' + idlist2.IronDemand_Iron__c);
                          if(i.Id == idlist2.IronDemand_Iron__c ) {
                              newEquipment = 0;  
                              break;
                          }
                      }
                      if(newEquipment == 1)
                      clistEquip.get(idlist2.IronDemand_Contact__c).add(new equipment__c( id = idlist2.IronDemand_Iron__c));
                   
                   } else {
                   
                      clistEquip.put(idlist2.IronDemand_Contact__c, new  List <equipment__c>{});
                      clistEquip.get(idlist2.IronDemand_Contact__c).add(new equipment__c( id = idlist2.IronDemand_Iron__c));
                   
                   }
                    
                   if (clistID.containsKey(idlist2.IronDemand_Contact__c)){
                      for(Iron_Demand__c IDi : clistID.get(idlist2.IronDemand_Contact__c) ) {
                          system.debug('IDi' + IDi.Id + ' equipment__c ' + idlist2.IronDemand_Iron__c);
                          if(IDi.Id == idlist2.IronDemand_Iron__c ) {
                              newID = 0;  
                              break;
                          }
                      }
                      if(newID == 1)
                      clistID.get(idlist2.IronDemand_Contact__c).add(new Iron_Demand__c( id = idlist2.Id, IronDemand_Contact__c = idlist2.IronDemand_Contact__c, Max_Hours__c = idlist2.Max_Hours__c, Max_Price__c = idlist2.Max_Price__c, Max_Year__c = idlist2.Max_Year__c, Min_Year__c = idlist2.Min_Year__c));
                   
                   } else {
                   
                      clistID.put(idlist2.IronDemand_Contact__c, new  List <Iron_Demand__c>{});
                      clistID.get(idlist2.IronDemand_Contact__c).add(new Iron_Demand__c( id = idlist2.Id, IronDemand_Contact__c = idlist2.IronDemand_Contact__c, Max_Hours__c = idlist2.Max_Hours__c, Max_Price__c = idlist2.Max_Price__c, Max_Year__c = idlist2.Max_Year__c, Min_Year__c = idlist2.Min_Year__c));
                   
                   }
                   
                 
                   
                   
                   ContactName.put(idlist2.IronDemand_Contact__c, idlist2.IronDemand_Contact__r.Name);
                   AccountIDMap.put(idlist2.IronDemand_Contact__c, idlist2.IronDemand_Contact__r.Account.Id);
                   AccountName.put(idlist2.IronDemand_Contact__c, idlist2.IronDemand_Contact__r.Account.Name);
    
               }
            }
            
            system.debug('clistEquip' + clistEquip);
            system.debug('Account Name ' + AccountIDMap);
            system.debug('Contact Name ' + ContactName);
            system.debug('clistID ' + clistID);
            
            /* Start section to assign zid to contacts */
            
            for (Id key : clistEquip.keySet()) {
              // The "key" variable is also available inside the loop
              List<equipment__c> equipmentListforContact = clistEquip.get(key);
                
              for (equipment__c equipmentIterator : equipmentListforContact) { 
                /* iterate through each equipment for contact */
                /* key = contactID */
               
                List<Product2> productList = equipmentunitmap.get(equipmentIterator.Id);   
                for (Product2 productIterator : productList) {
                    
                  newZid = 1;
                  system.debug('key ' + key + ' Account Name ' + AccountIDMap.get(key) + ' productIterator ' + productIterator.Account__c);
                  
                  /* iterate through zid list for equipment, add to clistZid if account != contact account */
                  /* also check for max price, max min year, max hours */
                  if(AccountIDMap.get(key) != productIterator.Account__c) {
                     
                    /* get iron demand field parameters */
                    List<Iron_Demand__c> ClientIDList = clistID.get(key);
                    
                    double unitPrice; 
                    
                    for (Iron_Demand__c irondemandIterator : ClientIDList) {
                      newEquipment = 0;
                      unitPrice = 99999999999.00; /* max out unit price */
                      try {
                          unitPrice = Double.valueOf(productIterator.ApexValue__c.remove('$').remove(','));
                      }  catch (Exception e) {
                          // EditText EtPotential does not contain a valid double
                      }
                      
                      
                      
                      if(
    
                        ((productIterator.Hour__c == null) || (irondemandIterator.Max_Hours__c == null) || (irondemandIterator.Max_Hours__c >= Double.valueOf(productIterator.Hour__c))
                          ) &&  
                
                        ((irondemandIterator.Min_Year__c == null && irondemandIterator.Max_Year__c == null) || 
                        (productIterator.Year__c == null) || 
                        (irondemandIterator.Max_Year__c == null && Double.valueOf(irondemandIterator.Min_Year__c) <= Double.valueOf(productIterator.Year__c))  || 
                        (irondemandIterator.Min_Year__c == null && Double.valueOf(irondemandIterator.Max_Year__c) >= Double.valueOf(productIterator.Year__c)) || 
                        ((irondemandIterator.Min_Year__c != null && Double.valueOf(irondemandIterator.Min_Year__c) <= Double.valueOf(productIterator.Year__c)) && (irondemandIterator.Max_Year__c != null  && Double.valueOf(irondemandIterator.Max_Year__c) >= Double.valueOf(productIterator.Year__c )))
                        ) 
                        
                          &&
                        ((productIterator.ApexValue__c.equals('Call For Price') || irondemandIterator.Max_Price__c == null || ( irondemandIterator.Max_Price__c >= unitPrice))
    
    
    
    
    
                        ))  {
    
                        system.debug('clistZid: ' + clistZid);
    
                        /* add the record to the clistZid */
                        if (clistZid.containsKey(key)){
                        
                          for(Product2 i : clistZid.get(key) ) {
                            system.debug('i' + i.Id + ' equipment__c ' + equipmentIterator.Id); 
                            if(i.Id == equipmentIterator.Id ) {
                                newEquipment = 1;  
                                break;
                            }
                          }
                        }
                        
                        if(newEquipment == 1) {
                            clistZid.get(key).add(new Product2( id = productIterator.id));
                            clistZIDstring.put(key, clistZidstring.get(key) + ',' + productIterator.Id);
                     
                        } else {
                       
                          clistZid.put(key, new  List <Product2>{});
                          clistZid.get(key).add(new Product2( id = productIterator.Id));
                          
                          clistZIDstring.put(key, productIterator.Id);
                          clist.add(key);
                       
                        }
                        
                      }
    
                    }
    
                  }
                  system.debug('clistZid' + clistZid);
                  system.debug('clistZidstring' + clistZidstring);
                } 
              }
            }
            
            EmailTemplate templateId = [Select id from EmailTemplate where DeveloperName = 'Iron_Demand_Daily_Matching'];
                    
            // Use Organization Wide Address  
            id owaid;
            for(OrgWideEmailAddress owa : [select id, DisplayName, Address from OrgWideEmailAddress  WHERE Address LIKE '%client%']) {
            if(owa.DisplayName.contains('Collin'))  owaid = owa.id; OWASender = owa.DisplayName + '<' + owa.Address + '>'; }       
             
            for(Id cID:clist) {
                
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateID(templateId.Id); 
                mail.setTargetObjectId(cID);
                mail.setSaveAsActivity(true);
                mail.setReplyTo('ClientServices@zadoon.com');
                
                mail.setOrgWideEmailAddressId(owaid);
                mail.setReferences('Account;' + AccountName.get(cID) + ';ContactName;' + ContactName.get(cID) + ';OWASender;' + OWASender);         
                
                              
                allmsg.add(mail);
                    
                    
                System.debug('mail '+mail);
          
            } 
            
            /* return allmsg; */
            system.debug(allmsg);
            if(DailyIronDemandMatchingEmail_Production == true)
                Messaging.sendEmail(allmsg,false); 
       }
       return allmsg;
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
  }
}