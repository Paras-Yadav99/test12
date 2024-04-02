/*
This invocable class is used to send email to userRequirementID and the action button is in lead record page.
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          16-Aug-2023         Kizzy Consulting        Pushkar               Initial Version
------------------------------------------------------------------------------------------------
*/
public class EmailUserRequirementContactFromLeadInvoc {
    @InvocableMethod(label=' send Lead Details' description='Send Email' category='Email')
    
    public static list<message> sendEmailtoUserRequirementContactFromLead(list<Id> LeadId) {
        system.debug('LeadId::'+LeadId);
        list<User_Requirement_ID__c> lstUserRequirement;
        list<contact> lstContact = new list<contact>();
        WrapperData WrapperData = new WrapperData();
        set<id> setProductId = new set<id>();
        set<id> setContactId = new set<id>();
        string zid = '';
        if(LeadId!=null && !LeadId.isEmpty()){
            lstUserRequirement = [SELECT id,lead__c,Contact__c,contact__r.LastName,contact__r.phone,contact__r.email,
                                  (SELECT id,Unit_Currently_Interested_In__c, Unit_Currently_Interested_In__r.Zid__c
                                   FROM Iron_Demand__r)
                                  FROM User_Requirement_ID__c
                                  WHERE lead__c in :LeadId AND contact__c != null AND status__c='Incomplete' ];
        }
        system.debug('lstUserRequirement::'+lstUserRequirement);
        if(lstUserRequirement!=null && !lstUserRequirement.isEmpty()){
            for(User_Requirement_ID__c eachUserReq : lstUserRequirement ){
                if(string.isNotBlank(eachUserReq.Contact__c)){
                    setContactId.add(eachUserReq.Contact__c);
                }
                for(Iron_Demand__c eachIronDemand : eachUserReq.Iron_Demand__r){
                    system.debug('lstUserRequirement:::'+lstUserRequirement.size());
                    system.debug('eachUserReq.Iron_Demand__r.size():::'+eachUserReq.Iron_Demand__r.size());
                    system.debug('zid:::'+eachIronDemand.Unit_Currently_Interested_In__r.Zid__c);
                    if(eachIronDemand.Unit_Currently_Interested_In__r.Zid__c !=null){
                        system.debug('zid:::'+eachIronDemand.Unit_Currently_Interested_In__r.Zid__c);
                        zid += eachIronDemand.Unit_Currently_Interested_In__r.Zid__c + ',' ;
                       
                    }
                    setProductId.add(eachIronDemand.Unit_Currently_Interested_In__c);
                }
                
            }
        }
        
          if(setContactId!=null && !setContactId.isEmpty()){
            lstContact = [SELECT ID,phone,email,lastname 
                          FROM contact
                          WHERE id in : setContactId AND email !=NULL];
        }
        if(string.isnotblank(ZID)){
             ZId = ZId.substring(0,zid.length()-1);
        }
        if(lstContact !=null && !lstContact.isEmpty() ){
            for(contact eachContact : lstContact){
                WrapperData = new WrapperData(eachContact.id,eachContact.LastName,eachContact.phone,eachContact.email,ZId);  
                system.debug('WrapperData:::'+WrapperData);
            }
        }
        
        system.debug('setProductId:::'+setProductId);
        list<product2> lstProduct; 
        if(setProductId!=null && !setProductId.isEmpty()){
            lstProduct = [SELECT id,Year__c,Manufacturer__c,Name,Model__c,Hour__c,Storage_State__c,ZID__c,
                          Number_of_Images_in_Google_Drive__c,Number_of_Videos_in_Google_Drive__c,
                          Starting_Advertised_Retail_Price__c,Old_SF_Unit_Details__c,
                          Google_Drive_LInk__c,Google_Drive_Videos_Link__c
                          FROM product2 
                          WHERE ID in  : setProductId ];
        }
        system.debug('lstProduct:::'+lstProduct);
        list<message> lstmessage = new list<message>();
        String response = '';
        if((setContactId!=null && !setContactId.isEmpty()) && (lstProduct!=null && !lstProduct.isEmpty())) {
            response = AdhocEmailUnitController.sendEmailUtil(setContactId,lstProduct);
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