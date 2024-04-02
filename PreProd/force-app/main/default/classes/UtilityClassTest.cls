@isTest
public class UtilityClassTest {

    @isTest
    public static void testMethod1(){
        UtilityClass.getPicklistEntry('Account', 'AccountSource');
        UtilityClass.getAllFields('Product2');
        UtilityClass.getRelationFields('Product2');
    }
}