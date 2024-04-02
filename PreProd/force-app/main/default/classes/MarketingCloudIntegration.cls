/*
This class is used to integrate salesforce with marketing cloud and create record in marketing cloud.
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          15-Sep-2023         Kizzy Consulting        Pushkar               Initial Version
------------------------------------------------------------------------------------------------
*/
public class MarketingCloudIntegration {
    // Method to query metadata records which are active
    public static string getMarketingInfo() {
        string accessToken = '';
        Marketing_Cloud_Info__mdt MarketingCloudMdt = [SELECT Client_ID__c,Client_Secret__c,Data_Extension__c,Get_Access_Token_URL__c,IsActive__c
                                                       FROM Marketing_Cloud_Info__mdt
                                                       WHERE IsActive__c = true LIMIT 1];
        if(MarketingCloudMdt != null){
           accessToken =  getAccessToken(MarketingCloudMdt.Get_Access_Token_URL__c,MarketingCloudMdt.Client_ID__c,MarketingCloudMdt.Client_Secret__c,MarketingCloudMdt.Data_Extension__c);
        }
        return accessToken;
    }
    //Method to obtain an access token
    public static string getAccessToken(string endPointUrl,string clientId, string clientSecret, string dataExtension){
        string accessToken = '';

        if(string.isnotblank(endPointUrl) && string.isnotblank(clientId) && string.isnotblank(clientSecret) && string.isnotblank(dataExtension) ){
            try {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endPointUrl);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                
                // Define the request body parameters
                String requestBody = 'grant_type=client_credentials'
                    + '&client_id=' + clientId
                    + '&client_secret=' + clientSecret;
                
                req.setBody(requestBody);
                system.debug('req::'+req);
                // Create a new HTTP instance
                Http http = new Http();
                HttpResponse response = http.send(req);
                system.debug('response:::'+response);
                // Check the response status
                if (response.getStatusCode() == 200) {
                    // Parse the JSON response to extract the access token
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    accessToken = (String) responseMap.get('access_token');
                    system.debug('accessToken1::'+accessToken);
                   // createRecord(accessToken,dataExtension);
                } else {
                    // Handle the error or exception here
                    //System.debug('Error getting access token: ' + response.getStatus() + ' ' + response.getStatusText());
                    
                }
            } catch (Exception e){
                // Handle any exceptions that may occur during the HTTP request
                System.debug('Exception during access token retrieval: ' + e.getMessage());
                
            }  
        }
        return accessToken;
        
    }
    // Method to create records in marketing cloud using the access token
    public static void createRecord(String accessToken, string dataExtension,EventDataWrapper eventData) {
        system.debug('accessToken:::'+accessToken);
        system.debug('dataExtension:::'+dataExtension);
        if(string.isnotblank(dataExtension) && string.isnotblank(accessToken)){
            try {
                system.debug('eventData::'+eventData);
                // Define the endpoint URL
                HttpRequest request = new HttpRequest();
                request.setEndpoint(dataExtension);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Authorization', 'Bearer ' + accessToken);
                system.debug('JSON.serialize(eventData)'+JSON.serialize(eventData));
                // Define the event data JSON
                 //eventData = '{"ContactKey": "paras1.yadav@kizzyconsulting.com","EventDefinitionKey": "APIEvent-dbedfcce-8bad-2b70-7f00-fe544532a0a3","Data": {"ContactId": "123459109","FirstName": "Paras","lastName": "Yadav","Email": "paras1.yadav@kizzyconsulting.com","Created Date": "01-01-2024"}}';
                //{"zid":"13512713514","phone":null,"lastname":"test contact","id":"003D400000UxCQGIA3","email":"pushkar.dahal@kizzyconsulting.com"}
                request.setBody(JSON.serialize(eventData));
                system.debug('requestfinal:::'+request);
                // Create a new HTTP instance
                Http http = new Http();
                HttpResponse response = http.send(request);
                system.debug('responseFinal::'+response);
                // Check the response status
                if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                    // Successful event submission
                    System.debug('Event submitted successfully.');
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    String EventId = (String) responseMap.get('eventInstanceId');
                    system.debug('EventId:::'+EventId);
                } else {
                    // Handle the error or exception here
                    //System.debug('Error submitting event: ' + res.getStatus() + ' ' + res.getStatusText());
                }
            } catch (Exception e) {
                // Handle any exceptions that may occur during the HTTP request
                System.debug('Exception during event submission: ' + e.getMessage());
            }   
        }
    }
    
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
    }
    
}