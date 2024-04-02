global class AdhocEmailer implements Database.Batchable<sObject> {

/* in theory can manually execute the batch and it should run w/o the test tool */

    /* Standard Zadoon Global Variables */
    public String OWASender; 
    public boolean display{get; set;}
    public boolean sendbuttondisplay {get; set;}
    public boolean unitTestFlag {get; set;}

    
    /* Custom Script Variables */
    public boolean AdhocEmailer_Production {get; set;}
    public String Regions {get;set;}
    public String ClientTypes {get;set;}
    public String Equipment {get;set;}
    public String EquipmentNeed {get;set;}
    public String Manufacturer {get;set;}
    public String Category {get;set;}
    public String Industry {get;set;}
    public String AccountIndustry {get;set;}
    public String AccountCategory {get;set;}
    public String AccountDealer {get;set;}
    public String Zid {get;set;}
    public String Model {get;set;}
    public String MassEmailEquipmentNeedBodyHidden {get;set;}
    public String MassEmailEquipmentNeedTitleHidden {get;set;}
    public String soql {get;set;}
    public Product2 product {get;set;}
    public Product2 tempEquipmentNeed {get;set;}
    public String prod_id {get;set;}
   
    /* Standard Zadoon Methods */ 
    public AdhocEmailer() {
         display = false;
         product = new Product2();
         tempEquipmentNeed = new Product2();
         
    }
    
    Public PageReference SendEmail(){
    
        display = true;
        
        System.debug('CPU usage time accumulated 1' +  Limits.getLimitCpuTime());
       System.debug('CPU usage time Usage 1 ' +  Limits.getCpuTime());
    
        AdhocEmailer be = new AdhocEmailer();
        be.AdhocEmailer_Production = true;
        be.Zid = Zid;
        be.ClientTypes = ClientTypes;
        be.Regions = Regions;
        be.Equipment = Equipment;
        be.EquipmentNeed = EquipmentNeed;
        be.AccountDealer = AccountDealer;
        be.Manufacturer = Manufacturer;
        be.Industry = Industry;
        be.AccountIndustry = AccountIndustry;
        be.AccountCategory = AccountCategory;
        be.Model = Model;
        be.Category = Category;
        be.unitTestFlag = unitTestFlag;
        be.product = product;
        be.tempEquipmentNeed = tempEquipmentNeed;

        database.executeBatch(be, 200); 
        
        return null;
       
       
       
    }
    
    Public PageReference GetRecordPage(){
    
        display = true;
        system.debug('1' + Zid);
        sendbuttondisplay = true;
        
        system.debug('product 11' +  product);
        
        EquipmentNeed = String.valueOf(tempEquipmentNeed.equipment__c);
        
        system.debug('product 111' +  product);
        
        if(EquipmentNeed != null && EquipmentNeed != '') {
        
            EquipmentNeed = String.valueOf(tempEquipmentNeed.equipment__c);
        
            Equipment__c EquipmentToUpdate = 
            [SELECT MassEmailEquipmentNeedBodyHidden__c, Manufacturer__c, Model__c FROM Equipment__c 
                 WHERE Id = :EquipmentNeed
                 LIMIT 1];
        
           
            EquipmentToUpdate.MassEmailEquipmentNeedBodyHidden__c = MassEmailEquipmentNeedBodyHidden;
            
            if(String.isNotEmpty(MassEmailEquipmentNeedTitleHidden)) {
                EquipmentToUpdate.MassEmailEquipmentNeedTitleHidden__c = MassEmailEquipmentNeedTitleHidden;
            } else {
                EquipmentToUpdate.MassEmailEquipmentNeedTitleHidden__c = EquipmentToUpdate.Manufacturer__c + ' ' + EquipmentToUpdate.Model__c + ' need.';
            }
            
            // Make the update call.
            update EquipmentToUpdate;
        
        }       
        system.debug('product 1111' +  product); 
       
        AdhocEmailer be = new AdhocEmailer();
        be.AdhocEmailer_Production = false;
        be.Zid = Zid;
        be.ClientTypes = ClientTypes;
        be.Regions = Regions;
        be.Equipment = Equipment;
        be.EquipmentNeed = EquipmentNeed;
        be.AccountDealer = AccountDealer;
        be.Manufacturer = Manufacturer;
        be.Industry = Industry;
        be.AccountIndustry = AccountIndustry;
        be.AccountCategory = AccountCategory;
        be.Model = Model;
        be.Category = Category;
        be.unitTestFlag = unitTestFlag;
        be.product = product;
        be.tempEquipmentNeed = tempEquipmentNeed;
        
        database.executeBatch(be, 200);
        
    
       return null;   
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
      
      Product2 ZidAccountID;
        
      soql = 'SELECT Id, Name, Account.Name, Account.Id FROM Contact WHERE Client_Email_Opt_Out__c = FALSE AND Account.Not_A_Client_We_Want_To_Do_Business_With__c = false';
      
       
      if(String.isNotBlank(ClientTypes))  {
         soql = soql + ' AND Contact.Account.Client_Type__c = :ClientTypes ';
      }
  
      if(Regions != '[]')  { 
      
        String RegionString = Regions.removeStart('[');
        RegionString = RegionString.removeEnd(']');
        List<String> RegionList = RegionString.split(',');
        
        RegionString = '';
        
        for(String s: RegionList) {
           RegionString += '\'' + s + '\',';
        }
        
        RegionString = RegionString.removeEnd(',');
      
        soql = soql + ' AND Contact.Account.Client_Region__c INCLUDES (' + RegionString + ')';
        
      }
  
      if(AccountIndustry != '[]') {
      
        String AccountIndustryString = AccountIndustry.removeStart('[');
        AccountIndustryString = AccountIndustryString.removeEnd(']');
        List<String> AccountIndustryList = AccountIndustryString.split(',');
        
        AccountIndustryString = '';
        
        for(String s: AccountIndustryList) {
           AccountIndustryString += '\'' + s + '\',';
        }
        
        AccountIndustryString = AccountIndustryString.removeEnd(',');
      
        soql = soql + ' AND Contact.Account.Industries_They_Service__c INCLUDES (' + AccountIndustryString + ')';
      
      }
      if(AccountCategory != '[]') {
       
        String AccountCategoryString = AccountCategory.removeStart('[');
        AccountCategoryString = AccountCategoryString.removeEnd(']');
        List<String> AccountCategoryList = AccountCategoryString.split(',');
        
        AccountCategoryString = '';
        
        for(String s: AccountCategoryList) {
           AccountCategoryString += '\'' + s + '\',';
        }
        
        AccountCategoryString = AccountCategoryString.removeEnd(',');
       
         soql = soql + ' AND Contact.Account.Categories_of_Equipment_They_Sell__c INCLUDES (' + AccountCategoryString + ')';
      
      }
       
      if(AccountDealer != '[]') {
      
        String AccountDealerString = AccountDealer.removeStart('[');
        AccountDealerString = AccountDealerString.removeEnd(']');
        List<String> AccountDealerList = AccountDealerString.split(',');
        
        AccountDealerString = '';
        
        for(String s: AccountDealerList) {
           AccountDealerString += '\'' + s + '\',';
        }
        
        AccountDealerString = AccountDealerString.removeEnd(',');
      
         soql = soql + ' AND Contact.Account.Authorized_Dealer_For__c INCLUDES (' + AccountDealerString + ')';
     
      }
     
       system.debug('ZID' + Zid);
     
      if(String.isNotBlank(Zid))     { 
             
             system.debug('in here ZID is Not Blank');   
                
             ZidAccountID = [SELECT Account__c FROM Product2 WHERE ZID__c = :Zid LIMIT 1];
             
             system.debug('ZidAccountID' + ZidAccountID);
             system.debug('ZID: ' + Zid + ' ZidAccountID ' + ZidAccountID.Account__c);
             
             soql = soql + ' AND Contact.Account.Id != \'' + ZidAccountID.Account__c + '\'';
        }
        
        if(unitTestFlag == TRUE) 
            soql += ' LIMIT 200 ';
        
        system.debug('soql' + soql); 
         
        return Database.getQueryLocator(soql);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> AccountContacts) {
        
        
      system.debug('AdhocEmailer_Production' + AdhocEmailer_Production);
      /* Standard Field (could not be global) */
      List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
      Map<Id, String> AccountName = new Map<Id, String>();
      Map<Id, String> ContactName = new Map<Id, String>(); 
      String ManufacturerString;
      String Zid3;
      String WhatId;
      EmailTemplate templateId;
      ID AccountId;
      String payload;
      payload = '<table><tr><td>Account</td><td>Contact</td><td>HTML Preview</td></tr>';
    
       System.debug('CPU usage time accumulated 2' +  Limits.getLimitCpuTime());
       System.debug('CPU usage time Usage 2 ' +  Limits.getCpuTime());
      
      

      Set<Id> clist = new Set<Id>();
                  
       System.debug('CPU usage time accumulated 3' +  Limits.getLimitCpuTime());
       System.debug('CPU usage time Usage 3 ' +  Limits.getCpuTime());
                    
        // Find Organization Wide Address  
        id owaid;
        for(OrgWideEmailAddress owa : [select id, DisplayName, Address from OrgWideEmailAddress]) {
        if(owa.DisplayName.contains('Collin'))  owaid = owa.id; OWASender = owa.DisplayName + '<' + owa.Address + '>'; }       
       
        system.debug('product' + product);
        prod_id = String.valueOf(product.equipment__c);
        EquipmentNeed = String.valueOf(tempEquipmentNeed.equipment__c);
        
        if(String.isNotEmpty(Zid)) {
            String TempZid;
            TempZid = 'ZID-' + Zid;
            Product2 Zid2 = [SELECT Id, Account__r.Id FROM Product2 WHERE ProductCode = :TempZid AND IsActive = true];
            Zid3 = Zid2.Id;
            AccountId = Zid2.Account__r.Id;
            templateId = [Select id from EmailTemplate where DeveloperName = 'MassEmailZid'];
        } else if (prod_id != null && prod_id != '') {  
            templateId = [Select id from EmailTemplate where DeveloperName = 'MassEmailClientTypeRegion'];        
        } else if (EquipmentNeed != null && EquipmentNeed != '' ) { 
            templateId = [Select id from EmailTemplate where DeveloperName = 'MassEmailEquipmentNeed'];
            
        }
        
        
       /* find contact list */ 
       
       clist = (new Map<Id,SObject>(AccountContacts)).keySet();
       
              /* find contact list */ 

       
       
       for(Contact AccountContact : AccountContacts) {
           

               AccountName.put(AccountContact.Id, AccountContact.Account.Name);
               ContactName.put(AccountContact.Id, AccountContact.Name);

       }
           
       
       
       System.debug('CPU usage time accumulated 4' +  Limits.getLimitCpuTime());
       System.debug('CPU usage time Usage 4 ' +  Limits.getCpuTime()); 
       

       
              
        for(Id cID:clist) {
            
            /* need to readd logic to not send zid to own account */
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateID(templateId.Id); 
            mail.setTargetObjectId(cID);
            mail.setSaveAsActivity(true);
            mail.setReplyTo('collin@zadoon.com');
            mail.setOrgWideEmailAddressId(owaid);
            
            prod_id = String.valueOf(product.equipment__c);
            EquipmentNeed = String.valueOf(tempEquipmentNeed.equipment__c);
            
            if(String.isNotEmpty(Zid3))     { 
                system.debug('added zid');
                mail.setWhatId(Zid3);
                WhatId = Zid3;
            }
  
            else if(prod_id != null  && prod_id !=  '') {
                system.debug('product' + product);
                system.debug('product equipment' + product.equipment__c);
                
                
                system.debug('added Equipment' + prod_id);
                
                mail.setWhatId(prod_id);
                WhatId = prod_id;            
            }
            else if (EquipmentNeed != null && EquipmentNeed != '' ) { 
                system.debug('added Equipment Need' + EquipmentNeed);
                
                mail.setWhatId(EquipmentNeed);
                WhatId = EquipmentNeed;
                
            }
  
            else if(String.isNotEmpty(Manufacturer) || String.isNotEmpty(Category)) {
                ManufacturerString = ';ManufacturerString;';
                if(String.isNotEmpty(Manufacturer))
                    ManufacturerString = ManufacturerString + Manufacturer;
                ManufacturerString = ManufacturerString + '|';
                if(String.isNotEmpty(Category))
                    ManufacturerString = ManufacturerString + Category;
            }
           
            
            
            mail.setReferences('Account;' + AccountName.get(cID) + ';ContactName;' + ContactName.get(cID) + ';OWASender;' + OWASender + ManufacturerString);         
            
            
            
            allmsg.add(mail);
                
            payload = payload + '<tr><td>' + AccountName.get(cID) + ';</td><td>' + ContactName.get(cID) + ';</td><td><a href="/' + templateId.Id + '?recipient_type_id=' + cID + '&related_to_id=' + WhatId + '">Html Preview</a></td></tr>';
            
                
            System.debug('mail '+mail);
      
        }
       
       payload = payload + '</table>';
        System.debug('CPU usage time accumulated 5' +  Limits.getLimitCpuTime());
       System.debug('CPU usage time Usage 5 ' +  Limits.getCpuTime());
            
        
        
        /* Do not send out emails unless in production context */
        if(AdhocEmailer_Production == true)
            Messaging.sendEmail(allmsg,false); 
        
        
        
       System.debug('CPU usage time accumulated 6' +  Limits.getLimitCpuTime());
       System.debug('CPU usage time Usage 6 ' +  Limits.getCpuTime());
        
        /* Return email payload for debugging */  
        Mass_Email_Batch__c batch = new Mass_Email_Batch__c(name =DateTime.now().format('MM/dd/yyyy HH:mm:ss'), Batch_Payload__c = payload);
        insert batch;

        
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
    
    
    
    /* Start of Zadoon Custom Email Logic */
    Public List<Messaging.SingleEmailMessage> GetAdhocEmailer(){
    

        return null;
        
        
        
    }
   
    
    //This var hold List of Regions
    public List<SelectOption> getListOfRegions()
    {
        List<SelectOption> Options =  new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult = Account.Client_Region__c.getDescribe();    
        
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();    
  
        Options.add(new selectOption('','Select Account Region'));
  
        for(Schema.picklistEntry f:ple)    
        {    
            options.add(new selectOption(f.getLabel(),f.getValue()));                    
        }   
        return Options;    
    }
    
    //This var hold List of Regions
    public List<SelectOption> getListOfClientTypes()
    {
        List<SelectOption> Options =  new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult = Account.Client_Type__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();    
        Options.add(new selectOption('','Select Client Type'));  
        for(Schema.picklistEntry f:ple)    
        {    
            options.add(new selectOption(f.getLabel(),f.getValue()));                    
        }   
        return Options;    
    }
    
    
    //This var hold List of Equipments
    public List<SelectOption> getListOfEquipment()
    {
    
    System.debug('CPU usage time accumulated 6' +  Limits.getLimitCpuTime());
       System.debug('CPU usage time Usage 6 ' +  Limits.getCpuTime());
       
        List<SelectOption> Options =  new List<SelectOption>();       
        
        Options.add(new selectOption('','Select Equipment'));
        
        for(List<Equipment__c> EquipmentList : [select id, Name from Equipment__c WHERE id IN (Select Equipment__c FROM Product2 WHERE isActive = true) ORDER BY Name]) {
           for(Equipment__c Equipment : EquipmentList) {
             Options.add(new selectOption(Equipment.id,Equipment.Name));
           } 
        
        }
        
        System.debug('CPU usage time accumulated 7' +  Limits.getLimitCpuTime());
       System.debug('CPU usage time Usage 7 ' +  Limits.getCpuTime());

        return Options;    
    }
    
    //This var hold List of Equipments
    public List<SelectOption> getListOfEquipmentNeed()
    {
        List<SelectOption> Options =  new List<SelectOption>();       
        
        Options.add(new selectOption('','Select Equipment Need'));
        
        for(List<Equipment__c> EquipmentList : [select id, Name from Equipment__c WHERE id IN (Select Equipment__c FROM Product2 WHERE isActive = true) ORDER BY Name]) {
           for(Equipment__c Equipment : EquipmentList) {
             Options.add(new selectOption(Equipment.id,Equipment.Name));
           } 
        
        }

        return Options;    
    } 
    
    //This var hold List of Equipments
    public List<SelectOption> getListOfManufacturers()
    {
        List<SelectOption> Options =  new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult = Equipment__c.Manufacturer__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();   
        Options.add(new selectOption('','Select Manufacturer'));
        for(Schema.picklistEntry f:ple)    
        {    
            Options.add(new selectOption(f.getLabel(),f.getValue()));                    
        }   
        return Options;    
    }
    
    //This var hold List of Equipments
    public List<SelectOption> getListOfCategories()
    {
        List<SelectOption> Options =  new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult = Equipment__c.Category__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues(); 
        Options.add(new selectOption('','Select Category'));      
        for(Schema.picklistEntry f:ple)    
        {    
            Options.add(new selectOption(f.getLabel(),f.getValue()));                    
        }   
        return Options;    
    }

    //This var hold List of Equipments
    public List<SelectOption> getListOfIndustries()
    {
        List<SelectOption> Options =  new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult = Equipment__c.Industry_Used_In__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues(); 
        Options.add(new selectOption('','Select Industry Used In'));      
        for(Schema.picklistEntry f:ple)    
        {    
            Options.add(new selectOption(f.getLabel(),f.getValue()));                    
        }   
        return Options;    
    }
    
    //This var hold List of Equipments
    public List<SelectOption> getListOfAccountIndustries()
    {
        List<SelectOption> Options =  new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult = Account.Industries_They_Service__c.getDescribe();    
        
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues(); 
        Options.add(new selectOption('','Select Industries They Service'));      
        for(Schema.picklistEntry f:ple)    
        {    
            Options.add(new selectOption(f.getLabel(),f.getValue()));                    
        }   
        return Options;    
    }
    
    //This var hold List of Equipments
    public List<SelectOption> getListOfAccountCategories()
    {
        List<SelectOption> Options =  new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult = Account.Categories_of_Equipment_They_Sell__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues(); 
        Options.add(new selectOption('','Select Account Category'));      
        for(Schema.picklistEntry f:ple)    
        {    
            Options.add(new selectOption(f.getLabel(),f.getValue()));                    
        }   
        return Options;    
    }
    
    //This var hold List of Equipments
    public List<SelectOption> getListOfAccountDealers()
    {
        List<SelectOption> Options =  new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult = Account.Authorized_Dealer_For__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues(); 
        Options.add(new selectOption('','Select Authorized Dealer For'));      
        for(Schema.picklistEntry f:ple)    
        {    
            Options.add(new selectOption(f.getLabel(),f.getValue()));                    
        }   
        return Options;    
    }
    
    /* display mass email bulk payloads */ 
    public Boolean showRecords{get;set;}
    public List<Mass_Email_Batch__c> MassEmailBatch {get;set;}
    //In constructor<br>   showRecords = false;
    public void fetchRecords() { 
        MassEmailBatch = [Select Batch_Payload__c, createdBy.Name, Name, CreatedDate from Mass_Email_Batch__c ORDER BY CreatedDate DESC  limit 20];
        
        // you need to place a limit of 1000 as VF supports max of 1000 recors to be displayed
        showRecords = true;
    }
    
    
    
    
}