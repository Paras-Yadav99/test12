/*
*this class is used to hold all the event regarding the email to any related person
*/
public class EmailEventHelper {
    
    /*
	 *this method is used to send the email to the contact when Ever Is_Payment_Sent__c is changed to true
	 */
    //EmailEventHelper.handleSendEmailOnIs_Payment_SentUpdation
    public static Messaging.SingleEmailMessage handleSendEmailOnIs_Payment_SentUpdation(opportunity eachOpportunity, string OrgWideEmail){
        String emailSubject ='Opportunity Sales Process Opportunity ';
        
        String htmlBody = createHTMLSalesOppEmailBody(eachOpportunity);
        
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if(String.IsNotBlank(eachOpportunity.Buyer_Primary_Contact__r.Email)){
            email.setToAddresses(new List<String>{eachOpportunity.Buyer_Primary_Contact__r.Email});
        }
        email.setSubject(emailSubject);
        email.setHtmlBody(htmlBody);
        // emailMessages.add(email);
        email.setOrgWideEmailAddressId(OrgWideEmail); //The sender of this email is Mellisa
        // Send emails in a single transaction
        // Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(emailMessages);
        return email;
        
    }
    
    private static string createHTMLSalesOppEmailBody(Opportunity eachOpportunity){
        String htmlBody = '';
        
        If(String.isNotBlank(eachOpportunity.Buyer_Primary_Contact__c) && String.isNotBlank(eachOpportunity.Buyer_Primary_Contact__r.Name)){
        htmlBody +=eachOpportunity.Buyer_Primary_Contact__r.Name +'<br><br>';
        }
        
        If(String.isNotBlank(eachOpportunity.Buyer_Primary_Contact__c) && String.isNotBlank(eachOpportunity.Buyer_Primary_Contact__r.Name)){
           // htmlBody +='This is to inform you that your payment in the amount of {offeramount}';
        }
        
        If(String.isNotBlank(eachOpportunity.Product__c) && String.isNotBlank(String.ValueOf(eachOpportunity.Product__r.Final_Sale_Price__c))){
            htmlBody +='This is to inform you that your payment in the amount of '+eachOpportunity.Offer_Amount__c;
        }
        
         If(String.isNotBlank(eachOpportunity.Product__c) && String.isNotBlank(String.ValueOf(eachOpportunity.Year_from_Unit__c))){
            htmlBody +=' for '+eachOpportunity.Year_from_Unit__c;
        }
         If(String.isNotBlank(eachOpportunity.Product__c) && String.isNotBlank(String.ValueOf(eachOpportunity.product__r.Manufacturer__c))){
            htmlBody +=' '+eachOpportunity.product__r.Manufacturer__c;
        }
         If(String.isNotBlank(eachOpportunity.Product__c) && String.isNotBlank(String.ValueOf(eachOpportunity.Model_from_Unit__c))){
            htmlBody +=' '+eachOpportunity.Model_from_Unit__c;
        }
         If(String.isNotBlank(eachOpportunity.Product__c) && String.isNotBlank(String.ValueOf(eachOpportunity.Unit_S_N__c))){
            htmlBody +='with serial number '+eachOpportunity.Unit_S_N__c;
        }
        htmlBody +=' has been processed.<br><br>';  
        
        htmlBody +='Please confirm that you have received the payment within 24 hours of this communication., and contact your representative at Zadoon if you have any questions.<br><br>';  
        
        htmlBody +='I will be coordinating transportation of the machine with ';
         htmlBody +=eachOpportunity.Owner.FirstName+' and will keep you informed.<br><br>';
        
        htmlBody +='Here at Zadoon, our purpose is to contend for the highest good of each other and our customers, vendors, and communities.  We relish the opportunity to live out this purpose, and we hope to become a consistent outlet for your surplus equipment.<br><br>';  
        htmlBody += 'Warm regards,<br><br>';
        htmlBody += 'Melissa Constantopolous<br><br>';
        
        htmlBody += 'Office Manager<br><br>';
        
        htmlBody += 'The Zadoon Team <br><br>';
        RETURN htmlBody;
        
    }
    

}