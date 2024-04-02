import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getContactList from '@salesforce/apex/UnitFilterController.getContactList';
import getFilteredContactList from '@salesforce/apex/UnitFilterController.getFilteredContactList';
import sendEmailToContact from '@salesforce/apex/UnitFilterController.sendEmailToContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BILLING_STATE_FIELD from '@salesforce/schema/Account.BillingStateCode';
import CLIENT_TYPE_FIELD from '@salesforce/schema/Account.Client_Type__c';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

const columns = [
    {
        label: 'Name', fieldName: 'contactName', sortable: true,
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    { label: 'Email', fieldName: 'Email', type: 'text', sortable: true },
    { label: 'Secondary Email', fieldName: 'Secondary_Email__c', type: 'text', sortable: true },

];

export default class SelectContacts extends LightningElement {
    @api selectedUnitsData;
    @api unitIds;
    @track data;
    @track _sourceData;
    @track selectedRowsByPage = {};
    @track preSelectedRows = [];
    @track defaultRecordTypeId;
    billingStatePickVal = [];
    error;
    columns = columns;
    rowCount = 0;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    @track searchString ='';
    @track accountBillingState ='';
    @track accountClientTypes ='';
    accountObjectName = 'Account';
    @track isLoading = false;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accCustomMetadataHandler({data,error}) {
    if(data) {
        console.log('eeeee',data);
        this.defaultRecordTypeId = data.defaultRecordTypeId;
    }
    if(error) {
        this.error = error;
    }
}

    @wire(getPicklistValues, {
        recordTypeId: '$defaultRecordTypeId',
        fieldApiName: BILLING_STATE_FIELD
    })
    levelPicklistValues;

    @wire(getPicklistValues, {
        recordTypeId: '$defaultRecordTypeId',
        fieldApiName: CLIENT_TYPE_FIELD
    })
    clientTypePicklistValues;

    //On component initiation
    connectedCallback() {
        this.isLoading = true;
        console.log(this.selectedUnitsData);
        this.unitIds = JSON.parse(this.selectedUnitsData);
        getContactList()
            .then(result => {
                // set @track contacts variable with return contact list from server  
                this._sourceData = result;
                this.gotoPage(1);
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message,
                });
                this.dispatchEvent(event);
                // reset contacts var with null   
                this._sourceData = null;
            });
    }

    @api
    sendEmail() {
        if (!this.selectedRowsByPage || !(Object.values(this.selectedRowsByPage).length > 0)) {
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'No Contact Is Selected To Send Email',
            });
            this.dispatchEvent(event);
        } else {
            let conList = Object.values(this.selectedRowsByPage);
            let conIds = [];
            conList.forEach(element => {
                conIds.push(...element);
            });

            sendEmailToContact({ conIds: conIds, unitIds: this.unitIds }).then(result => {
                const closeModelEvent = new CustomEvent('closemodel');
                this.dispatchEvent(closeModelEvent);

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
        }
    }

    @track
    ascSortedByName = false;
    doSorting(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        if (this.sortedBy == 'contactName') {
            this.sortedBy = 'Name';
            if (this.sortDirection == 'asc' && this.ascSortedByName) {
                this.sortDirection = 'desc';
                this.ascSortedByName = false;
            } else if (this.sortDirection == 'asc' && !this.ascSortedByName) {
                this.ascSortedByName = true;
            } else {
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
        let isReverse = direction === 'asc' ? 1 : -1;
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

    updateSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;
        if (this.selectedRowsByPage[this.currentPage]) {
            this.rowCount = this.rowCount - this.selectedRowsByPage[this.currentPage].length;
        }
        this.rowCount = this.rowCount + selectedRows.length;
        this.selectedRowsByPage[this.currentPage] = [];
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedRowsByPage[this.currentPage].push(selectedRows[i].Id);
        }
    }

    // Maximum ammount of data rows to display at one time
    @api
    get displayAmmount() { return this._displayAmmount };
    set displayAmmount(value) {
        this._displayAmmount = value;
        this.gotoPage(1);                                   // If pagination size changes then we need to reset
    }
    _displayAmmount = 10;

    get options() {
        return [
            { label: '10', value: 10 },
            { label: '20', value: 20 },
            { label: '30', value: 30 },
        ];
    }

    changePageSize(event) {
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
        var maxPages = this.getMaxPages();
        if (nextPage > 0 && nextPage <= maxPages) {
            this.gotoPage(nextPage);
        }
    }

    // On previous click
    handleButtonPrevious() {
        var nextPage = this.currentPage - 1;
        var maxPages = this.getMaxPages();
        if (nextPage > 0 && nextPage <= maxPages) {
            this.gotoPage(nextPage);
        }
    }

    handleButtonFirst() {
        this.disabledPreviousButton = true;
        this.gotoPage(1);
    }

    handleButtonLast() {
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
        if (this._sourceData) {
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
        this.isLoading = true;
        this.loading = true;
        maximumPages = this.getMaxPages();
        // Validate that desired page number is available
        if (pageNumber > maximumPages || pageNumber < 0) {
            // Invalid page change. Do nothing
            this.loading = false;
            this.isLoading = false;
            return;
        }

        // Reenable both buttons
        this.disabledPreviousButton = false;
        this.disabledNextButton = false;

        // Is data source valid?
        if (this._sourceData) {
            // Empty the data source used 
            //this.pagedData = [];
            let pData = [];
            // Start the records at the page position
            recordStartPosition = this.displayAmmount * (pageNumber - 1);
            // End the records at the record start position with an extra increment for the page size
            recordEndPosition = recordStartPosition + parseInt(this.displayAmmount, 10);

            // Loop through the selected page of records
            for (i = recordStartPosition; i < recordEndPosition; i++) {
                if (this._sourceData[i]) {
                    arrayElement = JSON.parse(JSON.stringify(this._sourceData[i]));

                    if (arrayElement) {
                        arrayElement.contactName = '/' + arrayElement.Id;
                        pData.push(arrayElement);
                    }
                }
            }
            this.currentPage = pageNumber;

            this.pagedData = JSON.parse(JSON.stringify(pData));
            this.preSelectedRows = [];
            if (this.selectedRowsByPage['' + this.currentPage]) {
                this.selectedRowsByPage['' + this.currentPage].forEach(element => {
                    this.preSelectedRows.push(element);
                });
            }
            // Set global current page to the new page

            // If current page is the final page then disable the next button
            if (maximumPages === this.currentPage) {
                this.disabledNextButton = true;
            }

            // If current page is the first page then disable the previous button
            if (this.currentPage === 1) {
                this.disabledPreviousButton = true;
            }
            this.loading = false;
            this.isLoading = false;
        }
    }

    handleSelectAll(event) {
        if (this.selectedRowsByPage[this.currentPage]) {
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

    handleDeselectAll(event) {
        if (this.selectedRowsByPage[this.currentPage]) {
            this.rowCount = this.rowCount - this.selectedRowsByPage[this.currentPage].length;

        }
        this.selectedRowsByPage[this.currentPage] = [];
        this.preSelectedRows = [];

    }

    updatePagedData(event) {
        
        console.log(event.target.name);
        
            if(event.target.name =='searchText'){
                this.searchString = event.target.value;
                
            }
            if(event.target.name =='billingState'){
                this.accountBillingState = event.target.value;
                
            }
            if(event.target.name =='clientType'){
                this.accountClientTypes = event.target.value;
                
            }
            console.log('1',this.accountClientTypes);
        console.log('2',this.accountBillingState);
        console.log('3',this.searchString);
            
        /*this.gotoPage(this.currentPage);
        try{

            if (this.searchString || this.accountClientTypes ||   this.accountBillingState) {
                let pData = [];
                let pData1 = [];
                let pData2 = [];
                let pData3 = [];
                pData3 =  JSON.parse(JSON.stringify(this.pagedData));;
                
                if(this.accountClientTypes != ''){
                    pData1 = pData3.filter(row => {
    
                        console.log(row);
                        if ( (row.Account_Client_Type__c && this.accountClientTypes != '' && row.Account_Client_Type__c != null 
                            && row.Account_Client_Type__c == this.accountClientTypes)
                            )
                            return true;
        
                    });
    
                }
                else{
                    pData1 = pData3;
    
                }
                if(this.accountBillingState != ''){
                    pData2 = pData1.filter(row => {
    
                        console.log(row);
                        if (  ( row.Account && row.Account.BillingStateCode && this.accountBillingState != '' && row.Account  != null && 
                        row.Account.BillingStateCode  != null && this.accountBillingState &&
                         row.Account.BillingStateCode == this.accountBillingState)
                            )
                            return true;
        
                    });
    
                }
                else{
                    pData2 = pData1;
    
                }
                if(this.searchString != ''){
                    pData = pData2.filter(row => {
    
                        console.log(row);
                        if ((this.searchString != '' &&
                            (row.Name && row.Name.includes(this.searchString)) ||
                            (row.Email && row.Email.includes(this.searchString)) ||
                            (row.Secondary_Email__c && row.Secondary_Email__c.includes(this.searchString))))
                            return true;
        
                    });
    
                }
                else{
                    pData = pData2;
    
                }
    
                
                this.pagedData = JSON.parse(JSON.stringify(pData));
            }
        }
        catch(error){
            console.log(error);

        }*/
        this.isLoading = true;
        getFilteredContactList({accountBillingState: this.accountBillingState,
            accountClientTypes: this.accountClientTypes,
            searchString: this.searchString})
            .then(result => {
                console.log(result.mapResponse.objectName);
                if (result.bIsSuccess) {
                    
                    this._sourceData = result.mapResponse.objectName;
                this.gotoPage(1);
                this.isLoading = false;
                    

                }
                else{
                    this._sourceData = null;
                    this.pagedData = [];
                    this.gotoPage(1);
                    this.isLoading = false;

                }
                // set @track contacts variable with return contact list from server  
                
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: 'no record found',
                });
                this.dispatchEvent(event);
                // reset contacts var with null   
                this._sourceData = null;
            });
        

        
        
    }
}