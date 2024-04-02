public class EmailFileAttachments {
    public static map<string,list<ContentDocumentLink>> getAttachements(set<id> setOfOppId){
        
        map<string,list<ContentDocumentLink>> mapOfIdVsContentDecoumentLink = new map<string,list<ContentDocumentLink>>();
        map<id,ContentVersion> mapOfIdVsContentVersion = new map<id,ContentVersion>();
        List<Attachment> attachmentsToInsert = new List<Attachment>();
        list<ContentDocumentLink> lstContDoc = new List<ContentDocumentLink>();
        list<ContentVersion> lstAttachment = new List<ContentVersion>();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        List<ID> fileIDs = new List<ID>();
        
        List<ContentDocumentLink> files = new List<ContentDocumentLink>();
        List<ContentVersion> docs  = new List<ContentVersion> ();
        if((setOfOppId != null && !setOfOppId.isEmpty())){
            files = [SELECT Id, ContentDocumentId,ContentDocument.title,LinkedEntityId
                     FROM ContentDocumentLink
                     WHERE LinkedEntityId IN :setOfOppId ];
            
            
            If(files!=NULL && ! files.IsEmpty()){
                for (ContentDocumentLink docLink : files) {
                    if(!mapOfIdVsContentDecoumentLink.containskey(docLink.LinkedEntityId)){
                        mapOfIdVsContentDecoumentLink.put(docLink.LinkedEntityId,new list<ContentDocumentLink>());
                    }
                    if(mapOfIdVsContentDecoumentLink.containskey(docLink.LinkedEntityId)){
                        mapOfIdVsContentDecoumentLink.get(docLink.LinkedEntityId).add(docLink);
                    }
                    
                    fileIDs.add(docLink.ContentDocumentId);
                }
            }
        }
        return mapOfIdVsContentDecoumentLink;
    }
}