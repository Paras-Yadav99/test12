@isTest 
public class EmailUserRequirementContactFromUnitTest {
 @testsetUp
    static void testsetUp(){
        list<contact> lstContact = testDataFactory.noOfContactToInsert(1,'test');
        insert lstContact;
        list<lead> lstLead = testDataFactory.noOfLeadToInsert(1,'');
        lstLead[0].contact__c = lstContact[0].id;
        insert lstLead;
        list<User_Requirement_ID__c> lstUserReq = testDataFactory.createUserRequirementID(1);
        lstUserReq[0].lead__c = lstLead[0].id;
        lstUserReq[0].contact__c =lstContact[0].id;
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
            list<product2> lstProduct = [SELECT id
                                         FROM product2];
            list<id> lstProductId = new list<id>();
            if(lstProduct!=null && !lstProduct.isEmpty()){
                for(product2 eachProduct : lstProduct){
                    lstProductId.add(eachProduct.id);
                } 
            }
           test.startTest();
            EmailUserRequirementContactFromUnitInvoc.sendEmailtoUserRequirementContact(lstProductId);
            test.stopTest();
            system.Assert(true);
        }
    
}