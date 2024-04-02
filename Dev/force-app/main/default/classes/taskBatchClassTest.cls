@isTest
public class taskBatchClassTest {
    @isTest static void testTaskBatchClass (){
    	list<task> lstOfTaskToInsert  = TestDataFactory.taskToInsert(1);
        insert lstOfTaskToInsert;
        
        Datetime ninetyDaysOld = Datetime.now().addDays(-91);
		Test.setCreatedDate(lstOfTaskToInsert[0].id, ninetyDaysOld);
    
        
         test.startTest();
   		 taskBatchClass newBatch = new taskBatchClass();
   		 Database.executeBatch(newBatch);
   		 test.stopTest();
    }
	@isTest public static  void testScheduleTaskBatchClass() {

		Test.StartTest();  
        scheduleTaskBatchClass newSchedule= new  scheduleTaskBatchClass();
        String sch = '0 0 23 * * ?';
        system.schedule('schedule taskBatch', sch, newSchedule);
    }
}