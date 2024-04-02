global class emailStaleUnitLeads Implements Schedulable {

    public boolean display{get; set;}
    public boolean SendEmail {get; set;}

    global void execute(SchedulableContext sc) {
        SendEmail = true;
        GetEmailMethod();
    }

    public emailStaleUnitLeads() {
         display = false;
    }

    Public PageReference GetRecordPage(){
    
        display = true;
        SendEmail = false;
        GetEmailMethod();
    
       return null;   
    }


    Public List<Messaging.SingleEmailMessage> GetEmailMethod() {
     
        List<Contact> clist;
        List<Id> alist = new List<Id>();
        
        date searchdate = Date.today().addDays(-7);
        date lastcontactdate = Date.today().addDays(-14);
        
        /* find accounts with last contact > 14 days ago with units older than 7 days */
        List<AggregateResult> ZIDs = [Select 
        MIN(CreatedAt__c), Lead_Unit_Owner__r.Name AccountName, Lead_Unit_Owner__c, Lead_Unit_Owner__r.Name ContactName
             From
                 Product2
             WHERE 
                 CreatedAt__c <= :searchdate AND 
                 Last_Equipment_Status_Confirmation__c <= :searchdate AND 
                 Lead_Unit_Owner__r.CL_Listing_Status_Last_Checked__c <= :lastcontactdate AND 
                 Unit_Stage__c IN ('Imported', 'Reviewing', 'Pursuing Purchasing', 'Pursuing Brokerage', 
                 'Consider Later', 'Needs Further Analysis', 'Advertising', 'Advertised', 'Keep Only for Iron Demand') AND 
                 IsActive = TRUE AND
                 Lead_Unit_Owner__r.Email != null 
             GROUP BY Lead_Unit_Owner__r.Email, Lead_Unit_Owner__r.Name, Lead_Unit_Owner__c];
                 
        /* Send Lead contacts email if they have product more than 14 days */
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        EmailTemplate templateId = [Select id from EmailTemplate where name = 'Equipment Status for Sale Leads'];
        
        // Use Organization Wide Address  
        id owaid;
        for(OrgWideEmailAddress owa : [select id, DisplayName, Address from OrgWideEmailAddress  WHERE Address LIKE '%client%']) {
            if(owa.DisplayName.contains('Collin'))  owaid = owa.id; }      
        
        for(AggregateResult prod:ZIDs) {
        
            system.debug('prod: ' + prod);
        
            Id ZIDContactID = (Id)prod.get('Lead_Unit_Owner__c');

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateID(templateId.Id); 
            mail.setTargetObjectId(ZIDContactID);
            mail.setWhatId(prod.Id);
            mail.setSaveAsActivity(true);
            mail.setReplyTo('ClientServices@zadoon.com');
           
            mail.setOrgWideEmailAddressId(owaid);
            mail.setReferences('<' + prod.get('ContactName') + '@' + prod.get('AccountName') + '.com>');  
            
            
            allmsg.add(mail);
            alist.add(ZIDContactID);
                
            System.debug('mail '+mail);
      
        }
        
        if(SendEmail == true) {
            Messaging.sendEmail(allmsg,false); 
            
            List<Lead> acctList = [SELECT Id FROM Lead WHERE Id IN :alist];
            
            for(Lead acct :acctList){
                acct.CL_Listing_Status_Last_Checked__c = date.today();
            }
    
            update acctList;
        }
            

            
        return allmsg;
        
        
    }

}