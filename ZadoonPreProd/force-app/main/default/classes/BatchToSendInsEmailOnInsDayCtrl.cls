/*
This Batch Class is used to handle the events from the BatchToSendInspectionEmailOnInspection
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          16-Aug-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/
public class BatchToSendInsEmailOnInsDayCtrl {
    
    // controller methode for batch execution 
    public static void handleExecution(list<Unit_Inspection__c>lstUnitInspections){
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
            If(lstUnitInspections!=Null && ! lstUnitInspections.IsEmpty()){
                for(Unit_Inspection__c eachUnitInspection : lstUnitInspections){
                    
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
                        }
                        list<string>lstString = new list<String>{eachUnitInspection.Inspection_Inspector__r.email};
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.toAddresses = lstString;
                        message.optOutPolicy = 'FILTER';
                        message.subject = Subject;
                        message.htmlBody =  getEmailHTMLBody(eachUnitInspection.Inspection_Inspector__r.Name,eachUnitInspection);
                        If(lstToCCString != Null && !lstToCCString.IsEmpty()){
                            message.setccAddresses(lstToCCString);
                        }
                        lstEmail.add(message);
                    }
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
    private static string getEmailHTMLBody(String Name,Unit_Inspection__c eachUnitInspection){
        String htmlBody ='Hi '+Name +',<br><br>';
        
        htmlBody +='It’s '+String.valueOf(eachUnitInspection.Inspection_Date__c)+' today, and I wanted to confirm that you are still scheduled for {inspection time}.  Can you please reply-all to this email and confirm?  Also, please let me know if you have any questions regarding the inspection in the meantime.<br>';
        
        htmlBody +='Thanks,';
        
        return htmlBody;

    }
/*    
     public static string emailHTMLBody(string productId, string Name){
        String htmlBody ='Hi '+Name +',<br><br>';
             
        htmlBody +='We need this pre-purchase inspection as soon as possible, and would love your help in getting it done.<br><br>';
        htmlBody +='Here is the link you (or an employee/inspector) can use to finish the inspection report https://zadoon1234--dev.sandbox.my.salesforce-sites.com/?parm1='+productId +'<br><br>';
        htmlBody +='You will find the unit details, such as make, model, serial, address, and site contact listed within the link. <br><br>';
        htmlBody +='<b>Please note that this is a time-sensitive matter- </b> our deal is predicated on the information that we obtain from you in this inspection. We realize that your schedule may be busy, and we are happy to work with you in terms of getting us on the schedule. However, we require all completed inspection forms, photos, videos, ECU readings, service history, and invoice/receipt etc. to be delivered to us within twenty-four (24) hours of the inspection being completed.<br><br>';
       
        htmlBody +='<b>Services requested checklist - all items must be completed!</b><br><br>';
        htmlBody +='[  ] Limit tech to two (2) hours on site; should not take more than about 90 minutes to complete this inspection <br>';
        htmlBody +='[  ] If any items on the checklist are not marked "A" please provide an explanation as to why <br>';
        htmlBody +='[  ] Call Hardy at 970-310-0202 while still at the machine, but when completed with inspection for a quick 5-minute phone call <br>';
        htmlBody +='[  ] Obtain a full list of active and archived codes <br>';
        htmlBody +='[  ] Provide ECU reading and related info (Matris/CatFacts/KomCare/KomTrax/and the like - if you are an on-brand dealer for the machine) <br>';
        htmlBody +='[  ] Provide any service history (if you are an on-brand dealer for the machine) <br><br>';
        htmlBody +='If your tech needs more than 2 hours to complete this inspection, please have him/her call Hardy at the 2-hour point for instructions as to whether to proceed. Please let me know a rough estimate and time frame to get this done. <br><br>';
        htmlBody +='I will also be your contact for payment. <br><br>';
        htmlBody +='Thanks,';
              
        return htmlBody;
    }
*/
}