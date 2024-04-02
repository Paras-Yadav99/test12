/*
This invocable class is used to send email to userRequirementID and the action button is in Unit record page.
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          16-Aug-2023         Kizzy Consulting      Pushkar               Initial Version
------------------------------------------------------------------------------------------------
*/
public class EmailUserRequirementContactFromUnitInvoc {
    @InvocableMethod(label=' send Unit Details' description='Send Email' category='Email')
    public static list<message> sendEmailtoUserRequirementContact(list<Id> UnitId) {
        system.debug('UnitId::'+UnitId);
        list<product2> lstProduct;
        set<id> setContactId = new  set<id>(); 
        list<contact> lstContact;
        if(UnitId!=null && !UnitId.isEmpty()){
            lstProduct = [SELECT id,Year__c,Manufacturer__c,Name,Model__c,Hour__c,Storage_State__c,ZID__c,
                          Number_of_Images_in_Google_Drive__c,Number_of_Videos_in_Google_Drive__c,
                          Starting_Advertised_Retail_Price__c,Old_SF_Unit_Details__c,
                          Google_Drive_LInk__c,Google_Drive_Videos_Link__c,
                          (SELECT id,User_Requirement_ID__r.contact__c FROM Iron_Demand__r)
                          FROM product2 
                          WHERE id in : UnitId AND ZID__c != null];
            system.debug('lstProduct::'+lstProduct);
        }
        string ZID = '';
        if(lstProduct!=null && !lstProduct.isEmpty()){
            system.debug('lstProduct::'+lstProduct);
            for(product2 eachProduct :lstProduct ){
                ZID += eachProduct.ZID__c;
                for(Iron_Demand__c eachIronDemand :eachProduct.Iron_Demand__r ){
                    system.debug('eachIronDemand.User_Requirement_ID__r.contact__c:::'+eachIronDemand.User_Requirement_ID__r.contact__c);
                    if(string.isNotBlank(eachIronDemand.User_Requirement_ID__r.contact__c)){
                        system.debug('eachIronDemand.User_Requirement_ID__r.contact__c:::'+eachIronDemand.User_Requirement_ID__r.contact__c);
                        setContactId.add(eachIronDemand.User_Requirement_ID__r.contact__c);
                    }
                    // system.debug('eachIronDemand.IronDemand_Contact__r.id:::'+eachIronDemand.IronDemand_Contact__r.id);
                }
            }
        }
        if(setContactId!=null && !setContactId.isEmpty()){
            lstContact = [SELECT ID, name, Phone, Email,lastname
                          FROM contact 
                          WHERE ID IN: setContactId AND Email !=NULL];
        }
        
        WrapperData WrapperData = new WrapperData() ; 
        if(lstContact != null && !lstContact.isEmpty()){
            for(contact eachContact : lstContact ){
                
                WrapperData = new WrapperData(eachContact.id,eachContact.lastname,eachContact.phone,eachContact.email,ZID);  
                system.debug('WrapperData:::'+WrapperData);
            }
        }
        
        system.debug('setContactId:Iron_Demand__c.IronDemand_Contact__r:'+setContactId);
        list<message> lstmessage = new list<message>();
        String response = '';
        if((setContactId!=null && !setContactId.isEmpty()) && (lstProduct!=null && !lstProduct.isEmpty())){
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
        public string lastName;
        public string phone ;
        public string email ;
        public string zid;
        //constructor
        WrapperData(){
            
        }
        WrapperData(String id,string lastName,string phone,string email,string zid ){
            this.id = id;
            this.lastname = lastname;
            this.phone = phone;
            this.email = email;
            this.zid = zid;
        }
    }
    
}