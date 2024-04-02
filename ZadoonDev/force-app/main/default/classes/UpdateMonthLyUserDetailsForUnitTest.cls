//This Class is used to test Batch: UpdateMonthLyUserDetailsForUnit and Batch Controller : UpdateMonthlyUserDetailForUnitController
@isTest
public class UpdateMonthLyUserDetailsForUnitTest {
    
     @isTest public static void testUpdateMonthlyUserForUnits(){
        list<Product2>lstProduct = new list<Product2>();
        User TestUser = TestDataFactory.createTestUser('TestFName','TestLname');
        insert TestUser;
        list<Monthly_Goal_For_User__c> newMonthly_Goal_For_User = TestDataFactory.CreateLstMonthlyGoalForUser(1,TestUser.Id);
        insert newMonthly_Goal_For_User;
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'Zadoon, LLC');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstTestProduct = TestDataFactory.noOfUnitsToCreate2(2,lstEquipment[0].Id,lstAccount[0].Id);
         integer counter=0;
         for(Product2 eachProduct2 : lstTestProduct){
             if(counter==0){
                eachProduct2.Inventory_Status__c ='Owned'; 
                 counter ++;
             }else{
                 eachProduct2.Inventory_Status__c ='Brokerage';  
             }
             eachProduct2.IsActive = true ;
             eachProduct2.Zadoon_s_Final_Purchase_Price__c = 100;
             eachProduct2.Unit_Owner__c = TestUser.id;
             eachProduct2.CreatedAt__c =  System.today();
           	 eachProduct2.Purchase_Date__c= System.today().addDays(-2);
        	 eachProduct2.Sold_Deactivated_Date__c= System.today().addDays(-3);
         }
        insert lstTestProduct;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
         
         
        UpdateMonthLyUserDetailsForUnit batchObj_cl = new UpdateMonthLyUserDetailsForUnit(false);
        test.startTest();
        database.executebatch(batchObj_cl);
        test.stopTest();
     }
    
    @isTest
    public static void testScheduleUpdateMonthLyUserDetailsForUnitY() {
		Test.StartTest();
		ScheduleUpdateMonthLyUserDetailsForUnitY newSchedule= new  ScheduleUpdateMonthLyUserDetailsForUnitY();
        String sch = '0 0 23 * * ?';
        system.schedule('schedule taskBatch', sch, newSchedule);
		Test.stopTest();
	}
    @isTest
    public static void testScheduleUpdateMonthLyUserDetailsForUnitM() {
		Test.StartTest();
		ScheduleUpdateMonthLyUserDetailsForUnitM newSchedule= new  ScheduleUpdateMonthLyUserDetailsForUnitM();
        String sch = '0 0 23 * * ?';
        system.schedule('schedule taskBatch', sch, newSchedule);
		Test.stopTest();
	}

}