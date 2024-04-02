public class MatchingEmailCmpController {
    @AuraEnabled(cacheable=true)
    public static AuraResponse getactiveUnitsRecord() {
        AuraResponse auraResponse;
        list<UnitWrapper> lstUnitWrapper = new list<UnitWrapper>();
        try{
            list<product2> lstProduct = [SELECT id,ZID__c,Name,Account__r.Name,Starting_Advertised_Retail_Price__c,account__c,category__c,
                                         Old_SF_Unit_Details__c,IsActive,CreatedDate,Purchase_Date__c,EW_Date_of_Last_Price_Analysis__c
                                         FROM product2
                                         WHERE IsActive = true ];
            system.debug('lstProduct::'+lstProduct);
            
            if(lstProduct != null && !lstProduct.isEmpty()){
                for(product2 eachProduct : lstProduct){
                    UnitWrapper newUnitWrapper = new UnitWrapper();
                    newUnitWrapper.Id = eachProduct.Id;
                    newUnitWrapper.Name = eachProduct.name;
                    newUnitWrapper.ZID = eachProduct.ZID__c;
                    newUnitWrapper.Category = eachProduct.category__c;
                    newUnitWrapper.AccountName = eachProduct.Account__r.Name;
                    newUnitWrapper.SARP = eachProduct.Starting_Advertised_Retail_Price__c;
                    newUnitWrapper.Unit_Details = eachProduct.Old_SF_Unit_Details__c;
                    newUnitWrapper.Account = eachProduct.account__c;
                    lstUnitWrapper.add(newUnitWrapper);
                }
            }
            if(lstUnitWrapper != null && !lstUnitWrapper.isEmpty()){
                auraResponse = new AuraResponse();
                auraResponse.isSuccess = true;
                auraResponse.message = 'List of active Units';
                auraResponse.unitWrapper = lstUnitWrapper;
                return auraResponse;
            }
        }
        catch(exception ex){
            auraResponse = new AuraResponse();
            auraResponse.isSuccess = false;
            auraResponse.message = ex.getmessage();
        }
        return auraResponse;
    }
    
    @AuraEnabled(cacheable=true)
    public static AuraResponse getAccountRecords(List<String> lstUnitid) {
        AuraResponse auraResponse;
        list<AccountWrapper> lstAccountWrapper = new list<AccountWrapper>();
        system.debug('lstUnitid::'+lstUnitid);   
        try{
            list<product2> lstProduct = new list<product2>();
            list<account> lstAccount = new list<account>();
            set<id> setOfAccId = new set<id>();
            if(lstUnitid != null && !lstUnitid.isEmpty()){
                lstProduct = [SELECT ID,account__r.name,account__r.Primary_Contact__r.Name,account__r.Primary_Contact__r.Email,account__c,zid__c
                              FROM product2
                              WHERE ID IN : lstUnitid AND account__c != null];
            }
            if(lstProduct!= null && !lstProduct.isEmpty()){
                for(product2 eachProduct :lstProduct ){
                    setOfAccId.add(eachProduct.account__c);
                }
            }
            if(setOfAccId != null && !setOfAccId.isEmpty()){
                lstAccount = [SELECT id,name,Primary_Contact__r.name,Primary_Contact__r.Email
                              FROM account
                              WHERE ID IN :setOfAccId ];
            }
            
            if(lstAccount!= null && !lstAccount.isEmpty()){
                for(Account eachAccount : lstAccount){
                    AccountWrapper newAccount = new AccountWrapper();
                    newAccount.Id = eachAccount.id;
                    newAccount.Name = eachAccount.name;
                    newAccount.Primary_Contact = eachAccount.Primary_Contact__r.Name;
                    newAccount.Email = eachAccount.Primary_Contact__r.Email;
                    lstAccountWrapper.add(newAccount);
                }
            }
            if(lstAccountWrapper != null && !lstAccountWrapper.isEmpty()){
                auraResponse = new AuraResponse();
                auraResponse.isSuccess = true;
                auraResponse.message = 'List of account records';
                auraResponse.AccountWrapper = lstAccountWrapper;
                return auraResponse;
            }
        }
        catch(exception ex){
            auraResponse = new AuraResponse();
            auraResponse.isSuccess = false;
            auraResponse.message = ex.getmessage();
        }
        return auraResponse;
    }
    
    @AuraEnabled
    public static AuraResponse sendEmailFromMarketingCloud(list<Id> lstAccountId, list<string> lstAccountClientType, list<string> lstAuthorizedDealerFor, list<string> lstZID) {
        system.debug('enter in sendEmailFromMarketingCloud::::');
        system.debug('lstAccountId123::'+lstAccountId);
        system.debug('lstAccountIdclientType::'+lstAccountClientType);
        system.debug('lstAuthorizedDealerFor::'+lstAuthorizedDealerFor);
        system.debug('lstZID::'+lstZID);
        String accountClientType;
        String ZID;
        string authorizedDealerFor;
        Set<Id> setOfAccId;
        if(lstZID != null && !lstZID.isEmpty()){
            ZID = String.join(lstZID, ',');
            system.debug('outputZID::'+ZID);
        }
        if(lstAccountClientType != null && !lstAccountClientType.IsEmpty()){
            accountClientType = String.join(lstAccountClientType, ',');
            system.debug('outputAccountClientType::'+AccountClientType);
        }
        if(lstAccountId != null && !lstAccountId.isEmpty()){
            setOfAccId = new Set<Id>(lstAccountId);
            system.debug('setOfAccId:::'+setOfAccId);
        }
        if(lstAuthorizedDealerFor != null && !lstAuthorizedDealerFor.isEmpty()){
            authorizedDealerFor = String.join(lstAuthorizedDealerFor, ',');
        }
        AuraResponse auraResponse;
        try{
            if(setOfAccId != null && !setOfAccId.isEmpty() && (string.isnotBlank(accountClientType) || string.isnotBlank(authorizedDealerFor)) 
               && string.isnotblank(ZID)){
                CreateMarketingCloudConnection batchInstance = new CreateMarketingCloudConnection(setOfAccId, accountClientType, authorizedDealerFor, ZID);
                Database.executeBatch(batchInstance);
                auraResponse = new AuraResponse();
                auraResponse.isSuccess = true;
                auraResponse.message = 'Email send Successfully!!';
                auraResponse.response = '';
                return auraResponse;
            } 
        }
        catch(exception ex){
            auraResponse = new AuraResponse();
            auraResponse.isSuccess = false;
            auraResponse.message = ex.getmessage();
        }
        
        system.debug('auraResponse::'+auraResponse);
        return auraResponse;
    }
    @AuraEnabled(cacheable=true)
    public static AuraResponse getunitRecordsBasedOndealer(List<String> lstAuthorizedDealer) {
        system.debug('lstAuthorizedDealer::'+lstAuthorizedDealer);
        system.debug('lstAuthorizedDealer1::'+lstAuthorizedDealer.size());
        AuraResponse auraresponse;
        list<UnitWrapper> lstUnitWrapper = new list<UnitWrapper>();
        try {
            if (lstAuthorizedDealer != null && !lstAuthorizedDealer.isEmpty()) {
                String query = 'SELECT Id, ZID__c, Name, Account__r.Name, Starting_Advertised_Retail_Price__c,category__c, Old_SF_Unit_Details__c, IsActive, CreatedDate, Purchase_Date__c, EW_Date_of_Last_Price_Analysis__c FROM Product2 WHERE (';
                for (String eachdealer : lstAuthorizedDealer) {
                    query += ' Manufacturer__c LIKE \'%' + eachdealer + '%\' OR';
                }
                query = query.substring(0, query.length() - 3);
                if(string.isNotblank(query)){
                    query += ') AND isactive = true';
                }
                system.debug('query::'+query);
                List<Product2> lstProduct = Database.query(query);
                system.debug('lstProduct::'+lstProduct);
                System.debug('SOQL Query: ' + query);
                
                    if(lstProduct != null && !lstProduct.isEmpty()){
                        for(product2 eachProduct : lstProduct){
                            UnitWrapper newUnitWrapper = new UnitWrapper();
                            newUnitWrapper.Id = eachProduct.Id;
                            newUnitWrapper.Name = eachProduct.name;
                            newUnitWrapper.ZID = eachProduct.ZID__c;
                            newUnitWrapper.Category = eachProduct.category__c;
                            newUnitWrapper.AccountName = eachProduct.Account__r.Name;
                            newUnitWrapper.SARP = eachProduct.Starting_Advertised_Retail_Price__c;
                            newUnitWrapper.Unit_Details = eachProduct.Old_SF_Unit_Details__c;
                            lstUnitWrapper.add(newUnitWrapper);
                        }
                    } 
                else {
                    auraResponse = new AuraResponse();
                    auraResponse.isSuccess = false;
                    auraResponse.message = 'Record not found';
                    return auraresponse; 
                }
                if(lstUnitWrapper != null && !lstUnitWrapper.isEmpty()){
                    auraResponse = new AuraResponse();
                    auraResponse.isSuccess = true;
                    auraResponse.message = 'List of active Units with manufacturer';
                    auraResponse.unitWrapper = lstUnitWrapper;
                    system.debug('auraresponse11::'+auraresponse);
                    return auraresponse;
                }
                
            }
        } catch (Exception ex) {
            auraResponse = new AuraResponse();
            auraResponse.isSuccess = false;
            auraResponse.message = ex.getmessage();
            return auraresponse;
        }
        system.debug('auraresponse::'+auraresponse);
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static AuraResponse getPicklistValues(String objectApiName, String fieldApiName) {
        AuraResponse auraResponse;
        try {
            if(string.IsnotBlank(objectApiName) && string.isnotBlank(fieldApiName)){
                Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
                if (fieldResult != null ) {
                    List<Schema.PicklistEntry> lstPicklistValues = fieldResult.getPicklistValues();
                    List<String> lstPicklistValue = new List<String>();
                    if(lstPicklistValues != null && !lstPicklistValues.isEmpty()){
                        for(Schema.PicklistEntry eachPicklistValue : lstPicklistValues) {
                            lstPicklistValue.add(eachPicklistValue.getLabel());
                        }  
                    }
                    if(lstPicklistValue != null && !lstPicklistValue.isEmpty()){
                        auraResponse = new AuraResponse();
                        auraResponse.isSuccess = true;
                        auraResponse.message = 'Picklist Values found';
                        auraResponse.lstPicklistValue = lstPicklistValue;
                        return auraResponse;
                    }
                }
            }
        } catch(Exception ex) {
            auraResponse = new AuraResponse();
            auraResponse.isSuccess = false;
            auraResponse.message = ex.getmessage();
        }
        return auraResponse;
    }
    
    public class AuraResponse {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
        @AuraEnabled public String response;
        @AuraEnabled public list<UnitWrapper> unitWrapper;
        @AuraEnabled public list<AccountWrapper> AccountWrapper;
        @AuraEnabled public list<string> lstPicklistValue;
    }
    
    public class UnitWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String ZID;
        @AuraEnabled public string AccountName;
        @AuraEnabled public decimal SARP;
        @AuraEnabled public string Account;
        @AuraEnabled public string Category;
        @AuraEnabled public string Unit_Details;
    }
    public class AccountWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String ZID;
        @AuraEnabled public String Name;
        @AuraEnabled public String Primary_Contact;
        @AuraEnabled public string Email;
    }
    
}