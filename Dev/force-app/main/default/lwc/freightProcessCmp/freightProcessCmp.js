import { LightningElement, api,track } from 'lwc';
import comboBoxStyle from '@salesforce/resourceUrl/comboBoxStyle';
import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContactData from '@salesforce/apex/FreightProcessCmpController.getContactData';
import SendFreightEmails from '@salesforce/apex/FreightProcessCmpController.SendFreightEmails';
import getInitialFreightData from '@salesforce/apex/FreightProcessCmpController.getInitialFreightData';

const columns=[{label:'Name',fieldName:'recordLink', type:'url',
typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
},
{label:'Primary Contact Name',fieldName:'recordLink1', type:'url',
typeAttributes: { label: { fieldName: 'ContactName' }, target: '_blank' }
},
{label:'Email',fieldName:'Email',type:'text'},
{label:'Phone ',fieldName:'Phone',type:'text'},
];
export default class FreightProcessCmp extends LightningElement {

    @api recordId;
    clientTypeValue;
    title = "Send Email For Freight Process";
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
    numberOfSelectedRows;
    selectedRows ='';
    searchKey;
    @track freightReccord;

    connectedCallback() {
        this.columns = columns;
        this.init();
    }

    renderedCallback() {
        this.loadCustomStyles();
    }

    handleFilterSelect(event) {
        this.spinnerToggle();
        this.clientTypeValue = event.detail.clientType;
        this.isFilter = false;
        this.isListOfContacts = true;
        var wrapperData = {
            "clientType": this.clientTypeValue,
            "searchKey":null
        }
        //this.spinnerToggle();
            console.log('this.numberOfRecordsPerPage wrapperData::: ' + JSON.stringify(wrapperData));
            // this.spinnerToggle();
        this.getData(wrapperData,true);
         this.spinnerToggle();
    }

    handleClose() {
        this.closeQuickAction();
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
    
    init() {
        this.spinnerToggle();
        getInitialFreightData({
                recordId: this.recordId
            })
            .then(result => {
                if (result.isSuccess) {
                    this.freightReccord = JSON.parse(result.response);
                    this.refreshData0(this.freightReccord);
                    console.log('freightReccord is not empty:::' + JSON.stringify(this.freightReccord));
                   // this.validateData(this.lstRecords);
                    this.spinnerToggle();
                    this.error = undefined;
                } else {
                    this.spinnerToggle();
                    this.showToast('error', result.message, result.response);
                    this.handleClose(); 
                }

            })
            .catch(error => {
                this.showToast('error', error.message, error.body);
                this.spinnerToggle();
                this.handleClose();
            });
    }

    handleSearchKeyChange(event){
        let strKey = event.detail.value;
        this.searchKey = event.detail.value;
        if(strKey.length >3){
            console.log('strKey Is not empty:::' + strKey);
        var wrapperData = {
            "clientType": this.clientTypeValue,
            "searchKey": strKey
        }
        
            console.log('this.numberOfRecordsPerPage wrapperData::: ' + JSON.stringify(wrapperData));
        this.getData(wrapperData,false);
        }else{
            var wrapperData = {
            "clientType": this.clientTypeValue,
            "searchKey":null
        }
        
            console.log('this.numberOfRecordsPerPage wrapperData::: ' + JSON.stringify(wrapperData));
        this.getData(wrapperData,false);
        }
    }

    getData(wrapper,isOnLoad) {
        if(isOnLoad){
        this.spinnerToggle();
        }
        getContactData({
                wrapperKey: JSON.stringify(wrapper)
            })
            .then(result => {
                if (result.isSuccess) {
                    this.lstRecords = [];
                    this.lstRecords = this.createCustomUrlRecord(JSON.parse(result.response));
                    console.log('List is  not empty:::' + JSON.stringify(this.lstRecords));
                    this.validateData(this.lstRecords);
                    this.refreshQueryData(this.lstRecords);
                    if(isOnLoad){
                    this.spinnerToggle();
                    }
                    this.error = undefined;
                } else {
                    if(isOnLoad){
                    this.spinnerToggle();
                    }
                    this.showToast('error', result.message, result.response);
                }

            })
            .catch(error => {
                this.showToast('error', error.message, error.body);
                if(isOnLoad){
                this.spinnerToggle();
                }
            });
    }

     refreshQueryData(data) {
        console.log('String to Refresh iss called..'+ JSON.stringify(data));
        const toggleList = this.template.querySelectorAll('c-custom-datatable');
        for (const toggleElement of toggleList) {
            toggleElement.refreshParentData(data);
        }
    }

    onSendEmail(){
         this.spinnerToggle();
        SendFreightEmails({
                freightWrappedData: JSON.stringify(this.freightReccord),
                lstSelectedAccountIds : this.selectedRows,
                wrappedAccountData : JSON.stringify(this.lstRecords),
                UnitId : this.recordId
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

    spinnerToggle() {
        this.showSpinner = !this.showSpinner;
    }

    handlePreviousButton(){
        this.isFilter = true;
        this.isListOfContacts = false;
    }

    handleFilterPrevious(){
        this.isFilter = false;
        this.isFreightScreen = true;
        this.refreshData0(this.freightReccord);
    }

    handleFreightData(event){
        this.freightReccord='';
       this.freightReccord = event.detail.value;
       console.log('Data from Freight Screen :::'+JSON.stringify(this.freightReccord));
        this.isFreightScreen = false;
        this.isFilter = true;
    }

    handleSendEmail(){
        if(this.selectedRows.length>0){
            this.onSendEmail();
        }else{
            this.showToast('error', 'Error on Sending The Email To Freight!!', 'Select at least One Row to send the email!!');
        }
        
    }

    handleCancelButton(){
        this.selectedRows = '';
    const data =[];
    this.refreshData(data);
    }

    refreshData(data) {
        console.log('String to Refresh iss called..'+ JSON.stringify(data));
        const toggleList = this.template.querySelectorAll('c-custom-datatable');
        for (const toggleElement of toggleList) {
            toggleElement.refershData(data);
        }
    }

    refreshData0(data) {
        console.log('String to Refresh iss called..'+ JSON.stringify(data));
        const toggleList = this.template.querySelectorAll('c-new-freight-process-record ');
        for (const toggleElement of toggleList) {
            toggleElement.refreshData(data);
        }
    }

    handleSelectedRows(event) {
        this.selectedRows = event.detail.value;
        this.numberOfSelectedRows = this.selectedRows.length;
        console.log('Selected List data :::::' + JSON.stringify(this.selectedRows));
        this.refreshData(this.selectedRows);

    }
    
    createCustomUrlRecord(data){

        var tempOppList = [];  
        for (var i = 0; i < data.length; i++) {  
            let tempRecord = Object.assign({},data[i]); //cloning object  
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