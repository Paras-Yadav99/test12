/*
This invocable class is used to send email to userRequirementID and the action button is in Opportunity record page.
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          16-Aug-2023         Kizzy Consulting        Pushkar               Initial Version
------------------------------------------------------------------------------------------------
*/
public class EmailUserRequirementContactFromOppInvoc {
@InvocableMethod(label=' send Opp Details' description='Send Email' category='Email')
    public static list<message> sendEmailtoUserRequirementContactFromOpp(list<Id> oppId) {
        system.debug('oppId::'+oppId);
         list<User_Requirement_ID__c> lstUserRequirement;
        list<product2> lstProduct;
         list<message> lstmessage = new list<message>();
        set<id> setProductId = new set<id>();
        set<id> setContactId = new  set<id>();
        list<contact> lstContact = new list<contact>();
        WrapperData WrapperData = new WrapperData();
        string zid = '';
        if(oppId!=null && !oppId.isEmpty()){
            lstUserRequirement = [SELECT Id,Opportunity__c,contact__c,contact__r.LastName,contact__r.phone,contact__r.email,
                                  (SELECT id,Unit_Currently_Interested_In__c,Unit_Currently_Interested_In__r.zid__c
                                   FROM Iron_Demand__r)
                                  FROM User_Requirement_ID__c 
                                  WHERE Opportunity__c in : oppId AND contact__c!=null AND status__c='Incomplete'];
            
        }
        system.debug('lstUserRequirement:::'+lstUserRequirement);
        
        if(lstUserRequirement!=null && !lstUserRequirement.isEmpty()){
            for(User_Requirement_ID__c eachUserReq : lstUserRequirement ){
                if(string.isNotBlank(eachUserReq.Contact__c)){
                     setContactId.add(eachUserReq.Contact__c);
                }
                for(Iron_Demand__c eachIronDemand : eachUserReq.Iron_Demand__r){
                    if(eachIronDemand.Unit_Currently_Interested_In__r.zid__c != null){
                        zid += eachIronDemand.Unit_Currently_Interested_In__r.zid__c;
                    }
                    setProductId.add(eachIronDemand.Unit_Currently_Interested_In__c);
                }
            }
        }
        
        if(setContactId != null && !setContactId.isEmpty()){
            lstContact = [SELECT id,lastname,phone,email
                          FROM contact
                          WHERE id in : setContactId AND email !=NULL ];
        }
        if(string.isnotblank(ZID)){
             Zid = ZId.substring(0,zid.length()-1);
        } 
        if(lstContact != null && !lstContact.isEmpty() ){
            for(contact eachContact :lstContact) {
                WrapperData = new WrapperData(eachContact.id,eachContact.LastName,eachContact.phone,eachContact.email,Zid);  
                 String wrapperString = JSON.serialize(WrapperData);
                system.debug('WrapperData:::'+WrapperData);  
                system.debug('wrapperString:::'+wrapperString);
            }
        }
        
        if(setProductId!=null && !setProductId.isEmpty()){
            lstProduct = [SELECT id,Year__c,Manufacturer__c,Name,Model__c,Hour__c,Storage_State__c,ZID__c,
                          Number_of_Images_in_Google_Drive__c,Number_of_Videos_in_Google_Drive__c,
                          Starting_Advertised_Retail_Price__c,Old_SF_Unit_Details__c,
                          Google_Drive_LInk__c,Google_Drive_Videos_Link__c
                          FROM product2 
                          WHERE ID in  : setProductId ];
        }
        system.debug('lstProduct:::'+lstProduct);
           
        String response = '';
        if((setContactId!=null && !setContactId.isEmpty()) && (lstProduct!=null && !lstProduct.isEmpty())) {
            //response = AdhocEmailUnitController.sendEmailUtil(setContactId,lstProduct);
        }
         system.debug('lstResponse:::'+response);
        lstmessage.add(new message(response));
        system.debug('lstmessage:::'+lstmessage);
        return lstmessage;
        
    }
       public class message {
        @InvocableVariable public String Message;
        public message(String Message) {
            this.Message = Message;
            
        }
    }
       //Wrapper class
    public class WrapperData{
        public String id ;
        public string lastname;
        public string phone ;
        public string email ;
        public string zid;
        //constructor
        WrapperData(){
            
        }
        WrapperData(String id,string lastname,string phone,string email,string zid ){
            this.id = id;
            this.lastname = lastname;
            this.phone = phone;
            this.email = email;
            this.zid = zid;
        }
    }
}