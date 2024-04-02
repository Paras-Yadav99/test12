@isTest
public class MarketingCloudIntegrationTest {
    @TestSetup
    public static void setData() {
        
    }
    @isTest 
    public static void testMarketingCloudIntegration() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MarketingCloudHttpCalloutMock(200, 
                       '{"ContactKey": "paras1.yadav@kizzyconsulting.com","EventDefinitionKey": "APIEvent-dbedfcce-8bad-2b70-7f00-fe544532a0a3","Data": {"ContactId": "123459109","FirstName": "Paras","lastName": "Yadav","Email": "paras1.yadav@kizzyconsulting.com","Created Date": "01-01-2024"}}'));
        MarketingCloudIntegration.getMarketingInfo();
         Test.stopTest();
    }
      public class MarketingCloudHttpCalloutMock implements HttpCalloutMock {
        public Integer statusCode;
        public String body;
        
        public MarketingCloudHttpCalloutMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(this.body);
            response.setStatusCode(this.statusCode);
            return response; 
        }
    }
    
}