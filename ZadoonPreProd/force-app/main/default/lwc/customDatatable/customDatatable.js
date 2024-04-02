import { LightningElement, api, track } from 'lwc';
export default class CustomDatatable extends LightningElement {
    @api columns;
    @api isHideCheckBox;
    @api isShowRowNumber;
    // Used to store data that need to be show.
    listOfRecords;
    // Used to store all records.
    @api records;
    // Used to show number of pages required as per the number of records on page.
    totalPages;
    differentPageSizeOptions;
    // Used to store page option from page 1 to end page.
    totalPageOptions;
    // Used to store number of recorrds need to show on page.
    @api numberOfRecordsPerPages;
    @api numberOfSelectedRows;
    @api lstSelectedRows;
    @api isShowSelected =false;
    @track numberOfRecordsPerPage = "10";
    @track lstSelectedRows1 = [];
    lstSelectedRows2 = [];
    @track selectedRowIds = new Set();
    @track previouslySelectedRows = [];
    allrecord;
    currentPage = 1;
    


    connectedCallback() {
        console.log('recordsfrom parent::'+JSON.stringify(this.records))
        console.log('String to test..' + JSON.stringify(this.lstSelectedRows));
        if (this.lstSelectedRows != null && this.lstSelectedRows.length > 0) {
            this.lstSelectedRows1 = JSON.parse(JSON.stringify(this.lstSelectedRows));
            this.lstSelectedRows2 = JSON.parse(JSON.stringify(this.lstSelectedRows));
            this.selectedRowIds = new Set(this.lstSelectedRows);
        }
        this.numberOfRecordsPerPage = this.numberOfRecordsPerPages;
        this.allrecord = this.numberOfRecordsPerPages;
        this.getData();
        this.assignPageAttributes();
        
        //this.differentPageSizeOption();
    }

    @api refreshParentData(lstData) {
        console.log('Data from Parent ::' + JSON.stringify(lstData));
        this.records = lstData;
        this.getData();
    }

    differentPageSizeOption() {
        const existingValues = this.getExistingValues();
        const existingValues1 = this.getExistingValues().map(option => option.value);
        var options = [];
        if (!existingValues1.includes(this.numberOfRecordsPerPages)) {
            options = [
                ...existingValues,
                { label: this.numberOfRecordsPerPages, value: this.numberOfRecordsPerPages }
            ];
        }
        this.differentPageSizeOptions = options;
    }
    get differentPageSizeOption() {
        return [
            //{ label: "ALL", value: this.allrecord },
            { label: "10", value: "10" },
            { label: "20", value: "20" },
            { label: "50", value: "50" },
            { label: "100", value: "100" }
        ];
    }

    @api refershData(selectedData) {

        this.lstSelectedRows1 = JSON.parse(JSON.stringify(selectedData));
        this.lstSelectedRows2 = JSON.parse(JSON.stringify(selectedData));
        this.selectedRowIds = new Set(selectedData);
        this.reselectRows();
    }

    getTotalPageOptions() {
        let options = [];
        for (let index = 1; index <= this.totalPages; index++) {
            options.push({
                label: index.toString(), value: index.toString()
            });
        }
        this.totalPageOptions = options;
    }
    loadCustomStyles() {
        if (!this.stylesLoaded) {
            Promise.all([loadStyle(this, comboBoxStyle)])
                .then(() => {
                    console.log("Custom styles loaded");
                    this.stylesLoaded = true;
                })
                .catch((error) => {
                    console.error("Error loading custom styles", error);
                });
        }
    }
    handleChange(event) {
        if (event.currentTarget.name === "pagesizeoption") {
            this.numberOfRecordsPerPage = event.currentTarget.value;
           this.assignPageAttributes();
        } else if (event.currentTarget.name === "currentpage") {
            this.currentPage = event.currentTarget.value;
        }
        this.getData();
         this.reselectRows();
    }
    assignPageAttributes() {
        if (this.records) {
            this.totalPages = Math.ceil(this.records.length / parseInt(this.numberOfRecordsPerPage));
            this.getTotalPageOptions();
            if (this.totalPageOptions.length > 0) {
                this.currentPage = this.totalPageOptions[0].value;
                 this.reselectRows();
            }
        }
    }
    handleNextClick(event) {
        if (parseInt(this.currentPage) >= parseInt(this.totalPageOptions[this.totalPageOptions.length - 1].value)) {
            console.log('No records found');
        } else {
            this.currentPage = (parseInt(this.currentPage) + 1).toString();
            this.getData();
            this.reselectRows();
        }
    }
    get hideNextButton() {
        if (this.totalPageOptions && this.totalPageOptions.length > 0) {
            const lastOption = this.totalPageOptions[this.totalPageOptions.length - 1];
            if (lastOption && lastOption.value) {
                return parseInt(this.currentPage) >= parseInt(lastOption.value);
            }
        }
        return true; // Default value if something is undefined
    }

