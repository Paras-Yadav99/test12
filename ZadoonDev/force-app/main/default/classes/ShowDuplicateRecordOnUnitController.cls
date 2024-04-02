public class ShowDuplicateRecordOnUnitController {
    
    @AuraEnabled
    public static AuraResponse getUnitDuplicateRecord(string recordId){ //Aura Method 
        
        AuraResponse AuraResponse;
        
        try{
            if(string.isNotEmpty(recordId)){  			 // try method
                AuraResponse = new AuraResponse(true ,
                                                'Success',
                                                JSON.serialize(getDuplicateRecord(recordId)));         
            }
            else {
                AuraResponse = new AuraResponse(false ,   //Else method
                                                'error',
                                                'recordId is not Found');   
            }
            
        }
        catch (exception ex){				//catch method
            system.debug('exwrwr:::'+ex);
            AuraResponse = new AuraResponse(false ,
                                            'Error',
                                            ex.getMessage());
        }
        
        return AuraResponse;
    } 
    
    @AuraEnabled 
    
    public static list<wrapper> getDuplicateRecord(string recordId){   
        
        list<wrapper> lstWrapper = new list<wrapper>(); 
        
        if(string.isNotEmpty(recordId)){
            
            Product2 newProduct2Details = [SELECT id, Serial_Number__c , Year__c,   // Query Current Records Details
                                            Make__c , Model__c , 
                                            Hour__c , equipment__c	
                                            FROM product2 WHERE id = :recordId];
            
            if(newProduct2Details != null){   
                
                list<product2> lstofUnit = [SELECT id,Name , Serial_Number__c ,   // Query Records Basis on current Record
                                             Year__c , Make__c ,
                                             Model__c ,Hour__c ,
                                             equipment__c,equipment__r.Name FROM product2 
                                             WHERE Serial_Number__c = : newProduct2Details.Serial_Number__c AND 
                                             year__c = : newProduct2Details.Year__c AND 
                                             Make__c =: newProduct2Details.Make__c AND 
                                             Hour__c = : newProduct2Details.Hour__c AND 
                                             equipment__c = : newProduct2Details.equipment__c];
                if(lstofUnit != null && !lstofUnit.isEmpty()){
                    
                    for(product2 eachProduct : lstofUnit){
                        
                        if(eachProduct.id != recordId )   {                 
                            lstWrapper.add(new wrapper(eachProduct.id,eachProduct.equipment__c,eachProduct.name , eachProduct.Serial_Number__c , // Add Data in list Of Wrapper 
                                                       eachProduct.Year__c, eachProduct.Make__c , eachProduct.Model__c , 
                                                       eachProduct.Hour__c , eachProduct.equipment__r.Name ));		
                        }
                    }
                }
            }
        }
        //system.debug('lstWrapper' + lstWrapper);        
        
        return lstWrapper;
        
    }
    
    public class AuraResponse{  // AuraResponse 
        
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public string message;
        @AuraEnabled public string response;
        
        AuraResponse(Boolean isSuccess,
                     String message,
                     string response){
                         
                         this.isSuccess = isSuccess;
                         this.message = message;
                         this.response = response;
                     }
    }
    public class Wrapper{                   //Wrapper Class       
        @AuraEnabled public string Id ='';
        @AuraEnabled public string equipmentId ='';
        @AuraEnabled Public string Name;
        @AuraEnabled Public string serialNumber;
        @AuraEnabled Public string year;
        @AuraEnabled Public string Make;
        @AuraEnabled Public string Model;
        @AuraEnabled Public Decimal Hour;
        @AuraEnabled Public string equipment;
        
        
        Wrapper(string Id,
                string equipmentId,
                string name , 
                string serialNumber , 
                string year , 
                string Make , 
                string Model , 
                Decimal Hour ,
                string equipment){ 
                    this.Id=Id;
                    this.equipmentId = equipmentId;
                    this.Name = name;
                    this.serialNumber = serialNumber;
                    this.year = year;
                    this.Make = Make;
                    this.Model = Model;
                    this.Hour = Hour;
                    this.equipment = equipment;
                    
                }
    }
}