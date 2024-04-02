/*
This class is used to provide data to UnitInspectionEmailCmp LWC and to handle events from the LWC
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          08-Sept-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/

public class UnitInspectionEmailCmpController {
    
     public class newException extends Exception {} 
    /**
     * This Method is used to provide Unit data on Load to show on new Unit Inspection Screen
	 */
    @AuraEnabled
    public static AuraResponse getIntialdata(String recordId){
        AuraResponse AuraResponse;
        
        try{
            
            if(String.IsNotBlank(recordId)){
            
            AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                            JSON.serialize(handleGetUnitData(recordId)));
            }else{
                AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            'Reocrd id not Found(s).');
            }
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        
        // Returning Aura-Response to LWC
        return AuraResponse;
    }
    
    @AuraEnabled
    public static AuraResponse getContactData(String searchKey){
        AuraResponse AuraResponse;
        
        try{
            
            AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                            JSON.serialize(handleGetContactData(searchKey)));
            
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        
        // Returning Aura-Response to LWC
        return AuraResponse;
    }
    
    private static WrapperData handleGetUnitData(Id recordId){
        List<Product2>lstUnits = new List<Product2>();
        WrapperData newWrapperData = new WrapperData();
        //lstUnits = [SELECT Id, Name ]
        lstUnits = [SELECT Id,
                    Name,
                    Storage_Address__c,
                    Storage_City__c,
                    Storage_Zip_Code__c,
                    Storage_State__c,
                    Storage_Country__c
                    FROM Product2 
                    WHERE Id =: recordId 
                    LIMIT 1];
            
            
        if(lstUnits!=null && !lstUnits.isEmpty()){
            for(product2 eachUnit : lstUnits){
                /*if(String.isNotBlank(String.valueOf(eachFreightCompanyUnit.Freight_Pickup_Date__c))){
                    isPickupDate = true;
                }*/
                String currentAddress = ' ';
                if(String.isNotBlank(eachUnit.Storage_Address__c)){
                   currentAddress += eachUnit.Storage_Address__c; 
                }
                if(String.isNotBlank(eachUnit.Storage_City__c)){
                   currentAddress += ' '+eachUnit.Storage_City__c; 
                }
                if(String.isNotBlank(eachUnit.Storage_State__c)){
                   currentAddress += ', '+eachUnit.Storage_State__c; 
                }
                if(String.isNotBlank(eachUnit.Storage_Country__c)){
                   currentAddress += ', '+eachUnit.Storage_Country__c; 
                }
                if(String.isNotBlank(eachUnit.Storage_Zip_Code__c)){
                   currentAddress += ' '+eachUnit.Storage_Zip_Code__c; 
                }
                
                WrapperData newWrapperData0 = new WrapperData(eachUnit.Id,
                                                              eachUnit.Name,
                                                              System.userInfo.getName(),
                                                              currentAddress);
                newWrapperData = newWrapperData0;
            }
        }
        return newWrapperData;
    }
    
    /*
     * This Method is used to provide Data regarding the Contacts to select for sending emails
	 */
    private static list<WrapperData> handleGetContactData(String searchKey){
        List<Contact>lstContacts = new list<Contact>();
        List<WrapperData> lstWrapperData = new List<WrapperData>();
      /*  lstContacts = [SELECT Id, Name, 
                       AccountId, Account.Name,
                       Phone, MobilePhone, 
                       Email, 
                       MailingCountry, 
                       MailingStreet, 
                       MailingCity, 
                       MailingState, 
                       MailingPostalCode, 
                       MailingAddress,
                       Can_Inspect_Machines__c 
                       FROM Contact
                       WHERE Can_Inspect_Machines__c =  true
                       AND(
                        Name LIKE searchKey OR
                        Email LIKE searckKey  
                       )];*/
                       System.debug('SearchKey:::'+searchKey);

        String query = 'SELECT Id, Name,AccountId, Account.Name, Phone, MobilePhone,  Email,  MailingCountry, MailingStreet,' ;
                query+=' MailingCity, MailingState,  MailingPostalCode,  MailingAddress, Can_Inspect_Machines__c  FROM Contact ';
                 query+=' WHERE Can_Inspect_Machines__c =  true';
                 If(String.IsNotBlank(searchKey)){
                    query+=' AND (Name LIKE \'%' + searchKey.trim() + '%\''; 
                    query += ' OR ' + 'Email' + ' LIKE \'%' + searchKey.trim() + '%\'';
                    query += ' OR ' + 'MailingStreet' + ' LIKE \'%' + searchKey.trim() + '%\'';
                    query += ' OR ' + 'MailingCity' + ' LIKE \'%' + searchKey.trim() + '%\'';
                    query += ' OR ' + 'MailingState' + ' LIKE \'%' + searchKey.trim() + '%\'';
                    query += ' OR ' + 'MailingCountry' + ' LIKE \'%' + searchKey.trim() + '%\'';
                    query += ' OR ' + 'MailingPostalCode' + ' LIKE \'%' + searchKey.trim() + '%\''+' )';
                 }

                 query += ' ORDER BY CreatedDate DESC';
         System.debug('Query String ::'+query);
            lstContacts = Database.Query(query);
        If(lstContacts != null && !lstContacts.IsEmpty()){
            for(Contact eachContact: lstContacts){
                String address = '';
                If(String.IsNotBlank(eachContact.MailingStreet)){
                    address +=eachContact.MailingStreet;
                }
                If(String.IsNotBlank(eachContact.MailingCity)){
                    address +=' '+ eachContact.MailingCity;
                }
                If(String.IsNotBlank(eachContact.MailingState)){
                    address +=' ,'+ eachContact.MailingState;
                }
                If(String.IsNotBlank(eachContact.MailingCountry)){
                    address +=' ,'+ eachContact.MailingCountry;
                }
                If(String.IsNotBlank(eachContact.MailingPostalCode)){
                    address +=' '+ eachContact.MailingPostalCode;
                }
                
                lstWrapperData.add(new WrapperData(eachContact.Id,
                                                   eachContact.Name,
                                                   eachContact.AccountId,
                                                   eachContact.Account.Name,
                                                   eachContact.Phone,
                                                   eachContact.Email,
                                                   address
                                                  ));
            }
        }
        return lstWrapperData;
    }
    
    /*
     * This Method is used to handle the Send Email Event to the Selected Contacts and creates the Unit_Inspection__c Records for the Unit and Inspector
	 */
    
     @AuraEnabled
    public static AuraResponse handleSendEmail(id recordId,list<string>lstSelectedContacts,string wrapperData){
        
        AuraResponse AuraResponse;
        
        try{
            Product2 currentUnit = new Product2();
            String emailSubject = 'Inspection Request-';
            String message = 'Error Occur!!';
            List<Messaging.SingleEmailMessage> lstMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
            Map<String,Unit_Inspection__c> mapContactIdVsUnitInspection = new Map<String,Unit_Inspection__c>();
            List<Unit_Inspection__c> lstUnitInspectionToBeInsert = new List<Unit_Inspection__c>();
            List<Contact>lstContacts = new List<Contact>();
            
            Wrapperdata newWrapperdata = (wrapperData)JSON.deserialize(wrapperData,wrapperData.class);
            
            //To get Selected contact Data 
            If(lstSelectedContacts != null && !lstSelectedContacts.IsEmpty()){
                lstContacts = [SELECT Id, Name, 
                               AccountId,
                               Email
                               FROM Contact
                               WHERE Id IN : lstSelectedContacts];
            }
            
            // To get Unit data
            Product2  eachUnit = [SELECT Id,
                                  Name,
                                  ZID__c,
                                  Storage_Address__c,
                                  Storage_City__c,
                                  Serial_Number__c,
                                  Storage_Zip_Code__c,
                                  Freight_Status__c,
                                  Freight_Requested_By__c,
                                  Freight_Budget__c,
                                  Site_Contact__c,
                                  Site_Contact__r.Name,
                                  Site_Contact__r.phone,
                                  Storage_State__c,
                                  Storage_Country__c,
                                  Google_Drive_LInk__c ,
                                  Manufacturer__c,
                                  Year__c,
                                  Model__c,
                                  Make__c
                                  FROM Product2 
                                  WHERE Id =: recordId 
                                  LIMIT 1];
            
            Product2 newUnitToUpdate = new Product2();
            newUnitToUpdate.Id = recordId;
            newUnitToUpdate.Inspection_Status__c = 'Requested';
            newUnitToUpdate.Inspection_Inspector__c =null;
            update newUnitToUpdate;
            
            //For Creating the Unit Inspection Records
            If(lstContacts != null && !lstContacts.IsEmpty()){
                for( Contact eachContact : lstContacts){
                    Unit_Inspection__c newUnitInspection = new Unit_Inspection__c();
                    newUnitInspection.Unit__c = recordId;
                    newUnitInspection.Inspecion_Account__c = eachContact.AccountId;
                    newUnitInspection.Inspection_Inspector__c = eachContact.Id;
                    newUnitInspection.Inspecion_Status__c = 'Requested';
                    newUnitInspection.Inspection_Requester__c = System.UserInfo.getUserId();
                    If(String.isNotBlank(newWrapperdata.opportunityValue)){
                    newUnitInspection.Associated_Opportunity__c = newWrapperdata.opportunityValue;
                    }
                    lstUnitInspectionToBeInsert.add(newUnitInspection);
                }
            }
            If(lstUnitInspectionToBeInsert!=null && !lstUnitInspectionToBeInsert.IsEmpty()){
                insert lstUnitInspectionToBeInsert;
                
                For(Unit_Inspection__c eachUnitInspection : lstUnitInspectionToBeInsert){
                    If(String.IsNotBlank(eachUnitInspection.Inspection_Inspector__c)){
                        mapContactIdVsUnitInspection.put(eachUnitInspection.Inspection_Inspector__c,eachUnitInspection);
                    }
                }
            }
            If(lstContacts != null && !lstContacts.IsEmpty()){
                for( Contact eachContact : lstContacts){
                    If(String.IsNotBlank(eachContact.Email)){
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new List<String>{eachContact.Email});
                    email.setSubject(emailSubject);
                    email.setHtmlBody(getHTMLTemplate(eachContact,eachUnit,mapContactIdVsUnitInspection.get(eachContact.Id).Id));
                    lstMessagingSingleEmailMessage.add(email);
                    }
                }
            }
            
            if(lstMessagingSingleEmailMessage!=null && ! lstMessagingSingleEmailMessage.IsEmpty()){
                Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(lstMessagingSingleEmailMessage);
                 message = 'Inspection Emails are send successfully!! ';
            }else{
                throw new newException('Emails are not sent,recipients are not found!!'); 
            }
            AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                            message);
            
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        
        // Returning Aura-Response to LWC
        return AuraResponse;
        
        
    }
    
    
    /*
     * This Method is used to handle Email Body
	 */
    private static string getHTMLTemplate(Contact eachContact,Product2 Unit,String UnitInspectionId){
        String htmlBody = '';
        htmlBody ='<!DOCTYPE html>'+
            '<html>'+
            '<body>'+
            '<p>' +eachContact.Name +',</p>'+
            '<p>We are in need of a pre-purchase inspection on the unit below. Could you please provide a quote and your availability to do this inspection?</p>'+
            
            '<p>Please review the unit details and the services requested checklist below, including the link to the inspection report that would need to be completed, prior to providing your '+
            'quote. Once you have reviewed, please provide us with the following information:</p>'+
            
            '<form action="submit_action" method="post">'+
            '<label for="quote">Quote Amount:</label>'+
           // '<input type="text" id="quote" name="quote" required><br><br>'+
            
            '<label for="next_available_day">Next Available Day:</label>'+
           // '<input type="date" id="next_available_day" name="next_available_day" required><br><br>'+
            
            '<p>If we are able to schedule the inspection with you, I will provide some additional details such as the site contact, PO#s, etc. in a follow-up email.</p>'+
            '</form>'+
            '<h2>Unit Details:</h2>'+
            '<p>'+Unit.Year__c+' '+Unit.Manufacturer__c+' '+ Unit.Model__c+'</p>'+
            '<p>SN: '+ Unit.Serial_Number__c+'</p>'+
            '<p>'+Unit.Storage_City__c+', '+Unit.Storage_State__c+', '+Unit.Storage_Zip_Code__c+'</p>'+
            
            '<h2>Services Requested Checklist - all items must be completed!</h2>'+
            '<ul>'+
            '<li>Please review the inspection report found here; this is what we will ask for you to complete:'+ System.Label.unit_Inspection_Site_URL + UnitInspectionId+'</li>'+
            '<li>Limit tech to two (2) hours on site; should not take more than about 90 minutes to complete this inspection</li>'+
            '<li>If your tech needs more than 2 hours to complete this inspection, please have him/her call Hardy (970-310-0202) at the 2-hour point for instructions as to whether to  '+
            'proceed.</li>'+
            '<li>Complete the attached inspection form completely (will require running and operating the machine)</li>'+
            '<li>If any items on the checklist are not marked "A" please provide an explanation as to why</li>'+
            '<li>Obtain pictures/videos (attached to the form or found here) and add them to the inspection report</li>'+
            '<li>Obtain a full list of active and archived codes</li>'+
            '<li>If you are an on-brand dealer for the machine:</li>'+
            '<ul>'+
            '<li>Provide ECU reading and related info (Matris/CatFacts/KomCare/KomTrax/etc.)</li>'+
            '<li>Provide any service history</li>'+
            '</ul>'+
            '<li>Call Hardy at 970-310-0202 while still at the machine, but when completed with inspection for a quick 5-minute phone call</li>'+
            '</ul>'+
            
            '<p>Thanks,</p>'+
            '</body>'+
            '</html>';
        
       /* 
        htmlBody +=eachContact.Name+'<br><br>';
        
        htmlBody +='Thanks for helping out with ths pre-purchase inspection.'+'<br><br>';
        
        htmlBody +='Please include '+unit.ZID__c+' as the PO# in all documentation, including invoices, credit card authorizations, bis of sale, etc.'+'<br><br>';
        
        htmlBody +='Please note that ttis is a time-sensitive matter - our deal predicated on the';
        htmlBody +='information that we obtain from you in this inspection. We';
        htmlBody +='reaize that your schedule may be busy. and we are happy to work with you in'; 
        htmlBody +='terms of getting us on the Schedule. However, we require all';
        htmlBody +='completed inspection forms, photos, videas, ECU readings, service history. and';
        htmlBody +='invoice/feceipt etc 10 be delivered 0 us wihin tenty-four 24)';
        htmlBody +='ours of he inspection being completed.<br><br>';
            
        htmlBody += 'Unit Details : <br>';
        htmlBody += Unit.Year__c +' ' ;
        htmlBody += Unit.Make__c+ ' ' ;
        htmlBody += Unit.Model__c+ ' ';
        
        htmlBody += '<br><br>';
        htmlBody += 'Location Details: <br><br>';
        
       // htmlBody += Unit.storage_street__c+'<br><br>';
        htmlBody += Unit.Storage_city__c +' ';
        htmlBody += Unit.Storage_state__C +' ';
        htmlBody += Unit.Storage_Country__c +' ';
        htmlBody += Unit.Storage_Zip_Code__c+' ';
        htmlBody += '<br><br>';*/
        
        /*
		{Avaiabity) (NEW FIELD ON INSPECTION OBJECT)

		(Special Instructions} (NEW FIELD ON INSPECTION OBJECT WITH HELPER TEXT. ‘PPE required. checkin al font desk required, etc”*/
      /*  
        htmlBody +='Site Contact: <br><br>';
        htmlBody += Unit.site_Contact__r.Name;
        htmlBody += '<br>';
        htmlBody += Unit.site_Contact__r.phone;
        htmlBody += '<br><br>';
        
        htmlBody += System.Label.unit_Inspection_Site_URL + UnitInspectionId;
        htmlBody += '<br><br>';
        htmlBody += 'Services res checklist - all items must be completed!';
        htmlBody += '<br><br>';
        
        htmlBody += '[ ] limt tech to (2) hours on site. should not take more than about 90 minutes to complete the inspection.<br>';
        htmlBody += '[ ] Compete the attached inspection form comeletly (will required running and operating the machine).<br>';
        htmlBody += '[ ] If any items on the checklist are not marked "A" please provide an explanation as to why.<br>';
        htmlBody += '[ ] call Hardy at 970-310-0202 while still at the machine, but when completed with inspection for a quick 5 minute phone call.<br>';
        htmlBody += '[ ] Obtain a full list of active and archived codes.<br>';
        htmlBody += '[ ] Provide ECU reading and related info (Matris/CatFocts/ KamCage/Kom Trax';
        htmlBody += '/and the like- if you are on- brand dealer for the machine).<br>';
        htmlBody += '[ ] Provide any service history (you are an on-brand dealer for tre machine).<br>';
        
        htmlBody += 'If your tech nesds more than 2 hours to complete this inspection, please';
        htmlBody += 'have  him/her call Hardy atthe 2-hour point for Instructions as to';
        htmlBody += 'Whether to proceed. Please let me know a rough estimate and timeframe';
        htmlBody += 'to get this done. I will also be your contact for payment.<br>';
        
        htmlBody += 'Thanks';*/
        
        RETURN htmlBody;
    }
    
    
    /*
     * Wrapper Class to hold the data for the LWC
	 */
    public Class WrapperData{
        @AuraEnabled 
        public String Id;
        @AuraEnabled 
        public String Name;
        @AuraEnabled 
        public String accountId;
        @AuraEnabled 
        public String accountName;
        @AuraEnabled 
        public String phone;
        @AuraEnabled 
        public String email;
        @AuraEnabled 
        public String address;
        @AuraEnabled 
        public String opportunityValue;
        
        WrapperData(){}
        
        WrapperData(String Id,String Name,String accId,String accName,String phone,String email,String address){
            this.Id = Id;
            this.Name = Name;
            this.accountId = accId;
            this.accountName = accName;
            this.phone = phone;
            this.email = email;
            this.address = address;
        }
         WrapperData(String Id,String Name,String accName,String address){
            this.Id = Id;
            this.Name = Name;
            this.accountName = accName;
            this.address = address;
        }
    }
    
	/*
     * Wrapper Class Aura-Response 
	 */       
    Public class AuraResponse{
        @AuraEnabled 
        public Boolean isSuccess;
        @AuraEnabled 
        public string message;
        @AuraEnabled 
        public string response;
        
        AuraResponse(Boolean isSuccess,
                     String message,
                     String response) {
                         
                         this.isSuccess = isSuccess;
                         this.message = message;
                         this.response = response;
                     }
    }
    
}