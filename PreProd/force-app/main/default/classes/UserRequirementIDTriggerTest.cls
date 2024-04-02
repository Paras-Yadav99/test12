@isTest
public class UserRequirementIDTriggerTest {
    @testsetUp
    static void setupTestData() {
        list<account> lstAccount = testDataFactory.noOfAccountToInsert(1,'test');
        insert lstAccount;
        list<contact> lstContact = testDataFactory.noOfContactToInsert(1,'test');
        insert lstContact;
       list<lead> lstLead = testDataFactory.noOfLeadToInsert(1,'');
       lstLead[0].contact__c = lstContact[0].Id;
        list<opportunity> lstOpp = testDataFactory.createOpportunity(1,lstAccount[0].id,'');
		lstOpp[0].contactId = lstContact[0].id;        
        //insert lstOpp;
        insert lstLead;
    }
    
    @isTest 
    public static void testHandleafterInsert(){
        list<lead> lstLead = [SELECT id,contact__c
                              FROM lead];
        system.debug('lstLead:::'+lstLead);
        list<User_Requirement_ID__c> newUserRequirement = testDataFactory.createUserRequirementID(1);
        newUserRequirement[0].lead__C = lstLead[0].id;
        test.startTest();
        insert newUserRequirement;
         test.stopTest();
        System.Assert(true);
    }
     /* @isTest 
    public static void TestHandleafterInsertOpp(){
        list<opportunity> lstOpp = [SELECT id,contactId
                              FROM opportunity];
        system.debug('lstOpp:::'+lstOpp);
        list<User_Requirement_ID__c> newUserRequirement = testDataFactory.createUserRequirementID(1);
        newUserRequirement[0].opportunity__c = lstOpp[0].id;
        test.startTest();
        insert newUserRequirement;
         test.stopTest();
        System.Assert(true);
    }*/
     @isTest 
    public static void TestHandleafterUpdate(){
                   list<lead> lstLead = [SELECT id,contact__c
                              FROM lead];
         system.debug('lstLead1:::'+lstLead);
        list<User_Requirement_ID__c> newUserRequirement = testDataFactory.createUserRequirementID(1);
        newUserRequirement[0].lead__C = lstLead[0].id;
        insert newUserRequirement;
         /*list<Unit_Category_Details__c> newUnitCategoryDetails= testDataFactory.createUnitCategoryDetails(1);
        newUnitCategoryDetails[0].User_Requirement_ID__c= newUserRequirement[0].Id;
        newUnitCategoryDetails[0].IsActive__c = true;*/
        newUserRequirement[0].WTB_Date__c = Date.newInstance(2023, 6, 22);
        newUserRequirement[0].WTB_Priority__c ='High (immediate WTB email)';
        newUserRequirement[0].WTB_Status__c = 'WTB In Process';
        //insert newUnitCategoryDetails;
        newUserRequirement[0].Max_Budget__c = 10000;
        newUserRequirement[0].WTB_Date__c = Date.newInstance(2023, 7, 22);
        newUserRequirement[0].WTB_Status__c = 'WTB Requested';
        test.startTest();
        update newUserRequirement;
         test.stopTest();
        System.Assert(true);
    }
        @isTest 
    public static void TestHandleafterUpdate1(){
                   list<lead> lstLead = [SELECT id,contact__c
                              FROM lead];
         system.debug('lstLead1:::'+lstLead);
        list<User_Requirement_ID__c> newUserRequirement = testDataFactory.createUserRequirementID(1);
        newUserRequirement[0].lead__C = lstLead[0].id;
        insert newUserRequirement;
         /*list<Unit_Category_Details__c> newUnitCategoryDetails= testDataFactory.createUnitCategoryDetails(1);
        newUnitCategoryDetails[0].User_Requirement_ID__c= newUserRequirement[0].Id;
        newUnitCategoryDetails[0].IsActive__c = true;*/
        newUserRequirement[0].WTB_Date__c = Date.newInstance(2023, 6, 22);
        newUserRequirement[0].WTB_Priority__c ='Medium (include w/ weekly WTB)';
        newUserRequirement[0].WTB_Status__c = 'WTB In Process';
        //insert newUnitCategoryDetails;
        newUserRequirement[0].Max_Budget__c = 10000;
        newUserRequirement[0].WTB_Date__c = Date.newInstance(2023, 7, 22);
        newUserRequirement[0].WTB_Status__c = 'WTB Completed';
        test.startTest();
        update newUserRequirement;
         test.stopTest();
        System.Assert(true);
    }
         @isTest 
    public static void TestHandleafterUpdate2(){
                   list<lead> lstLead = [SELECT id,contact__c
                              FROM lead];
         system.debug('lstLead1:::'+lstLead);
        list<User_Requirement_ID__c> newUserRequirement = testDataFactory.createUserRequirementID(1);
        newUserRequirement[0].lead__C = lstLead[0].id;
        insert newUserRequirement;
        /* list<Unit_Category_Details__c> newUnitCategoryDetails= testDataFactory.createUnitCategoryDetails(1);
        newUnitCategoryDetails[0].User_Requirement_ID__c= newUserRequirement[0].Id;
        newUnitCategoryDetails[0].IsActive__c = true;*/
        newUserRequirement[0].WTB_Date__c = Date.newInstance(2023, 6, 22);
        newUserRequirement[0].WTB_Priority__c ='Low (Post on iron sites only)';
        //insert newUnitCategoryDetails;
        newUserRequirement[0].Max_Budget__c = 10000;
        newUserRequirement[0].WTB_Date__c = Date.newInstance(2023, 7, 22);
        test.startTest();
        update newUserRequirement;
         test.stopTest();
        System.Assert(true);
    }
}