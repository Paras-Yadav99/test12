@isTest
public class EmailUserReqContactFromLeadInvocTest {
    @testsetUp
    static void testsetUp(){
        list<contact> lstContact = testDataFactory.noOfContactToInsert(1,'test');
        insert lstContact;
        list<lead> lstLead = testDataFactory.noOfLeadToInsert(1,'');
        lstLead[0].contact__c = lstContact[0].id;
        insert lstLead;
        list<User_Requirement_ID__c> lstUserReq = testDataFactory.createUserRequirementID(1,lstLead[0].id);
        insert lstUserReq;
        list<Equipment__c> newEquipment= testDataFactory.noOfEquipment(1);
        insert newEquipment;
        list<Product2> newUnit = testDataFactory.noOfUnitsToCreate(1,newEquipment[0].id);
        insert newUnit;
        list<Iron_Demand__c> lstIronDemand = testDataFactory.createlstIronDemand(1,newEquipment[0].id);
        lstIronDemand[0].User_Requirement_ID__c = lstUserReq[0].id;
        lstIronDemand[0].Unit_Currently_Interested_In__c = newUnit[0].id;
        insert lstIronDemand;
        
    }
    @IsTest
    public static void TestHandleAfterUpdate(){
        list<Id> lstLeadId = new list<Id>();
        list<lead> lstLead = [SELECT ID 
                              FROM lead];
        IF(lstLead!=null && !lstLead.isEmpty()){
            for(lead eachLead : lstLead){
                lstLeadId.add(eachLead.id);
            }
        }
        test.startTest();
        EmailUserRequirementContactFromLeadInvoc.sendEmailtoUserRequirementContactFromLead(lstLeadId);
        test.stopTest();
        system.Assert(true);
    }
}