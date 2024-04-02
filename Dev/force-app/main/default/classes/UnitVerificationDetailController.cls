/*
* This Class is used to provide and update Unit Verification line item data threw the LWC named as "UnitVerificationDetail"
*/
public class UnitVerificationDetailController {
    /*
	 * This methid is used to validate the recordId and get the Unit Verification Line Items
	 */
    @AuraEnabled
    public static AuraResponse getUnitVerificationLineItems(String recordId){
        AuraResponse auraResponse;
        
        try{
            
            if(string.isNotBlank(recordId)) {
                auraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(handleGetUnitVerificationLineItem(recordId)));
                
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
	 * This methid is used to update the Unit Verification Line Items
	 */
    @AuraEnabled
    public static AuraResponse saveUpdatedLineItems(String wrapperData){
        AuraResponse auraResponse;
        
        try{
            List<Wrapper>lstwrapper = new list<Wrapper>();
           // // System.debug('On save call Preant M1 data ::::'+lstwrapper);
            if(string.isNotBlank(wrapperData)) {
                lstwrapper = (List<Wrapper>)JSON.deserialize(wrapperData,List<Wrapper>.Class);
                auraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(handleSaveLineItemData(lstwrapper)));
                
            } else {
                auraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'Unit Verification line item(s) are not found(s) to update.' );
            }
            
        } catch (Exception ex) {
            auraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
            // //System.debug('At line ::::'+ex.getLineNumber());
        }
        // //System.debug('AuraResponse on Update :::::'+auraResponse);
        return auraResponse;
    }
    /*
	 * This methid is used to get the Unit Verification Line Items
	 */
    private static ParentWrapper handleGetUnitVerificationLineItem(Id recordId){
        boolean isOwned = false;
        list<Wrapper> lstwrapper = new list<Wrapper>();
        
        list<Unit_Verification_line_item__c> lstUnitVerificationlineitem = new list<Unit_Verification_line_item__c>();
        lstUnitVerificationlineitem = [SELECT Id, Name,
                                       Site_URL__c,
                                       Unit_Verification__c,
                                       Unit_Verification__r.Unit__c,Is_Active__c,
                                       Unit_Verification__r.Unit__r.Inventory_status__c,
                                       Price_is_Correct__c, Photo_Count_is_Correct__c, 
                                       Unit_Details_are_Complete__c, 
                                       Photos_of_Good_Quality__c, 
                                       Unit_Location_is_Correct__c
                                       FROM Unit_Verification_line_item__c
                                       WHERE Unit_Verification__c = : recordId
                                       AND Unit_Verification__c != null
                                       AND Is_Active__c = true
                                       WITH SECURITY_ENFORCED];
        
        if(lstUnitVerificationlineitem!=null &&! lstUnitVerificationlineitem.isEmpty()){
            For(Unit_Verification_line_item__c eachLineItem : lstUnitVerificationlineitem){
                Wrapper newWrapper = new Wrapper(eachLineItem.Id,
                                                 eachLineItem.Name,
                                                 eachLineItem.Site_URL__c,
                                                 eachLineItem.Price_is_Correct__c,
                                                 eachLineItem.Photo_Count_is_Correct__c,
                                                 eachLineItem.Unit_Details_are_Complete__c,
                                                 eachLineItem.Unit_Location_is_Correct__c,
                                                 eachLineItem.Photos_of_Good_Quality__c);
                lstwrapper.add(newWrapper);
                if(String.IsNotBlank(eachLineItem.Unit_Verification__r.Unit__c) && 
                   String.IsNotBlank(eachLineItem.Unit_Verification__r.Unit__r.Inventory_status__c) &&
                   eachLineItem.Unit_Verification__r.Unit__r.Inventory_status__c=='Owned'){
                       isOwned = true;
                   }
            }
        }
        ParentWrapper parentWrapper = new ParentWrapper(isOwned,lstwrapper);
        return parentWrapper;
    }
    
