public class KWIPPEDCustomerApproval {
	@future(callout=true)
    public static void UpdateMonthlyAmount(set<Id> setId){
        list<Product2> lstProduct = [SELECT Id ,Monthly_Business_Financing__c,
                                      Date_of_Monthly_Business_Financing__c, 
                                     Starting_Advertised_Retail_Price__c
                                     From Product2 where id IN :setId ];
        if(lstProduct!=null && !lstProduct.isEmpty()){
            for(Product2 eachProduct2 : lstProduct){
                eachProduct2.Date_of_Monthly_Business_Financing__c = system.today();
                eachProduct2.Monthly_Business_Financing__c = approveCustomer(eachProduct2.Starting_Advertised_Retail_Price__c);
            } 
            update lstProduct;
        }
    }
    
@InvocableMethod(label='Update Monthly Price' description='update Price')
    public static list<message> UpdateMonthlyAmountfromFlow(list<Id> setId){
         list<message> lstmessage = new list<message>();
        list<Product2> lstProduct = [SELECT Id ,Monthly_Business_Financing__c,
                                      Date_of_Monthly_Business_Financing__c, 
                                     Starting_Advertised_Retail_Price__c
                                     From Product2 WHERE id IN :setId 
                                     AND Starting_Advertised_Retail_Price__c > 0 ];
        
        if(lstProduct!=null && !lstProduct.isEmpty()){
            for(Product2 eachProduct2 : lstProduct){
                eachProduct2.Date_of_Monthly_Business_Financing__c = system.today();
                eachProduct2.Monthly_Business_Financing__c = approveCustomer(eachProduct2.Starting_Advertised_Retail_Price__c);
            } 
            update lstProduct;
            lstmessage.add(new message('Monthly Business Financing Updated'));
        }else{
            lstmessage.add(new message('SARP is less than 0'));
        }
        return lstmessage;
    }
    public class message {
        @InvocableVariable public String Message;
        public message(String Message) {
            this.Message = Message;
            
        }
    }
    public static decimal approveCustomer(decimal Amount) {
        decimal monthlyAmount = 0;
        String apiKey = '287167-ad395f-d3e952-83b3a0-6ac6e4';
        //String endpoint = 'https://www.kwipped.com/api/v2/approve/customers/129473';
        String endpoint = 'https://www.kwipped.com/api/v2/approve/finance-teasers/'+Amount;
        // String payload = '{"key": "value"}'; // Define your payload data here
        Blob headerValue = Blob.valueOf(apiKey);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        system.debug(authorizationHeader);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        //req.setBody(payload);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            System.debug('result Body::::::'+res.getBody());
            System.debug('Customer approval successful!');
            ResponseWrapper monthlyDataFromApprove = (ResponseWrapper)JSON.deserialize(res.getBody(), ResponseWrapper.class);
            if(monthlyDataFromApprove.success){
                for(cls_data eachclsdata : monthlyDataFromApprove.data){
                    if(eachclsdata.term == 60){
                        system.debug(eachclsdata.monthly_rate);
                        monthlyAmount =   decimal.valueOf(eachclsdata.monthly_rate);
                    }
                    
                }
                
            } else {
                System.debug('Customer approval failed: ' + res.getStatusCode() + ' ' + res.getBody());
            }
            
        }
        return monthlyAmount;
    }
    public class ResponseWrapper{
        public boolean success;
        public String action;	//get_teaser_rates
        public cls_data[] data;
    }
    class cls_data {
        public Double monthly_factor;	//0.018962300332526
        public Integer term;	//60
        public String monthly_rate;	//4726.24
        public Integer company_id;	//944
        public Double markup;	//0.06
        public Integer finance_sale_price;	//249244
        public Integer finance_total;	//249244
    }
    
    
  /*  public void createAppLinkOnApproval(String apiKey, String approvalEndpoint, String payload) {
        Blob headerValue = Blob.valueOf(apiKey);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(approvalEndpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(payload);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            System.debug('Application link creation on approval successful!');
        } else {
            System.debug('Application link creation on approval failed: ' + res.getStatusCode() + ' ' + res.getBody());
        }
    }*/
}