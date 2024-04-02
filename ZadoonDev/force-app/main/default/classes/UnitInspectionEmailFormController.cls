/*
This class is used to provide data to UnitInspectionEmailCmp LWC and to handle events from the LWC
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          11-Sept-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/

public without sharing class UnitInspectionEmailFormController {
  @AuraEnabled
    public static AuraResponse createIntialData(String wrapperKey){
        AuraResponse AuraResponse;
        
        try{
            //Check for input Value
            
            if(String.IsNotBlank(wrapperKey)){
                AuraResponse = handlecreateIntialData(wrapperKey);
            }else{
                AuraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'Connect to the Admin.Record Id Not Found.');
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
     * This Method is used to handle-update the Unit Inspection Data from the site LWC
	 */
    @AuraEnabled
    public static AuraResponse updateFreightData(String wrapperKey){
        AuraResponse AuraResponse;
        
        try{
            //Check for input Value
           // System.debug(' handle create initial data is called::::');
            AuraResponse =  handleUpdateUnitInspectionData(wrapperKey);
            
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        
        // Returning Aura-Response to LWC
        return AuraResponse;
    }
    
    /*
     * This Method is used to update the Unit Inspection Data from the site LWC
	 */
    private static AuraResponse handleUpdateUnitInspectionData(String wrapperKey){
        wrapperData newWrapperData = new wrapperData();
        AuraResponse AuraResponse;
        String message = 'Error, Please Refresh the Page and try again!!';
        Boolean isSuccess = false;
        System.debug('input data::::'+wrapperKey);
        newWrapperData = (wrapperData) JSON.deserialize(wrapperKey, wrapperData.Class);
        System.debug('input data:newWrapperData:::'+newWrapperData);
        Unit_Inspection__c currentUnit_Inspection = [SELECT Id,
                                                     Name,
                                                     Unit__c, 
                                                     Inspection_Date__c,
                                                     Quote_Amount__c, 
                                                     Inspecion_Status__c,
                                                     Inspecion_Account__c,
                                                     Inspection_Inspector__c                                               
                                                     FROM Unit_Inspection__c
                                                     WHERE Id =: newWrapperData.Id
                                                     LIMIT 1];
        If(currentUnit_Inspection.Inspecion_Status__c != 'Vendor Acquired'){
            Unit_Inspection__c Unit_InspectionToUpdate = new Unit_Inspection__c(Id = newWrapperData.Id,
                                                                                Quote_Amount__c = newWrapperData.quoteAmount,
                                                                                Inspection_Date__c =newWrapperData.pickUpDate,
                                                                                Inspecion_Status__c = 'Quotes Received');
            update Unit_InspectionToUpdate;
            isSuccess = true;
            message = 'Thank you for completing the form! Your submission has been received.';
             AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                           message);
        }else{
             AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            'Can not fill the Form.The Inpection is Completed!!');
        }
        
        
        return AuraResponse;
    }
    
    /*
     * This Method is used to provide the data on Load for the site LWC
	 */
    private static AuraResponse handlecreateIntialData(Id wrapperKey){
         AuraResponse AuraResponse;
        System.debug('newWrapperFilterData:::'+wrapperKey);
        wrapperData newWrapperData = new wrapperData();
        list<Unit_Inspection__c> lstFreightCompanyUnit = [SELECT Id, Name, 
                                                          Unit__c, 
                                                          Comments__c,
                                                          Inspecion_Status__c,
                                                          Inspection_Inspector__c,
                                                          Inspecion_Account__c,
                                                          Inspection_Date__c,
                                                          Quote_Amount__c,
                                                          Unit__r.Name,
                                                          Unit__r.ZID__c,
                                                          Unit__r.Storage_Address__c,
                                                          Unit__r.Storage_City__c,
                                                          Unit__r.Storage_Zip_Code__c,
                                                          Unit__r.Storage_State__c,
                                                          Unit__r.Storage_Country__c,
                                                          Unit__r.Inspection_Status__c
                                                          FROM Unit_Inspection__c
                                                          WHERE Id =: wrapperKey
                                                               LIMIT 1];
       // Boolean isPickupDate = false;
        Boolean isFreightSlected = false;
        System.debug('lstFreightCompanyUnit :::::'+lstFreightCompanyUnit);
        if(lstFreightCompanyUnit!=null && !lstFreightCompanyUnit.isEmpty() ){
            for(Unit_Inspection__c eachUnitInspection : lstFreightCompanyUnit){
                /*if(String.isNotBlank(String.valueOf(eachFreightCompanyUnit.Freight_Pickup_Date__c))){
                    isPickupDate = true;
                }*/
                If(eachUnitInspection.Inspecion_Status__c == 'Quotes Received'){
                    AuraResponse = new AuraResponse(false,
                                            'ERROR', 
                                              'You have already responded!! Thank You.');
                }else If(eachUnitInspection.Unit__r.Inspection_Status__c == 'Inspector Acquired'){
                     AuraResponse = new AuraResponse(false,
                                            'ERROR', 
                                              'Inspector is selected for the inspection!! Thank You.');
                }else If(eachUnitInspection.Unit__r.Inspection_Status__c == 'Completed'){
                     AuraResponse = new AuraResponse(false,
                                            'ERROR', 
                                              'Inspection is completed!! Thank You.');
                }else If(eachUnitInspection.Inspecion_Status__c == 'Requested'){
                String currentAddress = ' ';
                
                if(String.isNotBlank(eachUnitInspection.Unit__r.Storage_City__c)){
                   currentAddress += ' '+eachUnitInspection.Unit__r.Storage_City__c; 
                }
                if(String.isNotBlank(eachUnitInspection.Unit__r.Storage_State__c)){
                   currentAddress += ', '+eachUnitInspection.Unit__r.Storage_State__c; 
                }
                if(String.isNotBlank(eachUnitInspection.Unit__r.Storage_Country__c)){
                   currentAddress += ', '+eachUnitInspection.Unit__r.Storage_Country__c; 
                }
                if(String.isNotBlank(eachUnitInspection.Unit__r.Storage_Zip_Code__c)){
                   currentAddress += ' '+eachUnitInspection.Unit__r.Storage_Zip_Code__c; 
                }
                String destinationAddress = ' ';
               /* 
                if(String.isNotBlank(eachFreightCompanyUnit.Associated_Unit__r.Freight_Status__c)){
                    If(eachFreightCompanyUnit.Associated_Unit__r.Freight_Status__c =='Vendor Acquired'){
                        isFreightSlected = true;
                    }
                }*/
                wrapperData newWrapperData0 = new wrapperData(eachUnitInspection.Id,
                                                              eachUnitInspection.Unit__r.Name,
                                                              null,
                                                              currentAddress,
                                                              destinationAddress,
                                                              eachUnitInspection.Quote_Amount__c,
                                                              eachUnitInspection.Inspection_Date__c,
                                                              false,
                                                              false,
                                                              isFreightSlected
                                                             );
                
                System.debug('newWrapperData0:::::::::::::::::::::::::::'+newWrapperData0);
                AuraResponse = new AuraResponse(true,
                                            'SUCCESS', JSON.serialize(newWrapperData0));
                }else{
               	AuraResponse = new AuraResponse(false,
                                            'ERROR', 
                                              'You can\'t fill the form, connect to the Zadoon team once!! Thank You.');
                }
            }
            //  SYSTEM.debug('SET OF CONTACT IDS : : : '+setAccountIds);
        }else{
            AuraResponse = new AuraResponse(false,
                                            'ERROR', 
                                              'You can not fill the Form.The Inspection is Completed.');
        }
        
        
        return AuraResponse;
    }
    
    /*
     * Wrapper Class to hold the Data
	 */
    public class wrapperData{
        @AuraEnabled 
        public String Id{get;set;}
        @AuraEnabled 
        public String unitName{get;set;}
        @AuraEnabled 
        public String photoLink{get;set;}
        @AuraEnabled 
        public String unitLocation{get;set;}
        @AuraEnabled 
        public String destiationLocation{get;set;}
        @AuraEnabled 
        public Decimal quoteAmount{get;set;}
        @AuraEnabled
        public Date pickUpDate{get;set;}
        @AuraEnabled
        public Boolean freightReadyToMove{get;set;}
        @AuraEnabled
        public Boolean isQuoteSbmitted{get;set;}
        @AuraEnabled
        public Boolean isLinkExpired{get;set;}
        
        wrapperData(){
            
        }
        
        wrapperData(String Id,
                    String Name,
                    String photoLink,
                    String unitLocation,
                    String destiationLocation,
                    Decimal quoteAmount,
                    Date pickUpDate,
                    Boolean freightReadyToMove,
                   Boolean isQuoteSbmitted,
                   Boolean isLinkExpired){
                        this.Id = Id;
                        this.unitName = Name;
                        this.photoLink = photoLink;
                        this.unitLocation = unitLocation;
                        this.destiationLocation = destiationLocation;
                        this.quoteAmount = quoteAmount;
                        this.pickUpDate = pickUpDate;
                        this.freightReadyToMove = freightReadyToMove;
                       this.isQuoteSbmitted = isQuoteSbmitted;
                       this.isLinkExpired = isLinkExpired;
                    }
    }
    
   
    /*
     * Wrapper Aura-Response 
	 */
    Public class AuraResponse{
        @AuraEnabled 
        public Boolean isSuccess{get;set;}
        @AuraEnabled 
        public string message{get;set;}
        @AuraEnabled 
        public string response{get;set;}
        
        AuraResponse(Boolean isSuccess,
                     String message,
                     String response) {
                         
                         this.isSuccess = isSuccess;
                         this.message = message;
                         this.response = response;
                     }
    }
    

}