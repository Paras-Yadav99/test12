import { LightningElement, api, track } from 'lwc';
import comboBoxStyle from '@salesforce/resourceUrl/comboBoxStyle';
import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContactData from '@salesforce/apex/UnitInspectionEmailCmpController.getContactData';
import getIntialdata from '@salesforce/apex/UnitInspectionEmailCmpController.getIntialdata';
import handleSendEmail from '@salesforce/apex/UnitInspectionEmailCmpController.handleSendEmail';

const columns = [{
    label: 'Name', fieldName: 'recordLink', type: 'url',
    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
},
{
    label: 'Account Name', fieldName: 'recordLink1', type: 'url',
    typeAttributes: { label: { fieldName: 'accountName' }, target: '_blank' }
},
{ label: 'Email', fieldName: 'email', type: 'text' },
{ label: 'Phone ', fieldName: 'phone', type: 'text' },
{ label: 'Address ', fieldName: 'address', type: 'text' },
];
const PAGESIZEOPTIONS = [10, 20, 40];
export default class UnitInspectionEmailCmp extends LightningElement {

    @api recordId;
    clientTypeValue;
    title = "Get Quote for Unit inspection";
    isFreightScreen = true;
    isFilter = false;
    isListOfContacts = false;
    columns = [];
    lstRecords = [];
    numberOfRecordsPerPage = "10";
    showSpinner = false;
    isData = false;
    stylesLoaded = false;
    isHideCheckBox = false;
    isShowRowNumber = true;
    selectedRows = '';
    isSendDisabled = true;
    isNewInspectionScreen = true;
    searchKey;
    inspectionData = '';
    @track freightReccord;
    pageSizeOptions = PAGESIZEOPTIONS;

    connectedCallback() {
        this.columns = columns;
        this.spinnerToggle();
        this.init(null);
        this.getUnitDataOnLoad();
        this.spinnerToggle();
    }

    renderedCallback() {
        this.loadCustomStyles();
    }

    handleFilterSelect(event) {
        this.clientTypeValue = event.detail.clientType;
        this.isFilter = false;
        this.isListOfContacts = true;
        var wrapperData = {
            "clientType": this.clientTypeValue
        }

        console.log('this.numberOfRecordsPerPage wrapperData::: ' + JSON.stringify(wrapperData));
        this.getData(wrapperData);
    }

    handleClose() {
        this.closeQuickAction();
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }


    init(strKey) {
        //this.lstRecords = [];
        // this.spinnerToggle();
        getContactData({ searchKey: strKey })
            .then(result => {
                if (result.isSuccess) {
                    this.lstRecords = this.createCustomUrlRecord(JSON.parse(result.response));
                    console.log('List is  not empty:::' + JSON.stringify(this.lstRecords));
                    this.validateData(this.lstRecords);
                    this.refreshQueryData(this.lstRecords);
                    // this.spinnerToggle();
                    this.error = undefined;
                } else {
                    // this.spinnerToggle();
                    this.showToast('error', result.message, result.response);
                }

            })
            .catch(error => {
                this.showToast('error', error.message, error.body);
                // this.spinnerToggle();
            });
    }

    getUnitDataOnLoad() {
        getIntialdata({ recordId: this.recordId })
            .then(result => {
                if (result.isSuccess) {
                    this.inspectionData = JSON.parse(result.response);
                    console.log('List is  not empty:::' + JSON.stringify(this.inspectionData));
                    //this.validateData(this.lstRecords);
                    this.refreshData0(this.inspectionData);
                    // this.spinnerToggle();
                    this.error = undefined;
                } else {
                    // this.spinnerToggle();
                    this.showToast('error', result.message, result.response);
                }

            })
            .catch(error => {
                this.showToast('error', error.message, error.body);
                // this.spinnerToggle();
            });
    }

    refreshData0(data) {
        console.log('String to Refresh iss called..' + JSON.stringify(data));
        const toggleList = this.template.querySelectorAll('c-new-unit-inspection');
        for (const toggleElement of toggleList) {
            toggleElement.refreshData(data);
        }
    }

    handleSearchKeyChange(event) {
        let strKey = event.detail.value;
        if (strKey.length > 3) {
            console.log('strKey Is not empty:::' + strKey);
            this.init(strKey);
        } else {
            this.init(null);
        }
    }

