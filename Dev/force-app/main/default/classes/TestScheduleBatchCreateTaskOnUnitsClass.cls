@isTest
public class TestScheduleBatchCreateTaskOnUnitsClass {

     @isTest
    public static void testSchedulableContext(){
        System.Test.startTest();
        ScheduleBatchCreateTaskOnUnitsClass instScheduleClass = new ScheduleBatchCreateTaskOnUnitsClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, instScheduleClass); 
        System.Test.stopTest();
    }
}