    handlePreviousClick(event) {
        if (this.currentPage != "1") {
            this.currentPage = (parseInt(this.currentPage) - 1).toString();
            this.getData();
            this.reselectRows();
        }
    }
    get hidePreviousButton() {
        if (this.currentPage == "1") {
            return true;
        } else {
            return false;
        }
    }
    getData() {
        if (this.records) {
           let startIndex = parseInt(this.currentPage - 1) * parseInt(this.numberOfRecordsPerPage);
            let endIndex = parseInt(this.currentPage) * parseInt(this.numberOfRecordsPerPage);
            if (endIndex > this.records.length) {
                endIndex = this.records.length;
            }
            if (startIndex >= 0 && endIndex <= this.records.length) {
                this.listOfRecords = [];
                this.listOfRecords = this.records.slice(startIndex, endIndex);
                //this.listOfRecords = this.records
            }
        } else {
            console.log('List is empty');
        }
        // this.reselectRows();
    }

    getData1(event) {
        var searchKey = event.detail.value;
        console.log('this.records:::'+JSON.stringify(this.records))
        if (this.records) {
             this.currentPage = "1";
            let startIndex = parseInt(this.currentPage - 1) * parseInt(this.numberOfRecordsPerPage);
            let endIndex = parseInt(this.currentPage) * parseInt(this.numberOfRecordsPerPage);

            // Check if searchKey is null or empty
            if (!searchKey || searchKey.trim() === '') {
                // If searchKey is null or empty, show all records
                this.getData();
                this.assignPageAttributes();
            } else {
                // Filter records based on search criteria
                const filteredRecords = this.records.filter(record => {
                    const searchCriteria = searchKey.toLowerCase();
                    return (
                        record.Name.toLowerCase().includes(searchCriteria) ||
                        (record.email || '').toLowerCase().includes(searchCriteria)
                    );
                });
               
               // Update the total number of pages based on filtered records
                this.totalPages = Math.ceil(filteredRecords.length / parseInt(this.numberOfRecordsPerPage));
                this.getTotalPageOptions();

                if (endIndex > filteredRecords.length) {
                    endIndex = filteredRecords.length; console.log('List is empty'+endIndex);
                }

                if (startIndex >= 0 && endIndex <= filteredRecords.length) {
                    this.listOfRecords = filteredRecords.slice(startIndex, endIndex);
                    console.log('List is empty 202');
                }
            }
        } else {
            console.log('List is empty');
        }
        // this.reselectRows();
    }


    handleRowAction(event) {
        
        switch (event.detail.config.action) {
            case 'selectAllRows':
            
        console.log('selectedRows:::2' + JSON.stringify(this.selectedRowIds));
                for (let i = 0; i < event.detail.selectedRows.length; i++) {
                    this.selectedRowIds.add(event.detail.selectedRows[i].Id);
                }
                break;
            case 'deselectAllRows':
                this.selectedRowIds = new Set();
                break;
            case 'rowSelect':
                this.selectedRowIds.add(event.detail.config.value);
                break;
            case 'rowDeselect':
                const idToRemove =(event.detail.config.value);
                this.selectedRowIds.delete(idToRemove);
                
                break;
            default:
            
                break;
        }
       // this.handleFireEvent('select', this.selectedRowIds);
         this.handleFireEvent('select', Array.from(this.selectedRowIds));
        this.reselectRows();
    }




    // Helper method to reselect rows based on selectedRowIds
    reselectRows() {
        this.lstSelectedRows2 = [...this.lstSelectedRows1];
    }


   
    

    handleFireEvent(name, value) {
        const customEvent = new CustomEvent(name, {
            detail: {
                value: value
            }
        });
        this.dispatchEvent(customEvent);
    }

}