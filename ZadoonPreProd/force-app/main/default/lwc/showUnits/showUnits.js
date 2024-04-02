import { LightningElement, track, wire , api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendEmailToIronDemandsContact from '@salesforce/apex/UnitFilterController.sendEmailToIronDemandsContact';

const columns = [
    { label: 'Name', fieldName: 'unitName', sortable:true ,
      type: 'url',
      typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}
    },
    { label: 'ZID', fieldName: 'ZID__c', type : 'text', sortable:true},
    { label: 'Year', fieldName: 'Year__c', type : 'text', sortable:true},
    { label: 'Hour', fieldName: 'Hour__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' }},
    { label: 'Last Equipment Status Confirmation', fieldName: 'Last_Equipment_Status_Confirmation__c', sortable:true},
    { label: 'Seller Account Name', fieldName: 'Seller_Account_Name__c',sortable:true},
    { label: 'Displayed Vague Location', fieldName: 'Displayed_Vague_Location__c',sortable:true},
    { label: 'Starting Advertised Retail Price', fieldName: 'Starting_Advertised_Retail_Price__c',sortable:true},
    { label: 'Display Lowest Purchase Price', fieldName: 'Display_Lowest_Purchase_Price__c',sortable:true}

];

export default class ShowUnits extends LightningElement {
    @api unitData;
    @track data;
    @track _sourceData;
    @track selectedRowsByPage = {};
    @track preSelectedRows = [];
    error;
    columns = columns;
    rowCount = 0;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    searchString;

    //On component initiation
    connectedCallback() {
        this._sourceData = JSON.parse(this.unitData);
        this.gotoPage(1);
        // Initialize data table to the specified current page (should be 1)
        //this.gotoPage(this.currentPage);
    }

    @api
    refreshData(unitStringified){
        this.unitData = unitStringified;
        this._sourceData = JSON.parse(this.unitData);
        if(this._sourceData.length>0){
            this.gotoPage(1);
        }else{
            this.pagedData = undefined;
        }
        
    }

