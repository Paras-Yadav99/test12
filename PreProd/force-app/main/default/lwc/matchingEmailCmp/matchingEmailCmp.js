import { LightningElement, track, wire } from 'lwc';
import comboBoxStyle from '@salesforce/resourceUrl/comboBoxStyle';
import { loadStyle } from "lightning/platformResourceLoader";
import getactiveUnitsRecord from '@salesforce/apex/MatchingEmailCmpController.getactiveUnitsRecord';
import getAccountRecords from '@salesforce/apex/MatchingEmailCmpController.getAccountRecords';
import getPicklistValues from '@salesforce/apex/MatchingEmailCmpController.getPicklistValues';
import sendEmailFromMarketingCloud from '@salesforce/apex/MatchingEmailCmpController.sendEmailFromMarketingCloud';
import getunitRecordsBasedOndealer from '@salesforce/apex/MatchingEmailCmpController.getunitRecordsBasedOndealer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class MatchingEmailCmp extends LightningElement {
    @track DealerEmail = false;
    @track AdvertisingEmail = false;
    @track title = "Send Marketing Email";
    @track selectionScreen = true;
    @track showDealerEmail = false;
    @track showAdvertisingEmail = false;
    showActiveUnits = false;
    activeUnitRecords;
    selectedUnitId = [];
    isNextDisable = false;
    showAccountrecords = false;
    AccountRecords = [];
    showPicklistOption = false;
    showFirstScreen = true;
    showEmailButton = false;
    showNextButton = true;
    numberofSelectedRows = 0;
    isNextDisabled = true;
    showSpinner = false;
    lstSelected = [];
    @track lstOptions = [];
    @track lstAuthDealerOptions = [];
    isHideCheckBox = false;
    isShowRowNumber = true;
    numberOfRecordsPerPage = "10";
    selectedRows = [];
    isPreviousDisabled = true;
    isSendEmailDisabled = false;
    selectedUnitZID;
    clientTypePicklist = [];
    showDealerPicklistOption = false;
    showActiveUnitsWithDealerType = false;
    unitRecordsBasedOnManufacturer;
    emailType;
    AccountselectedRows;
    numberOfSelectedAccRows = 0;
    showClearButton;
    isClearDisabled = true;
    accIdFromUnit = [];

    connectedCallback() {
        getPicklistValues({ objectApiName: 'Account', fieldApiName: 'Authorized_Dealer_For__c' }).then(result => {

            if (result.isSuccess) {
                this.lstAuthDealerOptions = result.lstPicklistValue.map(option => ({ label: option, value: option }));
            }
        });

        getPicklistValues({ objectApiName: 'Account', fieldApiName: 'Client_Type__c' }).then(result => {
            if (result.isSuccess) {
                this.lstOptions = result.lstPicklistValue.map(option => ({ label: option, value: option }));
            }
        });
    }
    columns = [
        {
            label: 'Unit Name',
            fieldName: 'url',
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                },
                target: '_blank'
            }
        },
        { label: 'ZID', fieldName: 'ZID', type: 'text' },
        { label: 'Category', fieldName: 'Category', type: 'text' },
        { label: 'Account', fieldName: 'AccountName', type: 'text' },
        { label: 'SARP', fieldName: 'SARP', type: 'number' },
        { label: 'Unit Details', fieldName: 'Unit_Details', type: 'text' },
    ];
    handleChange(event) {
        const newselectedPicklist = [];
        this.lstSelected = event.detail.value;
        //Dealer type
        if (this.lstSelected.length > 0) {
            this.isNextDisabled = false;
        }
        else {
            this.isNextDisabled = true;
        }
        //
        for (let i = 0; i < this.lstSelected.length; i++) {
            newselectedPicklist.push(this.lstSelected[i]);
        }
        this.clientTypePicklist = newselectedPicklist;
    }
    
    Accountcolumns = [
        {
            label: 'Name',
            fieldName: 'url',
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                },
                target: '_blank'
            }
        },
        { label: 'Email', fieldName: 'Email', type: 'text' },
        { label: 'Primary Contact', fieldName: 'Primary_Contact', type: 'text' },

    ];
    renderedCallback() {
        this.loadCustomStyles();
    }
    handleCheckboxChange(event) {
        const checkboxValue = event.target.checked;
        if (event.target.label === 'Dealer Email') {
            this.DealerEmail = checkboxValue;
            this.emailType = event.target.label;
            if (checkboxValue) {
                this.AdvertisingEmail = false;
                this.isNextDisabled = false;
            }
            else {
                this.isNextDisabled = true;
            }
        } else if (event.target.label === 'Advertising/Price Drop Email') {
            this.AdvertisingEmail = checkboxValue;
            this.emailType = event.target.label;
            if (checkboxValue) {
                this.DealerEmail = false;
                this.isNextDisabled = false;
            }
            else {
                this.isNextDisabled = true;
            }
        }
    }
    handleNext() {
        if (this.DealerEmail) {
            this.title = 'Dealer Email';
            this.showClearButton = false;
            // Dealer type
            this.selectionScreen = false;
            if (this.lstSelected.length > 0) {
                this.isNextDisabled = false;
            }
            else {
                this.isNextDisabled = true;
            }

            this.isPreviousDisabled = false;
            this.DealerEmail = false;
            this.showDealerPicklistOption = true;
            //
        }
        //dealer type
        else if (this.showDealerPicklistOption) {
            this.showSpinner = true;
            getunitRecordsBasedOndealer({ lstAuthorizedDealer: this.clientTypePicklist }).then(result => {
                if (result.isSuccess) {
                    this.unitRecordsBasedOnManufacturer = result.unitWrapper.map(record => {
                        return {
                            ...record,
                            url: '/' + record.Id
                        };
                    });
                    this.showDealerEmail = true;
                    this.showActiveUnitsWithDealerType = true;
                    this.showClearButton = true;
                    this.showSpinner = false;
                }
                else {
                    this.showSpinner = false;
                    this.showToast('false', 'Record Not found', result.response);
                }
            }).catch(error => {

            });
            this.showDealerPicklistOption = false;
            if (this.numberOfSelectedRows > 0) {
                this.isNextDisabled = false;
            }
            else {
                this.isNextDisabled = true;
            }
        }
        else if (this.showActiveUnitsWithDealerType) {
            this.showNextButton = false;
            this.showEmailButton = true;
            this.getAccountRecords(this.selectedUnitId);
            this.showActiveUnitsWithDealerType = false;
        }
        else if (this.AdvertisingEmail) {
            this.isPreviousDisabled = false;
            this.showSpinner = true;
            this.showPicklistOption = true;
            this.showAdvertisingEmail = true;
            this.title = 'Send Advertising/Price Drop Email';
            this.selectionScreen = false;
            this.AdvertisingEmail = false;
            this.isNextDisabled = true;
            this.showSpinner = false;
        }
        else if (this.showPicklistOption) {
            this.showSpinner = true;
            getactiveUnitsRecord().then(result => {
                if (result.isSuccess) {
                    // this.activeUnitRecords = result;
                    this.activeUnitRecords = result.unitWrapper.map(record => {
                        return {
                            ...record,
                            url: '/' + record.Id // Set the URL to the record's Id
                        };
                    });
                    this.showActiveUnits = true;
                    this.showClearButton = true
                    this.accIdFromUnit = result.unitWrapper.map(item => item.Account);
                    this.showSpinner = false;
                }

            }).catch(error => {

            });
            this.showPicklistOption = false;
            if (this.selectedRows.length > 0) {
                this.isNextDisabled = false;
            } else {
                this.isNextDisabled = true;
            }
        }
        else if (this.showActiveUnits) {

            this.showPicklistOption = false;
            this.showActiveUnits = false;
            this.getAccountRecords(this.selectedUnitId);
            // this.showAccountrecords = true;
            this.showEmailButton = true;
            this.showNextButton = false;

        }
    }
    getAccountRecords(UnitIds) {
        this.showSpinner = true;
        getAccountRecords({ lstUnitid: UnitIds }).then(result => {
            this.showSpinner = true;
            if (result.isSuccess) {
                this.AccountRecords = result.AccountWrapper.map(record => {
                    return {
                        ...record,
                        url: '/' + record.Id
                    };
                });
                const ZID = result.AccountWrapper.map(item => item.ZID);
                let AccountId = result.AccountWrapper.map(item => item.Id);
                this.AccountselectedRows = AccountId;
                this.numberOfSelectedAccRows = this.AccountselectedRows.length;
                this.selectedUnitZID = JSON.stringify(ZID);
                this.showAccountrecords = true;
                this.isClearDisabled = false;
                this.refreshData(this.AccountselectedRows)
                this.showSpinner = false;
            }
        }).catch(error => {

        });
    }

    handlePrevious() {
        //Client type
        if (this.showPicklistOption) {
            this.showPicklistOption = false;
            this.showClearButton = false;
            this.selectionScreen = true;
            this.AdvertisingEmail = true;
            this.isPreviousDisabled = true;
            this.isNextDisabled = false;
        }
        else if (this.showActiveUnits) {
            this.showActiveUnits = false;
            this.showClearButton = false;
            this.showPicklistOption = true;
            this.isNextDisabled = false;

        }

        else if (this.showAccountrecords && this.emailType == 'Advertising/Price Drop Email') {
            this.showAccountrecords = false;
            this.showActiveUnits = true;
            this.showEmailButton = false;
            this.showNextButton = true;
        }

        //Dealer type
        if (this.showDealerPicklistOption) {
            this.showDealerPicklistOption = false;
            this.DealerEmail = true;
            this.selectionScreen = true;
            this.isPreviousDisabled = true;
            this.isNextDisabled = false;
        }
        else if (this.showActiveUnitsWithDealerType) {
            this.showActiveUnitsWithDealerType = false;
            this.showDealerPicklistOption = true;
            this.isNextDisabled = false;
            this.showClearButton = false;

        }
        else if (this.showAccountrecords && this.emailType == 'Dealer Email') {
            this.showAccountrecords = false;
            this.showActiveUnitsWithDealerType = true;
            this.showEmailButton = false;
            this.showNextButton = true;
            this.isClearDisabled = false;
        }
    }
    handleClose() {
        this.selectionScreen = true;
        this.showDealerPicklistOption = false;
        this.showActiveUnits = false;
        this.showAccountrecords = false;
        this.showPicklistOption = false;
        this.showEmailButton = false;
        this.showNextButton = true;
        this.isPreviousDisabled = true;
        this.isNextDisabled = true;
        this.unitRecordsBasedOnManufacturer = '';
        this.selectedUnitZID = '';
        this.AccountRecords = '';
        this.activeUnitRecords = '';
        this.clientTypePicklist = '';
        this.selectedRows = [];
        this.selectedUnitId = [];
        this.showActiveUnitsWithDealerType = false;
        this.numberOfSelectedRows = 0;
        this.AccountselectedRows = 0;
        this.numberOfSelectedAccRows = 0;
        this.showClearButton = false;
        this.AdvertisingEmail = false;
        this.DealerEmail = false;
        this.title = 'Send Marketing Email';
    }
    handleAccountRowSelection(event) {
        this.DealerEmail = false;
        this.AdvertisingEmail = false;
        this.isClearDisabled = false;
        this.AccountselectedRows = event.detail.value;
        this.numberOfSelectedAccRows = this.AccountselectedRows.length;
        this.refreshData(this.AccountselectedRows);
    }

    handleRowSelection(event) {
        this.DealerEmail = false;
        this.AdvertisingEmail = false;
        this.selectedRows = event.detail.value;
        this.numberOfSelectedRows = this.selectedRows.length;
        if (this.selectedRows.length > 0) {
            this.isNextDisabled = false;
            this.isClearDisabled = false;
        } else {
            this.isNextDisabled = true;
            this.isClearDisabled = true;
        }
        this.selectedUnitId = this.selectedRows;
        this.refreshData(this.selectedRows);
    }
    handleSendEmail(event) {
        if (this.selectedUnitId.length > 0 && this.lstSelected.length > 0 && this.selectedUnitZID.length > 0 && this.emailType == 'Advertising/Price Drop Email') {
            this.showSpinner = true;
            sendEmailFromMarketingCloud({ lstAccountId: this.selectedUnitId, lstAccountClientType: this.clientTypePicklist, lstAuthorizedDealerFor: null, lstZID: this.selectedUnitZID }).then(result => {
                if (result.isSuccess) {
                    this.showSpinner = false;
                    this.showToast('success', result.message, result.response);

                }
            }).catch(error => {
            });
        }
        else if (this.selectedUnitId.length > 0 && this.lstSelected.length > 0 && this.selectedUnitZID.length > 0 && this.emailType == 'Dealer Email') {
            this.showSpinner = true;
            sendEmailFromMarketingCloud({ lstAccountId: this.selectedUnitId, lstAccountClientType: null, lstAuthorizedDealerFor: this.clientTypePicklist, lstZID: this.selectedUnitZID }).then(result => {
                if (result.isSuccess) {
                    this.showSpinner = false;
                    this.showToast('success', result.message, result.response);

                }
            }).catch(error => {
            });
        }
        this.handleClose();
    }

    refreshData(data) {
        const toggleList = this.template.querySelectorAll('c-custom-datatable');
        for (const toggleElement of toggleList) {
            toggleElement.refershData(data);
        }
    }
    handleClear() {

        if (this.selectedRows.length > 0 && (this.showActiveUnits || this.showActiveUnitsWithDealerType)) {
            this.selectedRows = [];
            this.numberOfSelectedRows = 0;
            this.isNextDisabled = true;
            this.isClearDisabled = true;
            this.refreshData(this.selectedRows);
            this.isNextDisabled = true;
            this.isClearDisabled = true;
        }
        else if (this.AccountselectedRows.length > 0) {
            this.AccountselectedRows = [];
            this.numberOfSelectedAccRows = 0;
            this.isClearDisabled = true;
            this.refreshData(this.AccountselectedRows);
        }
    }
    showToast(variant,title,message) {
        const event = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message,
        });
        this.dispatchEvent(event);
    }
    loadCustomStyles() {
        if (!this.stylesLoaded) {
            Promise.all([loadStyle(this, comboBoxStyle)])
                .then(() => {
                    this.stylesLoaded = true;
                })
                .catch((error) => {
                    console.error("Error loading custom styles", error);
                });
        }
    }
}