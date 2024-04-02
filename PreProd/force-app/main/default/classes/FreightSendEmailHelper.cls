/*
This class is used to send the Freight Emails to the selected Account's Primary Contact's Emails
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          08-Aug-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/

public class FreightSendEmailHelper {
    public class newException extends Exception {} 
    /*
     * This method is used to send the Emails and retrun the success messages
	 */
    
    public static String sendFreightEmail(list<Account> lstAccount , Product2 eachUnit,Map<String,Freight_Company_Unit__c> mapAccountIdVsEachFreight_Company_Unit){
        System.debug('Send Emailclass is called.................');
        String message = 'Error Occur!!';
        List<Messaging.SingleEmailMessage> lstMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        if(lstAccount!=null && ! lstAccount.IsEmpty()){
            for(Account eachAccount : lstAccount){
                if(mapAccountIdVsEachFreight_Company_Unit.ContainsKey(eachAccount.Id) && mapAccountIdVsEachFreight_Company_Unit.get(eachAccount.Id)!=null)
                lstMessagingSingleEmailMessage.add(getEmails(eachAccount,eachUnit,mapAccountIdVsEachFreight_Company_Unit.get(eachAccount.Id)));
            } 
        } 
        if(lstMessagingSingleEmailMessage!=null && ! lstMessagingSingleEmailMessage.IsEmpty()){
        Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(lstMessagingSingleEmailMessage);
        message = 'Freight Emails are send successfully!! ';
        }else{
            throw new newException('Emails are not sent,recipients are not found!!'); 
        }

        return message;
    }
    
     /*
     * This method is used to provide the Messaging.SingleEmailMessage to send the Email.
	 */
    
 private static Messaging.SingleEmailMessage getEmails(Account eachAccount , Product2 eachUnit,Freight_Company_Unit__c eachFreight_Company_Unit) {
     
     	String emailSubject ='Freight Request:';
     String str1 = '';
     /*If(eachUnit.Freight_Ready_to_move__c){
         emailSubject +=' ready to move ';
     }else{
         emailSubject +=' quote only ';
     }
     If(String.isNotBlank(eachUnit.Year__c)){
         str1 += eachUnit.Year__c +' ';
     }*/
     If(String.isNotBlank(eachUnit.Manufacturer__c)){
         str1 += eachUnit.Manufacturer__c +' ';
     }
     str1 ='{'+ eachUnit.Model__c +' ' +eachUnit.ZID__c + ' - From '+eachFreight_Company_Unit.Storage_City__c+', '+eachFreight_Company_Unit.Storage_State__c +' }';
     str1 +=' To '+eachFreight_Company_Unit.Destination_City__c+', '+eachFreight_Company_Unit.Destination_State__c;// +'- PO # '+eachUnit.Name;
     emailSubject +=str1;
     If(eachUnit.Freight_Ready_to_move__c){
         emailSubject +=' Ready to move ';
     }else{
         emailSubject +=' Quote Only ';
     } 
        String emailBody = createEmailTemplate(eachAccount , str1, eachUnit,eachFreight_Company_Unit);
        
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{eachAccount.Primary_Contact__r.Email});
            email.setSubject(emailSubject);
            email.setHtmlBody(emailBody);
     		//email.setTargetObjectId(eachUnit.Id);
     		//email.setSaveAsActivity(true);
            //emailMessages.add(email);
        
        // Send emails in a single transaction
       // Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(emailMessages);
		return email;

    }
    
    /*
     * This method is used to provide the email body to send the Email.
	 */
    private static String createEmailTemplate(Account eachAccount , String str1,Product2 eachUnit,Freight_Company_Unit__c eachFreight_Company_Unit){
        String htmlBody ='';
        If(String.isNotBlank(eachAccount.Primary_Contact__r.FirstName)){
          htmlBody +=eachAccount.Primary_Contact__r.FirstName +',<br><br>';
        }
        String SiteURL = '';
        If(String.isNotBlank(System.Label.Freight_Site_URL)){
            SiteURL = System.Label.Freight_Site_URL + eachFreight_Company_Unit.Id;
        }
         
 		htmlBody += 'We are requesting a quote for the following unit.';
        If(eachUnit.Freight_Ready_to_move__c){
            
        htmlBody +=' This load is ready to move, please provide your earliest pickup date <br><br>';
        }else{
         htmlBody +=' We are only requesting quotes at this time, this load is not yet ready to move. <br><br>';
        }
        htmlBody +=' Unit : ' +eachUnit.Year__c +' '+eachUnit.Make__c +' '+eachUnit.Model__c +'<br>';
        htmlBody += ' PO# : ' +eachUnit.ZID__c +'<br>';
        htmlBody +=' Origin : ' +eachFreight_Company_Unit.Storage_City__c +' '+eachFreight_Company_Unit.Storage_State__c +'<br>';
        htmlBody += ' Destination : ' +eachFreight_Company_Unit.Destination_City__c +' '+eachFreight_Company_Unit.Destination_State__c  +'<br>';
        htmlBody += ' Heading to a port : ' +eachFreight_Company_Unit.Going_to_Port__c +'<br>';
        htmlBody += ' Unit Photos : <a href="' +eachUnit.Google_Drive_LInk__c + '" target="_blank"> Photos </a>'+'<br>';
       // htmlBody += ' Unit : ' +eachUnit.Year__c +'<br>';
        htmlBody += ' Unit Specs : <a href="' +eachUnit.Equipment_Specalog__c + '" target="_blank"> Unit SpecaLog </a>' +'<br><br>';
       // htmlBody +='Please fill out the below form to provide your best quote. ';
        htmlBody += '<b>Please <a href="' + SiteURL + '" target="_blank">click this link</a> provide your best Quote.</b>'+'<br><br>';
        htmlBody += 'Once submitted, we will keep you updated on progress.'+'<br><br>';
        htmlBody +=' If we proceed with this load, you will receive a Rate Con via “DropBox Sign” which is our e-signature platform.'+'<br><br>';     
        htmlBody +='Thank you!';
              
        return htmlBody;
    }
}