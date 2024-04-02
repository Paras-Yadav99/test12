/*
This class is used to create record in DebugLog object if exception occur
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          01-April-2024         Kizzy Consulting        Pushkar               Initial Version
------------------------------------------------------------------------------------------------
*/
public class DebugLoggerController {
    public static void createCustomException(Exception ex){
        String stackTrace = ex.getStackTraceString().substringBefore('\n');
        String className = stackTrace.substringAfter('.').substringBefore('.');	
        String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
        //governor limit query
        String queryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
        String dmLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
        String dmLStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
        String cpuT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
        list<Debug_Log__c> lstInstanceOfCustomException = new list<Debug_Log__c>() ;
        Debug_Log__c instanceOfCustomException = new Debug_Log__c();
        instanceOfCustomException.StackTrace__c = ex.getStackTraceString();
        instanceOfCustomException.Exception_Message__c=ex.getMessage();
        instanceOfCustomException.Exception_Type__c = ex.getTypeName();
        instanceOfCustomException.Line_Number__c = string.valueof(ex.getLineNumber());
        instanceOfCustomException.ClassName__c = className;
        instanceOfCustomException.MethodName__c = methodName;
        instanceOfCustomException.Govt_Limit_in_Executing_Code__c = 
            String.format('{0}\n{1}\n{2}\n{3}',new List<string>{QueryLimit, DMLimit,DMLStat,CPUT});
        
        lstInstanceOfCustomException.add(instanceOfCustomException);
        SObjectAccessDecision securityDecision = Security.stripInaccessible
            (AccessType.CREATABLE, lstInstanceOfCustomException);
        insert securityDecision.getRecords();
    }
}