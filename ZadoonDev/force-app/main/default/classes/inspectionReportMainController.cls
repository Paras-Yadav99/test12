public without sharing class inspectionReportMainController {
    public class lineitems {
        @AuraEnabled public String lineItemTitle {
            get;
            set;
        }
        @AuraEnabled public String lineItemValue {
            get;
            set;
        }
        @AuraEnabled public Boolean isPicklist {
            get;
            set;
        }
        @AuraEnabled public List < picklistValue > options {
            get;
            set;
        }
        public lineitems(String title, String StringOptParm) {
            this.lineItemTitle = title;
            this.lineItemValue = '-';
            this.isPicklist = false;
            if (!String.isBlank(StringOptParm)) {
                this.isPicklist = true;

            }
            this.options = setupOptions(StringOptParm);
        }
    }

    public static List < picklistValue > setupOptions(String optionString) {
        List < picklistValue > wrapperOptions = new List < picklistValue > ();
        if (!String.isBlank(optionString)) {
            for (String optionsLabel: optionString.split(';')) {
                picklistValue obj = new picklistValue(optionsLabel);
                wrapperOptions.add(obj);
            }

        }

        return wrapperOptions;
    }

    public class picklistValue {
        @AuraEnabled public String label {
            get;
            set;
        }
        @AuraEnabled public String value {
            get;
            set;
        }
        public picklistValue(String label) {
            this.label = label;
            this.value = label;
        }

    }

    public class dataWrapper {
        @AuraEnabled public String tableHeader {
            get;
            set;
        }
        @AuraEnabled public Boolean isTextArea {
            get;
            set;
        }
        @AuraEnabled public List < lineitems > lstLineItems {
            get;
            set;
        }
        public dataWrapper(String header, List < Inspection_Report_Header_Line_Item__c > lstLineItems, String type) {
            this.tableHeader = header;
            this.lstLineItems = setupLineItems(lstLineItems);
            this.isTextArea = false;
            if (type == 'Text Area') {
                this.isTextArea = true;

            }
        }
    }
    public static List < lineitems > setupLineItems(List < Inspection_Report_Header_Line_Item__c > lstLineItems) {
        List < lineitems > wrapperDataLineItems = new List < lineitems > ();
        for (Inspection_Report_Header_Line_Item__c lineItemTitle: lstLineItems) {
            lineitems obj = new lineitems(lineItemTitle.Inspection_Report_Header_Line_Item_Name__c, lineItemTitle.Picklist_Values__c);
            wrapperDataLineItems.add(obj);
        }
        return wrapperDataLineItems;
    }
    @AuraEnabled
    //public static LightningResponse handleSaveData(String headerData,String unitData,String unitId,string filesToInsert,String newRecordId){
    public static AuraResponse handleSaveData(String headerData, String unitData, String unitId, String newRecordId) {
        AuraResponse response;
        try {
            if (string.isNotBlank(unitId)) {
                Inspection_Report__c objToCreate = new Inspection_Report__c();
                objToCreate.Header_Data__c = headerData;
                objToCreate.Unit_JSON__c = unitData;
                objToCreate.Unit__c = unitId;
                objToCreate.Status__c = 'Submitted';
                if (string.isNotBlank(newRecordId)) {
                    objToCreate.Id = newRecordId;
                    update objToCreate;
                } else {
                    insert objToCreate;
                }
                response = new AuraResponse(true, 'Success', 'Inspection Report has been created successfully.');
            } else {
                response = new AuraResponse(false, 'Unit Id not found', null);
            }
        } catch (exception ex) {
            response = new AuraResponse(false, ex.getMessage() + ' ' + ex.getStackTraceString(), ex.getStackTraceString());
        }
        return response;
    }

    @AuraEnabled
    public static LightningResponse uploadFile(string filesToInsert, String recordId) {
        system.debug('fileUploadfun::' + filesToInsert);
        LightningResponse response = new LightningResponse();
        List < ContentVersion > lstVersionsToInsert = new List < ContentVersion > ();
        set < id > setContentVersionId = new set < id > ();
        list < ContentDocumentLink > lstContentDocumentLink = new list < ContentDocumentLink > ();
        Set < Id > setContentDocumentLink = new Set < Id > ();
        map < id, id > mapContentVersionIdVsContentDocumentLink = new map < id, id > ();
        try {
            if (string.isNotblank(filesToInsert)) {
                //list<FileInfo> fileData = new list<FileInfo>();
                //lstFileInfo fileData = (lstFileInfo)JSON.deserialize(filesToInsert, lstFileInfo.class);
                list < DataWrapper1 > fileData = (list < DataWrapper1 > ) JSON.deserialize(filesToInsert, list < DataWrapper1 > .class);
                system.debug('fileData::' + fileData);
                system.debug('fileData::' + fileData.size());
                // List<Map<String, Object>> originalData = new List<Map<String, Object>>();
                system.debug('fileData:' + fileData);
                //fileData.add(fileData1);
                for (DataWrapper1 eachFileInfo: fileData) {
                    //Upload File Into Folder
                    GoogleApi.uploadFileWithBase64(eachFileInfo.fileName, eachFileInfo.base64, 'folderId');

                    //ContentVersion cv = createContentVersion(eachFileInfo.base64, eachFileInfo.filename);
                    // lstVersionsToInsert.add(cv);
                }

                /* if(lstVersionsToInsert!=null && !lstVersionsToInsert.isEmpty() ) {
                     insert lstVersionsToInsert;
                     
                     if(lstVersionsToInsert!=null && !lstVersionsToInsert.isEmpty() ) {
                         for (ContentVersion eachContentVersion : lstVersionsToInsert) {
                             setContentVersionId.add(eachContentVersion.id);
                         }
                         if(setContentVersionId!=null && !setContentVersionId.isEmpty() ){
                             lstContentDocumentLink = createContentLink(setContentVersionId,recordId);
                         }
                         
                         if (lstContentDocumentLink != null && !lstContentDocumentLink.isEmpty() ) { 
                             insert lstContentDocumentLink;
                             for(ContentDocumentLink obj : lstContentDocumentLink){
                                 setContentDocumentLink.add(obj.Id);

                             }
                             response.bIsSuccess = true;
                             response.put('setContentDocumentLink',setContentDocumentLink);
                             //AuraResponse = new AuraResponse(true, 'SUCCESS', JSON.serialize(lstContentDocumentLink));
                             
                         } else {
                             //AuraResponse = new AuraResponse(false, 'ERROR', 'Something went wrong while creating content document link!');
                         }
                     }
                     
                 } else {
                     //AuraResponse = new AuraResponse(false, 'ERROR', 'Something went wrong while creating content version!');
                 }*/
            } else {
                //AuraResponse = new AuraResponse(false, 'ERROR', 'file , filename or recordId not found!');
            }

        } catch (Exception e) {
            response.put('Error', e.getMessage());
            // AuraResponse = new AuraResponse(false, 'ERROR', e.getMessage());
        }
        system.debug('response::' + response);
        return response;
    }

    /*private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        system.debug('base64'+base64  );
        system.debug('EncodingUtil.base64Decode(base64)'+EncodingUtil.base64Decode(base64));
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        return cv;
    }*/

    /*private static list<ContentDocumentLink> createContentLink(set<id> setContentVersionId,String recordId) {
        list<ContentDocumentLink> lstContentDocumentLink = new list<ContentDocumentLink>();
        if (setContentVersionId == null ) {
            return null; 
        }
        
        list<ContentVersion> lstContentVersion =  [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: setContentVersionId];
        for (ContentVersion eachContentVersion : lstContentVersion){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId =eachContentVersion.ContentDocumentId ;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            lstContentDocumentLink.add(cdl);
        }
        return lstContentDocumentLink;
    }*/

    @AuraEnabled
    public static LightningResponse createIntialData(Id parmValue) {
        LightningResponse response = new LightningResponse();
        try {

            Inspection_Report__c newRecord = new Inspection_Report__c();
            newRecord.Status__c = 'Not Submitted';
            insert newRecord;
            response.bIsSuccess = true;
            response.put('newRecord', newRecord.Id);

        } catch (Exception ex) {
            response.bIsSuccess = false;
            response.put('Error', ex.getMessage());
        }
        return response;
    }

    @AuraEnabled(cacheable = true)
    public static LightningResponse getIntialData(Id parmValue) {
        LightningResponse response = new LightningResponse();
        String sObjName;
        try {
            List < dataWrapper > sortedResult = new List < dataWrapper > ();
            List < dataWrapper > photoSortedResult = new List < dataWrapper > ();
            if (parmValue != null) {
                sObjName = parmValue.getSObjectType().getDescribe().getName();
                response.bIsSuccess = true;
                response.put('objectName', sObjName);
                if (sObjName == 'Product2') {
                    List < Product2 > selectedProd = [Select Id, category__c, ZID__c, Hour__c, Serial_Number__c, VIN__c, Make__c, Storage_City__c,
                        Storage_State__c, Storage_Country__c, Storage_Address__c, Inspection_Folder_Link__c,
                        Storage_Zip_Code__c, Site_Contact__c, Site_Contact_Mobile__c,
                        equipment__r.Name from product2 where Id =: parmValue
                    ];
                    String unitCategory = selectedProd[0].category__c;
                    response.put('unitType', unitCategory);
                    response.put('unitZid', selectedProd[0].ZID__c);
                    response.put('unitData', selectedProd[0]);
                    Map < Id, Inspection_Report_Header__c >
                        mapInspectionHeader = new Map < ID, Inspection_Report_Header__c > ([SELECT Id, Name, unit_Record_type__c, Type__c, order__c FROM Inspection_Report_Header__c where
                            unit_Record_type__c =: unitCategory and(Type__c = 'List'
                                OR Type__c = 'Text Area') order by order__c
                        ]);
                    List < Inspection_Report_Header_Line_Item__c > lstHeaderLineItem = [Select Id, Name, Inspection_Report_Header__c, Inspection_Report_Header__r.Name, Picklist_Values__c, Order__c,
                        Inspection_Report_Header__r.Type__c, Inspection_Report_Header_Line_Item_Name__c from Inspection_Report_Header_Line_Item__c
                        where Inspection_Report_Header__c in: mapInspectionHeader.keyset()
                        order by Order__c
                    ];
                    Map < String, List < Inspection_Report_Header_Line_Item__c >> mapData = new Map < String, List < Inspection_Report_Header_Line_Item__c >> ();
                    map < String, String > mapHeaderName = new map < String, String > ();
                    for (Inspection_Report_Header_Line_Item__c obj: lstHeaderLineItem) {
                        if (!mapData.containskey(obj.Inspection_Report_Header__r.Name)) {
                            mapData.put(obj.Inspection_Report_Header__r.Name, new List < Inspection_Report_Header_Line_Item__c > ());
                            mapHeaderName.put(obj.Inspection_Report_Header__r.Name, obj.Inspection_Report_Header__r.Type__c);
                        }
                        List < Inspection_Report_Header_Line_Item__c > lst = mapData.get(obj.Inspection_Report_Header__r.Name);
                        lst.add(obj);
                        mapData.put(obj.Inspection_Report_Header__r.Name, lst);
                    }
                    for (String headerName: mapData.keySet()) {
                        dataWrapper obj = new dataWrapper(headerName, mapData.get(headerName), mapHeaderName.get(headerName));
                        sortedResult.add(obj);
                    }

                    response.put('dataTable', mapInspectionHeader);
                    response.put('dataWapper', sortedResult);

                    Map < Id, Inspection_Report_Header__c >
                        mapInspectionHeader1 = new Map < ID, Inspection_Report_Header__c > ([SELECT Id, Name, unit_Record_type__c, Type__c FROM Inspection_Report_Header__c where
                            unit_Record_type__c =: unitCategory and Type__c = 'Photo'
                        ]);

                    List < Inspection_Report_Header_Line_Item__c > lstHeaderLineItem1 = [Select Id, Name, Inspection_Report_Header__c, Inspection_Report_Header_Line_Item_Name__c, Inspection_Report_Header__r.Name, Picklist_Values__c, Inspection_Report_Header__r.Type__c from Inspection_Report_Header_Line_Item__c
                        where Inspection_Report_Header__c in: mapInspectionHeader1.keyset()
                    ];

                    Map < String, List < Inspection_Report_Header_Line_Item__c >> mapData1 = new Map < String, List < Inspection_Report_Header_Line_Item__c >> ();
                    map < String, String > mapHeaderName1 = new map < String, String > ();
                    for (Inspection_Report_Header_Line_Item__c obj: lstHeaderLineItem1) {
                        if (!mapData1.containskey(obj.Inspection_Report_Header__r.Name)) {
                            mapData1.put(obj.Inspection_Report_Header__r.Name, new List < Inspection_Report_Header_Line_Item__c > ());
                            mapHeaderName1.put(obj.Inspection_Report_Header__r.Name, obj.Inspection_Report_Header__r.Type__c);
                        }
                        List < Inspection_Report_Header_Line_Item__c > lst = mapData1.get(obj.Inspection_Report_Header__r.Name);
                        lst.add(obj);
                        mapData1.put(obj.Inspection_Report_Header__r.Name, lst);
                    }
                    for (String headerName: mapData1.keySet()) {
                        dataWrapper obj = new dataWrapper(headerName, mapData1.get(headerName), mapHeaderName1.get(headerName));
                        photoSortedResult.add(obj);
                    }

                    response.put('dataPhotoWapper', photoSortedResult);

                } else if (sObjName == 'Inspection_Report__c') {
                    List < Inspection_Report__c > lstInspectRecord = [Select Id, Header_Data__c, Unit_JSON__c from Inspection_Report__c
                        where Id =: parmValue
                    ];
                    response.put('dataTable', lstInspectRecord[0]);

                }

            }

        } catch (Exception ex) {
            response.bIsSuccess = false;
            response.put('Error', ex.getMessage());

        }
        return response;

    }

    public class DataWrapper1 {
        public String filename {
            get;
            set;
        }
        public String base64 {
            get;
            set;
        }

        public DataWrapper1(String filename, String base64) {
            this.filename = filename;
            this.base64 = base64;
        }
    }
    /*
    @AuraEnabled
    public static LightningResponse sendEmailToUser(String emailId,String productId){
        LightningResponse response = new LightningResponse();
        try{
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            List<String> contactEmails = new List<String>();
            contactEmails.add(emailId);
            System.debug('ff'+productId);
            
            message.toAddresses = contactEmails;
            message.optOutPolicy = 'FILTER';
            message.subject = 'Zadoon : Unit Inspection Link';
            String htmlBody = 'https://dev-backhoeinspection.cs27.force.com/?parm1=';
            htmlBody += productId;
            message.htmlBody = htmlBody;
            
            Messaging.SingleEmailMessage[] messages = 
                new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                             + results[0].errors[0].message);
            }
            
            
        }
        catch(exception ex){
            
        }
        
        response.bIsSuccess = true;
        return response;
        
    }*/

    Public class AuraResponse {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public string message;
        @AuraEnabled public string response;

        AuraResponse(Boolean isSuccess,
            String message,
            String response) {

            this.isSuccess = isSuccess;
            this.message = message;
            this.response = response;
        }
    }
    ////////// Adding Google Drive Method ////////////
    @AuraEnabled
    public static AuraResponse getTokenFromAuthProvider(String authProviderName) {
        try {
            if (String.isBlank(authProviderName)) {
                return new AuraResponse(false, 'Auth provider name can\'t be empty.', null);
            }
            List < AuthProvider > authProviderInfo = [SELECT Id, ProviderType FROM AuthProvider WHERE DeveloperName =: authProviderName];
            if (authProviderInfo.isEmpty()) {
                return new AuraResponse(false, 'Auth provider not found.', null);
            }
            String token = '';
            Map < String, String > responseMap = new Map < String, String > ();
            if (authProviderInfo[0].ProviderType == 'Google') {
                String oldToken = Auth.AuthToken.getAccessToken(authProviderInfo[0].Id, 'Google');
                responseMap = Auth.AuthToken.refreshAccessToken(authProviderInfo[0].Id, 'Google', oldToken);
            }
            if (String.isNotBlank(responseMap.get('RefreshError'))) {
                return new AuraResponse(false, responseMap.get('RefreshError'), null);
            }
            if (String.isNotBlank(responseMap.get('AccessToken'))) {
                token = responseMap.get('AccessToken');
            }
            if (String.isBlank(token)) {
                return new AuraResponse(false, 'Token can\'t be empty.', null);
            }
            return new AuraResponse(true, 'Success', token);
        } catch (Exception ex) {
            return new AuraResponse(false, ex.getMessage(), ex.getStackTraceString());
        }
    }
}