/*
This class is used to provide data to FreightProcessForm LWC on Site and to handle events from the LWC
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          06-Aug-2023           Kizzy Consulting     Deepanshu               Initial Version
------------------------------------------------------------------------------------------------
*/

public without sharing  class FreightProcessFormController {
    /*
     * This Method is used to provide the data on Load for the site LWC
	 */
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
     * This Method is used to update the Freight data from the site LWC
	 */
    @AuraEnabled
    public static AuraResponse updateFreightData(String wrapperKey){
        AuraResponse AuraResponse;
        
        try{
            //Check for input Value
            
            AuraResponse = new AuraResponse(true,
                                            'SUCCESS',
                                            handleUpdateFreightData(wrapperKey));
            
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
        }
        
        // Returning Aura-Response to LWC
        return AuraResponse;
    }
    
    /*
     * This Method is used to handle update on Freight Company Unit Data
	 */
    private static string handleUpdateFreightData(String wrapperKey){
        wrapperData newWrapperData = new wrapperData();
        String message = 'Error, Please Refresh the Page and try again!!';
        Boolean isSuccess = false;
        System.debug('input data::::'+wrapperKey);
        newWrapperData = (wrapperData) JSON.deserialize(wrapperKey, wrapperData.Class);
        System.debug('input data:newWrapperData:::'+newWrapperData);
        Freight_Company_Unit__c currentFreightCompanyUnit = [SELECT Id, Name, 
                                                               Associated_Unit__c,Associated_Unit__r.Storage_Zip_Code__c,
                                                               Associated_Unit__r.Name,Associated_Unit__r.Storage_Address__c,Associated_Unit__r.Storage_City__c,
                                                               Associated_Unit__r.Freight_Status__c,Associated_Unit__r.Storage_State__c,
                                                               Is_Quote_Recived__c,Destination_City__c,Destination_State__c,Destination_Street__c,Destination_Zip_Code__c
                                                               FROM Freight_Company_Unit__c
                                                               WHERE Id =: newWrapperData.Id
                                                               LIMIT 1];
         If(currentFreightCompanyUnit.Associated_Unit__r.Freight_Status__c != 'Vendor Acquired' && !currentFreightCompanyUnit.Is_Quote_Recived__c &&  newWrapperData.quoteAmount !=null &&  newWrapperData.quoteAmount >0){
            Freight_Company_Unit__c FreightCompanyUnitToUpdate = new Freight_Company_Unit__c(Id = newWrapperData.Id,
                                                                                             Freight_Quoted_Amount__c = newWrapperData.quoteAmount,
                                                                                            // Freight_Pickup_Date__c =newWrapperData.pickUpDate,
                                                                                             Freight_Estimated_Pickup_Date__c = newWrapperData.pickUpDate,
                                                                                             Freight_Status__c = 'Quotes Received',
                                                                                             Is_Quote_Recived__c = true);
            update FreightCompanyUnitToUpdate;
            isSuccess = true;
             message = 'Thank you for completing the form! Your submission has been received.';
             /*message = 'Thanks for your quote!  We\'ll be going with your quote to move this unit.'+' '+'{';
             message += currentFreightCompanyUnit.Associated_Unit__r.Name +' ' ;
             message += currentFreightCompanyUnit.Associated_Unit__r.Storage_Address__c + ', '+ currentFreightCompanyUnit.Associated_Unit__r.Storage_City__c+', ';
             message += currentFreightCompanyUnit.Associated_Unit__r.Storage_State__c + '-' + currentFreightCompanyUnit.Associated_Unit__r.Storage_Zip_Code__c+' -> ';
             message += currentFreightCompanyUnit.Destination_Street__c +', '+currentFreightCompanyUnit.Destination_City__c+', '+ currentFreightCompanyUnit.Destination_State__c+'-';
             message += currentFreightCompanyUnit.Destination_Zip_Code__c+' '+'}'+' ';
             message +=    'Please let us know when you estimate the pickup dates to be. ';*/
        }else{
            isSuccess = false;
            message = 'Please Provide Quoted values!!';
        }
        
        
        
        return message;
    }
    
    /*
     * This Method is used to provide the data on Load for the site LWC
	 */
    private static AuraResponse handlecreateIntialData(Id wrapperKey){
        AuraResponse AuraResponse;
        System.debug('newWrapperFilterData:::'+wrapperKey);
        wrapperData newWrapperData = new wrapperData();
        list<Freight_Company_Unit__c> lstFreightCompanyUnit = [SELECT Id, Name, 
                                                               Associated_Unit__c, 
                                                               Associated_Unit__r.Name,
                                                               Associated_Unit__r.Freight_Status__c,
                                                               Freight_Budget__c, 
                                                               Going_to_Port__c,
                                                               Freight_Pickup_Date__c,
                                                               Freight_Ready_to_Move__c,
                                                               Freight_Company_Account__c,
                                                               Google_Drive_Photos_Link__c,
                                                               Storage_Street__c,
                                                               Storage_City__c,
                                                               Storage_State__c,
                                                               Storage_Country__c,
                                                               Storage_Zip_Code__c,
                                                               Destination_Street__c,
                                                               Destination_City__c,
                                                               Destination_State__c,
                                                               Destination_Country__c,
                                                               Destination_Zip_Code__c,
                                                               Is_Quote_Recived__c
                                                               FROM Freight_Company_Unit__c
                                                               WHERE Id =: wrapperKey
                                                               LIMIT 1];
       // Boolean isPickupDate = false;
        Boolean isFreightSlected = false;
        
        if(lstFreightCompanyUnit!=null && !lstFreightCompanyUnit.isEmpty()){
            for(Freight_Company_Unit__c eachFreightCompanyUnit : lstFreightCompanyUnit){
                /*if(String.isNotBlank(String.valueOf(eachFreightCompanyUnit.Freight_Pickup_Date__c))){
                    isPickupDate = true;
                }*/
                String currentAddress = ' ';
                if(String.isNotBlank(eachFreightCompanyUnit.Storage_Street__c)){
                   currentAddress += eachFreightCompanyUnit.Storage_Street__c; 
                }
                if(String.isNotBlank(eachFreightCompanyUnit.Storage_City__c)){
                   currentAddress += ' '+eachFreightCompanyUnit.Storage_City__c; 
                }
                if(String.isNotBlank(eachFreightCompanyUnit.Storage_State__c)){
                   currentAddress += ', '+eachFreightCompanyUnit.Storage_State__c; 
                }
                if(String.isNotBlank(eachFreightCompanyUnit.Storage_Country__c)){
                   currentAddress += ', '+eachFreightCompanyUnit.Storage_Country__c; 
                }
                if(String.isNotBlank(eachFreightCompanyUnit.Storage_Zip_Code__c)){
                   currentAddress += ' '+eachFreightCompanyUnit.Storage_Zip_Code__c; 
                }
                String destinationAddress = ' ';
                if(String.isNotBlank(eachFreightCompanyUnit.Destination_Street__c)){
                   destinationAddress += eachFreightCompanyUnit.Destination_Street__c; 
                }
                if(String.isNotBlank(eachFreightCompanyUnit.Destination_City__c)){
                   destinationAddress += ' '+eachFreightCompanyUnit.Destination_City__c; 
                }
                if(String.isNotBlank(eachFreightCompanyUnit.Destination_State__c)){
                   destinationAddress += ', '+eachFreightCompanyUnit.Destination_State__c; 
                }
                if(String.isNotBlank(eachFreightCompanyUnit.Destination_Country__c)){
                   destinationAddress += ', '+eachFreightCompanyUnit.Destination_Country__c; 
                }
                if(String.isNotBlank(eachFreightCompanyUnit.Destination_Zip_Code__c)){
                   destinationAddress += ' '+eachFreightCompanyUnit.Destination_Zip_Code__c; 
                }
                if(String.isNotBlank(eachFreightCompanyUnit.Associated_Unit__r.Freight_Status__c)){
                    If(eachFreightCompanyUnit.Associated_Unit__r.Freight_Status__c =='Vendor Acquired'){
                        isFreightSlected = true;
                    }
                }
                wrapperData newWrapperData0 = new wrapperData(eachFreightCompanyUnit.Id,
                                                              eachFreightCompanyUnit.Associated_Unit__r.Name,
                                                              eachFreightCompanyUnit.Google_Drive_Photos_Link__c,
                                                              currentAddress,
                                                              destinationAddress,
                                                              null,
                                                              eachFreightCompanyUnit.Freight_Pickup_Date__c,
                                                              eachFreightCompanyUnit.Freight_Ready_to_Move__c,
                                                              eachFreightCompanyUnit.Is_Quote_Recived__c,
                                                              isFreightSlected
                                                             );
                
                System.debug('newWrapperData0:::::::::::::::::::::::::::'+newWrapperData0);
                AuraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(newWrapperData0));
                //return newWrapperData0;
            }
            //  SYSTEM.debug('SET OF CONTACT IDS : : : '+setAccountIds);
        }else{
            
        //If No Data Found
        AuraResponse = new AuraResponse(False,
                                        'ERROR',
                                        'The Quote can not be submitted, Freight is completed.');
        }
        
        return AuraResponse;
    }
    
    /*
     * Wrapper Class to provide the data on Load for the site LWC
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
    
   
    
    // Aura-Response 
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