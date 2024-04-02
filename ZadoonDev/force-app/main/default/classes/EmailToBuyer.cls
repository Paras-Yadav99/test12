public class EmailToBuyer {
    /*
	 *this method is used to send the email to the contact when Ever Is_Payment_Sent__c is changed to true
	 */
    //EmailEventHelper.handleSendEmailOnIs_Payment_SentUpdation
    public static Messaging.SingleEmailMessage handleSendEmailOnIs_Payment_SentUpdation(opportunity eachOpportunity,list<string> lstEmailToCC){
        String emailSubject ='Proceeding with purchase of ';
        if(eachOpportunity.Year_from_Unit__c != null){
            emailSubject += '<b>'+eachOpportunity.Year_from_Unit__c+'</b> ';
        }
        if(string.isnotblank(eachOpportunity.Manufacturer__c)){
            emailSubject +='<b>'+ eachOpportunity.Manufacturer__c+'</b> ';
        }
        if(string.isnotblank(eachOpportunity.Model__c)){
            emailSubject +='<b>'+ eachOpportunity.Model__c+'</b> ';
        }
        if(string.isnotblank(eachOpportunity.Unit_S_N__c)){
            emailSubject += 'SN' + eachOpportunity.Unit_S_N__c+' ';
        }
         
        
        String htmlBody = createHTMLSalesOppEmailBody(eachOpportunity);
        
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if(String.IsNotBlank(eachOpportunity.Contact_Email__c)){
            email.setToAddresses(new List<String>{eachOpportunity.Contact_Email__c});
        }
        email.setSubject(emailSubject);
        email.setHtmlBody(htmlBody);
        // emailMessages.add(email);
        // Send emails in a single transaction
        // Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(emailMessages);
        return email;
        
    }
    
    private static string createHTMLSalesOppEmailBody(Opportunity eachOpportunity){
        String htmlBody = '';
        htmlBody +=    '<p>We are ready to proceed with the purchase of';
        If(string.isnotblank(eachOpportunity.Year_from_Unit__c)){
        htmlBody +=  '<b>'+  eachOpportunity.Year_from_Unit__c+'</b> ';
            
        }
        if(string.isnotblank(eachOpportunity.Manufacturer__c)){
             htmlBody += '<b>'+eachOpportunity.Manufacturer__c+'</b> ';
        }
        if(string.isnotblank(eachOpportunity.Model_from_Unit__c)){
            htmlBody += '<b>'+eachOpportunity.Model_from_Unit__c+'</b> ';
        }
        if(eachOpportunity.Hours_from_Units__c != null){
             htmlBody += 'with<b>' + eachOpportunity.Hours_from_Units__c + '</b> hours';
        }
        if(string.isnotblank(eachOpportunity.Unit_S_N__c)){
           htmlBody += 'and Serial Number <b>' + eachOpportunity.Unit_S_N__c +'</b>.';
        }
              htmlBody +=   'You will find our tax exemption form attached for your records.</p>'+'<br>';

        htmlBody += '<p>Please provide the following at your earliest convenience:</p>';
        htmlBody += '<ul><li>Your W-9 form - if you’ve sent us one within the last year, you do not need to resend</li><li>An invoice/bill of sale, which must include the following:</li><ul>';
        htmlBody +='<li>Invoice to:<ul><li>Zadoon, LLC</li><li>1268 Cronson Blvd, Bldg E</li><li>Crofton, MD 21114</li></ul></li>';
        htmlBody += '<li>Invoice from:<ul><li>Beneficiary Account Name</li><li>Beneficiary Account full Address including Street, City, State,';
        htmlBody += 'and Zip</li><li>Beneficiary Phone</li><li>Beneficiary Email</li>';
        if(string.isnotblank(eachOpportunity.Product__c)){
          htmlBody +=  '<li>Purchase Order #<b> '+eachOpportunity.Product__c +'</b> (Purchase Order # must be explicitly listed on invoice)</li>';
        }
        if(string.isnotblank(eachOpportunity.Unit_S_N__c)){
          htmlBody += '<li>Serial/VIN<b>' +eachOpportunity.Unit_S_N__c + '</b> (Serial/VIN must be explicitly listed on invoice)</li>';
        }
        
        htmlBody += '<li>The verbiage, "Machine is confirmed free and clear of any and all liens and encumbrances"</li><li>';
        htmlBody +='If there is a lien, please provide a current payoff quote and point of contact for the lienholder</li>';
        htmlBody +='</ul></li><li>Wire instructions:<ul>';
        htmlBody += '<li>Bank Name</li><li>Bank branch full Address including Street, City, State, and Zip</li><li>Bank Routing Number (we need both ACH and Wire routing numbers)</li>';
        htmlBody += '<li>Bank Account Number</li><li>Billing Contact Name and Phone Number (we will be calling this contact to confirm wire instructions verbally to avoid wire fraud issues)</li>';
        htmlBody += '<li>Bank Representative Name and Phone Number (if available)</li></ul></li><li>The exact address and site contact of the machine (name and phone number)</li>';
        htmlBody += '<li>The size of the attachment (bucket, blade, etc.; dimensions and capacity please)</li><li>Any known issues with the units being inspected</li>';
        htmlBody += '<li>Site requirements (PPE, hours of operation, check-in procedure, etc.)</li></ul>';
        htmlBody += '<li>*** note - all of our purchases are subject to inspection. If our inspection has already been conducted, this section does not apply. ';
        htmlBody += 'We will wire your funds after we’ve inspected the unit.Your invoice secures the machine for Zadoon while we await the inspection.';
        htmlBody += 'Please note that an unsatisfactory inspection may result in Zadoon rescinding or adjusting the offer amount.</li>';
        htmlBody += '</ul><p><a href="https://groove-assets.s3.us-west-2.amazonaws.com/attachments/1668004712-Zadoon%20Tax%20Exemption%20Certificate.pdf" >Zadoon Tax Exemption Certificate.pdf</a></p>';

   
        RETURN htmlBody;
        
    }
    
    
}



/*<!DOCTYPE html>



                    


*/