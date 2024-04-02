public class CustomLeadConvertController {
    public static string AccountId;
    Public static lead newLead;
    @AuraEnabled
    public static AuraResponse leadConvertController(string recordId){
        AuraResponse AuraResponse;
        try {
            if(string.isNotBlank(recordId)){
             
                newLead = [SELECT id, 
                               Status,NumberOfEmployees,PostalCode,Rating,State,StateCode,Street,Website,
                               Company,City,Country,fax,Industry,Latitude,Longitude,OwnerId,LeadSource,
                               Name,Phone,AnnualRevenue,
                               LastName FROM
                               Lead WHERE 
                               id = : recordId  AND 
                               isConverted = false
                              ];
                system.Debug('newLeadwst'+newLead);
                if(newLead!=null ){
                    
                    list<Wrapper> lstWrapperAccount = getAccount(newLead);
                    list<Wrapper> lstWrapperContact = getContact(newLead);
                    list<PicklistWrapper> lstClientTypeWrapper  = getPickListValue();
                    list<PicklistWrapper> lstClientRegionWrapper  = getClientRegionPickListValue();
                    list<PicklistWrapper> lstAuthorizedDealer  = getAuthorizedPickListValue();
                    system.debug('lstClientTypeWrapper1:'+lstClientTypeWrapper);
                    //if(lstWrapperAccount.size()>0 || lstWrapperContact.size()>0 ){
                        ParentWrapper ParentWrapper = new ParentWrapper(lstWrapperAccount,
                                                                        lstWrapperContact,
                                                                        newLead,
                                                                        lstClientTypeWrapper,
                                                                        lstClientRegionWrapper,
                                                                        lstAuthorizedDealer
                                                                       );
                            AuraResponse = new AuraResponse(true,
                                                            'ShowTable',
                                                            JSON.serialize(ParentWrapper) );
                    /*}else{
                        string accountId;
                        string contactId;
                        if(lstWrapperAccount.size()==1){
                            accountId = lstWrapperAccount[0].id;
                        }	
                        if(lstWrapperContact.size()==1){
                            contactId = lstWrapperContact[0].id;
                        }
                        if(lstWrapperAccount.size()==0 && lstWrapperContact.size()==1 ){
                            accountId = lstWrapperContact[0].accountId;
                        }
                        system.debug('accountId'+accountId);
                        system.debug('contactId'+contactId);
                        system.debug('newLead.id'+newLead.id);
                         AuraResponse=leadConverter(newLead.id,accountId,contactId);
                    }*/
                    
                }else{
                    AuraResponse = new AuraResponse(false,
                                                    'ERROR',
                                                    'Lead is alredy converted');
                }
            }else{
                AuraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'RecordId Not found!' );
            }
            
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        return AuraResponse;
    }
    public static list<PicklistWrapper> getPickListValue(){
        
        list<PicklistWrapper> lstWrapper = new list<PicklistWrapper>();
        Schema.DescribeFieldResult fieldResult = Account.Client_type__c.getDescribe();
        system.debug('fieldResult:'+fieldResult);
        List<Schema.PicklistEntry> lstPicklistValue = fieldResult.getPicklistValues();
        system.debug('lstPicklistValue:'+lstPicklistValue);
        if(lstPicklistValue!=null && !lstPicklistValue.isEmpty()){
            for(Schema.PicklistEntry eachPicklistValue : lstPicklistValue){
                lstWrapper.add(new PicklistWrapper(eachPicklistValue.getLabel(),eachPicklistValue.getValue()));
            }
        }
        system.debug('lstWrapper::12'+lstWrapper);
        return lstWrapper;
    }
    public static list<PicklistWrapper> getAuthorizedPickListValue(){
        
        list<PicklistWrapper> lstWrapper = new list<PicklistWrapper>();
        Schema.DescribeFieldResult fieldResult = Account.Authorized_Dealer_For__c.getDescribe();
        system.debug('fieldResult:'+fieldResult);
        List<Schema.PicklistEntry> lstPicklistValue = fieldResult.getPicklistValues();
        system.debug('lstPicklistValue:'+lstPicklistValue);
        if(lstPicklistValue!=null && !lstPicklistValue.isEmpty()){
            for(Schema.PicklistEntry eachPicklistValue : lstPicklistValue){
                lstWrapper.add(new PicklistWrapper(eachPicklistValue.getLabel(),eachPicklistValue.getValue()));
            }
        }
        system.debug('lstWrapper::12'+lstWrapper);
        return lstWrapper;
    }
    public static list<PicklistWrapper> getClientRegionPickListValue(){
        list<PicklistWrapper> lstWrapper = new list<PicklistWrapper>();
        Schema.DescribeFieldResult fieldResult = Account.Client_Region__c.getDescribe();
        system.debug('fieldResult:'+fieldResult);
        List<Schema.PicklistEntry> lstPicklistValue = fieldResult.getPicklistValues();
        system.debug('lstPicklistValue:'+lstPicklistValue);
        if(lstPicklistValue!=null && !lstPicklistValue.isEmpty()){
            for(Schema.PicklistEntry eachPicklistValue : lstPicklistValue){
                lstWrapper.add(new PicklistWrapper(eachPicklistValue.getLabel(),eachPicklistValue.getValue()));
            }
        }
        system.debug('lstWrapper::12'+lstWrapper);
        return lstWrapper;
    }
        /*
        map<String,string> MapOfPickListValues= new map<String,string>();
		Schema.DescribeFieldResult fieldResult = Account.Client_type__c.getDescribe();
		List<Schema.PicklistEntry> lstPicklistValue = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry eachPickListValue : lstPicklistValue){
			MapOfPickListValues.put(eachPickListValue.getLabel(),eachPickListValue.getValue());
		}     
		return MapOfPickListValues;*/
    
    @AuraEnabled
    public static AuraResponse createAccount(string company, string ClientType,list<string> ClientRegion, 
                                             list<string> AuthorizedDealerFor,string mobile){
        system.debug('ClientRegion:'+ClientRegion);
        system.debug('AuthorizedDealerFor:'+AuthorizedDealerFor);
        string clientRegionValue ; 
        string AuthorizedDealerForValue;
       	AuraResponse AuraResponse;
        try {
            if(ClientRegion.size()>0){
                for(string eachString : ClientRegion){
                    if(string.isNotBlank(clientRegionValue)){
                        clientRegionValue = clientRegionValue + eachString +';';
                    }else{
                        clientRegionValue =  eachString +';';
                    }
                    
                }
             clientRegionValue = clientRegionValue.removeEnd(';');   
            }
            
            if(AuthorizedDealerFor.size()>0){
                for(string eachString : AuthorizedDealerFor){
                    if(string.isNotBlank(AuthorizedDealerForValue)){
                        AuthorizedDealerForValue = AuthorizedDealerForValue + eachString +';';
                    }else{
                        AuthorizedDealerForValue =  eachString +';';
                    }
                    
                }
             AuthorizedDealerForValue = AuthorizedDealerForValue.removeEnd(';');   
            }
            /*Account newAccount = new Account(Name= fullName,
                                            Phone = mobile);*/
            system.debug('newLead'+newLead);
            system.debug('AuthorizedDealerForValue'+AuthorizedDealerForValue);
            system.debug('clientRegionValue'+clientRegionValue);
            Account newAccount = new Account();
            newAccount.Name = company;
            newAccount.Phone = mobile;
            //newAccount.Name = company;
            newAccount.Client_Type__c = ClientType;
            newAccount.Client_Region__c = clientRegionValue;
            newAccount.Authorized_Dealer_For__c = AuthorizedDealerForValue;
            //newAccount. = mobile;
           /* newAccount.AnnualRevenue = newLead.AnnualRevenue;
            newAccount.BillingCity = newLead.City;
            newAccount.BillingCountry = newLead.Country;
            newAccount.fax = newLead.fax;
            newAccount.Industry = newLead.Industry;
            newAccount.BillingLatitude = newLead.Latitude;
            newAccount.OwnerId = newLead.OwnerId;
            newAccount.AccountSource = newLead.LeadSource;
            newAccount.BillingLongitude = newLead.Longitude;
            newAccount.NumberOfEmployees = newLead.NumberOfEmployees;
            newAccount.BillingPostalCode = newLead.PostalCode;
            newAccount.Rating = newLead.Rating;
            newAccount.BillingState = newLead.State;
            newAccount.BillingStateCode = newLead.StateCode;
            newAccount.BillingStreet = newLead.Street;
            newAccount.Website = newLead.Website;*/

            insert newAccount;
            system.debug('newAccount'+newAccount);
            AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                            newAccount.id);
        }catch (Exception ex) {
            system.debug('ex'+ex);
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        return AuraResponse;
    }
    @AuraEnabled
    public static AuraResponse createContact(string firstName,string lastName, string accountId, string mobile){
       	AuraResponse AuraResponse;
        try {
            
            Contact newContact = new Contact(FirstName= firstName,
                                             LastName = lastName,
                                            Phone = mobile,
                                            accountId = accountId);
            insert newContact;
            AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                            newContact.id);
        }catch (Exception ex) {
            system.debug('ex'+ex);
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        return AuraResponse;
    }
    public static list<wrapper> getAccount(lead newLead){
        list<wrapper> lstWrapper = new list<wrapper>();
        list<Account> lstAccount = [SELECT id,
                                    Name,
                                    Phone,
                                    Primary_Contact_Email__c 
                                    FROM Account 
                                    WHERE Name =: newLead.Company ];
        if(lstAccount!=null && !lstAccount.isEmpty()){
            
            for(Account eachAccount : lstAccount){
                lstWrapper.add(new Wrapper(eachAccount.Id,
                                           eachAccount.Name,
                                           eachAccount.Phone,
                                           eachAccount.Primary_Contact_Email__c,
                                           eachAccount.Id));
            }
            
        }
        return lstWrapper;
        
    }

    public static list<Wrapper> getContact(lead newLead){
        
        list<wrapper> lstWrapper = new list<wrapper>();
        list<Contact> lstContact = [SELECT id,
                                    Name,
                                    Phone,
                                    Email,
                                    AccountId
                                    FROM Contact 
                                    WHERE Name =: newLead.Name ];
        
        if(lstContact!=null && !lstContact.isEmpty()){
            for(Contact eachContact : lstContact){
                lstWrapper.add(new Wrapper(eachContact.Id,
                                           eachContact.Name,
                                           eachContact.Phone,
                                           eachContact.Email,
                                          eachContact.AccountId));
            }
            
        }
        return lstWrapper;
    }
    @AuraEnabled
	public static AuraResponse getAccountData(string AccountName){
        AuraResponse AuraResponse;
        try {
            list<wrapper> lstWrapper = new list<wrapper>();
            if(string.isNotBlank(AccountName)){
                AccountName='%' + AccountName + '%';
                list<Account> lstAccount = [SELECT id,
                                                    Name,
                                                    Phone,
                                                    Primary_Contact_Email__c 
                                                    FROM Account 
                                                    WHERE Name LIKE : AccountName];
                if(lstAccount!=null && !lstAccount.isEmpty()){
                    
                    for(Account eachAccount : lstAccount){
                        lstWrapper.add(new Wrapper(eachAccount.Id,
                                                   eachAccount.Name,
                                                   eachAccount.Phone,
                                                   eachAccount.Primary_Contact_Email__c,
                                                   eachAccount.Id));
                    }
                    
                }
            	AuraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(lstWrapper));
            }
            
        }catch (Exception ex) {
            system.debug('ex'+ex);
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        return AuraResponse;
    }
    
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
                                            Email,
                                            AccountId
                                            FROM Contact 
                                            WHERE Name LIKE : ContactName ];
                
                if(lstContact!=null && !lstContact.isEmpty()){
                    for(Contact eachContact : lstContact){
                        lstWrapper.add(new Wrapper(eachContact.Id,
                                                eachContact.Name,
                                                eachContact.Phone,
                                                eachContact.Email,
                                                eachContact.AccountId));
                    }
                    
                }
            }
            AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                            JSON.serialize(lstWrapper));
            
            
        }catch (Exception ex) {
            system.debug('ex'+ex);
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        return AuraResponse;
    }   
             
    @AuraEnabled
    public static AuraResponse leadConverter(string LeadId,string accountId, string contactId){
       	AuraResponse AuraResponse;
        system.debug('LeadId'+LeadId);
         system.debug('accountId'+accountId);
         system.debug('contactId'+contactId);
        try {
            LeadStatus CLeadStatus= [SELECT Id, 
                                    MasterLabel 
                                    FROM LeadStatus 
                                    WHERE  IsConverted=true 
                                    Limit 1];
          
            /*Database.DMLOptions dml = new Database.DMLOptions();
dml.DuplicateRuleHeader.allowSave = true;
Database.SaveResult sr = Database.insert(<Pass your contact list here>, dml);*/
            
            Database.LeadConvert Leadconvert = new Database.LeadConvert();
            Leadconvert.setLeadId ( LeadId);                
            Leadconvert.setConvertedStatus(CLeadStatus.MasterLabel);
            Leadconvert.setDoNotCreateOpportunity(false); 
            if(string.isNotBlank(accountId)){
                Leadconvert.setAccountId(accountId);
            }
            if(string.isNotBlank(contactId)){
                Leadconvert.setContactId(contactId);
            }
            //Leadconvert.DuplicateRuleHeader.allowSave = true;
            system.debug('Leadconvert'+Leadconvert);
            Database.LeadConvertResult lcr = Database.convertLead(Leadconvert);
            
            system.debug('lcr'+lcr);
             if(lcr.isSuccess()){
                AuraResponse = new AuraResponse(true,
                                                'ShowOpportunity',
                                                lcr.getOpportunityId());
            }else{
                AuraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'lead not converted');
            }
            
        }catch (Exception ex) {
            system.debug('ex'+ex);
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        return AuraResponse;
            
    }
    Public class AuraResponse{
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
    public class ParentWrapper{
        @AuraEnabled public list<Wrapper> lstAccountWrapper ;
        @AuraEnabled public list<Wrapper> lstContactWrapper ;
        @AuraEnabled public lead recordLead;
        @AuraEnabled public list<PicklistWrapper> lstClientType;
        @AuraEnabled public list<PicklistWrapper> lstClientRegion;
        @AuraEnabled public list<PicklistWrapper> lstAuthorizedDealer;
    	ParentWrapper(list<Wrapper>lstAccountWrapper,
                      list<Wrapper> lstContactWrapper,
                     lead recordLead, 
                     list<PicklistWrapper> lstClientType,
                     list<PicklistWrapper> lstClientRegion,
                     list<PicklistWrapper> lstAuthorizedDealer){
                          this.lstAccountWrapper = lstAccountWrapper;
                          this.lstContactWrapper = lstContactWrapper;
                          this.recordLead = recordLead;
                         this.lstClientType=lstClientType;
                         this.lstClientRegion=lstClientRegion;
                         this.lstAuthorizedDealer = lstAuthorizedDealer;
                      }
    }
    public class Wrapper{
        @AuraEnabled public string Id ='';
        @AuraEnabled public string Name = '';
        @AuraEnabled public string MobileNumber = '';
        @AuraEnabled public string Email = '';
        @AuraEnabled public string accountId = '';
        wrapper(string Id,
                string Name,
                string MobileNumber, 
                string Email,
                string accountId){
                    this.Id=Id;        
                    this.Name = Name;
                    this.MobileNumber = MobileNumber;
                    this.Email = Email;
                    this.accountId = accountId;
        }
    }
    public class PicklistWrapper{
       	 @AuraEnabled public string label;
       	 @AuraEnabled public string value;
         
         public PicklistWrapper(string Label,
                                  string Value
                                 ) {
            this.label =  Label;
            this.value = Value;
         }
     }  
}