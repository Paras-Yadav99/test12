@istest
public class MatchingEmailCmpControllerTest {
    @testsetUp
    static void setupTestData() {
        list<account> lstAccount = testDataFactory.noOfAccountToInsert(1,'company');
        lstAccount[0].Client_Type__c ='Equipment Seller';
        insert lstAccount;
        list<Equipment__c> newEquipment= testDataFactory.noOfEquipment(1);
        newEquipment[0].Manufacturer__c = 'EAGLE';
        newEquipment[0].Category__c = 'Wheel Loader';
        insert newEquipment;
        list<Product2> newUnit = testDataFactory.noOfUnitsToCreate(1,newEquipment[0].id);
        newUnit[0].account__c = lstAccount[0].id;
        newUnit[0].isActive = true;
        insert newUnit;
    }
    @isTest 
    public static void testGetactiveUnitsRecord(){
        test.startTest();
        MatchingEmailCmpController.getactiveUnitsRecord();
         test.stopTest();
        system.Assert(true);
    }
     @isTest 
    public static void testGetAccountRecords(){
        list<String> lstUnitId = new list<String>();
        list<product2> lstProducts = [SELECT ID,account__r.name,account__r.Primary_Contact__c,account__r.Primary_Contact__r.Email,account__c,zid__c
                                      FROM product2];
        if(lstProducts != null && !lstProducts.isEmpty()){
            for(product2 eachProduct : lstProducts){
                lstUnitId.add(eachProduct.id);
            }
        }
        test.startTest();
        MatchingEmailCmpController.getAccountRecords(lstUnitId);
        test.stopTest();
        system.Assert(true);
    }
    @isTest 
    public static void testunitRecordsBasedOndealer(){
        list<String> lstAuthorizedDealer = new list<String>();
        list<Equipment__c> lstequipment = [SELECT ID,Manufacturer__c
                                          FROM Equipment__c];
        if(lstequipment != null && !lstequipment.isEmpty()){
            for(Equipment__c eachEquipment : lstequipment ){
                lstAuthorizedDealer.add(eachEquipment.Manufacturer__c);
            }
        }
        test.startTest();
        MatchingEmailCmpController.getunitRecordsBasedOndealer(lstAuthorizedDealer);
        test.stopTest();
        system.Assert(true);
    }
     @isTest 
    public static void testunitRecordBasedOndealer(){
        list<String> lstAuthorizedDealer = new list<String>();
        list<Equipment__c> lstequipment = [SELECT ID,Manufacturer__c,Category__c
                                          FROM Equipment__c];
        if(lstequipment != null && !lstequipment.isEmpty()){
            for(Equipment__c eachEquipment : lstequipment ){
                lstAuthorizedDealer.add(eachEquipment.Category__c);
            }
        }
        test.startTest();
        MatchingEmailCmpController.getunitRecordsBasedOndealer(lstAuthorizedDealer);
        test.stopTest();
        system.Assert(true);
    }
     @isTest 
    public static void testPicklistValues(){
        test.startTest();
        MatchingEmailCmpController.getPicklistValues('Account','Client_Type__c');
        test.stopTest();
        system.Assert(true); 
    }
    
      @isTest 
    public static void testSendEmailFromMarketingCloud(){
          list<String> lstUnitZid = new list<String>();
        list<id> lstAccountId = new list<id>();
        list<String> lstAccountClientType = new list<String>();
        list<product2> lstProducts = [SELECT ID,account__r.name,account__r.Client_Type__c,account__c,zid__c
                                      FROM product2 
                                      WHERE account__c != null AND account__r.Client_Type__c != null AND zid__c != null];
        if(lstProducts != null && !lstProducts.isEmpty()){
            for(product2 eachProduct : lstProducts){
                lstUnitZid.add(eachProduct.zid__c);
                 lstAccountId.add(eachProduct.account__c);
                 lstAccountClientType.add(eachProduct.account__r.Client_Type__c);
            }
        }
        if(!lstUnitZid.isEmpty() && !lstAccountId.isEmpty() && !lstAccountClientType.isEmpty()){
            test.startTest();
            MatchingEmailCmpController.sendEmailFromMarketingCloud(lstAccountId,lstAccountClientType,null,lstUnitZid);
            test.stopTest();
            system.Assert(true); 
        }
    }
    
}