/*
This Batch Class is used to handle the events from the BatchToSendInspectionEmailOnInspection
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0         27-Nov-2023           Kizzy Consulting     Pushkar               Initial Version
------------------------------------------------------------------------------------------------
*/
public class BatchSendReminderToOppBuyerCtrl {
    
    // controller methode for batch execution 
    public static void handleExecution(list<OpportunityFieldHistory>lstOpportunityFieldHistorys){
        //String Subject = 'Reminder Email to Buyer.';
        try{
            list<string>lstToCCString = new list<String>();
            list<User> lstUser = [SELECT Id, Username, Name ,
                                  Email
                                  FROM User 
                                  WHERE IsActive  = true
                                  AND Name=:System.Label.Office_Manager
                                  LIMIT 1];
            
            If(lstUser!=Null && ! lstUser.IsEmpty()){
                for(User eachUser : lstUser){
                    If(String.IsNotBlank(eachUser.Email)){
                        lstToCCString.add(eachUser.Email);
                    }
                }
            }
            
            List<Messaging.SingleEmailMessage> lstEmail= new List<Messaging.SingleEmailMessage>();
            If(lstOpportunityFieldHistorys!=Null && ! lstOpportunityFieldHistorys.IsEmpty()){
                for(OpportunityFieldHistory eachOpportunityFieldHistory : lstOpportunityFieldHistorys){
                     String Subject = 'Reminder Email to Buyer.';
                        list<string>lstString = new list<String>{eachOpportunityFieldHistory.Opportunity.Buyer_Contact_Email__c};
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.toAddresses = lstString;
                        message.optOutPolicy = 'FILTER';
                        message.subject = Subject;
                        message.htmlBody =  getEmailHTMLBody(eachOpportunityFieldHistory.Opportunity.Primary_Contact_First_Name__c);
                       // If(lstToCCString != Null && !lstToCCString.IsEmpty()){
                   	 message.setccAddresses(new List<String>{eachOpportunityFieldHistory.Opportunity.Owner.Email});
                       // }
                        lstEmail.add(message);
                   // }
                }
            }
            If(lstEmail!=Null && ! lstEmail.IsEmpty()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmail);
            }
        } catch (Exception ex) {
            System.debug('Error:::'+ex.getMessage());
        }
    }

    /**
     *This Method is used to provide HTML Template.. 
     */
    private static string getEmailHTMLBody(String Name){
        String htmlBody ='Hi '+Name +',<br><br>';
        
        htmlBody +='It’s '+' a reminder for to sign invoice.';
        
        htmlBody +='Thanks,';
        
        return htmlBody;

    }
}