    @track
    ascSortedByName = false;
    doSorting(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        if(this.sortedBy=='unitName'){
            this.sortedBy = 'Name';
            if(this.sortDirection == 'asc' && this.ascSortedByName){
                this.sortDirection = 'desc';
                this.ascSortedByName = false;
            }else if(this.sortDirection == 'asc' && !this.ascSortedByName){
                this.ascSortedByName = true;
            }else{
                this.sortDirection = 'asc';
            }
        }
        this.sortData(this.sortedBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        this.selectedRowsByPage = {};
        this.preSelectedRows = [];
        this.rowCount = 0;
        let parseData = JSON.parse(JSON.stringify(this._sourceData));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this._sourceData = parseData;
        this.gotoPage(1);
    }  

    updateSelectedRows(event){
        const selectedRows = event.detail.selectedRows;
        if(this.selectedRowsByPage[this.currentPage]){ 
            this.rowCount = this.rowCount - this.selectedRowsByPage[this.currentPage].length;
        }
        this.rowCount = this.rowCount +selectedRows.length;
        this.selectedRowsByPage[this.currentPage] = [];
        for ( let i = 0; i < selectedRows.length; i++ ){
            this.selectedRowsByPage[this.currentPage].push(selectedRows[i].Id);
        }
    }

    // Maximum ammount of data rows to display at one time
    @api 
    get displayAmmount() {return this._displayAmmount};     
    set displayAmmount(value) {
        this._displayAmmount = value;
        this.gotoPage(1);                                   // If pagination size changes then we need to reset
    }
    _displayAmmount = 10;

    get options() {
        return [
            { label: '10', value: 10 },
            { label: '20', value: 20 },
            { label: '30', value: 30},
        ];
    }

    changePageSize(event){
        this._displayAmmount = event.detail.value;
        this.gotoPage(1);  
    }


    // Data source for data table   
    @api 
    get sourceData() { return this._sourceData };        
    set sourceData(value) { 
        this._sourceData = value;
        this.gotoPage(1);                           // If source data changes then we need to reset
    }        

    // Partial JSON array of sourceData variable to bind to data table
    pagedData;          

    // Current page of results on display
    currentPage = 1;

    // Current maximum pages in sourceData set
    maxPages = 1;

    // Indicators to disable the paging buttons
    disabledPreviousButton = false;
    disabledNextButton = false;

    // Loading indicator
    loading = false;

    // Request reset of data table
    @api resetPaging() {
        // Initialize data table to the first page
        this.gotoPage(1);
    }

    // On next click
    handleButtonNext() {
        var nextPage = this.currentPage + 1;
        var maxPages =  this.getMaxPages();
        if(nextPage > 0 && nextPage <= maxPages) {
            this.gotoPage(nextPage);
        }
    }

    // On previous click
    handleButtonPrevious() {
        var nextPage = this.currentPage - 1;
        var maxPages =  this.getMaxPages();
        if(nextPage > 0 && nextPage <= maxPages) {
            this.gotoPage(nextPage);
        }
    }

    handleButtonFirst(){
        this.disabledPreviousButton = true;
        this.gotoPage(1);
    }

    handleButtonLast(){
        this.disabledNextButton = true;
        this.gotoPage(this.maxPages);
    }

    // How many pages of results?
    getMaxPages() {
        // There will always be 1 page, at least
        var result = 1;
        // Number of elements on sourceData
        var arrayLength;
        // Number of elements on sourceData divided by number of rows to display in table (can be a float value)
        var divideValue;
        // Ensure sourceData has a value
        if(this._sourceData) {
            arrayLength = this._sourceData.length;
            // Float value of number of pages in data table
            divideValue = arrayLength / this.displayAmmount;
            // Round up to the next Integer value for the actual number of pages
            result = Math.ceil(divideValue); 
        }
        this.maxPages = result;
        return result;
    }

    // Change page
    gotoPage(pageNumber) {
        var recordStartPosition, recordEndPosition;
        var i, arrayElement;        // Loop helpers
        var maximumPages = this.maxPages;
        this.loading = true;
        maximumPages = this.getMaxPages();
        // Validate that desired page number is available
        if( pageNumber > maximumPages || pageNumber < 0 ) {
            // Invalid page change. Do nothing
            this.loading = false;
            return;
        }

        // Reenable both buttons
        this.disabledPreviousButton = false;
        this.disabledNextButton = false;

        // Is data source valid?
        if(this._sourceData) {
            // Empty the data source used 
            //this.pagedData = [];
            let pData = [];
            // Start the records at the page position
            recordStartPosition = this.displayAmmount * (pageNumber - 1);
            // End the records at the record start position with an extra increment for the page size
            recordEndPosition = recordStartPosition + parseInt(this.displayAmmount, 10);

            // Loop through the selected page of records
            for ( i = recordStartPosition; i < recordEndPosition; i++ ) {
                if(this._sourceData[i]){
                    arrayElement = JSON.parse(JSON.stringify(this._sourceData[i]));

                    if(arrayElement) {
                        arrayElement.unitName = '/' + arrayElement.Id;
                        pData.push(arrayElement);
                    }
                }
            }
            this.currentPage = pageNumber;

            this.pagedData = JSON.parse(JSON.stringify(pData));
            this.preSelectedRows = [];
            if(this.selectedRowsByPage[''+this.currentPage]){
                this.selectedRowsByPage[''+this.currentPage].forEach(element => {
                    this.preSelectedRows.push(element);
                });
            }
            // Set global current page to the new page
            
            // If current page is the final page then disable the next button
            if(maximumPages === this.currentPage) {
                this.disabledNextButton = true;
            }

            // If current page is the first page then disable the previous button
            if(this.currentPage === 1) {
                this.disabledPreviousButton = true;
            }
            this.loading = false;
        }
    }

    handleSelectAll(event){
        if(this.selectedRowsByPage[this.currentPage]){
            this.rowCount = this.rowCount - this.selectedRowsByPage[this.currentPage].length;
        }
        this.selectedRowsByPage[this.currentPage] = [];
        this.preSelectedRows = [];
        this.pagedData.forEach(element => {
            this.selectedRowsByPage[this.currentPage].push(element.Id);
            this.preSelectedRows.push(element.Id);
        });
        this.rowCount = this.rowCount + this.preSelectedRows.length;

    }

    handleDeselectAll(event){
        if(this.selectedRowsByPage[this.currentPage]){
            this.rowCount = this.rowCount - this.selectedRowsByPage[this.currentPage].length;

        }
        this.selectedRowsByPage[this.currentPage] = [];
        this.preSelectedRows = [];
        
    }

    @track isModalOpen = false;
    @track selectUnitData;
    handleSendEmail(event){
        
        if(!this.selectedRowsByPage || ! (Object.values(this.selectedRowsByPage).length > 0)){
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'No Unit Is Selected To Send Email',
            });
            this.dispatchEvent(event);
        }else{
            let unitList = Object.values(this.selectedRowsByPage);
            let unitIds = []
            unitList.forEach(element => {
                unitIds.push(...element);
            });
            if(unitIds.length > 0){
                this.selectUnitData = JSON.stringify(unitIds);
                this.isModalOpen = true;
            }else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: 'No Unit Is Selected To Send Email',
                });
                this.dispatchEvent(event);

            }
            
        }

    }

    handleSendEmailToIronDemands(event){
        if(!this.selectedRowsByPage || ! (Object.values(this.selectedRowsByPage).length > 0)){
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'No Unit Is Selected To Send Email',
            });
            this.dispatchEvent(event);
        }else{
            let unitList = Object.values(this.selectedRowsByPage);
            let unitIds = []
            unitList.forEach(element => {
                unitIds.push(...element);
            });
            if(unitIds.length > 0){
                this.selectUnitData = JSON.stringify(unitIds);
                let unitIds1 = JSON.parse(this.selectUnitData);
                sendEmailToIronDemandsContact({unitIds: unitIds1}).then(result => {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        variant: 'Success',
                        message: 'Email Sent Succesfully',
                    });
                    this.dispatchEvent(event);
    
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: error.body.message,
                    });
                    this.dispatchEvent(event);
                });

            }else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: 'No Unit Is Selected To Send Email',
                });
                this.dispatchEvent(event);

            }
        }

    }

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    sendEmailToContacts(){
        let chilCmp = this.template.querySelector('c-select-contacts');
        chilCmp.sendEmail();
    }

    updatePagedData(event){
        this.searchString = event.detail.value;
        this.gotoPage(this.currentPage);
        if(this.searchString){
            let pData = [];
            
            pData = this.pagedData.filter(row=>{
                if( (row.Name && row.Name.includes(this.searchString)) || 
                    (row.ZID__c && row.ZID__c.includes(this.searchString)) ||
                    (row.Year__c && row.Year__c.includes(this.searchString)))
                    return true;

            });
            this.pagedData = JSON.parse(JSON.stringify(pData));
        }
    }
}