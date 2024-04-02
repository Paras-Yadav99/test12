@isTest(seeAllData=true)
public with sharing class testAutoPopulatePricebookEntry {

    // test product insertion and pricebook entry addition
    static testMethod void testProduct2Trigger() {
       
       
        /*
        // Create the Account Record.
        Product2 unit = new Product2();
        unit.Name='Test Product' ;
        unit.equipment__c='a006A000002GwLe';
        insert unit;
        
        Product2 unitNew = [select Id, Name from Product2 where Id =: unit.Id LIMIT 1];
        
       
        
        /* 
        cont.General_Enquiry__c = false;
        update cont;        
        
        accNew = [select Id, General_Enquiry__c from Account where Id =: acc.Id LIMIT 1];
        
        System.assertEquals(false, accNew.General_Enquiry__c);
       
       
        // Query the database for the newly inserted records.
        List<PricebookEntry> pbe = [SELECT Name, Description 
                                      FROM Account 
                                      WHERE Id IN :accounts];
       
       
       
        */
    }
    
}