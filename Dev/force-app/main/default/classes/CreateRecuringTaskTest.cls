@isTest
public class CreateRecuringTaskTest {

    @isTest public static void TestCreateRecuringTask(){
        list<Account> lstAcc = TestDataFactory.noOfAccountToInsert(2,'Kizzy');
        
        for(Account eachAccount : lstAcc){
            eachAccount.Check_Ins__c = 'Annually';
            eachAccount.Check_Ins_Assigned_User__c = UserInfo.getUserId();
        }
        
        insert lstAcc;
        for(Account eachAccount : lstAcc){
            eachAccount.Next_Recurring_Task_Date__c = System.Today();
            
        }
        update lstAcc;
        
        test.startTest();
        ScheduleCreateRucuringTask newScheduleCreateRucuringTask = new ScheduleCreateRucuringTask();
        String sch ='0 48 * * * ?'; 
        System.schedule('Schedule to update Account Name', sch,newScheduleCreateRucuringTask);
        test.stopTest();
    }
}