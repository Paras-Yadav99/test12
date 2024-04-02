public with sharing class AddUnitsPageController{
    
    //variable used for pagination.
    Public Integer noOfRecords { get; set; }
    public Integer PAGE_SIZE  = 10;
    public Integer startIndex  { get; set; }
    public Integer endIndex   { get; set; }
    public Integer totalPages { get; set; }
    public Integer Page = 1;
    public String selectedPage_Size { get;set; }
    public List< SelectOption > paginationSizeOptions {
        get {
            paginationSizeOptions = new List< SelectOption >();
            paginationSizeOptions.add(new SelectOption('10','10'));
            paginationSizeOptions.add(new SelectOption('20','20'));
            paginationSizeOptions.add(new SelectOption('30','30'));
            paginationSizeOptions.add(new SelectOption('40','40'));
            paginationSizeOptions.add(new SelectOption('50','50'));
            return paginationSizeOptions;
        } private set;
    }
    
    //variable used for search key and holding the selected records.
    public List < WrapperClass > wrapperRecordList    { get; set; }
    Map< Id, WrapperClass > mapHoldingSelectedRecords { get; set; }
    public List< WrapperClass > wrapperDeleteList     { get; set; }
    public List< SelectOption > categoryList 	{ get; set; }
    public String selectedCategory			{ get; set; }
    public String year						{ get; set; }		
    public String make						{ get; set; }
    public String model						{ get; set; }
    public Double weight					{ get; set; }
    public Double minWeight					{ get; set; }
    public Double maxWeight					{ get; set; }
    public Double minHour					{ get; set; }
    public Double maxHour					{ get; set; }
    public Double minPrice					{ get; set; }
    public Double maxPrice					{ get; set; }
    public String unitCode					{ get; set; }
    public String countryOrState			{ get; set; }
    public Id ironDemandId 					{ get; set; }
    public Iron_Demand__c irn_demand		{ get; set; }
    public String errorStr					{ get; set; }
    
    
    //constructor calling init method.
    public AddUnitsPageController(apexPages.StandardController controller){
        ironDemandId = (Id)controller.getId();
        errorStr = '';
        mapHoldingSelectedRecords = new Map< Id, WrapperClass >();
        getIronDemand();
        categoryList = UtilityClass.getPicklistEntry('Equipment__c','Category__c');
        init();
        
    }
    
    /* init method called on page load to set the pagination variable and  get the records based on filter 
criteria from page */
    private void init(){
        try{
            wrapperRecordList = new List< WrapperClass >();
            startIndex = (page-1)*PAGE_SIZE;
            endIndex = page*PAGE_SIZE;
            List< Product2 > productList = fetchProduct();
            noOfRecords = productList != null ? productList.size() :0;
            Integer totalRec = 0;
            for(Product2 pro : productList){
                if(totalRec >= startIndex && totalRec < endIndex){
                    if(mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(pro.id)){
                        wrapperRecordList.add(mapHoldingSelectedRecords.get(pro.id));
                    }else{
                        wrapperRecordList.add(new WrapperClass(pro,false));
                    }
                }
                totalRec++;
            }
            totalPages = (Integer)((Decimal)totalRec/PAGE_SIZE).round(RoundingMode.UP);
            system.debug('noOfRecords===>'+noOfRecords);
        }catch(Exception e){
            errorStr =utilityClass.ERROR_MSG+'<br/> Technical issue: '+e.getMessage()+', Exception Type: '+e.getTypeName()+', At Line: '+e.getLineNumber();
        }
    }
    
    //search method which queries the records based on filter from page.
    public void search() {
        updateSelectedRecordsMap();
        init();
    }
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext{
        get{ if(page < totalPages){
            return true;
        }else 
            return false;}
        set;}
    
    // returns the next page of the page set
    public void next() {
        updateSelectedRecordsMap();
        if(hasNext) page++;
        init();
    }
    
    // indicates whether there are more records before the current page set
    public Boolean hasPrevious{
        get{ if(page > 1) {
            return true;
        }else
            return false;}
        set;}
    
    
    // returns the previous page of the page set
    public void previous() {
        updateSelectedRecordsMap();
        if(hasPrevious) page--;
        init();
    }
    
    // returns the first page of the page set
    public void first() {
        updateSelectedRecordsMap();
        Page = 1;
        init();
    }
    
    // returns the last page of the page set
    public void last() {
        updateSelectedRecordsMap();
        Page = totalPages;
        init();
    }
    
    // set the page_size from dropdown
    public void refreshPageSize(){
        updateSelectedRecordsMap();
        PAGE_SIZE = Integer.valueOf(selectedPage_Size);
        init();
        
    }
    
    // update the map with the selected product records
    Private void updateSelectedRecordsMap(){
        for(WrapperClass wrp : wrapperRecordList){
            if(wrp.isSelected){
                mapHoldingSelectedRecords.put(wrp.pro.id, wrp);
            }
            if(!wrp.isSelected && mapHoldingSelectedRecords.containsKey(wrp.pro.id)){
                mapHoldingSelectedRecords.remove(wrp.pro.id);
            }
            system.debug('--->mapHoldingSelectedRecords  ===>'+mapHoldingSelectedRecords);
        }
    }
    
    // get current Iron demand records on page load to populate some values on page
    Private void getIronDemand(){
        List< String > getUnitFields = UtilityClass.getRelationFields('Iron_Demand_Unit__c');
        String soql = 'Select Id,Name, '+String.join(getUnitFields, ',')+' ,Iron_Demand__c,Iron_Demand__r.Name,CreatedDate FROM Iron_Demand_Unit__c WHERE Iron_Demand__c ='+' \'' + String.escapeSingleQuotes(ironDemandId) + '\'';
        wrapperDeleteList = new List< WrapperClass >();
        irn_demand = [Select Id,IronDemand_Iron__r.Name,IronDemand_Contact__r.FirstName,IronDemand_Contact__r.LastName,Name,Max_Year__c,isActive__c,Category__c,Make__c,Max_Hours__c,Max_Price__c,Model__c,IronDemand_Contact__r.MailingCountry,IronDemand_Contact__c,IronDemand_Iron__r.ownerId
                      From Iron_Demand__c Where Id =:ironDemandId];
        if(irn_demand != Null){
            selectedCategory = irn_demand.Category__c;
            make = irn_demand.Make__c;
            model = irn_demand.Model__c;
            year = irn_demand.Max_Year__c;
            for(Iron_Demand_Unit__c unit : database.query(soql)){
                wrapperDeleteList.add(new WrapperClass(unit,false));
            }
        }
    }
    
    // product/unit search query  based on filter criteria
    Private List< Product2 > fetchProduct() {
        String filter = '';
        if(String.isNotBlank(selectedCategory)) {
            filter += 'Category__c ='+' \'' + String.escapeSingleQuotes(selectedCategory.trim()) + '\''; 
        }
        if(String.isNotBlank(year)) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            filter += 'Year__c ='+' \'' + String.escapeSingleQuotes(year.trim()) + '\'' ;
        }
        if(String.isNotBlank(make)) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            filter += 'Manufacturer__c ='+' \'' + String.escapeSingleQuotes(make.trim()) + '\'' ;
        }
        if(String.isNotBlank(model)) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            filter += 'Model__c ='+' \'' + String.escapeSingleQuotes(model.trim()) + '\'' ;
        }
        if(minWeight !=null && minWeight > 0.0) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            filter += 'Operating_Weight__c >=' +minWeight;
        }
        if(maxWeight !=null && maxWeight > 0.0) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            filter += 'Operating_Weight__c <=' +maxWeight;
        }
        if(minHour != null && minHour > 0.0) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            filter += '(Hour__c >=' +minHour;
            filter += (maxHour > 0.0) ? '' : ')';
        }
        if(maxHour != null && maxHour > 0.0) {
            if(String.isNotBlank(filter)) filter += (minHour > 0.0) ? ' OR ' : ' AND (';
            filter += 'Hour__c <=' +maxHour+')';
        }
        if(minPrice != null && minPrice > 0.0) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            filter += 'Starting_Advertised_Retail_Price__c >=' +minPrice;
        }
        if(maxPrice != null && maxPrice > 0.0) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            filter += 'Starting_Advertised_Retail_Price__c <=' +maxPrice;
        }
        if(String.isNotBlank(unitCode)) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            filter += 'Name LIKE'+'\'%' + String.escapeSingleQuotes(unitCode.trim()) + '%\'';
        }
        if(String.isNotBlank(countryOrState)) {
            if(String.isNotBlank(filter)) filter += ' AND ';
            if(irn_demand.IronDemand_Contact__r.MailingCountry == 'United States' || irn_demand.IronDemand_Contact__r.MailingCountry == 'USA'){
                filter += 'Storage_State__c ='+' \'' + String.escapeSingleQuotes(countryOrState.trim()) + '\'' ;
            } else {
                filter += 'Storage_Country__c ='+' \'' + String.escapeSingleQuotes(countryOrState.trim()) + '\'' ;
            }
        }
        
        filter = filter.removeEnd('AND');
        system.debug('filter '+filter);
        List< String > productFields = UtilityClass.getAllFields('Product2');
        String query = 'Select '+String.join(productFields, ',')+', Account__r.Client_Region__c,Account__r.Name From Product2';
        if(String.isNotBlank(filter)) {
            query += ' WHERE '+filter+' AND isActive = true';
        }else{
            query += ' WHERE isActive = true';
        }
        
        system.debug('filter========>'+filter);
        return database.query(query);
    }
    
    // Method for adding the selected products under iron demand/Units 
    public void addSelectedProduct(){
        try{
            updateSelectedRecordsMap();
            system.debug('Add mapHoldingSelectedRecords====>'+mapHoldingSelectedRecords);
            List< Iron_Demand_Unit__c > ironProdToInsert = new List< Iron_Demand_Unit__c >();
            for(WrapperClass wrap : mapHoldingSelectedRecords.values()){
                if(wrap.isSelected){
                    ironProdToInsert.add(new Iron_Demand_Unit__c(Iron_Demand__c=ironDemandId,Unit__c=wrap.pro.id, Automation__c=false));
                }
            }
            system.debug('ironProdToInsert====>'+ironProdToInsert);
            if(ironProdToInsert.size() > 0){
                List< database.SaveResult > saveResult = database.insert(ironProdToInsert,false);
                createTask(ironProdToInsert);
                errorStr = 'Units added successfully under '+irn_demand.Name;
                getIronDemand();
            }
        }catch(Exception ex){
            system.debug('error during data insert==>'+ex + ' at line '+ex.getLineNumber());
            errorStr = utilityClass.ERROR_MSG+'<br/> Technical issue: '+ex.getMessage()+', Exception Type: '+ex.getTypeName()+', At Line: '+ex.getLineNumber();
        }
    }
    
    // delete the selected Iron Demand units from vf page under Iron Demand
    public void deleteSelectedUnits() {
        try{
            List < Iron_Demand_Unit__c > ironDemandDelete = new List < Iron_Demand_Unit__c > ();
            system.debug('wrapperDeleteList ---->'+wrapperDeleteList);
            for(WrapperClass wrap : wrapperDeleteList) {
                if(wrap.isSelected){
                    ironDemandDelete.add(wrap.ironDemand);
                }
            }
            database.delete(ironDemandDelete, false);
            getIronDemand();
        }catch(Exception e) {
            system.debug('error while deleting units/Products==>'+e+'  at line  '+e.getLineNumber());
            errorStr = utilityClass.ERROR_MSG+'<br/> Technical issue: '+e.getMessage()+', Exception Type: '+e.getTypeName()+', At Line: '+e.getLineNumber();
        }
    }
    
    // creates task whenever Iron Demand units added and assign it to equipment owner
    private void createTask( List< Iron_Demand_Unit__c > unitIronDemandList ) {
        if(unitIronDemandList.size() > 0){
            Task task = New Task();
            Integer count=0;
            task.Subject = 'Unit added '+irn_demand.Name;
            task.Priority = 'Normal';
            task.Status = 'In Pogress';
            task.WhoId = irn_demand.IronDemand_Contact__c;
            task.OwnerId = irn_demand.IronDemand_Iron__r.ownerId;
            task.WhatId = irn_demand.id;
            task.Description = 'The following units added: \n';
            for(Iron_Demand_Unit__c iron : unitIronDemandList){
                count++;
                task.Description += count+'. '+URL.getSalesforceBaseUrl().toExternalForm() + '/' + iron.Id+'\n';
            }
            task.Description = task.Description.removeEnd('\n');
            database.insert(task, false);
            system.debug('task =====>'+task);
        }
    }
}