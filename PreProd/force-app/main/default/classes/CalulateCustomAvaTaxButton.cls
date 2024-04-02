/*
This invocable class is used to send email to userRequirementID and the action button is in Unit record page.
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          13-Dec-2023           Kizzy Consulting      Paras                    Initial Version
------------------------------------------------------------------------------------------------cost
*/
public class CalulateCustomAvaTaxButton {
    @InvocableMethod(label='Calulate Avatax' description='Calulate custom Avatax')
    public static list<message> sendEmailtoUserRequirementContact(list<Id> SetOfOpportunityId) {
        list<Custom_AvaTax__c> lstCustomAvaTax = new list<Custom_AvaTax__c>();
        //Map<Id, Opportunity> triggerNewMap = ( Map<Id, Opportunity>)trigger.newMap;
        list<AvaTax_Line_Item__c> lstAvaTaxLineItem = new list<AvaTax_Line_Item__c>();
        set<Id> setAvataxId = new set<Id>();
        list<message> lstmessage = new list<message>();
		system.debug('SetOfOpportunityId::'+SetOfOpportunityId);
        if(SetOfOpportunityId != null && !SetOfOpportunityId.isEmpty()){
            system.debug('SetOfOpportunityId::'+SetOfOpportunityId);
            lstCustomAvaTax = [SELECT Account__c, Id, Name, Opportunity__c, Sales_Tax__c, Shipping_City__c, Shipping_Country__c,
                               Shipping_Postal_Code__c, Shipping_State__c, Shipping_Street__c, Status__c , Opportunity__r.Freight_Option__c,
                               Opportunity__r.Shipping_City__c,Opportunity__r.Shipping_Street__c,Opportunity__r.Shipping_Postal_Code__c,Opportunity__r.Shipping_State__c,
                               Opportunity__r.Shipping_Country__c,Opportunity__r.AccountId,Opportunity__r.Pro_Forma_City__c,Opportunity__r.Pro_Forma_Address__c,
                               Opportunity__r.Pro_Forma_Zip__c,Opportunity__r.Pro_Forma_State__c,Opportunity__r.Pro_Forma_Country__c,Opportunity__r.Pro_Forma_Price_Sent__c,
                              	Opportunity__r.Product__c,Opportunity__r.Tax_Exempt__c, (SELECT Id, Name, Amount__c, Custom_AvaTax__c, 
                                Quantity__c, Unit__c, Tax__c FROM AvaTax_Line_Items__r)
                               FROM Custom_AvaTax__c WHERE Opportunity__c IN : SetOfOpportunityId];
        }
        system.debug('lstCustomAvaTax:::'+lstCustomAvaTax);
        system.debug('lstCustomAvaTax:::'+lstCustomAvaTax.size());

        if(lstCustomAvaTax!=null && !lstCustomAvaTax.IsEmpty()){
            for(Custom_AvaTax__c eachCustomAvaTax : lstCustomAvaTax){
                if(eachCustomAvaTax.Opportunity__r.Tax_Exempt__c == false){
                    if(eachCustomAvaTax.Opportunity__r.Freight_Option__c == 'Zadoon'){
                        if(String.isNotBlank(eachCustomAvaTax.Opportunity__r.Shipping_City__c) && 
                           String.isNotBlank(eachCustomAvaTax.Opportunity__r.Shipping_Street__c) && 
                           String.isNotBlank(eachCustomAvaTax.Opportunity__r.Shipping_Postal_Code__c) && 
                           String.isNotBlank(eachCustomAvaTax.Opportunity__r.Shipping_State__c) &&
                           String.isNotBlank(eachCustomAvaTax.Opportunity__r.Shipping_Country__c) ){
                               if(eachCustomAvaTax.Opportunity__r.Pro_Forma_Price_Sent__c > 0){
                                   eachCustomAvaTax.Sales_Tax__c = 0;
                                   eachCustomAvaTax.Shipping_City__c = eachCustomAvaTax.Opportunity__r.Shipping_City__c;
                                   eachCustomAvaTax.Shipping_Street__c = eachCustomAvaTax.Opportunity__r.Shipping_Street__c;
                                   eachCustomAvaTax.Shipping_Postal_Code__c = eachCustomAvaTax.Opportunity__r.Shipping_Postal_Code__c;
                                   eachCustomAvaTax.Shipping_State__c = eachCustomAvaTax.Opportunity__r.Shipping_State__c;
                                   eachCustomAvaTax.Shipping_Country__c = eachCustomAvaTax.Opportunity__r.Shipping_Country__c;
                                   eachCustomAvaTax.Account__c = eachCustomAvaTax.Opportunity__r.AccountId;
                                   setAvataxId.add(eachCustomAvaTax.id);
                                   if(eachCustomAvaTax.AvaTax_Line_Items__r!=null && !eachCustomAvaTax.AvaTax_Line_Items__r.isEmpty()){
                                       for(AvaTax_Line_Item__c eachAvaTaxLineItem : eachCustomAvaTax.AvaTax_Line_Items__r){
                                           eachAvaTaxLineItem.Amount__c =eachCustomAvaTax.Opportunity__r.Pro_Forma_Price_Sent__c;
                                           eachAvaTaxLineItem.Unit__c  = eachCustomAvaTax.Opportunity__r.Product__c;
                                           lstAvaTaxLineItem.add(eachAvaTaxLineItem);
                                       }
                                   }else{
                                       lstmessage.add(new message('Avatax Line Item is missing'));
                                   }
                               }else{
                                   lstmessage.add(new message('Please add Pro Forma Price'));

                               }
                               
                           }else {
                               lstmessage.add(new message('Shipping Address is Blank'));
                           }
                    }else If (eachCustomAvaTax.Opportunity__r.Freight_Option__c == 'Buyer'){
                        if(String.isNotBlank(eachCustomAvaTax.Opportunity__r.Pro_Forma_City__c) && 
                           String.isNotBlank(eachCustomAvaTax.Opportunity__r.Pro_Forma_Address__c) && 
                           String.isNotBlank(eachCustomAvaTax.Opportunity__r.Pro_Forma_Zip__c) && 
                           String.isNotBlank(eachCustomAvaTax.Opportunity__r.Pro_Forma_State__c) &&
                           String.isNotBlank(eachCustomAvaTax.Opportunity__r.Pro_Forma_Country__c) ){
                               if(eachCustomAvaTax.Opportunity__r.Pro_Forma_Price_Sent__c > 0){

                               eachCustomAvaTax.Sales_Tax__c = 0;
                               eachCustomAvaTax.Shipping_City__c = eachCustomAvaTax.Opportunity__r.Pro_Forma_City__c;
                               eachCustomAvaTax.Shipping_Street__c = eachCustomAvaTax.Opportunity__r.Pro_Forma_Address__c;
                               eachCustomAvaTax.Shipping_Postal_Code__c = eachCustomAvaTax.Opportunity__r.Pro_Forma_Zip__c;
                               eachCustomAvaTax.Shipping_State__c = eachCustomAvaTax.Opportunity__r.Pro_Forma_State__c;
                               eachCustomAvaTax.Shipping_Country__c = eachCustomAvaTax.Opportunity__r.Pro_Forma_Country__c;
                               eachCustomAvaTax.Account__c = eachCustomAvaTax.Opportunity__r.AccountId;
                               setAvataxId.add(eachCustomAvaTax.id);
                               if(eachCustomAvaTax.AvaTax_Line_Items__r!=null && !eachCustomAvaTax.AvaTax_Line_Items__r.isEmpty()){
                                   for(AvaTax_Line_Item__c eachAvaTaxLineItem : eachCustomAvaTax.AvaTax_Line_Items__r){
                                       eachAvaTaxLineItem.Amount__c =eachCustomAvaTax.Opportunity__r.Pro_Forma_Price_Sent__c;
                                       eachAvaTaxLineItem.Unit__c  = eachCustomAvaTax.Opportunity__r.Product__c;
                                       lstAvaTaxLineItem.add(eachAvaTaxLineItem);
                                   }
                               }else{
                                   lstmessage.add(new message('Avatax Line Item is missing'));
                               }
                               }else{
                                   lstmessage.add(new message('Please add Pro Forma Price'));
                                   
                               }
                           }else {
                               lstmessage.add(new message('Pro Forma Address is Blank'));                          
                           }
                    }else {
                        lstmessage.add(new message('Freight Option must be selected for Calculating Taxes'));
                    }
                }else{
                    lstmessage.add(new message('This Account is Tax Exempt : Validate the Exempt Dates'));
                }
            }
            system.debug('lstCustomAvaTax::'+lstCustomAvaTax);
            Update lstCustomAvaTax;
            if(lstAvaTaxLineItem!=null && !lstAvaTaxLineItem.IsEmpty()){
                Update lstAvaTaxLineItem;
            }
            //set<Id> setAvataxId = new set<id>{lstCustomAvaTax[0].id};
            /*for(id eachCustomAvaTaxId : setAvataxId){
// Perform actions on each record
CustomAvaTaxCalculator.AvaTaxId= eachCustomAvaTaxId;
system.debug('eachCustomAvaTaxId:::'+eachCustomAvaTaxId);
// 	CustomAvaTaxCalculator.AvaTaxId= lstCustomAvaTax[0].id;
// CustomAvaTaxCalculator.calculateTax();
Database.executeBatch(new CalculateCustomAvaTaxBatchClass(setAvataxId), 1);
lstmessage.add(new message('Tax Updated'));


}*/
            if(setAvataxId!=null && !setAvataxId.IsEmpty()){
                Database.executeBatch(new CalculateCustomAvaTaxBatchClass(setAvataxId), 1);
                lstmessage.add(new message('Tax Updated'));
            }
        }else{
            lstmessage.add(new message('Custom Avatax record Missing'));
        }
        system.debug('lstmessage::'+lstmessage);
        return lstmessage;
    }
    public class message {
        @InvocableVariable public String Message;
        public message(String Message) {
            this.Message = Message;
            
        }
    }
}