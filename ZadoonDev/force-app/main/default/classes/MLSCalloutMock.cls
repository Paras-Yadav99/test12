@isTest
global class MLSCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        if (!req.getEndpoint().contains('googleapis')){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"ListingID": 29082562,"Category": "Dozers","Manufacturer": "Caterpillar","Year": 2020,"Condition": "Used","Description": "Good used Caterpillar Dozer available with low miles. Please call to make sure it is still available before you come.","DealerWebsiteUrl": "https://www.yourwebsite.com/caterpillar-dozer-11082562","WebsiteUrl": "https://www.mylittlesalesman.com/caterpillar-dozer-11082562","CreatedDate": "2022-04-21T08:30:43.527","ModifiedDate": "2022-04-21T22:13:56.467","AtAuction": false,"RetailFlag": true,"WholesaleFlag": false,"RentalFlag": false,"ListPrice": 45000,"CurrencyCode": "USD","Location": {"Address1": "16915 East Freeway","City": "Dallas","StateProvince": "Texas","Country": "United States","PostalCode": "77530"},"Images": {"Images": [{"Url": "https://d222222.cloudfront.net/22222/example-high-res-image1.jpg","OrderNo": 1},{"Url": "https://d222222.cloudfront.net/22222/example-high-res-image2.jpg","OrderNo": 2},{"Url": "https://d222222.cloudfront.net/22222/example-high-res-image3.jpg","OrderNo": 3}]},"Videos": {"Videos": [{"Url": "https://www.youtube.com/watch?v=2t2222222","OrderNo": 1},{"Url": "https://www.youtube.com/watch?v=33333333333","OrderNo": 2},{"Url": "https://youtu.be/dsdssfdsdffs","OrderNo": 3}]}}');
            res.setStatusCode(200);
            return res;
        }else {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"items": [{"alternateLink" : "test", "webContentLink": "test"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}