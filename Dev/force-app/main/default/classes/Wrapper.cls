global with sharing class Wrapper implements Comparable  {

    public sObject obj;
    
    // Constructor
    global Wrapper(sObject o) {
        obj = o;
    }
    
    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        Wrapper compareToWrapper = (Wrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if ((Decimal)obj.get('counter__c') > (Decimal)compareToWrapper.obj.get('counter__c')) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if ((Decimal)obj.get('counter__c') < (Decimal)compareToWrapper.obj.get('counter__c')) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
}