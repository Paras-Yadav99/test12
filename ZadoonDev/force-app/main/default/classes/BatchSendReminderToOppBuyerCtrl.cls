/*
This Batch Class is used to handle the events from the BatchToSendInspectionEmailOnInspection
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          16-Aug-2023           Kizzy Consulting     Pushkar               Initial Version
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
                    /*
                    If(String.IsNotBlank(eachUnitInspection.Inspection_Inspector__c)&& String.IsNotBlank(eachUnitInspection.Inspection_Inspector__r.Email)){
                        String Subject ='Inspection Request:';
                        If(String.IsNotBlank(eachUnitInspection.Unit__r.Year__c)){
                        Subject +=' '+eachUnitInspection.Unit__r.Year__c;
                        }
                        If(String.IsNotBlank(eachUnitInspection.Unit__r.Manufacturer__c)){
                        Subject +=' '+eachUnitInspection.Unit__r.Manufacturer__c;
                        }
                        If(String.IsNotBlank(eachUnitInspection.Unit__r.Model__c)){
                        Subject +=' '+eachUnitInspection.Unit__r.Model__c;
                        }
                        If(String.IsNotBlank(eachUnitInspection.Unit__r.Storage_City__c)){
                        
                        Subject +=' '+eachUnitInspection.Unit__r.Storage_City__c;
                        }
                        If(String.IsNotBlank(eachUnitInspection.Unit__r.Storage_State__c)){
                        Subject +=', '+eachUnitInspection.Unit__r.Storage_State__c;
                        }*/
                     String Subject = 'Reminder Email to Buyer.';
                        list<string>lstString = new list<String>{eachOpportunityFieldHistory.Opportunity.Primary_Contact_email__c};
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