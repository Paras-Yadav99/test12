@isTest
public class UpdateOpportunityApprovalTest {
@testSetup
    public static void CreateTestData(){
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
        for(Opportunity eachOpportunity : lstOpportunity){
            eachOpportunity.StageName = 'Delivering';
        }
        insert lstOpportunity;
    }
    @isTest public static void TestUpdateOpportunityApproval(){
        UpdateOpportunityApproval newInstance = new UpdateOpportunityApproval();
        test.startTest();
        database.executeBatch(newinstance);
        test.stopTest();
    }
}