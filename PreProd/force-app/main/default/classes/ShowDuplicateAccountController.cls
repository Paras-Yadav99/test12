/*
* This Class is used to provide Duplicate Account data to the LWC named as "ShowDuplicateAccount"
*/
public class ShowDuplicateAccountController {
    /*
	 * This methid is used to validate the recordId and get the Account
	 */
    @AuraEnabled
    public static AuraResponse getDuplicateAccounts(String recordId){
        AuraResponse auraResponse;
        
        try{
            
            if(string.isNotBlank(recordId)) {
                auraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(handleGetDuplicateAccounts(recordId)));
                
            } else {
                auraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'RecordId Not found!' );
            }
            
        } catch (Exception ex) {
            auraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        
        return auraResponse;
    }
   
   
    /*
	 * This method is used to get the list for the duplicate Account
	 */
    private static list<Wrapper> handleGetDuplicateAccounts(Id recordId){
        boolean isOwned = false;
        list<Wrapper> lstwrapper = new list<Wrapper>();
        Account CurrentAccount = [SELECT Id,Name
                                FROM Account
                                WHERE Id =: recordId
                                WITH SECURITY_ENFORCED
                                LIMIT 1];
        
        list<Account> lstDuplicateAccounts = new list<Account>();
        lstDuplicateAccounts = [SELECT Id,Name,Phone,
                                Client_Type__c,Client_Region__C
                                FROM Account
                                WHERE Name =: CurrentAccount.Name
                                AND Id !=: recordId
                                WITH SECURITY_ENFORCED
                                ];
        System.debug('lstDuplicateAccounts ::::'+lstDuplicateAccounts);
        
        if(lstDuplicateAccounts!=null &&! lstDuplicateAccounts.isEmpty()){
            For(Account eachAccount : lstDuplicateAccounts){
              
                Wrapper newWrapper = new Wrapper(eachAccount.Id,
                                                 eachAccount.Name,
                                                 eachAccount.Phone,
                                                 String.valueOf(eachAccount.Client_Region__c),
                                                 eachAccount.Client_Type__c);
                lstwrapper.add(newWrapper);
            }
        }
        return lstwrapper;
    }


	/*
	 * Wrapper Class to hold Accounts Data 
	 */    
    public class Wrapper{
        @AuraEnabled public string id;
        @AuraEnabled public String name;
        @AuraEnabled public String phone;
        @AuraEnabled public String clientRegion;
        @AuraEnabled public string clientType;
        
        Wrapper(string id,
                String name,
                String phone,
                String clientRegion,
                String clientType){
                    
                    this.id = id;
                    this.name=name;
                    this.phone= phone;
                    this.clientRegion = clientRegion;
                    this.clientType = clientType;
                }
        
    }
    
    /*
	 * wrapper Class to provide the response to the Ligthning Web Component
	 */    
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
    


}