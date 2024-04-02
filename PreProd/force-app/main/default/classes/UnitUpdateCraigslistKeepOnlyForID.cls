global class UnitUpdateCraigslistKeepOnlyForID  {

    
    @InvocableMethod
    Public Static Void UnitUpdateCraigslistKeepOnlyForID(List<Id> ProdID){

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        String OWASender; 
        String OWAEmail;

        Product2 Prod = [SELECT Id, Product2.Account__r.Primary_Contact__c, Unit_Stage__c, Craigslist_Email__c  FROM Product2 WHERE Id IN :ProdID LIMIT 1];
        
        Id cid = Prod.Account__r.Primary_Contact__c;
        
        String stage = Prod.Unit_Stage__c;     
        
        List<String> email = New List<String>();
        email.add(Prod.Craigslist_Email__c);   
        Id productId = Prod.Id;               
        
        
        EmailTemplate templateId = [Select id from EmailTemplate where DeveloperName = 'CL_Followup_Pursuing_Brokerage' LIMIT 1];
            
        // Use Organization Wide Address  
        id owaid;
        for(OrgWideEmailAddress owa : [select id, DisplayName, Address from OrgWideEmailAddress]) {
        if(owa.DisplayName.contains('Brandi') && (stage == 'Pursuing Brokerage' || stage == 'Keep Only for Iron Demand'))  {
          owaid = owa.id; 
          OWASender = owa.DisplayName + '<' + owa.Address + '>'; 
          OWAEmail = owa.Address;
          break;
          }
        if ( owa.DisplayName.contains('Collin') && stage == 'Pursuing Purchasing' )  {
          owaid = owa.id; 
          OWASender = owa.DisplayName + '<' + owa.Address + '>'; 
          OWAEmail = owa.Address;
          break;
          }
          
        
        }       
         
        
            
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(templateId.Id); 
        mail.setToAddresses(email);
        mail.setTargetObjectId(cID);
        mail.setTreatTargetObjectAsRecipient(false); /* used to not send email to target object id */
        mail.setSaveAsActivity(true);
        mail.setReplyTo(OWAEmail);
        mail.setwhatid(productId);

        
        
        
        mail.setOrgWideEmailAddressId(owaid);
        
        system.debug(mail);              
        allmsg.add(mail);
            
        Messaging.sendEmail(allmsg,false);    
 
    }
}