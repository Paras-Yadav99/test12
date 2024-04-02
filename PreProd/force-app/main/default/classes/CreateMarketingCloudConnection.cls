global class CreateMarketingCloudConnection implements Database.Batchable<sObject>,Database.Stateful {
	// Define instance variables to store parameters
    private set<Id> setOfAccountId;
    private string AccountClientType;
    private string AuthorizedDealerFor;
    private string ZID;
    global CreateMarketingCloudConnection(set<Id> setOfAccountId, string AccountClientType, string AuthorizedDealerFor, string ZID) {
        system.debug('setOfAccountId::'+setOfAccountId);
        system.debug('AccountClientType::'+AccountClientType);
        system.debug('AuthorizedDealerFor::'+AuthorizedDealerFor);
        system.debug('ZID::'+ZID);
        this.setOfAccountId = setOfAccountId;
        this.AccountClientType = AccountClientType;
        this.AuthorizedDealerFor = AuthorizedDealerFor;
		this.ZID = ZID;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        list<String> lstString;
        String query = 'SELECT Id, Email,AccountId FROM Contact WHERE '; 
        if(string.isNotBlank(AccountClientType)){
             lstString = AccountClientType.split(',');
            query += ' Account.Client_Type__c IN : lstString ';
        }else if(string.isNotBlank(AuthorizedDealerFor)){
             lstString = AuthorizedDealerFor.split(',');
            query += ' Account.Authorized_Dealer_For__c IN : lstString ';
        }
           
        if(setOfAccountId!=null && !setOfAccountId.IsEmpty()){
            query += ' AND AccountId NOT IN : setOfAccountId ';
            
        }
        query += ' AND AccountId != Null AND Email != Null';
        
        system.debug('query::::'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        list<Marketing_Cloud_Connection__c>lstMarketingCloudConnection = new list<Marketing_Cloud_Connection__c>();

        for(Contact eachContact : scope){
            Marketing_Cloud_Connection__c newMarketingCloudConnection = new Marketing_Cloud_Connection__c();
            newMarketingCloudConnection.Contact__c = eachContact.id;
            newMarketingCloudConnection.Email__c = eachContact.Email;
            newMarketingCloudConnection.Product_Keys__c = ZID ;
            lstMarketingCloudConnection.add(newMarketingCloudConnection);
        }
        if(lstMarketingCloudConnection!=null && !lstMarketingCloudConnection.isEmpty()){
            system.debug('lstMarketingCloudConnectionsize:::'+lstMarketingCloudConnection.Size());           
            system.debug('lstMarketingCloudConnection:::'+lstMarketingCloudConnection);
            //insert lstMarketingCloudConnection;
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
        // give a call to another batch class
        // Can give to another batch class
        // Can give callout request
        system.debug('batch job id = '+bc.getJobId());
    }
	
}