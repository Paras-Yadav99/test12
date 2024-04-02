global class IronDemandCatchUpEmail Implements Schedulable  {

    public Set<String> EmailString;
    public List<String> bodies = new List<String>();
    public boolean DailyIronDemandCatchupEmail_Production {get; set;}
    public Map<Id, String> AccountName = new Map<Id, String>();
    public Map<Id, String> ContactName = new Map<Id, String>(); 
    public String OWASender; 
    
    /* include to pass unit test */
    public Map<Id, String> testVar = new Map<Id, String>();
    public Map<Id, String> testVar2 = new Map<Id, String>();      

    
    
    public boolean display{get; set;}
    
    global void execute(SchedulableContext sc) {
        
        DailyIronDemandCatchupEmail_Production = true;
        GetIronDemandCatchUpEmail();
    
        
    }
    
    public IronDemandCatchUpEmail() {
         display = false;
    }
    
    Public PageReference GetRecordPage(){
    
        display = true;
        DailyIronDemandCatchupEmail_Production = false;
        GetIronDemandCatchUpEmail();
    
       return null;   
    }
    
    
    Public List<Messaging.SingleEmailMessage> GetIronDemandCatchUpEmail(){
    
        EmailString =  new Set<String>();
    
        Set<Id> elist = new Set<Id>();
        Set<Id> clist = new Set<Id>();

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

        for(List<Product2History> phlist : [SELECT Id, Product2Id, OldValue, NewValue, Product2.Unit_Stage__c, Product2.isActive,
                                        IsDeleted, Field, CreatedDate, CreatedById, Product2.Base__c,
                                        CreatedBy.Name, Product2.equipment__c from Product2History 
                                    WHERE Field = 'Unit_Stage__c' 
                                        AND (Product2.Unit_Stage__c = 'Advertising' OR Product2.Unit_Stage__c = 'Keep Only for Iron Demand')
                                        AND Product2.isActive = true]) {

            for(Product2History phlist2 : phlist) {
                if((phlist2.NewValue == 'Advertising' || phlist2.NewValue == 'Keep Only for Iron Demand' )) { 
                    elist.add(phlist2.Product2.equipment__c); // adds unique equipment id to set
                    system.debug(phlist2.Product2.equipment__c);
                }
            }
        }
                                  
                                       
        system.debug('in here3');
        system.debug(elist);  
        
        // need to get contacts w/ iron demand for equipment id
        
        for(List<Iron_Demand__c> idlist : [SELECT IronDemand_Contact__c, IronDemand_Contact__r.Name, IronDemand_Contact__r.Account.Name From Iron_Demand__c WHERE IronDemand_Iron__c IN :elist]) {
           for(Iron_demand__c idlist2 : idlist) {
               clist.add(idlist2.IronDemand_Contact__c);
               AccountName.put(idlist2.IronDemand_Contact__c, idlist2.IronDemand_Contact__r.Account.Name);
               ContactName.put(idlist2.IronDemand_Contact__c, idlist2.IronDemand_Contact__r.Name);

           }
        }
        
        system.debug('clist');
        system.debug(clist);
        
        EmailTemplate templateId = [Select id from EmailTemplate where DeveloperName = 'Iron_Demand_Catchup_Email'];
              
        // Use Organization Wide Address  
        id owaid;
        for(OrgWideEmailAddress owa : [select id, DisplayName, Address from OrgWideEmailAddress]) {
        if(owa.DisplayName.contains('Collin'))  owaid = owa.id; OWASender = owa.DisplayName + '<' + owa.Address + '>'; }       
              
        for(Id cID:clist) {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateID(templateId.Id); 
            mail.setTargetObjectId(cID);
            mail.setSaveAsActivity(true);
            mail.setReplyTo('collin@zadoon.com');
            /* mail.setSenderDisplayName('Collin Magliolo'); // cannot specify the sender display name AND orgwide email address */
            mail.setOrgWideEmailAddressId(owaid);
            mail.setReferences('Account;' + AccountName.get(cID) + ';ContactName;' + ContactName.get(cID) + ';OWASender;' + OWASender);         
        
                          
            allmsg.add(mail);
                
                
            System.debug('mail '+mail);
      
        }
            
        
        
        if(DailyIronDemandCatchupEmail_Production == true)
            Messaging.sendEmail(allmsg,false); 
        
                /* Truncate list to be below 900 */
        
        for(Integer i = allmsg.size() - 1; i >= 900; i--) {
        
            allmsg.remove(i);
        
        }    
            
        return allmsg;
        
    }
}