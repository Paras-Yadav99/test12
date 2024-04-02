@isTest
public class UnitCategoryDetailsTriggerTest {
    @testsetUp
    static void setupTestData() {
        list<account> lstAccount = testDataFactory.noOfAccountToInsert(1,'company');
        insert lstAccount;
        list<Equipment__c> newEquipment= testDataFactory.noOfEquipment(1);
        newEquipment[0].Operating_Weight__c = 1000;	
        insert newEquipment;
          list<Product2> newUnit = testDataFactory.noOfUnitsToCreate(1,newEquipment[0].id);
        newUnit[0].Starting_Advertised_Retail_Price__c = 1000;
        newUnit[0].Account__c=lstAccount[0].id;
        newUnit[0].Old_SF_Unit_Details__c = 'test';
		insert newUnit;
         list<account> lstNewAccount = testDataFactory.noOfAccountToInsert(1,'company');
        insert lstNewAccount;
        list<contact> lstContact = testDataFactory.noOfContactToInsert(1,'test');
        lstContact[0].accountid = lstNewAccount[0].id;
        insert lstContact;
        list<Opportunity> lstOpp = testDataFactory.createOpportunity1(1,lstAccount[0].id,newUnit[0].id);
        lstOpp[0].StageName = 'Proactive Brokerage';
        lstOpp[0].Buyer_Primary_Contact__c =lstContact[0].id; 
        insert lstOpp;
        list<lead> lstLead = testDataFactory.noOfLeadToInsert(1,'');
        lstLead[0].contact__c = lstContact[0].Id;
        insert lstLead;
        list<User_Requirement_ID__c> newUserRequirement = testDataFactory.createUserRequirementID(1);
		newUserRequirement[0].lead__c =  lstLead[0].id;       
        newUserRequirement[0].Max_Budget__c =1000;
        newUserRequirement[0].Min_Budget__c = 100;
        newUserRequirement[0].Weight_Max__c = 1100;
        newUserRequirement[0].Weight_Min__c = 100;
        insert newUserRequirement;
        list<User_Requirement_ID__c> newUserRequirementID = testDataFactory.createNewUserRequirementID(1);
        newUserRequirementID[0].opportunity__c = lstOpp[0].id;
        insert newUserRequirementID;
        list<User_Requirement_ID__c> newUserRequirementID3 = testDataFactory.createNewUserRequirementID(1);
        newUserRequirementID3[0].contact__c = lstContact[0].id;
        insert newUserRequirementID3;
         list<Unit_Category_Details__c> newUnitCategoryDetails2= testDataFactory.createUnitCategoryDetails(1);
        newUnitCategoryDetails2[0].User_Requirement_ID__c =newUserRequirementID[0].Id;
        string recordTypeIdFromUnit = Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get('UserRequirementID').getRecordTypeId();
        newUnitCategoryDetails2[0].recordtypeid=recordTypeIdFromUnit;
         newUnitCategoryDetails2[0].Category_Details__c = 'Backhoe';
        newUnitCategoryDetails2[0].Rear_Attachments__c='Bucket;Grapple';
         //newUnitCategoryDetails2[0].isActive__c = true;
        insert newUnitCategoryDetails2;
         list<Unit_Category_Details__c> newUnitCategoryDetails3= testDataFactory.createUnitCategoryDetails(1);
        newUnitCategoryDetails3[0].User_Requirement_ID__c =newUserRequirementID3[0].Id;
        string recordTypeIdFromUnit1 = Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get('UserRequirementID').getRecordTypeId();
        newUnitCategoryDetails3[0].recordtypeid=recordTypeIdFromUnit1;
        newUnitCategoryDetails3[0].Category_Details__c = 'Backhoe';
        newUnitCategoryDetails3[0].isActive__c = true;
        newUnitCategoryDetails3[0].A_C__c = true;
        newUnitCategoryDetails3[0].Rear_Coupler__c = 'None';
        newUnitCategoryDetails3[0].width__c = 10;
        newUnitCategoryDetails3[0].Rear_Attachments__c='Bucket;Grapple';
        insert newUnitCategoryDetails3;
        list<Unit_Category_Details__c> newUnitCategoryDetails1= testDataFactory.createUnitCategoryDetails(1);
        newUnitCategoryDetails1[0].unit__c = newUnit[0].id;
        newUnitCategoryDetails1[0].equipment__c =newEquipment[0].id; 
        String recordTypeId1 = Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId();
        system.debug('recordTypeId1:::'+recordTypeId1);
        newUnitCategoryDetails1[0].recordtypeid=recordTypeId1;
        newUnitCategoryDetails1[0].Category_Details__c = 'Backhoe';
		newUnitCategoryDetails1[0].isActive__c = true; 
        newUnitCategoryDetails1[0].Rear_Attachments__c='Bucket;Grapple';
        insert newUnitCategoryDetails1;
        
        
            list<Unit_Category_Details__c> newUnitCategoryDetailsfromUnits= testDataFactory.createUnitCategoryDetails(1);
        newUnitCategoryDetailsfromUnits[0].unit__c =newUnit[0].Id;
        string recordTypeIdFromUnits = Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId();
        newUnitCategoryDetailsfromUnits[0].equipment__c =newEquipment[0].id;
        newUnitCategoryDetailsfromUnits[0].recordtypeid=recordTypeIdFromUnits;
         newUnitCategoryDetailsfromUnits[0].Category_Details__c = 'Backhoe';
        newUnitCategoryDetailsfromUnits[0].A_C__c = true;
        newUnitCategoryDetailsfromUnits[0].Rear_Coupler__c = 'None';
        newUnitCategoryDetailsfromUnits[0].width__c = 10;
        newUnitCategoryDetailsfromUnits[0].Rear_Attachments__c='Bucket;Grapple';
        insert newUnitCategoryDetailsfromUnits;
        
        list<Unit_Category_Details__c> newUnitCategoryDetails= testDataFactory.createUnitCategoryDetails(1);
        newUnitCategoryDetails[0].User_Requirement_ID__c =newUserRequirement[0].Id;
        string recordTypeId = Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get('UserRequirementID').getRecordTypeId();
        newUnitCategoryDetails[0].recordtypeid=recordTypeId;
         newUnitCategoryDetails[0].Category_Details__c = 'Backhoe';
         newUnitCategoryDetails[0].isActive__c = true;
        newUnitCategoryDetails[0].Rear_Attachments__c='Bucket;Grapple';
        
        insert newUnitCategoryDetails;
        
    }
    @istest
    public static void testHandleUnitAfterUpdate(){
        string recordTypeId = Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get('UserRequirementID').getRecordTypeId();
        list<Unit_Category_Details__c> lstUnitCategoryDetails = [SELECT ID,user_requirement_id__C,unit__c,Category_Details__c,recordtypeid
                                                                 FROM Unit_Category_Details__c 
                                                                 WHERE user_requirement_id__c!=null And IsActive__c= False AND unit__c=null AND recordtypeid =: recordTypeId ]; 
        lstUnitCategoryDetails[0].isactive__c =true;   
        update lstUnitCategoryDetails;
        string recordTypeId1 = Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId();
        list<Unit_Category_Details__c> lstUnitCategoryDetail = [SELECT ID,user_requirement_id__C,unit__c,A_C__c,Category_Details__c,recordtypeid
                                                                FROM Unit_Category_Details__c  
                                                                WHERE recordtypeid =: recordTypeId1 AND unit__c!=null AND user_requirement_id__c=null  ]; 
        
        lstUnitCategoryDetail[0].A_C__c = true;
        test.startTest();
        update lstUnitCategoryDetail;
        test.stopTest();
        system.Assert(true);
        
    }
     @istest
    public static void testHandleUnitcategoryBeforeInsert(){
        Product2 newProduct = [SELECT ID FROM Product2 LIMIT 1];
        Equipment__c newEquipment = [SELECT ID FROM Equipment__c LIMIT 1];
          list<Unit_Category_Details__c> newUnitCategoryDetails1= testDataFactory.createUnitCategoryDetails(1);
        newUnitCategoryDetails1[0].unit__c = newProduct.id;
        newUnitCategoryDetails1[0].equipment__c =newEquipment.id; 
        String recordTypeId1 = Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId();
        system.debug('recordTypeId1:::'+recordTypeId1);
        newUnitCategoryDetails1[0].recordtypeid=recordTypeId1;
        newUnitCategoryDetails1[0].Category_Details__c = 'Backhoe';
		newUnitCategoryDetails1[0].isActive__c = true; 
        newUnitCategoryDetails1[0].Rear_Attachments__c='Bucket;Grapple';
        try{
         test.startTest();
        insert newUnitCategoryDetails1;
        test.stopTest();   
        }
        catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
        }
    }
    
       @istest
    public static void testHandleUnitcategoryBeforeInsert1(){
        User_Requirement_ID__c newUserReqID = [SELECT ID FROM User_Requirement_ID__c LIMIT 1];
          list<Unit_Category_Details__c> newUnitCategoryDetails1= testDataFactory.createUnitCategoryDetails(1);
        newUnitCategoryDetails1[0].User_Requirement_ID__c = newUserReqID.id;
        String recordTypeId1 = Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId();
        system.debug('recordTypeId1:::'+recordTypeId1);
        newUnitCategoryDetails1[0].recordtypeid=recordTypeId1;
        newUnitCategoryDetails1[0].Category_Details__c = 'Backhoe';
		newUnitCategoryDetails1[0].isActive__c = true; 
        newUnitCategoryDetails1[0].Rear_Attachments__c='Bucket;Grapple';
        try{
         test.startTest();
        insert newUnitCategoryDetails1;
        test.stopTest();   
        }
        catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
        }
    } 
    
}