    /*
	 * This methid is used to update Unit Verification Line Items
	 */
    private static string handleSaveLineItemData(List<Wrapper>lstwrapper){
        // //System.debug('On save call data ::::'+lstwrapper);
        String message = 'Error Occure when updating the Unit Verification line item(s).';
        list<Unit_Verification_line_item__c> lstLineItemsToUpdate = new list<Unit_Verification_line_item__c>();
        
        for(Wrapper eachWrapper : lstwrapper){
            Unit_Verification_line_item__c eachLineItem = new Unit_Verification_line_item__c();
            if( eachWrapper.id!=null){
             eachLineItem.Id = eachWrapper.id;   
            }
            if(eachWrapper.isPriceCorrect!=null){
             eachLineItem.Price_is_Correct__c = eachWrapper.isPriceCorrect ;   
            }
            if(eachWrapper.isPhootoCountCorrect!=null){
             eachLineItem.Photo_Count_is_Correct__c = eachWrapper.isPhootoCountCorrect ;   
            }
            if(eachWrapper.areUnitDetailsCompleted!=null){
              eachLineItem.Unit_Details_are_Complete__c = eachWrapper.areUnitDetailsCompleted ;  
            }
            
            if( eachWrapper.isUnitLocationCorrect !=null){
              eachLineItem.Unit_Location_is_Correct__c = eachWrapper.isUnitLocationCorrect ;  
            }
            if( eachWrapper.arePhotoQualityGood !=null){
              eachLineItem.Photos_of_Good_Quality__c = eachWrapper.arePhotoQualityGood ;  
            }
            lstLineItemsToUpdate.add(eachLineItem);
        } 
       // // System.debug('lstLineItemsToUpdate Before Save data ::::'+lstLineItemsToUpdate);
        if(lstLineItemsToUpdate!=null && !lstLineItemsToUpdate.IsEmpty()){
            update lstLineItemsToUpdate;
            message = 'Unit Verification line item(s) are updated successfully.';
         // //    System.debug('Message on update ::::'+ message);
        }
        // // System.debug('Message before Return  ::::'+ message);
        return message;
    }
    /*
	 * Wrapper Class to hold the list of Unit LineItem wrapper Data and Unit Inventory status
	 */
    public class ParentWrapper{
        @AuraEnabled public Boolean isOwned;
        @AuraEnabled public list<Wrapper> UnitVerificationWrapperData;
        
        ParentWrapper(Boolean isOwned,list<Wrapper> UnitVerificationWrapperData){
            this.isOwned= isOwned;
            this.UnitVerificationWrapperData =  UnitVerificationWrapperData;
        }
    }

	/*
	 * Wrapper Class to hold Unit verification line Item Data 
	 */    
    public class Wrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String siteName;
        @AuraEnabled public String siteURL;
        @AuraEnabled public Boolean isPriceCorrect;
        @AuraEnabled public Boolean isPhootoCountCorrect;
        @AuraEnabled public Boolean areUnitDetailsCompleted;
        @AuraEnabled public Boolean isUnitLocationCorrect;
        @AuraEnabled public Boolean arePhotoQualityGood;
        
        Wrapper(String id,
                String siteName,
                String siteURL,
                Boolean isPriceCorrect,
                Boolean isPhootoCountCorrect,
                Boolean areUnitDetailsCompleted,
                Boolean isUnitLocationCorrect,
                Boolean arePhotoQualityGood){
                    
                    this.id = id;
                    this.siteName=siteName;
                    this.siteURL = siteURL;
                    this.isPriceCorrect= isPriceCorrect;
                    this.isPhootoCountCorrect = isPhootoCountCorrect;
                    this.areUnitDetailsCompleted =  areUnitDetailsCompleted;
                    this.isUnitLocationCorrect = isUnitLocationCorrect;
                    this.arePhotoQualityGood = arePhotoQualityGood;
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