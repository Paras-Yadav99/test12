public class ConvertCaseToLead {
    public static Set<String> workingStatus = new Set<String>{'Replied', 'On Hold', 'Waiting on Unit Info from Seller'};
    public static Set<String> nurturingStatus = new Set<String>{'Escalated'};
    public static Set<String> newStatus = new Set<String>{'New'};
    public static final String DEFAULT_NAME = 'not provided';

    public static void run(List<Case> cases){
        List<Lead> leadsToInsert = new List<Lead>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Map<Id, Product2> unitMap = new Map<Id, Product2>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> unitIds = new Set<Id>();

        for(Case caseObj : cases){
            if(caseObj.ContactId != null){
                contactIds.add(caseObj.ContactId);
            }
            if(caseObj.UnitCase__c != null){
                unitIds.add(caseObj.UnitCase__c);
            }
        }

        contactMap = new Map<Id,Contact>([SELECT Id, 
                                                Phone,
                                                MobilePhone,
                                                LastName, 
                                                FirstName,
                                                AccountId,
                                                Account.Name,
                                                MailingPostalCode,
                                                MailingCountry, 
                                                MailingState
                                        FROM Contact 
                                        WHERE Id IN :contactIds]); 

    
        unitMap = new Map<Id,Product2>([
            SELECT Id, Account__c FROM Product2 WHERE Id IN :unitIds
        ]);
               
        for(Case caseObj : cases){
            Lead lead = new Lead();
            lead.CaseId__c = caseObj.Id;
            lead.Description__c = caseObj.Description;
            lead.Subject__c = caseObj.Subject;
            lead.Company = DEFAULT_NAME;
            lead.Status = getLeadStatus(caseObj);
            lead.OwnerId = isOwnedByQueue(caseObj.OwnerId) ? getOwner() : caseObj.OwnerId;
            lead.lastName = DEFAULT_NAME;
            lead.Email = caseObj.ContactEmail;
            lead.Account__c = caseObj.AccountId;
            if(caseObj.ContactId != null && contactMap.get(caseObj.ContactId) != null){
                Contact contactFromCase = contactMap.get(caseObj.ContactId);
                
                lead.Account__c = contactFromCase.AccountId != null ? contactFromCase.AccountId : null;
                lead.Company = contactFromCase.Account.Name != null ? contactFromCase.Account.Name : DEFAULT_NAME;
                lead.PostalCode = contactFromCase.MailingPostalCode != null ? contactFromCase.MailingPostalCode : null;
                lead.State = contactFromCase.MailingState != null ? contactFromCase.MailingState : null;
                lead.Country = contactFromCase.MailingCountry != null ? contactFromCase.MailingCountry : null;
                lead.Phone = contactFromCase.Phone != null ? contactFromCase.Phone : null;
                lead.MobilePhone  = contactFromCase.MobilePhone  != null ? contactFromCase.MobilePhone  : null;
                lead.Contact__c = contactFromCase.Id != null ? contactFromCase.Id : null;
                lead.LastName = String.isNotBlank(contactFromCase.LastName) ? contactFromCase.LastName : DEFAULT_NAME;
                lead.FirstName = String.isNotBlank(contactFromCase.FirstName) ? contactFromCase.FirstName : '';
            }

            if(caseObj.UnitCase__c != null && unitMap.get(caseObj.UnitCase__c) != null){
                Product2 unitFromCase = unitMap.get(caseObj.UnitCase__c);
                lead.Unit__c = unitFromCase.Id != null ? unitFromCase.Id : null;
                lead.Unit_Owner__c = unitFromCase.Account__c != null ? unitFromCase.Account__c : null;
            }

            leadsToInsert.add(lead);
        }

        if(leadsToInsert.size() > 0){
            insert leadsToInsert;
        }

    }

    private static String getLeadStatus(Case caseObj){
        if(workingStatus.contains(caseObj.Status)){
            return 'Working';
        } else if(nurturingStatus.contains(caseObj.Status)){
            return 'Nurturing';
        } else if(newStatus.contains(caseObj.Status)){
            return 'New';
        } else {
            return caseObj.Opportunity_Related_To__c != null ? 'Qualified' : 'Unqualified';
        }
    }

    private static Boolean isOwnedByQueue(Id ownerId){
        String objName = ownerId.getSobjectType().getDescribe().getName();
        return objName == 'Group';
    }

    private static Id getOwner(){
        Id userId = UserInfo.getUserId();
        List<User> lauraUser = [SELECT Id, Name FROM User WHERE UserName = :System.Label.LauraUserName LIMIT 1];
        if(lauraUser[0] != null){
            userId = lauraUser[0].Id;
        }

        return userId;
    }
}