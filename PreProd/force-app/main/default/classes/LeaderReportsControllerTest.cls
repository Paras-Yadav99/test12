//this class is used to test the LeaderReportsController Class
@isTest
public class LeaderReportsControllerTest {
    
    @isTest public static void testLeaderReportsController(){
        User TestUser = TestDataFactory.createTestUser('TestFName','TestLname');
        insert TestUser;
        String QuarterActionValue;
        integer thisYear = Date.Today().Year();
        String thisMonth = System.now().format( 'MMMM' );
        if (thisMonth == 'January' || thisMonth == 'February' || thisMonth == 'March') {
            QuarterActionValue = 'Quarter 1';
        } else if (thisMonth == 'April' || thisMonth == 'May' || thisMonth == 'June') {
            QuarterActionValue = 'Quarter 2';
        } else if (thisMonth == 'July ' || thisMonth == 'August' || thisMonth == 'September') {
            QuarterActionValue = 'Quarter 3';
        } else if (thisMonth == 'October' || thisMonth == 'November' || thisMonth == 'December') {
            QuarterActionValue = 'Quarter 4';
        }
        list<Monthly_Goal_For_User__c> newMonthly_Goal_For_User = TestDataFactory.CreateLstMonthlyGoalForUser(7,TestUser.Id);
        integer counter = 0;
        for(Monthly_Goal_For_User__c eachMonthly_Goal_For_User :newMonthly_Goal_For_User){
            if(counter ==0){
                eachMonthly_Goal_For_User.Month__c = 'January';
            }else if (counter==1 || counter==2){
                eachMonthly_Goal_For_User.Month__c = 'April';
                eachMonthly_Goal_For_User.GP_Procured_Goal__c = 100;
                eachMonthly_Goal_For_User.Gross_Profit__c = 100;
                eachMonthly_Goal_For_User.Gross_Profit_Goal__c = 100;
                eachMonthly_Goal_For_User.Potential_Gross_Profit_Owned_Units__c = 100;
            }else if (counter==3){
                eachMonthly_Goal_For_User.Month__c = 'June';
                eachMonthly_Goal_For_User.GP_Procured_Goal__c = 100;
                eachMonthly_Goal_For_User.Gross_Profit__c = 80;
                eachMonthly_Goal_For_User.Gross_Profit_Goal__c = 100;
                eachMonthly_Goal_For_User.Potential_Gross_Profit_Owned_Units__c = 80;
            }else if (counter==4){
                eachMonthly_Goal_For_User.Month__c = 'October';
                eachMonthly_Goal_For_User.GP_Procured_Goal__c = 100;
                eachMonthly_Goal_For_User.Gross_Profit__c = 70;
                eachMonthly_Goal_For_User.Gross_Profit_Goal__c = 100;
                eachMonthly_Goal_For_User.Potential_Gross_Profit_Owned_Units__c = 80;
            }else if (counter==5){
                eachMonthly_Goal_For_User.Month__c = 'July';
                eachMonthly_Goal_For_User.GP_Procured_Goal__c = 100;
                eachMonthly_Goal_For_User.Gross_Profit__c = 100;
                eachMonthly_Goal_For_User.Gross_Profit_Goal__c = 100;
                eachMonthly_Goal_For_User.Potential_Gross_Profit_Owned_Units__c = 80;
            }else if (counter==6){
                eachMonthly_Goal_For_User.Month__c = 'August';
                eachMonthly_Goal_For_User.GP_Procured_Goal__c = 100;
                eachMonthly_Goal_For_User.Gross_Profit__c = 100;
                eachMonthly_Goal_For_User.Gross_Profit_Goal__c = 100;
                eachMonthly_Goal_For_User.Potential_Gross_Profit_Owned_Units__c = 80;
            }
            counter++;
            
        }
        insert newMonthly_Goal_For_User;
        
        System.Test.startTest();
        LeaderReportsController.getMonthlyUserData(thisYear,QuarterActionValue);
        LeaderReportsController.getMonthlyUserQuarterData(thisYear);
        System.Test.stopTest();
    }
    
    
    
    @isTest public static void testLeaderReportsControllerElseTest(){
        integer Year;
        System.Test.startTest();
        LeaderReportsController.getMonthlyUserData(Year,'');
        LeaderReportsController.refreshData(null);
        System.Test.stopTest();
    }
    
    @isTest public static void testLeaderReportsControllerCatchTest(){
        integer Year = Date.Today().Year();
        System.Test.startTest();
        LeaderReportsController.getMonthlyUserData(Year,'Quarter 5');
        LeaderReportsController.getMonthlyUserQuarterData(Year);
        System.Test.stopTest();
    }
    @isTest public static void testLeaderReportsRefreshDataTest(){
        integer Year = Date.Today().Year();
        System.Test.startTest();
        LeaderReportsController.refreshData(Year);
        System.Test.stopTest();
    }
    
}