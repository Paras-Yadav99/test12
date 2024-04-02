/*
This class is used to provide data to FreightProcessCmp LWC and to handle events from the LWC
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          06-Aug-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/

public class FreightProcessCmpController {
    
    public class newException extends Exception {} 
    
    //To delete freight records if system gone into fatal error
    public static list<Freight_Company_Unit__c>lstToDeleteFreightCompanyUnits = new list<Freight_Company_Unit__c>();
   // To revert the updates on Accounts if System goes to fatal error
    public static list<Account>lstToReUpdateAccounts = new list<Account>();
    
     /*
     * This Method is used to provide the contact data on Load for the LWC
	 */
	 @AuraEnabled
    public static AuraResponse getContactData(String wrapperKey){
        AuraResponse AuraResponse;
        
        try{
            //Check for input Value
            
            AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                            JSON.serialize(handleGetContactData(wrapperKey)));
            
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        
        // Returning Aura-Response to LWC
        return AuraResponse;
    }
    
     /*
     * This Method is used to provide the Freight data on Load for the site LWC
	 */
     @AuraEnabled
    public static AuraResponse getInitialFreightData(String recordId){
        AuraResponse AuraResponse;
        
        try{
            //Check for input Value
            
            If(String.isNotBlank(recordId)){
            AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                            JSON.serialize(handleGetInitialFreightData(recordId)));
                
            }else{
                AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            'Record Id not Found!');
            }
            
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        
        // Returning Aura-Response to LWC
        return AuraResponse;
    }
    
     /*
     * This Method is used to handle Send Email Event 
	 */
      @AuraEnabled
    public static AuraResponse SendFreightEmails(String freightWrappedData,list<String>lstSelectedAccountIds,String wrappedAccountData, string UnitId){
        AuraResponse AuraResponse;
         Savepoint sp = Database.setSavepoint();
        try{
            //Check for input Value
            
            AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                            handleSendFreightEmails(freightWrappedData,lstSelectedAccountIds,wrappedAccountData,UnitId));
                
           
            
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
            System.debug('ERROR :::::'+ex.getMessage());
            System.debug('ERROR AT:::::'+ex.GetLineNumber());
            Database.rollback(sp);
          /*  if(lstToDeleteFreightCompanyUnits!=null && !lstToDeleteFreightCompanyUnits.IsEmpty()){
                delete lstToDeleteFreightCompanyUnits;
            }
            if(lstToReUpdateAccounts!=null && !lstToReUpdateAccounts.IsEmpty()){
               // update lstToReUpdateAccounts;
            }*/
        }
        
        // Returning Aura-Response to LWC
        return AuraResponse;
    }
    
     /*
     * This Method is used to provide the data on Load for the LWC
	 */
    private static list<wrapperData> handleGetContactData(String wrapperKey){
        inputWrapper newInputWrapper = (inputWrapper)JSON.deserialize(wrapperKey, inputWrapper.Class);
        System.debug('newWrapperFilterData:::'+newInputWrapper);
       	Map<String, Object> Mapfilters = new Map<String, Object>(); 
        list<wrapperData>lstwrapperData = new list<wrapperData>();
        if(String.IsNotBlank(newInputWrapper.clientType)){
            Mapfilters.put('Client_Type__c',newInputWrapper.clientType);
        }
     
        String query = ReturnFilterQuery.buildFilterQuery('Account',Mapfilters);
        System.debug('query'+query);
        If(String.IsNotBlank(newInputWrapper.searchKey)){
            String searchKey =newInputWrapper.searchKey; 
            query+=' AND (Name LIKE \'%' + searchKey.trim() + '%\''; 
            query += ' OR ' + 'Primary_Contact__r.Name' + ' LIKE \'%' + searchKey.trim() + '%\'';
            query += ' OR ' + 'Primary_Contact__r.Email' + ' LIKE \'%' + searchKey.trim() + '%\'';
            query += ' OR ' + 'Primary_Contact__r.MailingStreet' + ' LIKE \'%' + searchKey.trim() + '%\'';
            query += ' OR ' + 'Primary_Contact__r.MailingCity' + ' LIKE \'%' + searchKey.trim() + '%\'';
            query += ' OR ' + 'Primary_Contact__r.MailingState' + ' LIKE \'%' + searchKey.trim() + '%\'';
            query += ' OR ' + 'Primary_Contact__r.MailingCountry' + ' LIKE \'%' + searchKey.trim() + '%\'';
            query += ' OR ' + 'Primary_Contact__r.MailingPostalCode' + ' LIKE \'%' + searchKey.trim() + '%\''+' )';
        }
        
        query += ' ORDER BY CreatedDate DESC';
        System.debug('query'+query);
        list<Account>lstAccounts = Database.query(query);
        set<String>setAccountIds = new set<String>();
        if(lstAccounts!=null && !lstAccounts.isEmpty()){
            for(Account eachAccount : lstAccounts){
                setAccountIds.add(eachAccount.Id);
            }
            SYSTEM.debug('SET OF CONTACT IDS : : : '+setAccountIds);
        }
        if(setAccountIds!=null && !setAccountIds.isEmpty()){
            lstwrapperData = handleGetWrappedData(setAccountIds);
        }
        
        return lstwrapperData;
    }
    
     /*
     * This child Method is used to provide Wrapper the data on Load for the LWC
	 */
    private static wrapperFreight handleGetInitialFreightData(Id recordId){
        System.debug('recordId ::::'+recordId);
        
        wrapperFreight newwrapperFreight = new wrapperFreight();
        list<Product2>lstUnits = new list<Product2>();
        lstUnits = [SELECT Id,
                    Name,
                    Storage_Address__c,
                    Storage_City__c,
                    Storage_Zip_Code__c,
                    Freight_Status__c,
                    Freight_Requested_By__c,
                    Freight_Budget__c,
                    Equipment_Specalog__c,
                    Site_Contact__c,
                    Site_Contact__r.Name,
                    Storage_State__c,
                    Storage_Country__c,
                    Freight_Drop_off_Date__c,
                    Freight_Ready_to_move__c,
                    Freight_destination__c,
                    Google_Drive_LInk__c,
                    Delivering_to_port_intl__c
                    FROM Product2 
                    WHERE Id =: recordId 
                    LIMIT 1];
        
        If(lstUnits!=null && !lstUnits.IsEmpty()){
            for(Product2 eachUnit : lstUnits){
                
                String ContactName = '';
                if(String.isNotBlank(eachUnit.Site_Contact__r.Name)){
                   ContactName = eachUnit.Site_Contact__r.Name; 
                }
                If(String.IsBlank(eachUnit.Equipment_Specalog__c)){
                     throw new newException('Please add Equipment Specalog before getting Freight Quotes'); 
                }
                if(String.IsBlank(eachUnit.Storage_City__c)||String.IsBlank(eachUnit.Storage_State__c)){
                    throw new newException('Please add Storage City and State'); 
                }
                 System.debug('eachUnit ::::'+eachUnit);
                wrapperFreight newwrapperFreight0 = new wrapperFreight(eachUnit.Id,
                                                                       eachUnit.Name,
                                                                       eachUnit.Storage_Address__c,
                                                                       eachUnit.Storage_City__c,
                                                                       eachUnit.Storage_State__c,
                                                                       eachUnit.Storage_Zip_Code__c,
                                                                       eachUnit.Storage_Country__c,
                                                                       ContactName,
                                                                       eachUnit.Site_Contact__c,
                                                                       eachUnit.Google_Drive_LInk__c,
                                                                       eachUnit.Delivering_to_port_intl__c,   
                                                                        'Requested',
                                                                       String.ValueOf(eachUnit.Freight_Drop_off_Date__c),
                                                                       System.UserInfo.getName(),
                                                                       System.UserInfo.getUserId(),
                                                                       eachUnit.Freight_Ready_to_move__c,
                                                                      eachUnit.Freight_Budget__c,
                                                                      false,
                                                                      false);
                newwrapperFreight = newwrapperFreight0;
            }
        }
        System.debug('newwrapperFreight :::::'+newwrapperFreight);
        return newwrapperFreight;
    }
    
    private static list<wrapperData> handleGetWrappedData(Set<String>setAccountIds){
        List<Account>lstAccounts = new List<Account>();        
        list<wrapperData>lstwrapperData = new list<wrapperData>();
        lstAccounts = [SELECT Id, Name, 
                       Client_Type__c, Primary_Contact_Email__c, 
                       Primary_Contact_Phone__c, 
                       Primary_Contact__c,
                       Primary_Contact__r.Name
                       FROM Account
                       WHERE Id IN : setAccountIds];
        if(lstAccounts!=null && !lstAccounts.isEmpty()){
            for(Account eachAccount : lstAccounts){
                wrapperData newWrapperData = new WrapperData(eachAccount.Id,
                                                             eachAccount.Name,
                                                             eachAccount.Primary_Contact__r.Name,
                                                             eachAccount.Primary_Contact__c,
                                                             eachAccount.Primary_Contact_Email__c,
                                                             eachAccount.Primary_Contact_Phone__c);
                lstwrapperData.add(newWrapperData);
            }
        }
        return lstwrapperData;
    }
    
     /*
     * This Child Method is used to handle send email from the Ppublic method
	 */
    private static String handleSendFreightEmails(String freightWrappedData,list<String>lstSelectedAccountIds,String wrappedAccountData, string UnitId){
        // String sendFreightEmail(list<Account> lstAccount , Product2 eachUnit,Map<String,Freight_Company_Unit__c> mapAccountIdVsEachFreight_Company_Unit)
        wrapperFreight wrapperFreightToInsert =(wrapperFreight)JSON.deserialize(freightWrappedData, wrapperFreight.Class);
        list<wrapperData>lstwrapperData = new list<wrapperData>();
        lstwrapperData = (list<wrapperData>)JSON.deserialize(wrappedAccountData, list<wrapperData>.Class);
        Map<String,Freight_Company_Unit__c> mapAccountIdVsEachFreight_Company_Unit = new Map<String,Freight_Company_Unit__c>();
        List<Account>lstAccounts = new List<Account>();   
        List<Product2>lstUnits = new List<Product2>(); 
        Set<Id>setOfAccountIds = new Set<Id>();
        //Map<String,String>mapAccIdVsContactId = Map<String,String>();
       // System.debug('selected acc: '+lstSelectedAccountIds.size());
        if(lstSelectedAccountIds!=null && !lstSelectedAccountIds.IsEmpty()){
        lstAccounts = [SELECT Id, Name, 
                       Client_Type__c, Primary_Contact_Email__c, 
                       Primary_Contact_Phone__c, 
                       Primary_Contact__c,
                       Freight_Quote_Submitted__c,
                       Primary_Contact__r.Name,
                       Primary_Contact__r.FirstName,
                       Primary_Contact__r.Email
                       FROM Account
                       WHERE Id IN : lstSelectedAccountIds
                       AND Primary_Contact_Email__c!=null];
            
        }
        
        if(lstAccounts!= null && !lstAccounts.IsEmpty()){
            for(Account eachAccount : lstAccounts){
                setOfAccountIds.add(eachAccount.Id);
            }
        }
        
        // get Unit  data
        Product2  eachUnit = [SELECT Id,
                    Name,
                    Storage_Address__c,
                    Storage_City__c,
                    Storage_Zip_Code__c,
                    Freight_Status__c,
                    Freight_Requested_By__c,
                    Freight_Budget__c,
                    Site_Contact__c,
                    Site_Contact__r.Name,
                    Storage_State__c,
                    Storage_Country__c,
                    Equipment_Specalog__c,
                    Freight_Drop_off_Date__c,
                    Freight_Ready_to_move__c,
                    Freight_destination__c,
                    Google_Drive_LInk__c ,
                              Manufacturer__c,
                              Year__c,ZID__c,Make__c,
                              Model__c
                    FROM Product2 
                    WHERE Id =: UnitId 
                    LIMIT 1];
        
        product2 unitToUpdate = new product2();
        unitToUpdate.Id = eachUnit.Id;
        unitToUpdate.Freight_Status__c = 'Requested';
        unitToUpdate.Freight_Requested_By__c = System.UserInfo.getUserId();
        lstUnits.add(unitToUpdate);
        
        //This list is used to create new Freight_Company_Unit__c records
        List<Freight_Company_Unit__c> lstFreightCompanyUnitToInsert = New List<Freight_Company_Unit__c>();

        if(lstwrapperData!=null && !lstwrapperData.IsEmpty()){
            for(WrapperData eachWrapperData : lstWrapperData){
                If(setOfAccountIds.contains(eachWrapperData.Id)){
                    
                
                String DestinationsiteContact = null;
                If(String.isNotBlank(wrapperFreightToInsert.destinationSiteContact)){
                    DestinationsiteContact= wrapperFreightToInsert.destinationSiteContact;
                }
                String salesOppId = null;
                If(String.isNotBlank(wrapperFreightToInsert.opportunityValue)){
                    salesOppId= wrapperFreightToInsert.opportunityValue;
                }
                Freight_Company_Unit__c eachFreight_Company_UnitToInsert = new Freight_Company_Unit__c(
                    Associated_Unit__c = UnitId,
                    Current_Location_Site_Contact__c = wrapperFreightToInsert.currentSiteContactId,
                    Freight_Ready_to_Move__c = wrapperFreightToInsert.freightReadyToMove,
                    Going_to_Port__c = false, 
                    Freight_Budget__c =wrapperFreightToInsert.freightBudget, 
                    Freight_Status__c =wrapperFreightToInsert.freightStatus, 
                    Freight_Requestor__c = wrapperFreightToInsert.freightRequestorId, 
                    //Freight_Pickup_Date__c = wrapperFreightToInsert. , 
                    //Freight_Quoted_Amount__c = wrapperFreightToInsert., 
                    Storage_Street__c= wrapperFreightToInsert.storageStreet, 
                    Storage_City__c = wrapperFreightToInsert.storageCity, 
                    Storage_Zip_Code__c = wrapperFreightToInsert.storageZipCode, 
                    Storage_State__c= wrapperFreightToInsert.storageState, 
                    Storage_Country__c= wrapperFreightToInsert.storageCountry, 
                    //Freight_Estimated_Pickup_Date__c= wrapperFreightToInsert., 
                    //Freight_Notes__c= wrapperFreightToInsert.,
                    Google_Drive_Photos_Link__c= wrapperFreightToInsert.googlePhotoLink,
                    Destination_Location_Site_Contact__c= DestinationsiteContact, 
                    Destination_Street__c= wrapperFreightToInsert.destinationStreet, 
                    Destination_City__c= wrapperFreightToInsert.destinationCity, 
                    Destination_Zip_Code__c= wrapperFreightToInsert.destinationZipCode, 
                    Destination_State__c= wrapperFreightToInsert.destinationState, 
                    Destination_Country__c= wrapperFreightToInsert.destinationCountry, 
                    Associated_sales_procurement_opp__c = salesOppId,
                    Ramps_available_at_Drop_Off_site__c = wrapperFreightToInsert.RampsAvailableAtDropOffSite,
                    Ramps_available_at_Pick_Up_site__c = wrapperFreightToInsert.RampsAvailableAtPickUpSite,
                    Freight_Company_Account__c = eachWrapperData.Id
                    
                );
                
                lstFreightCompanyUnitToInsert.add(eachFreight_Company_UnitToInsert);
                }
            }
            
            if(lstFreightCompanyUnitToInsert!=null && !lstFreightCompanyUnitToInsert.IsEmpty()){
                insert lstFreightCompanyUnitToInsert;
                lstToDeleteFreightCompanyUnits = lstFreightCompanyUnitToInsert;
              // //  System.debug('lstFreightCompanyUnitToInsert ::::::'+lstFreightCompanyUnitToInsert);
            }
        }
        System.debug('lstFreightCompanyUnitToInsert ::::::'+lstFreightCompanyUnitToInsert.size());
        if(lstFreightCompanyUnitToInsert!=null && !lstFreightCompanyUnitToInsert.IsEmpty()){
            for(Freight_Company_Unit__c eachFreightCompanyUnit : lstFreightCompanyUnitToInsert){
                mapAccountIdVsEachFreight_Company_Unit.put(eachFreightCompanyUnit.Freight_Company_Account__c,eachFreightCompanyUnit);
                
               // //  System.debug('mapAccountIdVsEachFreight_Company_Unit ::::::'+mapAccountIdVsEachFreight_Company_Unit);
            }
        }
        if(lstAccounts!=null && !lstAccounts.IsEmpty()){
            lstToReUpdateAccounts.addAll(lstAccounts);
            list<Account>lstAccountToUpdate = new List<Account>();
            for(Account eachAccount : lstAccounts){
                Account newAccount = new Account();
                newAccount.Id =eachAccount.Id; 
                Decimal Freight_Quote_Submitted = 1;
                if(Integer.valueOf(eachAccount.Freight_Quote_Submitted__c)>0){
                    Freight_Quote_Submitted = eachAccount.Freight_Quote_Submitted__c+1;
                 // //   System.debug('Freight_Quote_Submitted:::'+Freight_Quote_Submitted);
                 // //    System.debug('newAccount.Freight_Quote_Submitted__c:::'+newAccount.Freight_Quote_Submitted__c);
                }
             // //    System.debug('Freight_Quote_Submitted:::'+Freight_Quote_Submitted);
                newAccount.Freight_Quote_Submitted__c = Freight_Quote_Submitted; 
                lstAccountToUpdate.add(newAccount);
            }
            if(lstAccountToUpdate!=null && !lstAccountToUpdate.IsEmpty()){
                update lstAccountToUpdate;
               // //  System.debug('lstAccountToUpdate:::'+lstAccountToUpdate);
            }
            if(lstUnits!=null && !lstUnits.IsEmpty()){
                update lstUnits;
               // //  System.debug('lstUnits:::'+lstUnits);
            }
        }
        
        String message= FreightSendEmailHelper.sendFreightEmail(lstAccounts , eachUnit, mapAccountIdVsEachFreight_Company_Unit);
         System.debug('message ::::::'+message);
        return message;
    }
    

    
    /*
     * Wrapper Class to hold Data
	 */
      public class wrapperData{
        @AuraEnabled 
        public string Id;
        @AuraEnabled 
        public string Name;
        @AuraEnabled 
        public string ContactName;
        @AuraEnabled 
        public string ContactId;
        @AuraEnabled 
        public string Email;
        @AuraEnabled 
        public string Phone;
        
        wrapperData(String Id,String Name, string ContactName, string ContactId, String Email, String Phone){
            this.Id = Id;
            this.Name = Name;
            this.ContactName = ContactName;
            this.ContactId = ContactId;
            this.Email = Email;
            this.Phone = Phone;
        }
    }
    
     /*
     * Wrapper Class for Filter Wrapper Data
	 */
    public class inputWrapper{
        @AuraEnabled 
        public string clientType;
        @AuraEnabled 
        public string searchKey;
            
            inputWrapper(){
                
            }
    }
    
    /*
     * Wrapper Class to hold the Freight data
	 */    
      public class wrapperFreight{
        @AuraEnabled 
        public string Id;
        @AuraEnabled 
        public string unitName;
        @AuraEnabled 
        public string opportunityValue;
          @AuraEnabled 
        public string storageStreet='';
          @AuraEnabled 
        public string storageCity ='';
          @AuraEnabled 
        public string storageZipCode='';
          @AuraEnabled 
        public string storageState='';
          @AuraEnabled 
        public string storageCountry='';
        @AuraEnabled 
        public string currentSiteContact;
          @AuraEnabled 
        public string currentSiteContactId;
          @AuraEnabled 
        public string destinationStreet='';
          @AuraEnabled 
        public string destinationCity='';
          @AuraEnabled 
        public string destinationZipCode='';
          @AuraEnabled 
        public string destinationCountry='';
          @AuraEnabled 
        public string destinationState='';
        @AuraEnabled 
        public string destinationSiteContact='';
          @AuraEnabled 
        public String googlePhotoLink;
        @AuraEnabled 
        public Boolean goingToPort;
        @AuraEnabled 
        public string freightStatus;
          @AuraEnabled 
        public string freightStatusDate;
        @AuraEnabled 
        public string freightRequestor;
        @AuraEnabled 
        public string freightRequestorId;
        @AuraEnabled 
        public Boolean freightReadyToMove;
          @AuraEnabled 
        public Decimal freightBudget;
        @AuraEnabled 
        public Boolean RampsAvailableAtPickUpSite;
          @AuraEnabled 
        public Boolean RampsAvailableAtDropOffSite;
          wrapperFreight(){}
        
          wrapperFreight(String Id,
                         String unitName,
                         String storageStreet,
                         String storageCity,
                         String storageState,
                         String storageZipCode,
                         String storageCountry,
                         String currentSiteContact,
                         String currentSiteContactId,
                         String googlePhotoLink,
                         Boolean goingToPort,
                         String freightStatus,
                         String freightStatusDate,
                         String freightRequestor,
                         String freightRequestorId,
                         Boolean freightReadyToMove,
                        Decimal freightBudget,
                        Boolean RampsAvailableAtPickUpSite,
                        Boolean RampsAvailableAtDropOffSite){
                             this.Id = Id;
                             this.unitName = unitName;                        
                             this.storageStreet = storageStreet;
                             this.storageCity = storageCity;
                             this.storageState =storageState;
                             this.storageZipCode = storageZipCode;
                             this.storageCountry = storageCountry;
                             this.currentSiteContact = currentSiteContact;
                             this.currentSiteContactId = currentSiteContactId;
                            this.googlePhotoLink =googlePhotoLink;
                             this.goingToPort =goingToPort;
                            this.freightStatus = freightStatus;
                             this.freightStatusDate =freightStatusDate;
                             this.freightRequestor =freightRequestor;
                             this.freightRequestorId =freightRequestorId;
                             this.freightReadyToMove = freightReadyToMove;
                            this.freightBudget = freightBudget;
                            this.RampsAvailableAtPickUpSite =RampsAvailableAtPickUpSite;
                            this.RampsAvailableAtDropOffSite =RampsAvailableAtDropOffSite;
                         }
    }
    
    // Aura-Response 
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