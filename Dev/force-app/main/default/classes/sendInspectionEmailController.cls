public  class sendInspectionEmailController {
    @AuraEnabled
    public static AuraResponse getContactData(string ContactName){
        AuraResponse AuraResponse;
        try {
            list<wrapper> lstWrapper = new list<wrapper>();
            if(string.isNotBlank(ContactName)){
                ContactName='%' + ContactName + '%';
                list<Contact> lstContact = [SELECT id,
                                            Name,
                                            Phone,
                                            Email
                                            FROM Contact 
                                            WHERE Name LIKE : ContactName ];
                
                if(lstContact!=null && !lstContact.isEmpty()){
                    for(Contact eachContact : lstContact){
                        lstWrapper.add(new Wrapper(eachContact.Id,
                                                eachContact.Name,
                                                eachContact.Phone,
                                                eachContact.Email));
                    }
                    
                }
            }
            AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                            JSON.serialize(lstWrapper));
            
            
        }catch (Exception ex) {
            
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        return AuraResponse;
            
    }
    @AuraEnabled
    public static AuraResponse getUnitData(string recordId){
        AuraResponse AuraResponse;
        list<Product2> lstUnit;
        try {
            if(string.isNotBlank(recordId)){
                 lstUnit = [SELECT id, name, Google_Drive_LInk__c 
                                    FROM Product2 
                                    WHERE id =: recordId AND Google_Drive_LInk__c !=Null 
                                    LIMIT 1];
                if(lstUnit!= null && !lstUnit.isEmpty()){
                    AuraResponse = new AuraResponse(true,
                                                    'success',
                                                    lstUnit[0].Google_Drive_LInk__c);
                }else{
                    AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            'Please add Goole Photos Link');
                }
            }else{
                AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            'Unit Id is null');
            }
        }catch (Exception ex) {
            
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        return AuraResponse;
            
    }
	@AuraEnabled
    public static AuraResponse sendEmailToUser(String EmailId,String recordId,list<string> lstContactId){
        AuraResponse AuraResponse;
        list<string>lstEmailId = new list<String>{EmailId};
       	
        try{
            if(string.isNotBlank(EmailId)){
                if(recordId.startsWith('01t')){
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = lstEmailId;
                    message.optOutPolicy = 'FILTER';
                    message.subject = 'Zadoon : Unit Inspection Link';
                    //String htmlBody = emailHTMLBody(recordId,' ');
                    //htmlBody += recordId;
                    message.htmlBody =  emailHTMLBody(recordId,' ');
                    
                    Messaging.SingleEmailMessage[] messages = 
                        new List<Messaging.SingleEmailMessage> {message};
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    if (results[0].success) {
                        
                        AuraResponse = new AuraResponse(true,
                                                        'success',
                                                        'The email was sent successfully.');
                        
                    } else {
                        AuraResponse = new AuraResponse(false,
                                                    'ERROR',
                                                    'The email failed to send: ' + results[0].errors[0].message);
                        
                    }
                }else If(recordId.startsWith('a4I')){
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = lstEmailId;
                    message.optOutPolicy = 'FILTER';
                    message.subject = 'Zadoon : Unit Inspection Link';
                    /*String htmlBody = 'Hi , <br>Unit Inspection Link<br>'; 
                    
                    
                    htmlBody += 'https://zadoon1234--dev.sandbox.my.salesforce-sites.com/?parm1=';
                    htmlBody += recordId;*/
                    message.htmlBody =  emailHTMLBody(recordId,' ');
                    
                    Messaging.SingleEmailMessage[] messages = 
                        new List<Messaging.SingleEmailMessage> {message};
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    
                    if (results[0].success) {
                        
                        AuraResponse = new AuraResponse(true,
                                                        'sucess',
                                                        'The email was sent successfully.');
                       
                    } else {
                        AuraResponse = new AuraResponse(false,
                                                    'ERROR',
                                                    'The email failed to send: ' + results[0].errors[0].message);
                        
                    }
                }
            }else if(lstContactId!=null && !lstContactId.isEmpty()){
               
                list<Contact> lstContact =[SELECT Id,email,firstName,LastName FROM Contact WHERE Id IN : lstContactId AND email != null];
                
                if(lstContact!=null && !lstContact.isEmpty()){
                    List<Messaging.SingleEmailMessage> lstEmail= new List<Messaging.SingleEmailMessage>();
                    for(Contact eachContact : lstContact){
                        string FullName;
                        if(string.isNotBlank(eachContact.firstName) && string.isNotBlank(eachContact.LastName) ){
                            FullName = eachContact.firstName +' '+eachContact.LastName;
                        }else If(string.isBlank(eachContact.firstName) && string.isNotBlank(eachContact.LastName)){
                            FullName = eachContact.LastName;
                        }else If(string.isNotBlank(eachContact.firstName) && string.isBlank(eachContact.LastName)){
                            FullName = eachContact.firstName;
                        }else{
                           	FullName=''; 
                        }
                        if(string.isNotBlank(eachContact.email)){
                            list<string>lstString = new list<String>{eachContact.email};
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            message.toAddresses = lstString;
                            message.optOutPolicy = 'FILTER';
                            message.subject = 'Zadoon : Unit Inspection Link';
                            message.htmlBody =  emailHTMLBody(recordId,FullName);
                            lstEmail.add(message);
                        }
                    }
                    
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmail);
                    if (results[0].success) {
                        
                        AuraResponse = new AuraResponse(true,
                                                        'success',
                                                        'The email was sent successfully.');
                       
                    } else {
                        AuraResponse = new AuraResponse(false,
                                                    'ERROR',
                                                    'The email failed to send: ' + results[0].errors[0].message);
                        
                    }
                }
            }
            
        }
        catch(exception ex){
         
           AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        
        return AuraResponse;
        
    }
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
    public class Wrapper{
        @AuraEnabled public string Id ='';
        @AuraEnabled public string Name = '';
        @AuraEnabled public string MobileNumber = '';
        @AuraEnabled public string Email = '';
        
        wrapper(string Id,
                string Name,
                string MobileNumber, 
                string Email){
                    this.Id=Id;        
                    this.Name = Name;
                    this.MobileNumber = MobileNumber;
                    this.Email = Email;
                   
        }
    }
    public class AuraResponse{
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public string message;
        @AuraEnabled public string response;
        
        AuraResponse(Boolean isSuccess,
                     String message,
                     String response) {
                         
                         this.isSuccess = isSuccess;
                         this.message = message;
                         this.response = response;
                     }
    }
}