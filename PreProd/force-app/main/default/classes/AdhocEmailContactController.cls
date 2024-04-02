public with sharing class AdhocEmailContactController {
    
    //variable used for pagination.
    Public Integer noOfRecords {get; set;}
    public Integer PAGE_SIZE  = 10;
    public Integer startIndex {get; set;}
    public Integer endIndex {get; set;}
    public Integer totalPages {get; set;}
    public Integer Page = 1;
    public String selectedPage_Size {get;set;}
    public List< SelectOption > paginationSizeOptions{
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
    public List< SelectOption > categoryList 	{ get; set; }
    public String selectedCategory			{ get; set; }
    public Map< Id , Contact > selectedContactMap {get; set;}
    Public List< WrapperClass > wrapperRecordList {get; set;}
    public Map< Id, WrapperClass > mapHoldingSelectedRecords;
    public String error {get; set;}
    public Integer SelectedConCount {get; set;}
    private apexPages.StandardSetController controller {get; set;}
    // Search keys
    public String minYear					{ get; set; }
    public String maxYear					{ get; set; }
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
    public AdhocEmailContactController(apexPages.StandardSetController controller) {
        this.controller = controller;
        mapHoldingSelectedRecords = new Map < Id, WrapperClass >();
        SelectedConCount = 0;
        init();
    }
    
    private void init() {
        try {
            error = '';
            wrapperRecordList = new List< WrapperClass >();
            selectedContactMap = new Map < Id, Contact >([SELECT id,FirstName,LastName, Email From Contact Where ID IN :controller.getSelected() AND Email != null]);
            if(selectedContactMap != null) SelectedConCount = selectedContactMap.size();
            if( SelectedConCount == 0 )
                return;
            categoryList = UtilityClass.getPicklistEntry('Equipment__c','Category__c');
            startIndex = (page-1)*PAGE_SIZE;
            endIndex = page*PAGE_SIZE;
            List< Product2 > productList = getProducts();
            noOfRecords = productList != null ? productList.size() :0;
            Integer totalRec = 0;
            for( Product2 pro : productList ) {
                if( totalRec >= startIndex && totalRec < endIndex ) {
                    if( mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(pro.id) ) {
                        wrapperRecordList.add( mapHoldingSelectedRecords.get(pro.id) );
                    }else {
                        wrapperRecordList.add( new WrapperClass(pro,false) );
                    }
                }
                totalRec++;
            }
            totalPages = (Integer)((Decimal)totalRec/PAGE_SIZE).round(RoundingMode.UP);
            system.debug('wrapperRecordList ===>'+wrapperRecordList.size());
        }catch(Exception ex) {
            error = utilityClass.ERROR_MSG+'<br/> Technical issue: '+ex.getMessage()+', Exception Type: '+ex.getTypeName()+', At Line: '+ex.getLineNumber();
        }
    }
    
    private List< Product2 > getProducts() {
        String filter = '';
        if( String.isNotBlank(selectedCategory) ) {
            filter += 'Category__c ='+' \'' + String.escapeSingleQuotes(selectedCategory.trim()) + '\''; 
        }
        if( String.isNotBlank(minYear) ) {
            if( String.isNotBlank(filter) ) filter += ' AND ';
            filter += 'Year__c >='+' \'' + String.escapeSingleQuotes(minYear.trim()) + '\'' ;
        }
        if( String.isNotBlank(maxYear) ) {
            if( String.isNotBlank(filter) ) filter += ' AND ';
            filter += 'Year__c <='+' \'' + String.escapeSingleQuotes(maxYear.trim()) + '\'' ;
        }
        if( String.isNotBlank(make) ) {
            if( String.isNotBlank(filter) ) filter += ' AND ';
            filter += 'Manufacturer__c ='+' \'' + String.escapeSingleQuotes(make.trim()) + '\'' ;
        }
        if( String.isNotBlank(model) ) {
            if( String.isNotBlank(filter) ) filter += ' AND ';
            filter += 'Model__c ='+' \'' + String.escapeSingleQuotes(model.trim()) + '\'' ;
        }
        if( minWeight !=null && minWeight > 0.0 ) {
            if( String.isNotBlank(filter) ) filter += ' AND ';
            filter += 'Operating_Weight__c >=' +minWeight;
        }
        if( maxWeight !=null && maxWeight > 0.0 ) {
            if( String.isNotBlank(filter) ) filter += ' AND ';
            filter += 'Operating_Weight__c <=' +maxWeight;
        }
        if( minHour != null && minHour > 0.0 ) {
            if( String.isNotBlank(filter) ) filter += ' AND ';
            filter += 'Hour__c >=' +minHour;
        }
        if( maxHour != null && maxHour > 0.0 ) {
            if( String.isNotBlank(filter)) filter += ' AND ';
            filter += 'Hour__c <=' +maxHour;
        }
        if( minPrice != null && minPrice > 0.0 ) {
            if( String.isNotBlank(filter) ) filter += ' AND ';
            filter += 'Starting_Advertised_Retail_Price__c	 >=' +minPrice;
        }
        if( maxPrice != null && maxPrice > 0.0 ) {
            if( String.isNotBlank(filter) ) filter += ' AND ';
            filter += 'Starting_Advertised_Retail_Price__c <=' +maxPrice;
        }
        if( String.isNotBlank(unitCode) ) {
            if( String.isNotBlank(filter) ) filter += ' AND ';
            filter += 'Name LIKE'+'\'%' + String.escapeSingleQuotes(unitCode.trim()) + '%\'';
        }
        filter = filter.removeEnd('AND');
        system.debug('filter---->'+filter);
        List< String > productFields = UtilityClass.getAllFields('Product2');
        String query = 'Select '+String.join(productFields, ',')+' From Product2';
        if( String.isNotBlank(filter) ) {
            query += ' WHERE '+filter+' AND isActive = true';
        }else {
            query += ' WHERE isActive = true';
        }
        
        system.debug('query========>'+query);
        return database.query(query);
    }
    
    public void search() {
        updateSelectedRecordsMap();
        init();
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
        init();
    }
    
    // indicates whether there are more records before the current page set
    public Boolean hasPrevious {
        get{ if( page > 1 ){
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
    public void refreshPageSize() {
        updateSelectedRecordsMap();
        PAGE_SIZE = Integer.valueOf(selectedPage_Size);
        init();
        
    }
    
    // update the map with the selected product records
    Private void updateSelectedRecordsMap() {
        try {
            for( WrapperClass wrp : wrapperRecordList) {
                if( wrp.isSelected ) {
                    mapHoldingSelectedRecords.put( wrp.pro.id, wrp );
                }
                if( !wrp.isSelected && mapHoldingSelectedRecords.containsKey(wrp.pro.id) ) {
                    mapHoldingSelectedRecords.remove( wrp.pro.id );
                }
            }
            system.debug('product size: '+mapHoldingSelectedRecords.size());
        }catch( Exception ex ) {
            error = utilityClass.ERROR_MSG+'<br/> Technical issue: '+ex.getMessage()+', Exception Type: '+ex.getTypeName()+', At Line'+ex.getLineNumber();
            system.debug('error occured ===>'+ex+ 'line number     '+ex.getLineNumber());
        }
    }
    
    // send email to the selected contacts with unit details
    public void sendEmail() {
        try {
            updateSelectedRecordsMap();
            system.debug('product size: '+mapHoldingSelectedRecords.size());
            List <Product2 > tempProduct = new List <Product2> ();
            for( WrapperClass wrp : mapHoldingSelectedRecords.values()) {
                if(wrp.isSelected)
                    tempProduct.add(wrp.pro);
            }
            error = AdhocEmailUnitController.sendEmailUtil(selectedContactMap.keySet(),tempProduct);
        } catch( Exception ex ) {
            error =utilityClass.ERROR_MSG+'<br/> Technical issue: '+ex.getMessage()+', Exception Type: '+ex.getTypeName()+', At Line: '+ex.getLineNumber();
            system.debug('error occured====> '+ex+'  line Number  =='+ex.getLineNumber());
        }
    }
}