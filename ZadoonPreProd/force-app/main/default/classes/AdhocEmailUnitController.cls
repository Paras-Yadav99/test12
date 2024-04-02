public with sharing class AdhocEmailUnitController {
    //variable used for pagination.
    Public Integer noOfRecords {get; set;}
    public Integer PAGE_SIZE  = 10;
    public Integer startIndex {get; set;}
    public Integer endIndex {get; set;}
    public Integer totalPages {get; set;}
    public Integer Page = 1;
    public String selectedPage_Size {get;set;}
    
    public list<SelectOption> paginationSizeOptions {
        get {
            paginationSizeOptions = new List<SelectOption>();
            paginationSizeOptions.add(new SelectOption('10','10'));
            paginationSizeOptions.add(new SelectOption('20','20'));
            paginationSizeOptions.add(new SelectOption('30','30'));
            paginationSizeOptions.add(new SelectOption('40','40'));
            paginationSizeOptions.add(new SelectOption('50','50'));
            return paginationSizeOptions;
        } private set;
    }
    public static List< Product2 > sendUnitList {get; set;} // this list used to pass AdhocEmailVFComponent vf component
    public List< Product2 > prodList {get; set;}
    public List < WrapperClass > wrapperList {get; set;}
    Map< Id, WrapperClass > mapHoldingSelectedRecords {get;set;}
    // searck key variables
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String phone {get; set;}
    public static String error {get; set;}
    
    public AdhocEmailUnitController(apexPages.StandardSetController standardController) {
        error = '';
        mapHoldingSelectedRecords = new Map< Id, WrapperClass >();
        List< String > allFields = UtilityClass.getAllFields('Product2');
        prodList = new List < Product2 >();
        List<Product2> selectedUnits = standardController.getSelected();
        String soql = 'Select '+String.join(allFields, ',')+' From Product2 Where Id IN :selectedUnits AND isActive=true';
        prodList = database.query(soql);
        if ( prodList.size() == 0 ) return;
        getAllContacts();
    }
    
    public AdhocEmailUnitController(){}
    
    private void getAllContacts() {
        try {
            wrapperList = new List < WrapperClass > ();
            startIndex = (page-1)*PAGE_SIZE;
            endIndex = page*PAGE_SIZE;
            List< Contact > contactList = fetchContact();
            noOfRecords = contactList != null ? contactList.size() :0;
            system.debug('noOfRecords ===>'+noOfRecords);
            Integer totalRec = 0;
            for( Contact con : contactList ) {
                if( totalRec >= startIndex && totalRec < endIndex ) {
                    if( mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(con.id) ) {
                        wrapperList.add(mapHoldingSelectedRecords.get(con.id));
                    }else {
                        wrapperList.add(new WrapperClass(con,false));
                    }
                }
                totalRec++;
            }
            totalPages = (Integer)((Decimal)totalRec/PAGE_SIZE).round(RoundingMode.UP);
            system.debug('wrapperList====>'+wrapperList);
        }catch( Exception ex ) {
            system.debug('error occured >>>'+ex+ '  At line Number  '+ex.getLineNumber());
            error = utilityClass.ERROR_MSG+'<br/> Technical issue: '+ex.getMessage()+', Exception Type: '+ex.getTypeName()+', At Line: '+ex.getLineNumber();
        }
    }
    
    private List< Contact > fetchContact() {
        List< String > fields = UtilityClass.getAllFields('Contact');
        String  filter ='';
        String soql = ''
            + ' select ' + String.join(fields, ',')+', Account.Name '
            + ' from Contact';
        if(String.isnotBlank(firstName)) {
            filter += ' FirstName LIKE'+'\'%' + String.escapeSingleQuotes(firstName.trim()) + '%\'';
        }
        if(String.isNotBlank(lastName)) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            filter += ' LastName LIKE'+'\'%' + String.escapeSingleQuotes(lastName.trim()) + '%\'';
        }
        if(String.isNotBlank(email)) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            filter += ' Email='+'\'' + String.escapeSingleQuotes(email.trim()) + '\'';
        }
        if(String.isNotBlank(phone)) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            filter += ' Phone='+'\'' + String.escapeSingleQuotes(phone.trim()) + '\'';
        }
        if(String.isNotBlank(filter)) {
            soql += ' WHERE '+filter+ ' AND Email !=Null';
        }else {
            soql += ' WHERE Email != Null AND Iron_Demands__c !=0';
        }
        system.debug('filter >>>>'+filter);
        system.debug('soql >>>>'+soql);
        
        return Database.query(soql);
    }
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get{if( page < totalPages ) {
            return true;
        }
            else
                return false;}
        set;}
    
    // returns the next page of the page set
    public void next() {
        updateSelectedRecordsMap();
        if(hasNext) page++;
        getAllContacts();
    }
    
    // indicates whether there are more records before the current page set
    public Boolean hasPrevious {
        get{ if(page > 1) {
            return true;
        }else
            return false;}
        set;}
    
    // returns the previous page of the page set
    public void previous() {
        updateSelectedRecordsMap();
        if(hasPrevious) page--;
        getAllContacts();
    }
    
    // returns the first page of the page set
    public void first() {
        updateSelectedRecordsMap();
        Page = 1;
        getAllContacts();
    }
    
    // returns the last page of the page set
    public void last() {
        updateSelectedRecordsMap();
        Page = totalPages;
        getAllContacts();
    }
    
    // set the page_size from dropdown
    public void refreshPageSize() {
        updateSelectedRecordsMap();
        PAGE_SIZE = Integer.valueOf(selectedPage_Size);
        getAllContacts();
        
    }
    
    // update the map with the selected product records
    Private void updateSelectedRecordsMap() {
        for( WrapperClass wrp : wrapperList ) {
            if( wrp.isSelected ) {
                mapHoldingSelectedRecords.put(wrp.con.id, wrp);
            }
            if( !wrp.isSelected && mapHoldingSelectedRecords.containsKey(wrp.con.id) ) {
                mapHoldingSelectedRecords.remove(wrp.con.id);
            }
        }
    }
    
    public void search() {
        updateSelectedRecordsMap();
        getAllContacts();
    }
    
    // send method called from vf page
    public void sendEmail() {
        try {
            updateSelectedRecordsMap();
            system.debug('sendUnitList ===>'+sendUnitList);
            sendEmailUtil(mapHoldingSelectedRecords.keySet(),prodList);
        } catch( Exception ex ) {
            error =utilityClass.ERROR_MSG+'<br/> Technical issue: '+ex.getMessage()+', Exception Type'+ex.getTypeName()+', At Line '+ex.getLineNumber();
        }
    }
    
    // generic method used for sending email for unit and contact adhoc 
    public static String sendEmailUtil(Set<ID> conIDSet, List < Product2 > unitList) {
        system.debug('util send method conId: '+conIDSet.size());
        system.debug('util send method unitList: '+unitList.size());
       	OrgWideEmailAddress[] owea = UtilityClass.owea;
        EmailTemplate emailTemplate = [Select Id,HtmlValue from EmailTemplate where DeveloperName = 'AdhocEmailTemplate'];
        List< Messaging.SingleEmailMessage > emails = new List< Messaging.SingleEmailMessage >();
        for(ID conId : conIDSet) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(conId);
            email.setSaveAsActivity(true);
            if( owea != null && owea.size() > 0) email.setOrgWideEmailAddressId(owea.get(0).Id );
            for(Product2 unit : unitList) {
                email.setTemplateID(emailTemplate.Id); 
                email.setWhatId(unit.Id);
            }
            emails.add(email);
        }
        sendUnitList = unitList;
        List< Messaging.SendEmailResult > result = new List< Messaging.SendEmailResult >();
        if( !test.isRunningTest() && emails.size() > 0) {
            result = Messaging.sendEmail(emails,false);
            system.debug('email sent!');
        }
        if( result.size()>0 && result[0].isSuccess() ) {
            error = utilityClass.EMAIL_SUCCESS_MSG;
        } else if( result.size()>0 && !result[0].isSuccess()) {
            error = utilityClass.EMAIL_ERROR_MSG+'<br/> Technical issue: '+result[0].getErrors();
        }
        return error;
    }
}