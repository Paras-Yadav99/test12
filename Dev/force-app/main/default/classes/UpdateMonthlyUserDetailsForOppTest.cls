//This class is used to test UpdateMonthlyUserDetailsForOpp and UpdateMonthlyUserDetailsForOppController
@isTest
public class UpdateMonthlyUserDetailsForOppTest {
    
    @isTest public static void testUpdateMonthlyUserForOpportunity(){
        
        User TestUser = TestDataFactory.createTestUser('TestFName','TestLname');
        insert TestUser;
        list<Monthly_Goal_For_User__c> newMonthly_Goal_For_User = TestDataFactory.CreateLstMonthlyGoalForUser(1,TestUser.Id);
        insert newMonthly_Goal_For_User;
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = TestDataFactory.noOfUnitsToCreate2(2,lstEquipment[0].Id,lstAccount[0].Id);
         integer counter=0;
         for(Product2 eachProduct2 : lstProduct){
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
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
        list<Opportunity> lstOpportunitySell = testDataFactory.createOpportunity(2, lstAccount[0].id, lstProduct[0].id);
        string ProcuretmentRecordType = label.Opp_Rec_type_Dev_Name_procurement_opp ;
        list<recordType> lstRecordType ;
        if(string.isNotBlank(ProcuretmentRecordType)){
            lstRecordType = [SELECT Id,DeveloperName From RecordType Where DeveloperName =: ProcuretmentRecordType];
        }
        RecordType RecordTypeInventory_Sell ;
        if(string.isNotBlank(system.label.Opp_Rec_Type_Inventory_Sell)){
            RecordTypeInventory_Sell = [SELECT Id,DeveloperName From RecordType Where DeveloperName =: system.label.Opp_Rec_Type_Inventory_Sell LIMIT 1];
        }
        for(Opportunity eachOpportunity : lstOpportunity){
            if(lstRecordType !=null && !lstRecordType.isEmpty()){
                eachOpportunity.RecordTypeId = lstRecordType[0].id;
                eachOpportunity.CloseDate = System.today();
                eachOpportunity.stageName= 'Closed Won';
                eachOpportunity.Amount = 1000;
                eachOpportunity.OwnerId = TestUser.id;
            }
            
        }
        
        for(Opportunity eachOpportunity : lstOpportunitySell){
            eachOpportunity.Product__c = lstProduct[1].id;
            eachOpportunity.CloseDate = System.today();
            eachOpportunity.stageName= 'Closed Won';
            eachOpportunity.Amount = 1000;
            eachOpportunity.OwnerId = TestUser.id;
            lstOpportunity.add(eachOpportunity);
        }
        if(lstOpportunity !=null && !lstOpportunity.isEmpty()){
            insert lstOpportunity;
        }
        UpdateMonthlyUserDetailsForOpp batchObj_cl = new UpdateMonthlyUserDetailsForOpp(false,system.today().year());
        
        
        test.startTest();
        database.executebatch(batchObj_cl);
        test.stopTest();
    }
    @isTest
    public static void testScheduleUpdateMonthlyUserDetailsForOppYe() {
		Test.StartTest();
		ScheduleUpdateMonthlyUserDetailsForOppYe newSchedule= new  ScheduleUpdateMonthlyUserDetailsForOppYe();
        String sch = '0 0 23 * * ?';
        system.schedule('schedule taskBatch', sch, newSchedule);
		Test.stopTest();
	}
    @istest
    public static void testScheduleUpdateMonthlyUserDetailsForOppMo() {
		Test.StartTest();
		ScheduleUpdateMonthlyUserDetailsForOppMo newSchedule= new  ScheduleUpdateMonthlyUserDetailsForOppMo();
        String sch = '0 0 23 * * ?';
        system.schedule('schedule taskBatch', sch, newSchedule);
		Test.stopTest();
	}
}