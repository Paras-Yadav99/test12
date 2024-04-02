public class SendUnitDetailsToContacts implements Database.Batchable<sObject>{
    public Set<Id> contactIds;
    public String htmlBody;
    public List<Product2> unitList = new List<Product2>();
    public SendUnitDetailsToContacts(set<Id> contactIds, String htmlBody){
        this.contactIds = contactIds;
        this.htmlBody = htmlBody;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT id, Name , Owner.Email, Email '
                      +'FROM Contact Where Id in :contactIds';
       return Database.getQueryLocator(query);
    }

     public void execute(Database.BatchableContext BC, List<Contact> contactList){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List<String> contactEmails = new List<String>();
        for(Contact con: contactList){
            contactEmails.add(con.Email);
        }
        message.toAddresses = contactEmails;
        message.optOutPolicy = 'FILTER';
        message.subject = 'Zadoon : Units Details';
        System.debug('Html Body: '+htmlBody);
        message.htmlBody = htmlBody;
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                 Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                  + results[0].errors[0].message);
        }
       
    }

    public void finish(Database.BatchableContext BC){
    }
}