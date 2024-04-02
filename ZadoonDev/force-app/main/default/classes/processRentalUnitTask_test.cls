@isTest
public class processRentalUnitTask_test {
    @testsetup
    public static void testData() {
        Test.startTest();
		Contact con = TestDataFactory.createContact(true);
        Account account = new Account(Name='Test Account');
        insert account;
        Model__c model = TestDataFactory.createModel(true);
        Equipment__c equipment = TestDataFactory.createEquipment(true, model.Id);
        Product2 unit = TestDataFactory.createUnit(true, model.Id, equipment.id);
        Iron_Demand__c iron = TestDataFactory.createIronDemand(true, equipment.id, con.id);
        

           // insert unitList;
            

      	String rentalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Rental').getRecordTypeId();
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiating',recordtypeid =rentalRecordTypeId, CloseDate=Date.today(),  Model__c = '1234', AccountId = account.id);
        insert opp1;
        Rental_Unit__c rentalUnit = new Rental_Unit__c();
        rentalUnit.unit__c = unit.Id;
        rentalUnit.Opportunity__c = opp1.Id; 
        rentalUnit.Rental_Term__c = 12;
        rentalUnit.Rental_Type__c = 'Weekly';
        rentalUnit.Rental_Start_Date__c = System.Today()-7;
        rentalUnit.Rate_Approved_By__c = UserInfo.getUserId();
        insert rentalUnit;
        
        Rental_Unit__c rentalUnit1 = new Rental_Unit__c();
        rentalUnit1.unit__c = unit.Id;
        rentalUnit1.Opportunity__c = opp1.Id; 
        rentalUnit1.Rental_Term__c = 12;
        rentalUnit1.Rental_Type__c = 'Monthly';
        rentalUnit1.Rental_Start_Date__c = System.Today()-30;
        rentalUnit1.Rate_Approved_By__c = UserInfo.getUserId();
        insert rentalUnit1;
        

    }
    
    @isTest
    public static void HT_BatchCreateRenewalLeadTest() {
        Test.StartTest();
        String schTime = '0 0 12 * * ?';
        SchedulerProcessRentalUnitTask schJob = new SchedulerProcessRentalUnitTask();
        String JobId = system.schedule('updateOpportunityClosed', schTime, schJob);
        system.assertNotEquals(null,JobId);
        Database.executeBatch(new processRentalUnitTask());
        Test.stopTest();
    }
}