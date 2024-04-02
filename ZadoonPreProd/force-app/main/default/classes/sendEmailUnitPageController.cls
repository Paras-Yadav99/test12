/*
* Author : Akhtar Husain
* Created Date: 12 Nov, 2020
* Description: Purpose of this class to send email to the contacts under iron demands from unit record page
* Reference: button 'Send email to contacts' that use sendEmailUnitPage vf page

*/
public with sharing class sendEmailUnitPageController {
    public List < WrapperClass > wrapperList {get; set;}
    public Product2 prod {get; set;}
    public String error {get; set;}
    public Product2 equipmentID {get; set;}
    
    public sendEmailUnitPageController(apexPages.StandardController controller){
        prod = (Product2)controller.getRecord();
        error = '';
        getContact();
    }
    
    // private method to get contact list under equipment iron demands when page loads
    private void getContact() {
        try {
            equipmentID = [SELECT id,Model__c,Category__c,Product_Price_Unit__c,Name,equipment__c,equipment__r.Name,DisplayUrl,Make__c,Year__c,Hour__c,Displayed_Vague_Location__c,Old_SF_Unit_Details__c,ZID__c,Google_Drive_LInk__c,Google_Drive_Videos_Link__c
                           FROM Product2 WHERE ID = :prod.id AND isActive=true];
            wrapperList = new List < WrapperClass > ();
            List< String > contactFields = UtilityClass.getAllFields('Contact');
            String soql = 'Select '+String.join(contactFields, ',')+',Account.Name '
                +' From Contact Where ID IN (SELECT IronDemand_Contact__c FROM Iron_Demand__c WHERE IronDemand_Iron__c = '+' \'' + String.escapeSingleQuotes(equipmentID.equipment__c) + '\'' +'AND IsActive__c = TRUE)'
                +' AND Email != Null AND Client_Email_Opt_Out__c = false AND Not_A_Client_We_Want_To_Do_Business_With__c = false ';
            system.debug('soql ===>'+soql);
            for( Contact con : database.query(soql) ){
                wrapperList.add( new WrapperClass(con,false) );
            }
            
            System.debug('wrapperList==>' + wrapperList);
            if( wrapperList.size() == 0 ) {
                error = 'No contact(s) found to send email!';
            }
            
        } catch( Exception ex ) {
            error = utilityClass.ERROR_MSG+'<br/> Technical issue: '+ex.getMessage()+', Exception Type: '+ex.getTypeName()+', At Line: '+ex.getLineNumber();
            system.debug('error occured >>>>'+ex);
        }
    }
    
    // This method used to send machine details over email to selected contacts
    
    public void sendEmail() {
        try {
            EmailTemplate template = [Select id from EmailTemplate where DeveloperName = 'Z2_Unit_to_Iron_Demand_Contact_Email'];
            // EmailTemplate template = [Select id,HtmlValue From EmailTemplate Where developerName='Equipment_Email' LIMIT 1];
            OrgWideEmailAddress[] owea = UtilityClass.owea;
            List< Messaging.SingleEmailMessage > emails = new List< Messaging.SingleEmailMessage >();
            for( WrapperClass wrap : wrapperList ) {
                if( wrap.isSelected ) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTargetObjectId( wrap.con.id );
                    if(owea != null && owea.size() > 0) email.setOrgWideEmailAddressId( owea.get(0).Id );
                    email.setTemplateId( template.id );
                    email.setWhatId( equipmentID.id );
                    email.setSaveAsActivity( true );
                    emails.add( email );
                }
            }
            List< Messaging.SendEmailResult > result = new List< Messaging.SendEmailResult >();
            if( !test.isRunningTest() ) {
                result = Messaging.sendEmail( emails,false );
            }
            if( result.size()>0  && result[0].isSuccess() ) {
                system.debug('email sent successfully!');
                error = UtilityClass.EMAIL_SUCCESS_MSG;
            } else if( result.size()>0 ) {
                error = UtilityClass.EMAIL_ERROR_MSG+'<br/> Technical issue: '+result[0].getErrors();
                system.debug('error occured ===>'+result[0].getErrors());
            }
            
        }catch( Exception e ) {
            error = utilityClass.ERROR_MSG+'<br/> Technical issue: '+e.getMessage()+', Exception Type: '+e.getTypeName()+', At Line: '+e.getLineNumber();
            system.debug('Error occurs while sending emails ==>'+e);
        }  
    }
}