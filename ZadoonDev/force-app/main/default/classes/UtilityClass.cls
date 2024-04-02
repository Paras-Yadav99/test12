public without sharing class UtilityClass {
    
    public static final String ERROR_MSG = 'Database error occured, Please reach out to your system admin!';
    public static final String EMAIL_SUCCESS_MSG = 'Email sent successfully!';
    public static final String EMAIL_ERROR_MSG = 'Error while sending emails, Please reach out to your system admin!';
    public static final String EMAIL_MISSING = 'Contact(s) email address is missing!';
    public static boolean runOnce = true;
    public static boolean runUnitRelatedTranactionTrigger_Once = true;
    public static OrgWideEmailAddress[] owea = [SELECT Id,Address FROM OrgWideEmailAddress where Address = :userinfo.getUserEmail()];//label.From_Email_Address
    
    public static List< SelectOption > getPicklistEntry(String objectName, String fieldName) {
        List< SelectOption > categoryOptions = new List< SelectOption >();
        categoryOptions.add(new SelectOption('','--None--'));
        Map< String,Schema.SObjectField > fields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        for( Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
            categoryOptions.add(new SelectOption(pickListVal.value,pickListVal.label));
        }
        System.debug('categoryOptions ==> '+categoryOptions);
        return categoryOptions;
    }
    
   /* public static String formEmailBody( Map< Id, WrapperClass > mapHoldingSelectedRecords ){
        User u = [Select Id, Name, Title,MobilePhone from User where Id = :UserInfo.getUserId() LIMIT 1];
        String body = '<table border="2" cellspacing="2" style="table-layout: auto; font-family: arial, sans-serif;border-collapse: collapse;width: 100%;"><tr style="border: none;text-align:left; background-color:#ff8c00; white-space: nowrap;" height="25"><th>Product Name</th><th>Make</th><th>Model</th><th>Year</th></tr>';
        for(Id proId : mapHoldingSelectedRecords.keySet()){
            String name = mapHoldingSelectedRecords.get(proId).pro.Name; if(mapHoldingSelectedRecords.get(proId).pro.Name == null) name = 'N/A';
            String make = mapHoldingSelectedRecords.get(proId).pro.Manufacturer__c; if(mapHoldingSelectedRecords.get(proId).pro.Manufacturer__c == null) make = 'N/A';
            String model = mapHoldingSelectedRecords.get(proId).pro.Model__c; if(mapHoldingSelectedRecords.get(proId).pro.Model__c == null) model = 'N/A';
            String year = mapHoldingSelectedRecords.get(proId).pro.Year__c; if(mapHoldingSelectedRecords.get(proId).pro.Year__c == null) year = 'N/A';
            body += '<tr style="border: 2px solid #dddddd; white-space: nowrap;border-right: solid 2px #dddddd; border-left: solid 2px #dddddd;"><td style="width:100px;">' +name+ '</td><td style="width:100px;">' + make + '</td><td style="width:100px;">' + model + '</td><td style="width:100px;">' + year + '</td></tr>';
            
        }
        body += '</table><br/><br/>';
        body += 'Regards,<br/>Zadoon<br/>'; 
        body += 'Name: '+u.Name+'<br/>';
        body += 'Title: '+u.Title+'<br/>';
        body += 'Mobile: '+u.MobilePhone+'<br/>';
        body += 'Main Office: +1-844-512-5055';
        return body;
    }*/
    
    // public method used to form email body dynamically
    
    /*public static String formEmailBody( List< Iron_Demand_Unit__c > ironDemandUnits,Integer recCount ) {
        EmailTemplate template = [Select id,Subject,Body,HtmlValue From EmailTemplate Where developerName='Iron_Demand_Unit_24_hour_Email' LIMIT 1];
        system.debug(' template Id '+ template.id);
        User usr = [Select id,Name,Title,MobilePhone From User Where Id =:userInfo.getUserId()];
        String body = '';
        String htmlTable = '<table border="2" cellspacing="2" style="font-family: arial, sans-serif;border-collapse: collapse;width: 100%;"> <thead><tr style="border: none;text-align: left;background-color:#ff8c00; white-space: nowrap;" height="25">';
        htmlTable += '<th>Product Name</th><th>Make</th><th>Model</th><th>Year</th><th>Hours</th><th>Location</th><th>ZID</th><th>Google Drive Photo Link</th><th>Google Drive Videos Link</th></tr></thead>';
        for(Iron_Demand_Unit__c iron : ironDemandUnits){
            String make = iron.Unit__r.Manufacturer__c;   if(iron.Unit__r.Manufacturer__c == null) make = 'N/A';
            String model = iron.Unit__r.Model__c; if(iron.Unit__r.Model__c == null) model = 'N/A';
            String year = iron.Unit__r.Year__c;   if(iron.Unit__r.Year__c == null) year = 'N/A';
            String hours = String.valueOf(iron.Unit__r.Hour__c);  if(iron.Unit__r.Hour__c == null) hours = 'N/A';
            String location = iron.Unit__r.Displayed_Vague_Location__c;  if(iron.Unit__r.Displayed_Vague_Location__c == null) location = 'N/A';
            String unit_Details = iron.Unit__r.Old_SF_Unit_Details__c;   if(iron.Unit__r.Old_SF_Unit_Details__c == null) unit_Details = 'N/A';
            String zid = iron.Unit__r.ZID__c; if(iron.Unit__r.ZID__c == null) zid = 'N/A';
            String photo_link = iron.Unit__r.Google_Drive_LInk__c; if(iron.Unit__r.Google_Drive_LInk__c == null) photo_link = 'Pictures coming soon';
            String video_link = iron.Unit__r.Google_Drive_Videos_Link__c; if(iron.Unit__r.Google_Drive_Videos_Link__c == null) video_link = 'Videos currently not available';
            if(recCount <= 5) {
                body += '<ul style="list-style-type:square"><li style="font-weight: bold; font-size: 16px;">'+iron.Unit__r.Name+'</li></ul>';
                body += '<li><b>Make:</b>'+ make +'</li><li><b>Model:</b>'+ model +'</li><li><b>Year:</b>'+ year +'</li>';
                body += '<li><b>Hours: </b>'+ hours +'</li><li><b>Location: </b>'+ location +'</li>';
                body += '<li><b>Unit Details: </b>'+unit_Details+'</li><li><b>ZID: </b>'+zid+'</li>';
                body += '<li><b>Google Drive photos link:</b> <a href='+photo_link+'>Go to Drive photos</a></li>';
                body += '<li><b>Google Drive videos link:</b> <a href='+video_link+'>Go to Drive video</a></li>';
                body += '<hr>';
            } else {
                htmlTable += '<tbody><tr style="border: 2px solid #dddddd; white-space: nowrap;border-right: solid 2px #dddddd; border-left: solid 2px #dddddd; "><td style="width:100px;">'+iron.Unit__r.Name+'</td><td style="width:100px;">'+ make +'</td><td style="width:100px;">' +model+ '</td><td style="width:100px;">' +year+ '</td><td style="width:100px;">' +hours+ '</td><td style="width:100px;">' +location+ '</td>';
                htmlTable += '<td style="width:100px;">' +zid+ '</td><td style="width:100px;"> <a href=' +photo_link+ '>Go to Drive photos</a></td><td> <a href=' +video_link+ '>Go to Drive video</a></td></tr></tbody>';
            }
        }
        htmlTable += '</table>';
        if(recCount <= 5) {
            template.HTMLValue = template.HTMLValue.replace('{!dynamic}', body);
        } else {
            template.HTMLValue = template.HTMLValue.replace('{!dynamic}', htmlTable);
        }
        if(recCount > 1) template.HTMLValue = template.HTMLValue.replace('machine', 'machines');
        String contName ='';
        if (ironDemandUnits[0].Iron_Demand__r.IronDemand_Contact__r.FirstName != null){
            contName = ironDemandUnits[0].Iron_Demand__r.IronDemand_Contact__r.FirstName;
        } else if(ironDemandUnits[0].Iron_Demand__r.IronDemand_Contact__r.LastName != null) {
            contName = contName = ironDemandUnits[0].Iron_Demand__r.IronDemand_Contact__r.LastName;
        }
        template.HTMLValue = template.HTMLValue.replace('{!Iron_Demand_Unit__c.OwnerFirstName}', contName);
        template.HTMLValue = template.HTMLValue.replace('{!User.Name}', usr.Name);
        template.HTMLValue = template.HTMLValue.replace('{!User.Title}', usr.Title != null ? usr.Title : 'N/A');
        template.HTMLValue = template.HTMLValue.replace('{!User.MobilePhone}', usr.MobilePhone != null ? usr.MobilePhone : 'N/A');
        return template.HTMLValue;
    }*/
    
    // public method that get all the fields from sObject
    public static List<String> getAllFields(String sObjectName){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        List<String> field = new List<String>(fieldMap.keySet());
        return field;
    }
    
    // public method that get all the fields of parent sObject
    public static List<String> getRelationFields(String sObjectName){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        for(String fieldName: fieldMap.keySet()) {  
            if(fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.REFERENCE)
            {
                Schema.SObjectType parentSchema = fieldMap.get(fieldName).getDescribe().getReferenceTo().get(0);
                system.debug('parentSchema===>'+parentSchema);
                if(String.valueOf(parentSchema) == 'Product2'){
                    Map<String, Schema.SObjectField> parentFieldMap = parentSchema.getDescribe().fields.getMap();
                    for(String parentField : parentFieldMap.keySet()){ 
                        fieldNames.add('Unit__r.'+parentField);
                    }
                }
            }
        }
        System.debug('Parent field  '+fieldNames);
        return fieldNames;
    }
    
}