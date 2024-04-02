global class Email2Lead implements Messaging.InboundEmailHandler{
    Map<String, String> emailToOwnerMap;
    Map<String, String> VendorSettingsMap;
    Static Final String defaultStatus = Label.Lead_Default_Status ;
    Map<String, String> vendorToMailMap = new Map<String, String>{
        'MachineTrader' => 'MT',
        'Machinio' => 'Machinio',
        'MyLittleSalesman' => 'MLS',
        'EquipmentTrader' => 'ET',
        'RitchieList' => 'RitchieList',
        'Fleet' => 'Fleet',
        'Rock_and_Dirt' => 'RAD',
        'TalkDesk' => 'TD',
        'IronSiteRitchieList' => 'ISRT',
        'Finance' => 'Finance',
        'Admin' => 'Admin',
        'Numbers' => 'Numbers',
        'WTB' => 'WTB'
    };
    
    global Email2Lead(){
        emailToOwnerMap = new Map<String, String>();
        for(Lead_Owner_Setting__mdt setting : Lead_Owner_Setting__mdt.getAll().values()){
            emailToOwnerMap.put(setting.Email__c.toLowercase() , setting.Owner_Username__c);
        }

        VendorSettingsMap = new Map<String, String>();
        for(Vendor_Setting__mdt setting : Vendor_Setting__mdt.getAll().values()){
            VendorSettingsMap.put(setting.Email__c, setting.DeveloperName);
        }

    }
    
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email, 
        Messaging.InboundEnvelope envelope
    ){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        createNewLeadFromMail(email);
        return result;
    }
    
    global void createNewLeadFromMail(
    	Messaging.InboundEmail email
    ){
        //system.debug(email.toAddresses[0]);
        //system.debug( VendorSettingsMap.get(email.toAddresses[0]));
        //system.debug(email.plainTextBody);
        //system.debug(email.htmlBody);
        boolean addAttachment = false;
        Lead lead = new Lead(); 
        lead.Subject__c = email.subject.length() > 255 ? email.subject.substring(0, 255) : email.subject;
        lead.Company = email.fromName;
        lead.Status = defaultStatus;
        lead.OwnerId = getOwnerFromAddress(email.toAddresses[0]);
        lead.LeadSource = getLeadSource(email.toAddresses[0]);
        
        if(email.htmlBody != null){
            lead.Email_HTML_Body__c = email.htmlBody;
        }
        system.debug('email.toAddresses[0]::'+email.toAddresses[0]);
        system.debug('VendorSettingsMap.keySet().contains(email.toAddresses[0])'+VendorSettingsMap.keySet().contains(email.toAddresses[0]));
        if(VendorSettingsMap.keySet().contains(email.toAddresses[0])){
            //system.debug('VendorSettingsMap.keySet().contains(email.toAddresses[0])'+VendorSettingsMap.keySet().contains(email.toAddresses[0]));
            if(VendorSettingsMap.get(email.toAddresses[0])!= null){
                //system.debug('VendorSettingsMap.get(email.toAddresses[0])'+VendorSettingsMap.get(email.toAddresses[0]));
                if(vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'MLS')
                {
                    lead = populateMLSData(email.plainTextBody, lead);
                    
                } else if(vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'MT')
                {
                   
                    if(String.isNotBlank(email.plainTextBody)){
                        system.debug('email.plainTextBody'+email.plainTextBody);
                         lead = populateMachineTraderData(email.plainTextBody, lead);
                    }else{
                        system.debug('email.htmlBody'+email.htmlBody);
                        lead = populateMachineTraderHTMLData(email.htmlBody, lead);
                    }
                }else if(vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'Machinio')
                {
                    lead = populateMachinioData(email.plainTextBody, lead);
                }else if(vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'ET')
                {
                    if(String.isNotBlank(email.plainTextBody)){
                        system.debug('email.plainTextBody'+email.plainTextBody);
                        lead = populateEquipmentTraderData(email.plainTextBody, lead);
                    }else{
                        system.debug('email.htmlBody2424'+email.htmlBody);
                        lead = populateEquipmentTraderHTMLData(email.htmlBody, lead);
                    }
                        
                }else if(vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'RitchieList')
                {
                     if(String.isNotBlank(email.plainTextBody)){
                        system.debug('populateRitchieData:::'+email.plainTextBody);
                          lead = populateRitchieData(email.plainTextBody, lead);
                    }else{
                        system.debug('populateRitchieHTMLData:::'+email.htmlBody);
                        lead = populateRitchieHTMLData(email.htmlBody, lead);
                    }
                   
                }
                else if(vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'Fleet')
                {   system.debug('lead = populateFleetData(email.htmlBody,' +email.htmlBody);
                    lead = populateFleetData(email.htmlBody, lead);
                }else if (vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'TD'){
                    lead = populateTalkDeskData(email.plainTextBody, lead,Email);
                }else if(vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'ISRT')
                {
                     if(String.isNotBlank(email.plainTextBody)){
                        system.debug('populateRitchieData:::'+email.plainTextBody);
                          lead = populateIronSiteRitchieListData(email.plainTextBody, lead);
                    }else{
                        system.debug('populateRitchieHTMLData:::'+email.htmlBody);
                        //lead = populateRitchieHTMLData(email.htmlBody, lead);
                    }
                   
                }else if(vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'Finance'){
                     if(String.isNotBlank(email.plainTextBody)){
                        addAttachment = true;
                         //populateFinanceData(String emailBody, Lead lead,Messaging.InboundEmail email){
                         lead = populateFinanceData(lead,Email);
                         lead.Restrict_Round_Robbin__c = true;
                         //Id attachmentId =  createAttachment(email.binaryAttachments[0].body, lead.Id,  'pdf', email.binaryAttachments[0].fileName);
                         //system.debug('populateRitchieData:::'+attachmentId);
                      
                    }else{
                        system.debug('populateRitchieHTMLData:::'+email.htmlBody);
                    }
                   
                }else if(vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'Admin')
                {
                     if(String.isNotBlank(email.plainTextBody)){
                        addAttachment = true;
                         //populateFinanceData(String emailBody, Lead lead,Messaging.InboundEmail email){
                         lead = populateAdminData(lead,Email);
                         lead.Restrict_Round_Robbin__c = true;
                         //Id attachmentId =  createAttachment(email.binaryAttachments[0].body, lead.Id,  'pdf', email.binaryAttachments[0].fileName);
                         //system.debug('populateRitchieData:::'+attachmentId);
                      
                    }else{
                        system.debug('populateRitchieHTMLData:::'+email.htmlBody);
                        
                    }
                   
                }else if(vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'Numbers')
                {
                     if(String.isNotBlank(email.plainTextBody)){
                        addAttachment = true;
                         populateNumberData(lead,Email);
                         lead.Restrict_Round_Robbin__c = true;
                     }
                }else if(vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'WTB')
                {
                     if(String.isNotBlank(email.plainTextBody)){
                        addAttachment = true;
                         populateNumberData(lead,Email);
                         lead.Restrict_Round_Robbin__c = true;
                     }
                }
                
                /*else if(vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) != null &&  
                    vendorToMailMap.get(VendorSettingsMap.get(email.toAddresses[0])) == 'RAD')
                {
                     if(String.isNotBlank(email.htmlBody)){
                         system.debug('email.htmlBody'+email.htmlBody);
                          lead = populateRADData(email.htmlBody, lead);
                    }else{
                        system.debug('email.plainTextBody'+email.plainTextBody);
                        //lead = populateRADHTMLData(email.htmlBody, lead);
                    }
                   
                }*/
            }
        }else{
            system.debug('email.fromAddress::'+email.fromAddress);
            Contact contactFromEmail;
            if(string.isNotBlank(email.fromAddress)){
                contactFromEmail = getContactFromEmail(email.fromAddress.deleteWhitespace());
            }
            
            Product2 unitFromEmail = getProduct(email.plainTextBody);
            
            //lead.lastname = email.fromName;
            list<string> lstName = new list<string>();
            //system.debug('email.fromName'+email.fromName);
            if(string.isNotBlank(email.fromName) ){
             	lstName = email.fromName.split(' ', 2);
                if(lstName.size()==2){
                    lead.firstName=lstName[0];
                    lead.LastName= lstName[1];
                }else{
                    lead.lastname = email.fromName;
                } 
            }
            
            lead.Company = email.fromName;
            if(string.isNotBlank(email.fromAddress)){
              lead.Email = email.fromAddress.deleteWhitespace();  
            }
            
            if(contactFromEmail != null){
                lead.Account__c = contactFromEmail.AccountId != null ? contactFromEmail.AccountId : null;
                lead.PostalCode = contactFromEmail.MailingPostalCode != null ? contactFromEmail.MailingPostalCode : null;
                lead.State = contactFromEmail.MailingState != null ? contactFromEmail.MailingState : null;
                lead.Country = contactFromEmail.MailingCountry != null ? contactFromEmail.MailingCountry : null;
                lead.Phone = contactFromEmail.Phone != null ? contactFromEmail.Phone : null;
                lead.MobilePhone  = contactFromEmail.MobilePhone  != null ? contactFromEmail.MobilePhone  : null;
                lead.Contact__c = contactFromEmail != null ? contactFromEmail.Id : null;
            }
            if(unitFromEmail != null){
                lead.Unit__c = unitFromEmail.Id != null ? unitFromEmail.Id : null;
                lead.Unit_Owner__c = unitFromEmail.Account__c != null ? unitFromEmail.Account__c : null;
            }
        }
        if(String.isBlank(lead.lastname)){
            lead.lastname = 'NA';

        }
        if(String.isBlank(lead.Company)){
            lead.Company = 'NA';
        }
        //system.debug('email.plainTextBody'+email.plainTextBody);
        if(string.isNotBlank(email.plainTextBody)){
            if(email.plainTextBody.length()>32767){
                lead.Description__c = email.plainTextBody.SubString(0,32767);
            }else{
                lead.Description__c = email.plainTextBody;
            }
        }
        // Validate the lead to check whether it is lead or not a lead.
        Map<String, String> validationResult = LeadIndentifierHelper.validateEmail(lead);
        String username = '';
        // If it's true then it's lead & assign the lead to the specific user & don't allow the lead for round robbin.
        if(validationResult.get('needToCreate') == 'TRUE') {
            username = validationResult.get('username');
        }else if(validationResult.get('needToCreate') == 'FALSE') {
            // If it's false then it's not a lead.
            username = 'sanjeet@kizzyconsulting.com.dev';
        }else if(validationResult.get('needToCreate') == 'NONE') {
            // If it's false then it's a lead & allow the lead for round robbin.
            lead.Restrict_Round_Robbin__c = false;
        }
        if(String.isNotBlank(username)) {
            List<User> targetUser = [SELECT Id FROM USER WHERE Username =:username];
            lead.Restrict_Round_Robbin__c = true;
            if(!targetUser.isEmpty()) {
                lead.OwnerId = targetUser[0].Id;
            }
        }
        insert lead;
        //to add attachment to the lead 
        if(addAttachment){
            
            if(email.binaryAttachments !=null && !email.binaryAttachments.isEmpty()){
                list<Attachment> lstAttachment = new list<Attachment>();
                
                for(integer i = 0 ; i< email.binaryAttachments.Size();i++){
                    if(email.binaryAttachments[i].Headers!=null && !email.binaryAttachments[i].Headers.isEmpty()){
                        system.debug('email.binaryAttachments[i].Headers::'+email.binaryAttachments[i].Headers);
                        for(integer j = 0 ; j< email.binaryAttachments[i].Headers.size();j++){
                            //string name = email.binaryAttachments[i].Headers[j].name;
                            if(email.binaryAttachments[i].Headers[j].name=='Content-Type'){//, value=image/jpeg; ){
                                Attachment newAttachment =  createAttachment(email.binaryAttachments[i].body, lead.Id, 
                                                                    email.binaryAttachments[i].Headers[j].value.substringBefore(';'), email.binaryAttachments[0].fileName);
                                lstAttachment.add(newAttachment);
                                
                            }
                        } 
                    }
                }
                if(lstAttachment!=null && !lstAttachment.isEmpty()){
                    system.debug('lstAttachment:'+lstAttachment);
                    insert lstAttachment;
                }
            }
        }
         system.debug('lead.Id::'+lead.Id);
                         //Attachment newAttachment =  createAttachment(email.binaryAttachments[0].body, lead.Id,  'application/pdf', email.binaryAttachments[0].fileName);
                 //system.debug('lead.Id::'+attachmentId);       
    }
    public static Attachment createAttachment(blob fileContent, String recordId, String fileType, string fileName){
        //for pdf files content type should be pdf
        //for jpeg file content type should be image/jpeg
        Attachment attach = new Attachment();
        attach.ParentId = recordId;
        attach.Name = fileName;
        attach.Body = fileContent;
        attach.contentType = fileType;
        //insert attach;
        return attach;
    }
    global Lead populateTalkDeskData(String emailBody, Lead lead,Messaging.InboundEmail email){
        Contact contactFromNumber;
        /*if(string.isNotBlank(email.fromAddress)){
            contactFromEmail = getContactFromEmail(email.fromAddress.deleteWhitespace());
        }*/
        //tring myString = 'This is a sample string';
        String[] lstLine = emailBody.split('\\.');
        system.debug('lstLine'+ lstLine);
        string firstLine = lstLine[0];
        system.debug('firstLine::'+firstLine);
        string [] lstWord = firstLine.split('\\s+');
        String mobileNumber = lstWord[lstWord.size() - 1];
        system.debug('mobileNumber:::'+mobileNumber);
        if(string.isNotBlank(mobileNumber)){
        	contactFromNumber = getContactFromNumber(mobileNumber.deleteWhitespace());
        }
        Product2 unitFromEmailBody = getProduct(emailBody);
        
        list<string> lstName = new list<string>();
        //system.debug('email.fromName'+email.fromName);
        if(string.isNotBlank(email.fromName) ){
            lstName = email.fromName.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = email.fromName;
            } 
        }
        
        lead.Company = email.fromName;
        if(string.isNotBlank(email.fromAddress)){
            lead.Email = email.fromAddress.deleteWhitespace();  
        }
        
        if(contactFromNumber != null){
            lead.Account__c = contactFromNumber.AccountId != null ? contactFromNumber.AccountId : null;
            lead.PostalCode = contactFromNumber.MailingPostalCode != null ? contactFromNumber.MailingPostalCode : null;
            lead.State = contactFromNumber.MailingState != null ? contactFromNumber.MailingState : null;
            lead.Country = contactFromNumber.MailingCountry != null ? contactFromNumber.MailingCountry : null;
            lead.Phone = contactFromNumber.Phone != null ? contactFromNumber.Phone : null;
            lead.MobilePhone  = contactFromNumber.MobilePhone  != null ? contactFromNumber.MobilePhone  : null;
            lead.Contact__c = contactFromNumber != null ? contactFromNumber.Id : null;
        }
        if(unitFromEmailBody != null){
            lead.Unit__c = unitFromEmailBody.Id != null ? unitFromEmailBody.Id : null;
            lead.Unit_Owner__c = unitFromEmailBody.Account__c != null ? unitFromEmailBody.Account__c : null;
        }
        return lead;
    }
    

    global Id getOwnerFromAddress(
   		String toAddress
    ){
        system.debug('toAddress::'+toAddress);
        system.debug('emailToOwnerMap::'+emailToOwnerMap);
        system.debug('emailToOwnerMap.get(toAddress.toLowercase())::'+emailToOwnerMap.get(toAddress.toLowercase()));
        system.debug('toAddress::'+toAddress);
        system.debug('toAddress::'+toAddress);
        system.debug('toAddress::'+toAddress);
        Id userId = userInfo.getUserId();
        If(emailToOwnerMap!=null && 
           String.isNotBlank(toAddress) &&
           !emailToOwnerMap.isEmpty() &&
           string.isNotBlank(emailToOwnerMap.get(toAddress.toLowercase()))
          ){ 
            String userName = emailToOwnerMap.get(toAddress.toLowercase());
            if(string.isNotBlank(userName)) {
             	//l
                list<User> ownerRecord  = [SELECT Id, Name, UserName FROM User 
                                  	WHERE UserName = :userName];
                  
                  system.debug('ownerRecord:'+ownerRecord);
                if(ownerRecord!=null && !ownerRecord.isEmpty() ) {
                    userId = ownerRecord[0].Id;
                }
         	}
        }
        system.debug('userId::'+userId);
      	return userId;
    }

    private String getLeadSource(String toAddress){

        return [SELECT Id, Label FROM Lead_Owner_Setting__mdt WHERE Email__c = :toAddress LIMIT 1]?.Label;
    }
    
    global Contact getContactFromEmail(
   		String email
    ){
        
        List<Contact> contacts = [SELECT Id, 
                                  		Phone,
                                  		MobilePhone,
                                  		AccountId,
                                  		MailingPostalCode,
                                  		MailingCountry, 
                                  		Email,
                                  		MailingState
                                  FROM Contact 
                                  WHERE Email = :email OR
                                  Secondary_Email__c = :email OR
                                  Craigslist_Email__c = :email LIMIT 1];
                
        return contacts.size() > 0 ? contacts[0] : null;
    }
    global Contact getContactFromNumber(
   		String PhoneNumber
    ){
        List<Contact> contacts = [SELECT Id, 
                                  		Phone,
                                  		MobilePhone,
                                  		AccountId,
                                  		MailingPostalCode,
                                  		MailingCountry, 
                                  		MailingState
                                  FROM Contact 
                                  WHERE Phone = :PhoneNumber OR
                                  MobilePhone = :PhoneNumber LIMIT 1];
        
        return contacts.size() > 0 ? contacts[0] : null;
    }
    
    global Product2 getProduct(
   		String emailBody
    ){
        Product2 product = null;
        String keyWord = 'zid-';//TODO: add this to custom label
        if(string.isNotBlank(emailBody) && emailBody.containsIgnoreCase(keyWord)){
            String zid = getZidFromMail(emailBody, keyWord);
            product = getProductFromZid(zid);
        }
        
        return product;
    }

    global Product2 getProductFromZid(String zid){
        Product2 product = null;
        if(String.isNotBlank(zid)){
            List<Product2> lstUnit = [SELECT Id, Account__c FROM Product2
                                    WHERE Zid__c = :zid];
            if(lstUnit != null && !lstUnit.isEmpty()){
                product = lstUnit[0];
            }
        }
        return product;
    }
    
    global String getZidFromMail(
   		String emailBody, 
        String keyword
    ){
        String zid = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
       		String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfSpace = emailBodyLower.indexOf(' ',startIndex);
            Integer indexOfNewLine = emailBodyLower.indexOf('\n', startIndex);
            if(indexOfSpace < 0 && indexOfNewLine < 0){
                zid = emailBodyLower.subString(startIndex, emailBodyLower.length());
            }else if(indexOfSpace > 0 && indexOfNewLine > 0){
                Integer endIndex = indexOfSpace < indexOfNewLine ?  indexOfSpace : indexOfNewLine;
            	zid = emailBodyLower.subString(startIndex, endIndex);
            } else{
                Integer endIndex = indexOfSpace < 0 ?  indexOfNewLine : indexOfSpace;
            	zid = emailBodyLower.subString(startIndex, endIndex);
            }
            
        }
        if(String.isNotBlank(zid)){
            list<string>lstZid =zid.split('-');
            if(lstZid.size()==2){
                zid = lstZid[1];
            }
            
        }
        return zid;
    }

    global Lead populateMLSData(String emailBody, Lead lead){
        String stockId = getMLSDataFromMail(emailBody, '*Stock #:*');
        if(String.isBlank(stockId)){
            stockId = getMLSDataFromMail(emailBody, 'Stock #:');
        }
        String name = getMLSDataFromMail(emailBody, '*Name:*');
        String email = getMLSDataFromMail(emailBody, '*Email:*');
        String phone = getMLSDataFromMail(emailBody, '*Phone:*');
        if(String.isBlank(phone)){
            phone = getMLSDataFromMail2(emailBody, 'Text message them back at');
        }
        String source = getMLSDataFromMail(emailBody, '*Source:*');
        String mlsId = getMLSDataFromMail(emailBody, '*MLS #:*');
        String company = getMLSDataFromMail(emailBody, '*Company:*');
        //lead.lastname = name;
        if(string.isNotBlank(name)){
            list<string> lstName = new list<string>();
            lstName = name.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = name;
            }
        }
        if(string.isNotBlank(email)){
            lead.Email = email.deleteWhitespace();
        }
        
        lead.Phone = phone;
        if(String.isNotBlank(company) || String.isNotBlank(name)){
            lead.Company = String.isNotBlank(company) ? company : name;
        }
        
        if(String.isNotBlank(stockId)){
            stockId = stockId.split('-')[1];
        }
        Product2 unit = getProductFromZid(stockId);
        if(unit != null){
            lead.Unit__c = unit.Id != null ? unit.Id : null;
            lead.Unit_Owner__c = unit.Account__c != null ? unit.Account__c : null;
        }
        Contact contactFromEmail = getContactFromEmail(email);
        if(contactFromEmail != null){
            lead.Contact__c = contactFromEmail.Id;
        }else{
            if(string.isNotBlank(email)){
                lead.Contact__c = createContact(name, email.deleteWhitespace(), phone).Id;
            }else{
                lead.Contact__c = createContact(name, email, phone).Id;
            }
            
        }

        if(String.isBlank(name)){
            lead.lastname = 'NA';

        }
        if(String.isBlank(company)){
            lead.Company = 'NA';
        }

        return lead;
    }

    global Lead populateRitchieData(String emailBody, Lead lead){
        String name;
        String email;
        String phone;
        String stockId = '';
        if(String.isNotBlank(getRitchieDataFromMail(emailBody.stripHtmlTags(), 'Buyer\'s contact details:'))){
            List<String> dataList = getRitchieDataFromMail(emailBody.stripHtmlTags(), 'Buyer\'s contact details:').split('\n');
            system.debug('dataList::'+dataList);
            system.debug('dataList::'+dataList.size());
            name = dataList[0];
            email = dataList[1];
            phone = dataList[2];
        } else if(String.isNotBlank(getRitchieDataFromMail2(emailBody.stripHtmlTags(), 'Call me anytime today'))){
            List<String> dataList = getRitchieDataFromMail2(emailBody.stripHtmlTags(), 'Call me anytime today').split('/');
            name = dataList[0].trim();
            email = dataList[1].trim();
            phone = dataList[2].trim();
        } else if(String.isNotBlank(getRitchieDataFromMail3(emailBody.stripHtmlTags(), 'Sender', 'phone number'))){
            List<String> dataList = getRitchieDataFromMail3(emailBody.stripHtmlTags(), 'Sender', 'phone number').split(' ');
            name = dataList[0].trim() + ' ' + dataList[1].trim();
            email = dataList[4].trim();
            phone = getRitchieDataFromMail3(emailBody.stripHtmlTags(), 'Phone number', 'location');
            stockId = getRitchieDataFromMail3(emailBody.stripHtmlTags(), 'Customer asset number:', ')');
        }
        
        system.debug('name:'+name);
        system.debug('email:'+email);
        system.debug('phone:'+phone);
        system.debug('stockId:'+stockId);
        //lead.lastname = name;
        if(string.isNotBlank(name)){
            list<string> lstName = new list<string>();
            lstName = name.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = name;
            }
        }
        if(string.isNotBlank(email)){
            lead.Email = email.deleteWhitespace();
        }
        
        lead.Phone = phone;

        if(String.isNotBlank(stockId)){
            stockId = stockId.split('-')[1];
        }
        Product2 unit = getProductFromZid(stockId);
        if(unit != null){
            lead.Unit__c = unit.Id != null ? unit.Id : null;
            lead.Unit_Owner__c = unit.Account__c != null ? unit.Account__c : null;
        }

        Contact contactFromEmail = getContactFromEmail(email);
        if(contactFromEmail != null){
            lead.Contact__c = contactFromEmail.Id;
        }else{
            if(string.isNotBlank(email)){
                lead.Contact__c = createContact(name, email.deleteWhitespace(), phone).Id;
            }else{
                lead.Contact__c = createContact(name, email, phone).Id;
            }
            
            
        }

        if(String.isBlank(name)){
            lead.lastname = 'NA';

        }

        return lead;
    }
    global Lead populateIronSiteRitchieListData(String emailBody, Lead lead){
        String name;
        String email;
        String phone;
        //String stockId = '';
        if(String.isNotBlank(getRitchieDataFromMail(emailBody.stripHtmlTags(), 'Buyer\'s contact details:'))){
            String CoustemerDetails = getRitchieDataFromMail(emailBody, 'Buyer\'s contact details:');
           /* system.debug('CoustemerDetails::'+CoustemerDetails);
            system.debug('CoustemerDetails123::'+CoustemerDetails.split('\n'));*/
            
            list<string> dataList = CoustemerDetails.split('\n');
            /*system.debug('dataList::'+dataList);
            system.debug('dataList[0]::'+dataList[0]);
            system.debug('dataList[1]::'+dataList[1]);
            system.debug('dataList::'+dataList.size());*/
            if(dataList.size() == 3){
                name = dataList[0];
                email = dataList[1];
                phone = dataList[2];
            }else if(dataList.size() > 0){
                name = CoustemerDetails;
            }
            
            
        } else if(String.isNotBlank(getRitchieDataFromMail1(emailBody.stripHtmlTags(), 'Buyer\'s contact details:'))){
            String CoustemerDetails = getRitchieDataFromMail1(emailBody, 'Buyer\'s contact details:');
            
            list<string> dataList = CoustemerDetails.split('\n');
            if(dataList.size() == 3){
                name = dataList[0];
                email = dataList[1];
                phone = dataList[2];
            }else if(dataList.size() > 0){
                name = CoustemerDetails;
            }
            
            
        }
        if(string.isNotBlank(name)){
            list<string> lstName = new list<string>();
            lstName = name.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = name;
            }
        }
        if(string.isNotBlank(email)){
            lead.Email = email.deleteWhitespace();
        }
        
        lead.Phone = phone;

       /* if(String.isNotBlank(stockId)){
            stockId = stockId.split('-')[1];
        }*/
        /*Product2 unit = getProductFromZid(stockId);
        if(unit != null){
            lead.Unit__c = unit.Id != null ? unit.Id : null;
            lead.Unit_Owner__c = unit.Account__c != null ? unit.Account__c : null;
        }*/

        Contact contactFromEmail = getContactFromEmail(email);
        if(contactFromEmail != null){
            lead.Contact__c = contactFromEmail.Id;
        }else{
            if(string.isNotBlank(email)){
                lead.Contact__c = createContact(name, email.deleteWhitespace(), phone).Id;
            }else{
                lead.Contact__c = createContact(name, email, phone).Id;
            }
            
            
        }

        if(String.isBlank(name)){
            lead.lastname = 'NA';

        }

        return lead;
    }
    /*global Lead populateRADData(String emailBody, Lead lead){
        String name;
        String email;
        String phone;
        string testEmail;
        String stockId = '';
        system.debug('emailBody'+emailBody);
        system.debug('Stringfsrfa'+String.isNotBlank(getRADDataFromMail(emailBody, '<br>\n<br>\n')));
        if(String.isNotBlank(getRADDataFromMail(emailBody, '<br>\n<br>\n'))){
            name = getRADDataFromMail(emailBody, '<br>\n<br>\n');
            testEmail= name+'<br>\n';
            email = getRADDataFromMail(emailBody, testEmail);
			//name = dataList[0];
            //email = dataList[1];
            //phone = dataList[2];
        }
        
        if(string.isnotempty(name)){
                
            //lead.lastname = name;
            list<string> lstName = new list<string>();
            lstName = name.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = name;
            }
		}	
        lead.Email = email;
        lead.Phone = phone;
		if(String.isNotBlank(getRADDataFromMail(emailBody, 'ZID-'))){
            stockId = getRADDataFromMail(emailBody, 'ZID-');
        }
        if(String.isNotBlank(stockId)){
            stockId = stockId.split('-')[1];
        }
        Product2 unit = getProductFromZid(stockId);
        if(unit != null){
            lead.Unit__c = unit.Id != null ? unit.Id : null;
            lead.Unit_Owner__c = unit.Account__c != null ? unit.Account__c : null;
        }

        Contact contactFromEmail = getContactFromEmail(email);
        if(contactFromEmail != null){
            lead.Contact__c = contactFromEmail.Id;
        }else{
            lead.Contact__c = createContact(name, email, phone).Id;
        }

        if(String.isBlank(name)){
            lead.lastname = 'NA';

        }

        return lead;
    }*/

    global Lead populateFleetData(String emailBody, Lead lead){
        system.debug('getFleetDataFromMail(emailBody.stripHtmlTags()');
        String name = getFleetDataFromMail(emailBody.stripHtmlTags(), 'Name:', 'Phone');
        String email = getFleetDataFromMail(emailBody.stripHtmlTags(), 'Email:', 'Message,Type');
        String phone = getFleetDataFromMail(emailBody.stripHtmlTags(), 'Phone:', 'Email');
        String stockId = getFleetDataFromMail(emailBody.stripHtmlTags(), 'Stock #:', 'TAKE ACTION NOW');
        if(string.isNotBlank(name)){
            //lead.lastname = name;
            list<string> lstName = new list<string>();
            lstName = name.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = name;
            }
        }
        if(string.isNotBlank(email)){
            lead.Email = email.deleteWhitespace();
        }
        
        lead.Phone = phone;

        if(String.isNotBlank(stockId)){
            stockId = stockId.split('-')[1];
        }
        Product2 unit = getProductFromZid(stockId);
        if(unit != null){
            lead.Unit__c = unit.Id != null ? unit.Id : null;
            lead.Unit_Owner__c = unit.Account__c != null ? unit.Account__c : null;
        }
        Contact contactFromEmail;
        system.debug('email::'+email);
        if(string.isNotBlank(email)){
            if(email.endsWith('    ')){
                contactFromEmail = getContactFromEmail(email.removeEnd('    '));
            }else {
                contactFromEmail = getContactFromEmail(email.deleteWhitespace());
            }
            
        }
        system.debug('contactFromEmail::'+contactFromEmail);
        if(contactFromEmail != null){
            lead.Contact__c = contactFromEmail.Id;
        }else{
            if(string.isNotBlank(email)){
                lead.Contact__c = createContact(name, email.deleteWhitespace(), phone).Id;
            }
            else{
                lead.Contact__c = createContact(name, email, phone).Id;
            }
            
            
        }

        if(String.isBlank(name)){
            lead.lastname = 'NA';

        }

        return lead;
    }
	
    global lead populateEquipmentTraderData(String emailBody, Lead lead){
        //system.debug('lead1212::'+lead);
        //system.debug('emailBody1212::'+emailBody);
        String name = getETDataFromMail(emailBody, '* Name:*');
        if(String.isBlank(name)){
            name = getETDataFromMail(emailBody, '*Name:*');
        }
        if(String.isBlank(name)){
            name = getETDataFromMail(emailBody, 'Name:');
        }

        String stockId = getETDataFromMail(emailBody, '* Stock #:*');
        if(String.isBlank(stockId)){
            stockId = getETDataFromMail(emailBody, '*Stock #:*');
        }
        if(String.isBlank(stockId)){
            stockId = getETDataFromMail(emailBody, 'Stock #:');
        }
        
        String email = getETDataFromMail(emailBody, '* Email: *');
        //system.debug('email:'+email);
        if(String.isBlank(email)){
            email = getETDataFromMail(emailBody, '*Email: *');
        }
       if(String.isBlank(email)){
            email = getETDataFromMail(emailBody, 'Email:');
        }
        if(String.isNotBlank(email) && emailBody.containsIgnoreCase('Email:')){
            email= email.replace('Email:', '');
        }
		//system.debug('email::'+email);
        String phone = getETDataFromMail(emailBody, '* Phone: *');
        if(String.isBlank(phone)){
            phone = getETDataFromMail(emailBody, '*Phone: *');
        }
        if(String.isBlank(phone)){
            phone = getETDataFromMail(emailBody, 'Phone:');
        }

        //lead.lastname = name;
        if(string.isNotBlank(name)){
            list<string> lstName = new list<string>();
            lstName = name.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = name;
            }
        }
        //system.debug('email:::'+email);
        if(string.isNotBlank(email)){
            lead.Email = email.deleteWhitespace();
        }
        
        lead.Phone = phone;
        if(String.isNotBlank(stockId)){
            stockId = stockId.split('-')[1];
        }
        Product2 unit = getProductFromZid(stockId);
        if(unit != null){
            lead.Unit__c = unit.Id != null ? unit.Id : null;
            lead.Unit_Owner__c = unit.Account__c != null ? unit.Account__c : null;
        }
        Contact contactFromEmail = getContactFromEmail(email);
        if(contactFromEmail != null){
            lead.Contact__c = contactFromEmail.Id;
        }else{
            if(string.isNotBlank(email)){
                if(email.contains('Phone')){
                    email= email.substringBefore('Phone');
                }
                //system.debug('email23122'+email);
                lead.Contact__c = createContact(name, email.deleteWhitespace(), phone).Id;
            }else{
                lead.Contact__c = createContact(name, email, phone).Id;
            }
            
        }
        if(String.isBlank(name)){
            lead.lastname = 'NA';

        }
        if(String.isBlank(lead.Company)){
            lead.Company = 'NA';
        }
        return lead;
    }
    
    global Lead populateRitchieHTMLData(String emailBody,Lead lead){
        String name = getRitchieNameDataFromHTMLMail(emailBody, '<br> <br>');
        String stockId = getRitchieGIDDataFromHTMLMail(emailBody, 'ZID-');
        String email = getEmailFromRitchieHTMLData(emailBody, '<br>');
        String phone = getRitchiePhoneDataFromHTMLMail(emailBody, ')<br>');
        //lead.lastname = name;
        system.debug('name:'+name);
        system.debug('stockId:'+stockId);
        system.debug('email:'+email);
        system.debug('phone:'+phone);
        if(string.isNotBlank(name)){
            list<string> lstName = new list<string>();
            lstName = name.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = name;
            }
        }
        if(string.isNotBlank(email)){
            lead.Email = email.deleteWhitespace();
        }
        
        lead.Phone = phone;
        
        if(String.isNotBlank(stockId)){
            stockId = stockId.split('-')[1];
        }
        Product2 unit = getProductFromZid(stockId);
        if(unit != null){
            lead.Unit__c = unit.Id != null ? unit.Id : null;
            lead.Unit_Owner__c = unit.Account__c != null ? unit.Account__c : null;
        }
        Contact contactFromEmail = getContactFromEmail(email);
        if(contactFromEmail != null){
            lead.Contact__c = contactFromEmail.Id;
        }else{
            if(string.isNotBlank(email)){
                lead.Contact__c = createContact(name, email.deleteWhitespace(), phone).Id;
            }else{
                lead.Contact__c = createContact(name, email, phone).Id;
            }
            
        }
        if(String.isBlank(name)){
            lead.lastname = 'NA';

        }
        if(String.isBlank(lead.Company)){
            lead.Company = 'NA';
        }
        return lead;
       

    }

    /*global Lead populateRADHTMLData(String emailBody,Lead lead){
        String name = getRitchieNameDataFromHTMLMail(emailBody, '<br> <br>');
        String stockId = getRitchieGIDDataFromHTMLMail(emailBody, 'ZID-');
        String email = getEmailFromRitchieHTMLData(emailBody, '<br>');
        String phone = getRitchiePhoneDataFromHTMLMail(emailBody, ')<br>');
        //lead.lastname = name;
        list<string> lstName = new list<string>();
        lstName = name.split(' ', 2);
        if(lstName.size()==2){
          	lead.firstName=lstName[0];
            lead.LastName= lstName[1];
        }else{
            lead.lastname = name;
        }
        lead.Email = email;
        lead.Phone = phone;
        
        if(String.isNotBlank(stockId)){
            stockId = stockId.split('-')[1];
        }
        Product2 unit = getProductFromZid(stockId);
        if(unit != null){
            lead.Unit__c = unit.Id != null ? unit.Id : null;
            lead.Unit_Owner__c = unit.Account__c != null ? unit.Account__c : null;
        }
        Contact contactFromEmail = getContactFromEmail(email);
        if(contactFromEmail != null){
            lead.Contact__c = contactFromEmail.Id;
        }else{
            lead.Contact__c = createContact(name, email, phone).Id;
        }
        if(String.isBlank(name)){
            lead.lastname = 'NA';

        }
        if(String.isBlank(lead.Company)){
            lead.Company = 'NA';
        }
        return lead;
       

    }*/
    
    global lead populateEquipmentTraderHTMLData(String emailBody, Lead lead){
        String name = getETDataFromHTMLMail(emailBody, 'Name:</strong>');
        String stockId = getETDataFromHTMLMail(emailBody, 'Stock #:</b></strong>');
        String email = getEmailFromETHTMLData(emailBody, 'Email: </strong><a href="mailto:billwalcutt@yahoo.com" target="_blank">');
        //system.debug('email12'+email);
        String phone = getETDataFromHTMLMail(emailBody, 'Phone: </strong>');
        //lead.lastname = name;
        if(string.isNotBlank(name)){
            list<string> lstName = new list<string>();
            lstName = name.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = name;
            }
        }
        //system.debug('email:'+email);
        if(string.isNotBlank(email)){
            lead.Email = email.deleteWhitespace();
        }
        
        lead.Phone = phone;
        if(String.isNotBlank(stockId)){
            stockId = stockId.split('-')[1];
        }
        Product2 unit = getProductFromZid(stockId);
        if(unit != null){
            lead.Unit__c = unit.Id != null ? unit.Id : null;
            lead.Unit_Owner__c = unit.Account__c != null ? unit.Account__c : null;
        }
        Contact contactFromEmail = getContactFromEmail(email);
        //system.debug('contactFromEmail'+contactFromEmail);
        if(contactFromEmail != null){
            lead.Contact__c = contactFromEmail.Id;
        }else{
            //system.debug('email::'+email);
            if(string.isNotBlank(email)){
                lead.Contact__c = createContact(name, email.deleteWhitespace(), phone).Id;
            }else{
                lead.Contact__c = createContact(name, email, phone).Id;
            }
            
        }
        if(String.isBlank(name)){
            lead.lastname = 'NA';

        }
        if(String.isBlank(lead.Company)){
            lead.Company = 'NA';
        }
        return lead;
    }

    global lead populateMachineTraderHTMLData(String emailBody, Lead lead){
        String name = getMachineTraderNameDataFromHTMLMail(emailBody, 'From:</strong> ');
        String stockId = getMachineTraderNameDataFromHTMLMail(emailBody, 'Stock Number:</strong>');
        String email = getMachineTraderEmailDataFromHTMLMail(emailBody, 'Email:</strong>');
        String phone = getMachineTraderPhoneDataFromHTMLMail(emailBody, 'Phone:</strong>');
        
        String company = getMachineTraderNameDataFromHTMLMail(emailBody, 'From:</strong> ');
        //lead.lastname = name;
        if(string.isNotBlank(name)){
            list<string> lstName = new list<string>();
            lstName = name.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = name;
            }
        }
        if(string.isNotBlank(email)){
            lead.Email = email.deleteWhitespace();
        }
        
        lead.Phone = phone;
         
        if(String.isNotBlank(stockId)){
            stockId = stockId.split('-')[1];
        }
       
        Product2 unit = getProductFromZid(stockId);
        if(unit != null){
            lead.Unit__c = unit.Id != null ? unit.Id : null;
            lead.Unit_Owner__c = unit.Account__c != null ? unit.Account__c : null;
        }

        Contact contactFromEmail = getContactFromEmail(email);
        if(contactFromEmail != null){
            lead.Contact__c = contactFromEmail.Id;
        }else{
            if(string.isNotBlank(email)){
                lead.Contact__c = createContact(name, email.deleteWhitespace(), phone).Id;
            }else{
                lead.Contact__c = createContact(name, email, phone).Id;
            }
            
        }
        if(String.isBlank(name)){
            lead.lastname = 'NA';

        }
        if(String.isBlank(lead.Company)){
            lead.Company = company;
        }
        return lead;
    }
    global Lead populateMachinioData(String emailBody, Lead lead){
        String stockId = getMachinioDataFromMail(emailBody, 'Stock / ID:');
        String name = getMachinioDataFromMail(emailBody, 'Name:');
        String email = getMachinioDataFromMail(emailBody, 'Email:');
        String phone = getMachinioDataFromMail(emailBody, 'Phone:');
        String company = getMachinioDataFromMail(emailBody, 'Company:');
        String zip = getMachinioDataFromMail(emailBody, 'Zip Code:');
        String location = getMachinioDataFromMail(emailBody, 'Location:');
        String price = getMachinioDataFromMail(emailBody, 'Price:');
        String cmnt = getMachinioDataFromMail(emailBody, 'Comments:');
        //lead.lastname = name;
        if(string.isNotBlank(name)){
            list<string> lstName = new list<string>();
            lstName = name.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = name;
            }
        }
        if(string.isNotBlank(email)){
            lead.Email = email.deleteWhitespace();
        }
        
        lead.Phone = phone;
        lead.Restrict_Round_Robbin__c = true;
        lead.Company = company;
        if(String.isNotBlank(stockId)){
            stockId = stockId.split('-')[1];
        }
        Product2 unit = getProductFromZid(stockId);
        if(unit != null){
            lead.Unit__c = unit.Id != null ? unit.Id : null;
            lead.Unit_Owner__c = unit.Account__c != null ? unit.Account__c : null;
        }
        Contact contactFromEmail = getContactFromEmail(email);
        if(contactFromEmail != null){
            lead.Contact__c = contactFromEmail.Id;
        }else{
            if(string.isNotBlank(email)){
                lead.Contact__c = createContact(name, email.deleteWhitespace(), phone).Id;
            }else{
                lead.Contact__c = createContact(name, email, phone).Id;
            }
            
        }
        return lead;
    }

    global Lead populateMachineTraderData(String emailBody, Lead lead){
        //system.debug('emailBody'+emailBody);
        String stockId = getMachineTraderDataFromMail(emailBody, 'Stock Number:');
        String name = getMachineTraderDataFromMail(emailBody, 'From:');
        String email = getMachineTraderDataFromMail(emailBody, 'Email:* ');
        system.debug('email'+stockId);
        
        String phone = getMachineTraderDataFromMail(emailBody, 'Phone:');
        String zip = getMachineTraderDataFromMail(emailBody, 'Location:');
        String location = getMachineTraderDataFromMail(emailBody, 'Unit Location:');
        String price = getMachineTraderDataFromMail(emailBody, 'Price:');
        String offer = getMachineTraderDataFromMail(emailBody, 'Offer:');
        String cmnt = getMachineTraderDataFromMail(emailBody, 'Message:');
        //lead.lastname = name;
        if(string.isNotBlank(name)){
            list<string> lstName = new list<string>();
            lstName = name.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = name;
            }
        }
        if(string.isNotBlank(email)){
            lead.Email = email.deleteWhitespace();
        }
        
        lead.Phone = phone;
        if(String.isNotBlank(stockId)){
            stockId = stockId.split('-')[1];
        }
        Product2 unit = getProductFromZid(stockId);
        if(unit != null){
            lead.Unit__c = unit.Id != null ? unit.Id : null;
            lead.Unit_Owner__c = unit.Account__c != null ? unit.Account__c : null;
        }
        Contact contactFromEmail = getContactFromEmail(email);
        if(contactFromEmail != null){
            lead.Contact__c = contactFromEmail.Id;
        }else{
            if(string.isNotBlank(email)){
                lead.Contact__c = createContact(name, email.deleteWhitespace(), phone).Id;
            }else{
                lead.Contact__c = createContact(name, email, phone).Id;
            }
            
        }
        return lead;
    }

    global String getMLSDataFromMail(
        String emailBody,
        String keyword){

        keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('\n', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf('*')+1,returnStr.length());
                returnStr = returnStr.trim();
                System.debug('***'+returnStr);
            }
        }

        return returnStr;
    }

    global String getFleetDataFromMail(
        String emailBody,
        String keyword,
        String endKeyword){
        
        keyword = keyword.toLowerCase();

        endKeyword = endKeyword.toLowerCase();
        
        
        //list<String> lsteachkeyWord = endKeyword.split(,);
        String returnStr = '';
        system.debug('emailBody::'+emailBody);
        //system.debug('emailBody'+emailBody.length());
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer endIndex = -1;
            for(string  eachKeyword: endKeyword.split(',') ){
                endIndex = emailBodyLower.indexOf(eachKeyword, startIndex);
                if(endIndex > 0){
                  break;  
                }
            }
            //system.debug('startIndex'+startIndex);
            //system.debug('endKeyword'+endKeyword);
            //system.debug('endIndex'+endIndex);
            if(endIndex >0){
                //system.debug();
                returnStr = emailBody.subString(startIndex, endIndex);
                system.debug('returnStr1:::'+returnStr);
                returnStr = returnStr.trim();
                system.debug('returnStr1:::'+returnStr);
                returnStr = returnStr.substring(returnStr.lastIndexOf(':')+1,returnStr.length());
                system.debug('returnStr1:::'+returnStr);
                returnStr = returnStr.trim();
                System.debug('***'+returnStr);
            }
            
        }

        return returnStr;
    }
    
    global String getETDataFromMail(
        String emailBody,
        String keyword){

        keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) && emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('\n', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf('*')+1,returnStr.length());
                returnStr = returnStr.trim();
                System.debug('***'+returnStr);
            }
        }

        return returnStr;
    }

    global String getRitchieDataFromMail(
        String emailBody,
        String keyword){

        keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('message from buyer:', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf(':')+1,returnStr.length());
                System.debug('***13'+returnStr);
                returnStr = returnStr.trim();
                System.debug('***'+returnStr);
            }
        }
		system.debug('returnStr::'+returnStr);
        return returnStr;
    }
    global String getRitchieDataFromMail1(
        String emailBody,
        String keyword){
		system.debug('emailBody::'+emailBody);
        keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('wanted to buy:', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf(':')+1,returnStr.length());
                System.debug('***13'+returnStr);
                returnStr = returnStr.trim();
                System.debug('***'+returnStr);
            }
        }
		system.debug('returnStr::'+returnStr);
        return returnStr;
    }

    global String getRitchieDataFromMail2(
        String emailBody,
        String keyword){
        String endKeyword = 'if you want to respond to this buyer';

        keyword = keyword.toLowerCase();
        String returnStr = '';
        System.debug(emailBody.containsIgnoreCase(keyword) );
        System.debug(emailBody.containsIgnoreCase(endKeyword) );
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword) && emailBody.containsIgnoreCase(endKeyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer endIndex = emailBodyLower.indexOf(endKeyword.toLowerCase(), startIndex);
            if(endIndex>0){    
                returnStr = emailBody.subString(startIndex, endIndex);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(keyWord.length()+1,returnStr.length());
                returnStr = returnStr.trim();
                System.debug('***'+returnStr);
            }
        }

        return returnStr;
    }

    global String getRitchieDataFromMail3(
        String emailBody,
        String keyword,
        String endKeyword){

        keyword = keyword.toLowerCase();
        String returnStr = '';
        System.debug(emailBody.containsIgnoreCase(keyword) );
        System.debug(emailBody.containsIgnoreCase(endKeyword) );
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword) && emailBody.containsIgnoreCase(endKeyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer endIndex = emailBodyLower.indexOf(endKeyword.toLowerCase(), startIndex);
            if(endIndex>0){
                returnStr = emailBody.subString(startIndex, endIndex);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(keyWord.length()+1,returnStr.length());
                returnStr = returnStr.trim();
                System.debug('***'+returnStr);
            }
        }

        return returnStr;
    }
    
     global String getRitchieNameDataFromHTMLMail(
        String emailBody,
        String keyword){
              keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('<br>', startIndex+9);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf('<br>')+5,returnStr.length());
                returnStr = returnStr.trim();
                System.debug('***'+returnStr);
            }
        }

        return returnStr;
            
            
        }
     global String getRitchieGIDDataFromHTMLMail(
        String emailBody,
        String keyword){
              keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            
            //Integer indexOfNewLine = emailBodyLower.indexOf('-  </p>', startIndex);
            
            Integer indexOfNewLine =startIndex+10;
            //system.debug('indexOfNewLine'+indexOfNewLine);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                //system.debug('returnStr1'+returnStr);
                returnStr = returnStr.trim();
                //system.debug('returnStr2'+returnStr);
                returnStr = returnStr.substring(returnStr.lastIndexOf('ZID-'),returnStr.length());
                //system.debug('returnStr3'+returnStr);
                returnStr = returnStr.trim();
                //System.debug('***'+returnStr);
            }
        }

        return returnStr;
            
            
        }
     global String getRitchiePhoneDataFromHTMLMail(
        String emailBody,
        String keyword){
              keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('<br> <br> <strong>', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf('<br>')+5,returnStr.length());
                returnStr = returnStr.trim();
                //System.debug('***'+returnStr);
            }
        }

        return returnStr;
            
            
        }
     global String getETDataFromHTMLMail(
        String emailBody,
        String keyword){

        keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('</p>', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf('g>')+2,returnStr.length());
                returnStr = returnStr.trim();
                //System.debug('***'+returnStr);
            }
        }

        return returnStr;
    }


    global String getMachineTraderNameDataFromHTMLMail(
        String emailBody,
        String keyword){

        keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('</span>', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf('g>')+2,returnStr.length());
                returnStr = returnStr.trim();
                //System.debug('***'+returnStr);
            }
        }

        return returnStr;
    }
    
     global String getMachineTraderEmailDataFromHTMLMail(
        String emailBody,
        String keyword){

        keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) && emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('?subject', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf('o:')+2,returnStr.length());
                returnStr = returnStr.trim();
                //System.debug('***'+returnStr);
            }
        }

        return returnStr;
    }
     global String getMachineTraderPhoneDataFromHTMLMail(
        String emailBody,
        String keyword){

        keyword = keyword.toLowerCase();
        String returnStr = '';  
        if(string.isNotBlank(emailBody) && emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('</a>', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf('">')+2,returnStr.length());
                returnStr = returnStr.trim();
                //System.debug('***'+returnStr);
            }
        }

        return returnStr;
    }
    global String getEmailFromETHTMLData(
        String emailBody,
        String keyword){

        keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('</a>', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf('k">')+3,returnStr.length());
                returnStr = returnStr.trim();
                //System.debug('***'+returnStr);
            }
        }

        return returnStr;
    }
    
     global String getEmailFromRitchieHTMLData(
        String emailBody,
        String keyword){

        keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('<br> (', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
           
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf('k">')+3,returnStr.length());
                 Integer lstIndex = returnStr.lastIndexOf('<br>');
                returnStr = returnStr.subString(lstIndex+5, returnStr.length());
                returnStr = returnStr.trim();
                //System.debug('***'+returnStr);
            }
           
        }

        return returnStr;
    }

    global String getMLSDataFromMail2(
        String emailBody,
        String keyword){

        keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.lastIndexOf(keyWord);
            Integer indexOfQuotes = emailBodyLower.indexOf('"', startIndex);
            if(indexOfQuotes>0){
                returnStr = emailBody.subString(startIndex, indexOfQuotes);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf(' '),returnStr.length());
                returnStr = returnStr.trim();
                //System.debug('***'+returnStr);
            }
        }

        return returnStr;
    }

    global String getMachinioDataFromMail(
        String emailBody,
        String keyword){

        keyword = keyword.toLowerCase();
        String returnStr = '';
        if(string.isNotBlank(emailBody) && emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('\n', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                //System.debug(returnStr);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf(':')+1,returnStr.length());
                returnStr = returnStr.trim();
                //System.debug('***'+returnStr);
            }
        }

        return returnStr;
    }

    global String getMachineTraderDataFromMail(
        String emailBody,
        String keyword){
		//system.debug('keyword::'+keyword);//
            
        keyword = keyword.toLowerCase();
            //system.debug('keyword::'+keyword);
        String returnStr = '';
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            Integer indexOfNewLine = emailBodyLower.indexOf('\n', startIndex);
            if(indexOfNewLine>0){
                returnStr = emailBody.subString(startIndex, indexOfNewLine);
                //System.debug('returnStr::'+returnStr);
                returnStr = returnStr.trim();
                returnStr = returnStr.substring(returnStr.lastIndexOf('*')+1,returnStr.length());
                returnStr = returnStr.trim();
                //System.debug('***'+returnStr);
            }
        }

        return returnStr;
    }
    global Lead populateFinanceData(Lead lead,Messaging.InboundEmail email){
        
        list<string> lstName = new list<string>();
         if(string.isNotBlank(email.fromName) ){
            lstName = email.fromName.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = email.fromName;
            } 
        }
        
        lead.Company = email.fromName;
        if(string.isNotBlank(email.fromAddress)){
            lead.Email = email.fromAddress.deleteWhitespace();  
        
           
            Contact contactFromEmail = getContactFromEmail(email.fromAddress.deleteWhitespace());
            if(contactFromEmail != null){
                lead.Contact__c = contactFromEmail.Id;
            }
        }
        return lead;
    }
    global Lead populateAdminData(Lead lead,Messaging.InboundEmail email){
        
        list<string> lstName = new list<string>();
         if(string.isNotBlank(email.fromName) ){
            lstName = email.fromName.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = email.fromName;
            } 
        }
        
        lead.Company = email.fromName;
        if(string.isNotBlank(email.fromAddress)){
            lead.Email = email.fromAddress.deleteWhitespace();  
        
           
            Contact contactFromEmail = getContactFromEmail(email.fromAddress.deleteWhitespace());
            if(contactFromEmail != null){
                lead.Contact__c = contactFromEmail.Id;
            }
        }
        return lead;
    }
    global Lead populateNumberData(Lead lead,Messaging.InboundEmail email){
        Id procurementRecordTypeId;
        if(string.isNotBlank(label.Lead_Record_Type_Procurement_lead)){
            procurementRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
                .get(label.Lead_Record_Type_Procurement_lead).getRecordTypeId();
        }
        if(string.isNotBlank(procurementRecordTypeId)){
            lead.RecordTypeId = procurementRecordTypeId;
        }
        list<string> lstName = new list<string>();
        map<String,User> mapOfEmailVsUser = new map<String,User>();
        list<User> lstUser = [SELECT Id,Email,Name,isActive FROM USER WHERE isActive = True];
        if(lstUser!=null && !lstUser.isEmpty()){
            for(User eachUser : lstUser){
                mapOfEmailVsUser.put(eachUser.Email,eachUser);
                
            }
        }
        if(string.isNotBlank(email.fromName) ){
            lstName = email.fromName.split(' ', 2);
            if(lstName.size()==2){
                lead.firstName=lstName[0];
                lead.LastName= lstName[1];
            }else{
                lead.lastname = email.fromName;
            } 
        }
        
        lead.Company = email.fromName;
        system.debug('email.:::'+email.fromAddress);
        system.debug('mapOfEmailVsUser::'+mapOfEmailVsUser);
        system.debug('mapOfEmailVsUser.KeySet::'+mapOfEmailVsUser.KeySet());
        
        if(string.isNotBlank(email.fromAddress)){
            lead.Email = email.fromAddress.deleteWhitespace();  
            system.debug('mapOfEmailVsUser::'+mapOfEmailVsUser.get(email.fromAddress));
            if(mapOfEmailVsUser.containsKey(email.fromAddress) && mapOfEmailVsUser.get(email.fromAddress) !=null ){
                lead.OwnerId = mapOfEmailVsUser.get(email.fromAddress).id;
            }
            system.debug('lead.OwnerId::'+lead.OwnerId);
            Contact contactFromEmail = getContactFromEmail(email.fromAddress.deleteWhitespace());
            if(contactFromEmail != null){
                lead.Contact__c = contactFromEmail.Id;
            }
            /*if(string.isNotBlank(email.toAddresses[0])){
                list<user> lstUser= [select id , name , email From User Where Email =: email.toAddresses[0].toLowercase() ]; 
            }
            lead.OwnerId = */
        }
        
        return lead;
    }
    /*global String getRADDataFromMail(
        String emailBody,
        String keyword){
		system.debug('emailBody'+emailBody);
            system.debug('keyword'+keyword);
        keyword = keyword.toLowerCase();
            system.debug('keyword'+keyword);
        String returnStr = '';
            system.debug('emailBody.containsIgnoreCase(keyword)'+emailBody.containsIgnoreCase(keyword));
        if(string.isNotBlank(emailBody) &&emailBody.containsIgnoreCase(keyword)){
            String emailBodyLower = emailBody.toLowerCase();
			system.debug('emailBodyLower'+emailBodyLower);
            Integer startIndex = emailBodyLower.indexOf(keyWord);
            system.debug('startIndex'+startIndex);
            Integer indexOfNewLine = emailBodyLower.indexOf('<p', startIndex);
            system.debug('indexOfNewLine'+indexOfNewLine);
            returnStr = emailBody.subString(startIndex, indexOfNewLine);
            system.debug('returnStr1'+returnStr);
            returnStr = returnStr.trim();
            system.debug('returnStr2'+returnStr);
            returnStr = returnStr.substring(returnStr.lastIndexOf('<br>')+1,returnStr.length());
            system.debug('returnStr3'+returnStr);
            returnStr = returnStr.trim();
			
            System.debug('returnStr***'+returnStr);
        }

        return returnStr;
    }*/

    private Contact createContact(String name, String email, String phone){
        system.debug('email12121212'+email);
        Contact con = new Contact();
        con.LastName = name;
        con.Email = email;
        con.Phone = phone;
        if(String.isBlank(con.LastName)){
            con.LastName = 'NA';
        }
        insert con;
        return con;
    }
}