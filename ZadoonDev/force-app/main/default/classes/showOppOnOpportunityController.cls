// this Class is used in LWC  

public class showOppOnOpportunityController {
    
    @AuraEnabled
    public static AuraResponse getOpportunityDetails(Id recordId){
        AuraResponse AuraResponse;
        
        try{
            ParentWrapper ParentWrapper = new ParentWrapper();
            if(string.isNotBlank(recordId)) {
                ParentWrapper.closeWonOpportunity =  getCloseWonOpportunity(recordId);
                ParentWrapper.closeLostOpportunity = getCloseLostOpportunity(recordId);
                ParentWrapper.totalNoOfcloseWonOpportunity = getCloseWonOpportunity(recordId).Size(); 
                ParentWrapper.totalNoOfcloseLostOpportunity = getCloseLostOpportunity(recordId).Size(); 
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
    
    
    // function to get close Won Opportunity releated to that Account 
    
    private static list<wrapper> getCloseWonOpportunity(Id recordId){
        system.debug(recordId);
        list<Wrapper> lstWrapper = new list<Wrapper>();
        //To get current Opportunity Record 
        Opportunity currentOpportunity=[SELECT Id,  
                                        Name, 
                                        AccountId, 
                                        IsWon, 
                                        Product__c,
                                        Product__r.Manufacturer__c,
                                        Product__r.Base__c,
                                        Buyer_Primary_Contact__c,
                                        RecordTypeId
                                        FROM opportunity 
                                        WHERE id=:recordId  AND 
                                        Product__c != null AND
                                        Product__r.Manufacturer__c != null AND
                                       Product__r.Base__c != null];
        system.debug('Current Opportunity :::'+currentOpportunity);
        
        if(currentOpportunity != Null && currentOpportunity.RecordTypeId==getRecordTypeId(System.Label.Opp_Rec_type_Dev_Name_procurement_opp)){
            //to get All Close Won Opportunity record releated to that Unit__c 
            list<opportunity> lstOpportunity = [SELECT Id, 
                                                Name, 
                                                Account.Name,
                                                Product__r.Name,
                                                Product__r.Base__c,
                                                Product__r.Manufacturer__c,
                                                Starting_Advertised_Retail_Price2__c,
                                                Loss_Reason__c,
                                                Buyer_Primary_Contact__r.Name, 
                                                Closedate, 
                                                Buyer_Mobile_Number__c,
                                                Offer_Amount__c,
                                                Lowest_Purchase_Price__c,
                                                Total_Cost__c  
                                                FROM opportunity 
                                                WHERE Product__r.Manufacturer__c != null AND
                                                Product__r.Manufacturer__c=:currentOpportunity.Product__r.Manufacturer__c AND 
                                                IsClosed=true AND 
                                                Product__c != null AND 
                                                Product__r.Base__c != Null AND
                                                Product__r.Base__c =: currentOpportunity.Product__r.Base__c AND
                                                //Product__r.equipment__c != null AND 
                                                Id !=:currentOpportunity.Id AND
                                                (StageName = 'Won - Purchased' OR 
                                                 StageName = 'Won - Brokered'OR
                                                 StageName = 'Closed Won'OR
                                                 IsWon=true) AND 
                                               ( recordType.DeveloperName =: label.Opp_Rec_Type_Broker_Sell OR 
                                               recordType.DeveloperName =: label.Opp_Rec_Type_Inventory_Sell )
                                               ];
            if(lstOpportunity!=null && !lstOpportunity.isEmpty()) {
                
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
                                               eachOpportunity.Closedate,
                                               eachOpportunity.Offer_Amount__c,
                                               eachOpportunity.Lowest_Purchase_Price__c,
                                               eachOpportunity.Total_Cost__c));
                }
            }
        }else if(currentOpportunity.RecordTypeId==getRecordTypeId(System.Label.Opp_Rec_Type_Broker_Sell)||
                 currentOpportunity.RecordTypeId==getRecordTypeId(System.Label.Opp_Rec_Type_Inventory_Sell)){
                     system.debug('Current Opportunity For Broker or Inventry:::'+currentOpportunity);
                     //to get All Close Won Opportunity record releated to that Unit__c 
                     list<opportunity> lstOpportunity = [SELECT Id, 
                                                         Name, 
                                                         Account.Name,
                                                         Product__r.Name,
                                                         Starting_Advertised_Retail_Price2__c,
                                                         Loss_Reason__c,
                                                         Buyer_Primary_Contact__r.Name, 
                                                         Closedate, 
                                                         Buyer_Mobile_Number__c,
                                                         Offer_Amount__c,
                                                         Lowest_Purchase_Price__c,
                                                         Total_Cost__c  
                                                         FROM opportunity 
                                                         WHERE Buyer_Primary_Contact__c=:currentOpportunity.Buyer_Primary_Contact__c AND 
                                                         IsClosed=true AND 
                                                         Buyer_Primary_Contact__c != null AND 
                                                         Id !=:currentOpportunity.Id AND
                                                         (StageName = 'Won - Purchased' OR
                                                          StageName = 'Won - Brokered'OR
                                                          StageName = 'Closed Won' OR
                                                          IsWon=true)];
                     if(lstOpportunity!=null && !lstOpportunity.isEmpty()) {
                         
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
                                                        eachOpportunity.Closedate,
                                                        eachOpportunity.Offer_Amount__c,
                                                        eachOpportunity.Lowest_Purchase_Price__c,
                                                        eachOpportunity.Total_Cost__c));
                         }
                     }
                     system.debug(lstOpportunity);
                 }
        //Returning Wrapper to LWC
        
        system.debug(lstWrapper);
        return lstWrapper;
    }
    
    
    
    // function to get close Lost Opportunity releated to that Unit__c 
    
    private static list<wrapper> getCloseLostOpportunity(Id recordId){
        system.debug(recordId);
        list<Wrapper> lstWrapper = new list<Wrapper>();
        //To Get Current Opportunity
        opportunity currentOpportunity=[SELECT Id, 
                                        Name, 
                                        AccountId, 
                                        IsWon, 
                                        IsClosed, 
                                        Product__c,
                                        Product__r.Base__c,
                                        Product__r.Manufacturer__c,
                                        Buyer_Primary_Contact__c,
                                        RecordTypeId 
                                        FROM opportunity 
                                        WHERE id=:recordId AND 
                                        Product__c != null AND
                                       Product__r.Base__c != null AND
                                       Product__r.Manufacturer__c != null];
        
        
        if(currentOpportunity.RecordTypeId==getRecordTypeId(System.Label.Opp_Rec_type_Dev_Name_procurement_opp)){         
            //To Get All CloseLost Opportunity Releated to Unit
            list<opportunity> lstOpportunity = [SELECT Id,
                                                Name, 
                                                Account.Name,
                                                Product__r.Name,
                                                Product__r.Manufacturer__c,
                                                Product__r.Base__c,
                                                Starting_Advertised_Retail_Price2__c,
                                                Loss_Reason__c,
                                                Buyer_Primary_Contact__r.Name, 
                                                Closedate, 
                                                Buyer_Mobile_Number__c,
                                                Offer_Amount__c,
                                                Lowest_Purchase_Price__c,
                                                Total_Cost__c  
                                                FROM opportunity 
                                                WHERE Product__r.Manufacturer__c != null AND
                                                IsClosed=true AND 
                                                Product__c != null AND 
                                                Product__r.Base__c != Null AND
                                                Product__r.Base__c =: currentOpportunity.Product__r.Base__c AND
                                                Product__r.Manufacturer__c=:currentOpportunity.Product__r.Manufacturer__c AND 
                                                 
                                                Id !=:currentOpportunity.Id AND
                                                (StageName = 'Stopped Pursuing' OR
                                                 StageName = 'Rejected' OR
                                                 StageName = 'Closed Lost')AND 
                                               ( recordType.DeveloperName =: label.Opp_Rec_Type_Broker_Sell OR 
                                               recordType.DeveloperName =: label.Opp_Rec_Type_Inventory_Sell )
                                               ];
            
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
                                               eachOpportunity.Closedate,
                                               eachOpportunity.Offer_Amount__c,
                                               eachOpportunity.Lowest_Purchase_Price__c,
                                               eachOpportunity.Total_Cost__c));
                }
            }
        }else if(currentOpportunity.RecordTypeId==getRecordTypeId(System.Label.Opp_Rec_Type_Broker_Sell)||
                 currentOpportunity.RecordTypeId==getRecordTypeId(System.Label.Opp_Rec_Type_Inventory_Sell)){
                     //To Get All CloseLost Opportunity Releated to Unit
                     list<opportunity> lstOpportunity = [SELECT Id,
                                                         Name, 
                                                         Account.Name,
                                                         Product__r.Name,
                                                         Starting_Advertised_Retail_Price2__c,
                                                         Loss_Reason__c,
                                                         Buyer_Primary_Contact__r.Name,
                                                         Buyer_Primary_Contact__c, 
                                                         Closedate, 
                                                         Buyer_Mobile_Number__c,
                                                         Offer_Amount__c,
                                                         Lowest_Purchase_Price__c,
                                                         Total_Cost__c  
                                                         FROM opportunity 
                                                         WHERE Buyer_Primary_Contact__c=:currentOpportunity.Buyer_Primary_Contact__c AND
                                                         IsClosed=true AND 
                                                         Buyer_Primary_Contact__c != null AND
                                                         Id !=:currentOpportunity.Id AND
                                                         (StageName = 'Stopped Pursuing' OR 
                                                          StageName = 'Rejected' OR
                                                          StageName = 'Closed Lost')];
                     
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
                                                        eachOpportunity.Closedate,
                                                        eachOpportunity.Offer_Amount__c,
                                                        eachOpportunity.Lowest_Purchase_Price__c,
                                                        eachOpportunity.Total_Cost__c));
                         }
                     }
                     //Returning Wrapper to LWC
                 }
        system.debug(lstWrapper);
        return lstWrapper;
    }
    
    // get RecordType id based on label Record Type Name 
    private static id getRecordTypeId(string labelValue){
        // To query RecordType Id
        RecordType CurrentRecordType = [SELECT Id
                                        FROM RecordType
                                        WHERE DeveloperName =:labelValue LIMIT 1];
        system.debug(CurrentRecordType.Id);
        return CurrentRecordType.Id;
        
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
    
    
    //wrapper calss to Wrappe 
    public class ParentWrapper {
        @AuraEnabled public list<Wrapper> closeWonOpportunity;
        @AuraEnabled public list<Wrapper> closeLostOpportunity;
        @AuraEnabled public decimal totalNoOfcloseWonOpportunity; 
        @AuraEnabled public decimal totalNoOfcloseLostOpportunity; 
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
        @AuraEnabled public decimal offerAmount;
        @AuraEnabled public decimal lowestPurchasePrice;
        @AuraEnabled public decimal totalCost; 
        
        
        
        wrapper(string Id,
                string Name, 
                string AccountName,
                string UnitName, 
                decimal StartingRetailPrice,
                string LossReason,
                string PrimaryContact,
                string BuyerMobileNumber ,
                date CloseDate,
                decimal offerAmount,
                decimal lowestPurchasePrice,
                decimal totalCost) {
                    this.Id=Id;        
                    this.Name = Name;
                    this.AccountName = AccountName;
                    this.UnitName = UnitName;
                    this.StartingRetailPrice = StartingRetailPrice;
                    this.LossReason = LossReason;       
                    this.PrimaryContact = PrimaryContact;
                    this.BuyerMobileNumber = BuyerMobileNumber;
                    this.CloseDate = CloseDate;
                    this.offerAmount = offerAmount;
                    this.lowestPurchasePrice = lowestPurchasePrice;
                    this.totalCost = totalCost;
                    
                }
    }    
}