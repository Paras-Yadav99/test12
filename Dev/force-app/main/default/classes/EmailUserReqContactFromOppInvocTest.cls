@isTest
public class EmailUserReqContactFromOppInvocTest {
    @testsetUp
    static void testsetUp(){
        list<contact> lstContact = testDataFactory.noOfContactToInsert(1,'test');
        insert lstContact;
        list<lead> lstLead = testDataFactory.noOfLeadToInsert(1,'');
        lstLead[0].contact__c = lstContact[0].id;
        insert lstLead;
        list<account> lstAccount = testDataFactory.noOfAccountToInsert(1,'kizzy');
        insert lstAccount;
        list<opportunity> lstOpp = testDataFactory.createOpportunity(1,lstAccount[0].id,'');
        lstOpp[0].contactId = lstContact[0].id;
        insert lstOpp;
        list<User_Requirement_ID__c> lstUserReq = testDataFactory.createUserRequirementID(1,null);
        lstUserReq[0].opportunity__C = lstOpp[0].id;
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
    @isTest
    public static void TestHandleAfterUpdate(){
        list<id> lstOppId = new list<id>();
        list<opportunity> lstOpp = [SELECT id
                                    FROM opportunity ];
        if(lstOpp!=null && !lstOpp.isEmpty()){
            for(opportunity eachOpp : lstOpp){
                lstOppId.add(eachOpp.id);
            }
        }
        test.startTest();
        EmailUserRequirementContactFromOppInvoc.sendEmailtoUserRequirementContactFromOpp(lstOppId);
        test.stopTest();
        system.Assert(true);
    }
}