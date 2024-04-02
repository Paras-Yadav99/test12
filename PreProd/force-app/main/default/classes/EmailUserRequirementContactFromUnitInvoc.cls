/*
This invocable class is used to send email to userRequirementID and the action button is in Unit record page.
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          16-Aug-2023         Kizzy Consulting        Pushkar               Initial Version
------------------------------------------------------------------------------------------------
*/
public class EmailUserRequirementContactFromUnitInvoc {
    @InvocableMethod(label=' send Unit Details' description='Send Email' category='Email')
    public static list<message> sendEmailtoUserRequirementContact(list<Id> UnitId) {
        list<product2> lstProduct;
        set<id> setContactId = new  set<id>(); 
        list<contact> lstContact;
        list<Marketing_Cloud_Connection__c>lstMarketingCloudConnection = new list<Marketing_Cloud_Connection__c>();
        if(UnitId!=null && !UnitId.isEmpty()){
            lstProduct = [SELECT id,Year__c,Manufacturer__c,Name,Model__c,Hour__c,Storage_State__c,ZID__c,
                          Number_of_Images_in_Google_Drive__c,Number_of_Videos_in_Google_Drive__c,
                          Starting_Advertised_Retail_Price__c,Old_SF_Unit_Details__c,
                          Google_Drive_LInk__c,Google_Drive_Videos_Link__c,
                          (SELECT id,User_Requirement_ID__r.contact__c FROM Iron_Demand__r)
                          FROM product2 
                          WHERE id in : UnitId AND ZID__c != null];
            
        }
        string ZID = '';
        string ZIDMC = '';
        
        if(lstProduct!=null && !lstProduct.isEmpty()){
            
            for(product2 eachProduct :lstProduct ){
                ZID += eachProduct.ZID__c;
                ZIDMC += eachProduct.ZID__c+',';
                for(Iron_Demand__c eachIronDemand :eachProduct.Iron_Demand__r ){
                    if(string.isNotBlank(eachIronDemand.User_Requirement_ID__r.contact__c)){
                        setContactId.add(eachIronDemand.User_Requirement_ID__r.contact__c);
                    }
                    
                }
            }
        }
        
        ZIDMC = removeLastChar.removeChars(ZIDMC,1);
        
        if(setContactId!=null && !setContactId.isEmpty()){
            lstContact = [SELECT ID, name, Phone, Email,lastname,firstName
                          FROM contact 
                          WHERE ID IN: setContactId AND Email !=NULL];
        }
        MarketingCloudIntegration.EventDataWrapper EventDataWrapper ; 
        
        //list<DataWrapper> lstDataWrapper = new list<DataWrapper>();
        WrapperData WrapperData = new WrapperData() ;
        MarketingCloudIntegration.DataWrapper DataWrapper ;
        if(lstContact != null && !lstContact.isEmpty()){
            for(contact eachContact : lstContact ){
                Marketing_Cloud_Connection__c newMarketingCloudConnection = new Marketing_Cloud_Connection__c();
                newMarketingCloudConnection.Contact__c = eachContact.id;
                newMarketingCloudConnection.Email__c = eachContact.Email;
                newMarketingCloudConnection.Product_Keys__c = ZIDMC ;
                lstMarketingCloudConnection.add(newMarketingCloudConnection);
            }
        }
        if(lstMarketingCloudConnection!=null && !lstMarketingCloudConnection.isEmpty()){
            insert lstMarketingCloudConnection;
        }
        list<message> lstmessage = new list<message>();
        lstmessage.add(new message('Email Send'));
        
        return lstmessage;
    }
        /*if(lstContact != null && !lstContact.isEmpty()){
            for(contact eachContact : lstContact ){
                
                WrapperData = new WrapperData(eachContact.id,eachContact.lastname,eachContact.phone,eachContact.email,ZID);  
                
               DataWrapper = new MarketingCloudIntegration.DataWrapper(eachContact.email,eachContact.firstname,eachContact.lastname,ZIDMC,eachContact.id);
                //lstDataWrapper.add(DataWrapper);
            }
            //EventDataWrapper = new EventDataWrapper(lstContact[0].Name , );
        }
        if(DataWrapper!=null && 
          string.isNotblank(ZIDMC)){
              string accessToken = '';
              Marketing_Cloud_Info__mdt MarketingCloudMdt = [SELECT Client_ID__c,Client_Secret__c,Data_Extension__c,Get_Access_Token_URL__c,
                                                             IsActive__c,Event_Definition_Key__c
                                                             FROM Marketing_Cloud_Info__mdt
                                                             WHERE IsActive__c = true AND DeveloperName = 'Maching_Email'  LIMIT 1 ];
              if(MarketingCloudMdt != null){
                  accessToken =  MarketingCloudIntegration.getAccessToken(MarketingCloudMdt.Get_Access_Token_URL__c,MarketingCloudMdt.Client_ID__c,MarketingCloudMdt.Client_Secret__c,MarketingCloudMdt.Data_Extension__c);
              }
              //accessToken = MarketingCloudIntegration.getMarketingInfo();
              if(String.isNotBlank(accessToken) && MarketingCloudMdt != null ){
                  EventDataWrapper = new MarketingCloudIntegration.EventDataWrapper(lstContact[0].Name ,MarketingCloudMdt.Event_Definition_Key__c, DataWrapper);
                  MarketingCloudIntegration.createRecord(accessToken, MarketingCloudMdt.Data_Extension__c,EventDataWrapper);
              }else{
                  
              }
        }
        
        list<message> lstmessage = new list<message>();
        String response = '';
        if((setContactId!=null && !setContactId.isEmpty()) && (lstProduct!=null && !lstProduct.isEmpty())){
           // response = AdhocEmailUnitController.sendEmailUtil(setContactId,lstProduct);
        }
        
        lstmessage.add(new message(response));
        
        return lstmessage;
    }*/
    
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
    }/*
    public class EventDataWrapper {
        public String ContactKey;
        public String EventDefinitionKey;
        public DataWrapper Data;
        public EventDataWrapper(String ContactKey,String EventDefinitionKey,DataWrapper Data){
            this.ContactKey = ContactKey;
            this.EventDefinitionKey = EventDefinitionKey;
            this.Data = Data;
        }
    }

    public class DataWrapper {
        public String Email;
        public String FirstName;
        public String LastName;
        public String Product_Keys;
        public String Contact_Id;

        // Constructor
        public DataWrapper(String Email, String FirstName, String LastName, String Product_Keys, String Contact_Id) {
            this.Email = Email;
            this.FirstName = FirstName;
            this.LastName = LastName;
            this.Product_Keys = Product_Keys;
            this.Contact_Id = Contact_Id;
        }
    }*/

    
}