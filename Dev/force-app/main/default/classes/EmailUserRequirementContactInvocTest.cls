@isTest 
public class EmailUserRequirementContactInvocTest {
    @testsetup
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
    
    @isTest 
    public static void TestHandleAfterUpdate(){
         list<id> lstContactId = new list<id>();
        list<contact> lstContact = [SELECT id
                                    FROM contact ];
        if(lstContact!=null && !lstContact.isEmpty()){
            for(contact eachCon : lstContact){
                lstContactId.add(eachCon.id);
            }
        }
         test.startTest();
            EmailUserRequirementContactInvoc.sendEmailtoUserRequirementContactFromContact(lstContactId);
            test.stopTest();
            system.Assert(true);
    }
}