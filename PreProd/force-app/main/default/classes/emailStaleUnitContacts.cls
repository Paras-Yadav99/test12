global class emailStaleUnitContacts Implements Schedulable {

    public boolean display{get; set;}
    public boolean SendEmail {get; set;}

    global void execute(SchedulableContext sc) {
        SendEmail = true;
        GetEmailMethod();
    }

    public emailStaleUnitContacts() {
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
        date lastcontactdate = Date.today().addDays(-21);
        
        /* find accounts with last contact > 21 days ago with units older than 7 days */
        List<AggregateResult> ZIDs = [Select 
        MIN(CreatedAt__c), Account__c AccountID, Account__r.Name AccountName, Account__r.Primary_Contact__c, Account__r.Primary_Contact__r.Name ContactName
             From
                 Product2
             WHERE 
                 CreatedAt__c <= :searchdate AND 
                 Last_Equipment_Status_Confirmation__c <= :searchdate AND 
                 Account__r.CL_Listing_Status_Last_Checked__c <= :lastcontactdate AND 
                 Unit_Stage__c IN ('Imported', 'Reviewing', 'Pursuing Purchasing', 'Pursuing Brokerage', 
                 'Consider Later', 'Needs Further Analysis', 'Advertising', 'Advertised', 'Keep Only for Iron Demand') AND 
                 IsActive = TRUE AND
                 Account__r.Do_not_send_equipment_status_emails__c = false AND
                 Account__r.Not_A_Client_We_Want_To_Do_Business_With__c   = false AND 

                 Account__r.Primary_Contact__c != null AND 
                 Account__r.Primary_Contact__r.Email != null 
             GROUP BY Account__c, Account__r.Name, Account__r.Primary_Contact__c, Account__r.Primary_Contact__r.Name];
                 
        /* Send Account contacts email if they have product more than 30 days */
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        EmailTemplate templateId = [Select id from EmailTemplate where name = 'Equipment Status for Sale'];
        
        // Use Organization Wide Address  
        id owaid;
        for(OrgWideEmailAddress owa : [select id, DisplayName, Address from OrgWideEmailAddress  WHERE Address LIKE '%client%']) {
            if(owa.DisplayName.contains('Collin'))  owaid = owa.id; }      
        
        for(AggregateResult prod:ZIDs) {
        
            system.debug('prod: ' + prod);
        
            Id ZIDContactID = (Id)prod.get('Primary_Contact__c');
            Id AccountID = (Id)prod.get('AccountID');

            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateID(templateId.Id); 
            mail.setTargetObjectId(ZIDContactID);
            mail.setWhatId(prod.Id);
            mail.setSaveAsActivity(true);
            mail.setReplyTo('ClientServices@zadoon.com');
           
            mail.setOrgWideEmailAddressId(owaid);
            mail.setReferences('<' + prod.get('ContactName') + '@' + prod.get('AccountName') + '.com>'); 
            
            
            allmsg.add(mail);
            alist.add(AccountID);
                
            System.debug('mail '+mail);
      
        }
        
        if(SendEmail == true) {
            Messaging.sendEmail(allmsg,false); 
            
            List<Account> acctList = [SELECT Id FROM Account WHERE Id IN :alist];
            
            for(Account acct :acctList){
                acct.CL_Listing_Status_Last_Checked__c = date.today();
            }


    
            update acctList;
        }
            

            
        return allmsg;
        
        
    }

}