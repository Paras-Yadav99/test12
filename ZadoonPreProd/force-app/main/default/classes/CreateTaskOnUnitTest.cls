@isTest 
public class CreateTaskOnUnitTest {
    @isTest public static void testCreateTaskOnUnit(){
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate(1, lstEquipment[0].id);
        for(Product2 eachProduct2 : lstProduct){
            eachProduct2.isActive = true;
        }
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
    
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
        //string recordtypeid =Schema.SObjectType.Account.getRecordTypeInfosByName().get('record type name').getRecordTypeId();
        for(opportunity eachOpportunity : lstOpportunity){
            eachOpportunity.Market_on_FB_Group__c = true; 
            eachOpportunity.StageName = 'Proactive Brokerage';
        }
        insert lstOpportunity;
        
        test.startTest();
        CreateTaskOnUnit newCreateTaskOnUnit = new CreateTaskOnUnit();
        database.executeBatch(newCreateTaskOnUnit);
        test.stopTest();
    }
    public static testMethod void testschedule() {

        Test.StartTest();
        ScheduleCreateTasksOnUnit sh1 = new ScheduleCreateTasksOnUnit();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    }
}