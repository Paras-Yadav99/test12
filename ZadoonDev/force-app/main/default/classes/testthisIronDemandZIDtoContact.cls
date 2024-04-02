@isTest
private class testthisIronDemandZIDtoContact {
 
    static testMethod void myIDZIDtoContactTest() 
    {

        thisIronDemandZIDtoContact testObject = new thisIronDemandZIDtoContact();
    
        testObject.thisIronDemandId = 'a02c000000IKq6j';
        
        Id testIronDemandId = 'a02c000000IKq6j';
        System.assertEquals(testObject.thisIronDemandId, testIronDemandId, testObject.thisIronDemandId);
        
        testObject.thisAccountId = '001c000001Ay1HU';
        
        Id testAccountId = '001c000001Ay1HU';
        System.assertEquals(testObject.thisAccountId, testAccountId);
        
         
        LIST<Product2> ZIDList = testObject.getThisIronDemandZidsToContact();
         
        // soql tests 
        
        
        Id [] fixedSearchResults= new Id[1];

        fixedSearchResults[0] = '01t6A000000RNvq';

       Test.setFixedSearchResults(fixedSearchResults);

       List<List<SObject>> searchList = [FIND 'test'

                                         IN ALL FIELDS RETURNING

                                            Account(id, name WHERE name = 'test' LIMIT 1)];
       
        
        
    }
}