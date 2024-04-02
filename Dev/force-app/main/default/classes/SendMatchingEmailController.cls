public with sharing class SendMatchingEmailController {
    @AuraEnabled
    public static void SendMatchingEmailToContact(Id UnitId){
        try {
            emailUnitContactIronDemand.EmailMethod(UnitId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}