    onSendEmail() {
        this.spinnerToggle();
        handleSendEmail({
            recordId: this.recordId,
            lstSelectedContacts: this.selectedRows,
            wrapperData: JSON.stringify(this.inspectionData)

        })
            .then(result => {
                if (result.isSuccess) {
                    console.log('result is not empty:::' + JSON.stringify(result));
                    // this.validateData(this.lstRecords);
                    this.showToast('Success', result.message, result.response);
                    this.spinnerToggle();
                    this.error = undefined;
                    this.closeQuickAction();
                } else {
                    this.spinnerToggle();
                    console.log('result is not empty:::' + JSON.stringify(result));
                    this.showToast('error', result.message, result.response);
                }

            })
            .catch(error => {
                console.log('error is not empty:::' + JSON.stringify(error));
                this.showToast('error', error.message, error.body);
                this.spinnerToggle();
            });
    }

    validateData(wrappedData) {
        this.isData = false;
        if (wrappedData != null && wrappedData.length > 0) {
            //this.numberOfRecordsPerPage = JSON.stringify(wrappedData.length);
            this.isData = true;
        }
    }

    handleInspectionData(event) {
        this.inspectionData = '';
        this.inspectionData = event.detail.value;
        console.log('Data from Freight Screen :::' + JSON.stringify(this.freightReccord));
        this.isNewInspectionScreen = false;
        //this.isFilter = true;
    }

    spinnerToggle() {
        this.showSpinner = !this.showSpinner;
    }

    handlePrevious() {
        this.isNewInspectionScreen = true;
        /*this.isListOfContacts = false;*/
    }

    handleFilterPrevious() {
        /*this.isFilter = false;
        this.isFreightScreen = true;
        this.refreshData0(this.freightReccord);*/
    }


    handleSendEmail() {
        if (!this.arrayIsEmpty(this.selectedRows)) {
            this.onSendEmail();
            //this.showToast('success', 'Error on Sending The Email To Freight!!', 'Select at least One Row to send the email!!');
        } else {
            this.showToast('error', 'Error on Sending The Email To Freight!!', 'Select at least One Row to send the email!!');
        }

    }

    arrayIsEmpty(array) {
        //If it's not an array, return FALSE.
        /*if (!Array.isArray(array)) {
            return FALSE;
        }*/
        //If it is an array, check its length property
        if (array.length > 0) {
            //Return TRUE if the array is empty
            return false;
        }
        //Otherwise, return FALSE.
        return true;
    }



    handleCancelButton() {
        this.selectedRows = '';
        const data = [];
        this.refreshData(data);
    }

    refreshQueryData(data) {
        console.log('String to Refresh iss called..' + JSON.stringify(data));
        const toggleList = this.template.querySelectorAll('c-custom-datatable');
        for (const toggleElement of toggleList) {
            toggleElement.refreshParentData(data);
        }
    }

    refreshData(data) {
        console.log('String to Refresh iss called..' + JSON.stringify(data));
        const toggleList = this.template.querySelectorAll('c-custom-datatable');
        for (const toggleElement of toggleList) {
            toggleElement.refershData(data);
        }
    }

    handleRowSelection(event) {
        console.log('Records selected***' + JSON.stringify(event.detail));
    }



    handleSelectedRows(event) {
        this.selectedRows = event.detail.value;
        console.log('Selected List data :::::' + JSON.stringify(this.selectedRows));
        if (this.selectedRows.length > 0) {
            this.isSendDisabled = false;
            this.refreshData(this.selectedRows);
        } else {
            this.isSendDisabled = true;
        }
         this.refreshData(this.selectedRows);

    }

    createCustomUrlRecord(data) {

        var tempOppList = [];
        for (var i = 0; i < data.length; i++) {
            let tempRecord = Object.assign({}, data[i]); //cloning object  
            tempRecord.recordLink = "/" + tempRecord.Id;
            tempRecord.recordLink1 = "/" + tempRecord.ContactId;
            tempOppList.push(tempRecord);
        }
        return tempOppList;
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

    showToast(variant,
        title,
        message) {
        const event = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message,
        });
        this.dispatchEvent(event);
    }

}