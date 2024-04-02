global class emailMatchingUnitstoContacts Implements Schedulable {


    global void execute(SchedulableContext sc) {
        EmailMethodUnitIDContacts();
    }


    Webservice static void EmailMethodUnitIDContacts() {
/*      
        Set<Id> elist = new Set<Id>();
        Set<Id> clist = new Set<Id>();

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

        for(List<Product2History> phlist : [SELECT Id, Product2Id, OldValue, NewValue, 
                                    IsDeleted, Field, CreatedDate, CreatedById, 
                                    CreatedBy.Name, Product2.equipment__c from Product2History WHERE CreatedDate >=  LAST_N_DAYS:1 AND Field = 'Unit_Stage__c']) {

            for(Product2History phlist2 : phlist) {
                if(phlist2.CreatedDate >= system.now().AddDays(-1) && phlist2.NewValue == 'Advertising') {
                    elist.add(phlist2.Product2.equipment__c); // adds unique equipment id to set

                    system.debug(phlist2.Product2.equipment__c);
                }
            }
                                  
                                       
            system.debug('in here3');
            system.debug(elist);  
            
            // need to get contacts w/ iron demand for equipment id
            
            for(List<Iron_Demand__c> idlist : [SELECT IronDemand_Contact__c From Iron_Demand__c WHERE IronDemand_Iron__c IN :elist ]) {
               for(Iron_demand__c idlist2 : idlist) {
                   clist.add(idlist2.IronDemand_Contact__c);
               }
            }
            
            system.debug('clist');
            system.debug(clist);
            

          
            EmailTemplate templateId = [Select id from EmailTemplate where DeveloperName = 'Iron_Demand_Daily_Matching'];
            
            for(Id cID:clist) {
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateID(templateId.Id); 
                mail.setTargetObjectId(cID);
                mail.setSaveAsActivity(true);
                mail.setReplyTo('collin@zadoon.com');
                mail.setSenderDisplayName('Collin Magliolo');
                
                allmsg.add(mail);
                    
                System.debug('mail '+mail);
          
            }
            
  
        }
                    Messaging.sendEmail(allmsg,false);
        */
    }     
}