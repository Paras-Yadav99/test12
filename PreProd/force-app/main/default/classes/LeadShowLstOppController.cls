public with sharing class LeadShowLstOppController {
    // function to get close Won Opportunity releated to that Account 
    @AuraEnabled
    public static AuraResponse getOpportunityDetails(Id recordId){
        AuraResponse AuraResponse ;//= new AuraResponse();
        
        try{
            ParentWrapper ParentWrapper = new ParentWrapper();
            if(string.isNotBlank(recordId)) {
                ParentWrapper.closeWonOpportunity =  getCloseWonOpportunity(recordId);
                ParentWrapper.closeLostOpportunity = getCloseLostOpportunity(recordId);
                
                AuraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(ParentWrapper));
                
            } else {
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
    
    private static list<wrapper> getCloseWonOpportunity(Id recordId){
        system.debug(recordId);
        list<Wrapper> lstWrapper = new list<Wrapper>();
        lead CurrentLead=[SELECT Id, LastName, FirstName, Name,Contact__c, Account__c,Unit__c 
                          FROM Lead 
                          WHERE id=: recordId];
        system.debug(CurrentLead.Contact__c);
        list<opportunity> lstOpportunity = [SELECT Id, 
                                            Name, 
                                            Account.Name,
                                            Product__r.Name,
                                            Starting_Advertised_Retail_Price2__c,
                                            Loss_Reason__c,
                                            Buyer_Primary_Contact__c,
                                            Buyer_Primary_Contact__r.Name, 
                                            Closedate,
                                            StageName,
                                            IsClosed,
                                            Buyer_Mobile_Number__c 
                                            FROM opportunity 
                                            WHERE Buyer_Primary_Contact__c=:CurrentLead.Contact__c AND 
                                            IsClosed=true AND 
                                            Buyer_Primary_Contact__c != null AND 
                                            (StageName = 'Won - Purchased' OR
                                             StageName = 'Won - Brokered'OR
                                             IsWon=true OR
                                             StageName='Closed Won')];
        System.debug('lstOpportunity :'+lstOpportunity);
        if(lstOpportunity!=null && !lstOpportunity.isEmpty()){
            
            //Assigning data to the Wrapper 
            for (Opportunity eachOpportunity: lstOpportunity) {
                lstWrapper.add(new Wrapper(eachOpportunity.Id,
                                            eachOpportunity.Name,
                                           eachOpportunity.Account.Name,
                                           eachOpportunity.Product__r.Name,
                                           eachOpportunity.Starting_Advertised_Retail_Price2__c,
                                           eachOpportunity.Loss_Reason__c,
                                           eachOpportunity.Buyer_Primary_Contact__r.Name,
                                           eachOpportunity.Buyer_Mobile_Number__c ,
                                           eachOpportunity.Closedate));
            }
        }
        
        
        //Returning Wrapper to LWC
        system.debug(lstOpportunity);
        system.debug(lstWrapper);
        return lstWrapper;
    }
    
    private static list<wrapper> getCloseLostOpportunity(Id recordId){
        system.debug(recordId);
        list<Wrapper> lstWrapper = new list<Wrapper>();
        Lead CurrentLead=[SELECT Id, LastName, FirstName, Name,Contact__c, Account__c,Unit__c
                          FROM Lead 
                          WHERE id=: recordId];
        //To Get All CloseLost Opportunity Releated to Unit
        list<opportunity> lstOpportunity = [SELECT Id,
                                            Name, 
                                            Account.Name,
                                            Product__r.Name,
                                            Starting_Advertised_Retail_Price2__c,
                                            Loss_Reason__c,
                                            Buyer_Primary_Contact__c,
                                            Buyer_Primary_Contact__r.Name, 
                                            Closedate, 
                                            Buyer_Mobile_Number__c 
                                            FROM opportunity 
                                            WHERE Buyer_Primary_Contact__c=:CurrentLead.Contact__c AND
                                            IsClosed=true AND
                                            Buyer_Primary_Contact__c!= null AND
                                            (StageName = 'Stopped Pursuing' OR 
                                             StageName = 'Rejected' OR
                                             StageName='Closed Lost' OR
                                             IsWon=false 
                                            )];
        System.debug('lstOpportunity :'+lstOpportunity);
        if(lstOpportunity!=null && !lstOpportunity.isEmpty()) {
            
            //Assigning data to Wrapper
            for (Opportunity eachOpportunity: lstOpportunity) {
                lstWrapper.add(new Wrapper(eachOpportunity.Id,
                                           eachOpportunity.Name,
                                           eachOpportunity.Account.Name,
                                           eachOpportunity.Product__r.Name,
                                           eachOpportunity.Starting_Advertised_Retail_Price2__c,
                                           eachOpportunity.Loss_Reason__c,
                                           eachOpportunity.Buyer_Primary_Contact__r.Name,
                                           eachOpportunity.Buyer_Mobile_Number__c ,
                                           eachOpportunity.Closedate));
            }
        }
        //Returning Wrapper to LWC
        
        system.debug(lstWrapper);
        return lstWrapper;
    }
    //Wrapper Class 
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
    
    
    //wrapper calss to Wrappe 
    public class ParentWrapper {
        @AuraEnabled public list<Wrapper> closeWonOpportunity;
        @AuraEnabled public list<Wrapper> closeLostOpportunity;
    }
     
    //Wrapper Class 
    public class Wrapper{
        @AuraEnabled public string Id ='';
        @AuraEnabled public string Name = '';
        @AuraEnabled public string AccountName = '';
        @AuraEnabled public string UnitName = '';
        @AuraEnabled public decimal StartingRetailPrice ;
        @AuraEnabled public string LossReason = '';
        @AuraEnabled public string PrimaryContact = '';
        @AuraEnabled public string BuyerMobileNumber  = '';
        @AuraEnabled public date CloseDate;
        
        
        wrapper(string Id,
                string Name, 
                string AccountName,
                string UnitName, 
                decimal StartingRetailPrice,
                string LossReason,
                string PrimaryContact,
                string BuyerMobileNumber ,
                date CloseDate ) {
            this.Id=Id;        
            this.Name = Name;
            this.AccountName = AccountName;
            this.UnitName = UnitName;
            this.StartingRetailPrice = StartingRetailPrice;
            this.LossReason = LossReason;       
            this.PrimaryContact = PrimaryContact;
            this.BuyerMobileNumber = BuyerMobileNumber;
            this.CloseDate = CloseDate;
            
        }
    }
    
            
}