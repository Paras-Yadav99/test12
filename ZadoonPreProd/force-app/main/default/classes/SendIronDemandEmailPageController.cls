/*
Author: Akhtar Husain TGS
Created Date: 18 Nov, 2020
Description: This Class send the iron demand unit under Iron Demand. Button on Iron Demand 'Units to Contact' that send email to Contact
*/

public with sharing class SendIronDemandEmailPageController {
    public List< WrapperClass > wrapperList { get; set; }
    public Id recId { get; set; }
    public static String error { get; set; }
    public iron_Demand__c ironDmnd { get; set; }
    public static List< Iron_Demand_Unit__c > ironDemand_Units {get; set;}
    
    public SendIronDemandEmailPageController(apexPages.StandardController controller) {
        recId = (Id)controller.getId();
        error = '';
        getRecords();
    }
    
    // blank constructor for vf component
    public SendIronDemandEmailPageController(){}
    
    // private method to get iron demand units records when page loads
    private void getRecords() {
        try{
            wrapperList = new List< WrapperClass >();
            List< String > unitFields = UtilityClass.getRelationFields('Iron_Demand_Unit__c');
            List< String > ironFields = UtilityClass.getAllFields('Iron_Demand_Unit__c');
            String soql = 'Select '+String.join(ironFields, ',')+','+String.join(unitFields, ',')+', Iron_Demand__r.Name,Iron_Demand__r.IronDemand_Contact__r.Email,iron_Demand__r.IronDemand_Contact__r.FirstName,iron_Demand__r.IronDemand_Contact__r.LastName From Iron_Demand_Unit__c' ;
            soql += ' Where Iron_Demand__c ='+' \'' + String.escapeSingleQuotes(recId) + '\'';
            soql += ' AND Iron_Demand__r.isActive__c = true' ;
            system.debug('soql ===>'+soql);
            for(Iron_Demand_Unit__c unit : database.query(soql)) {
                ironDmnd = unit.Iron_Demand__r;
                wrapperList.add(new WrapperClass(unit,false));
            }
        } catch( Exception ex) {
            error = utilityClass.ERROR_MSG+'<br/> Technical issue: '+ex.getMessage()+', Exception Type: '+ex.getTypeName()+', Cause: '+ex.getCause()+', At Line: '+ex.getLineNumber();
        }
    }
    
    // send the email to the iron demand contact with the units details in email body
    
    public void sendEmail() {
        system.debug('ironDemand_Units --->'+wrapperList);
        List<Iron_Demand_Unit__c> templist = new List< Iron_Demand_Unit__c >();
        try{
            if( ironDmnd.IronDemand_Contact__r.Email != null ) {
                for( WrapperClass wrap : wrapperList ) {
                    if( wrap.isSelected ) {
                        templist.add(wrap.ironDemand);
                    }
                }
                SendIronDemandEmailPageController.sendEmailUtil(templist);
            } else {
                error = UtilityClass.EMAIL_MISSING;
                system.debug(error);
            }
        }catch( Exception ex ) {
            error = utilityClass.ERROR_MSG+'<br/> Technical issue: '+ex.getMessage()+', Exception Type: '+ex.getTypeName()+', At Line: '+ex.getLineNumber();
            system.debug(error);
        }
    }
    
    public static void sendEmailUtil(List< Iron_Demand_Unit__c > ironDemandUnits) {
        system.debug('ironDemandUnits: '+ironDemandUnits);
        if(ironDemandUnits.size() > 0) {
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplate = [Select Id,HtmlValue from EmailTemplate where DeveloperName = 'Iron_Demand_Email_Template'];
            OrgWideEmailAddress[] owea = UtilityClass.owea;
            Messaging.SingleEmailMessage email;
            for(Iron_Demand_Unit__c unit : ironDemandUnits ) {
                email = new Messaging.SingleEmailMessage();
                email.setTemplateID(emailTemplate.Id);
                email.setTargetObjectId(unit.Iron_Demand__r.IronDemand_Contact__c);
                email.setWhatId(unit.Id);
                email.setSaveAsActivity(true);
                if(owea != null && owea.size() > 0) email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            messages.add(email);
            ironDemand_Units = ironDemandUnits;
            system.debug('messages: '+messages);
            List< Messaging.SendEmailResult > result = new List< Messaging.SendEmailResult >();
            if( !test.isRunningTest() && messages.size() > 0) {
                result = Messaging.sendEmail(messages, false);
                system.debug('email sent');
            }
            if( result.size() >0 && result[0].isSuccess() ){
                error = UtilityClass.EMAIL_SUCCESS_MSG;
                system.debug(error);
            }else if (result.size() >0 && !result[0].isSuccess()) {
                error = UtilityClass.EMAIL_ERROR_MSG+'<br/> Technical issue: '+result[0].getErrors();
                system.debug(error);
            }
        } else {
            error = 'No Iron Demand Unit(s) found to send email!';
            system.debug(error);
        }
    }
}