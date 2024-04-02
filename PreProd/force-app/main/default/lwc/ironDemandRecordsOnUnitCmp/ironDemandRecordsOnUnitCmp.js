import { LightningElement, api } from 'lwc';
import comboBoxStyle from '@salesforce/resourceUrl/comboBoxStyle';
import { loadStyle } from "lightning/platformResourceLoader";
import getIronDemandRecords from '@salesforce/apex/IronDemandRecordsOnUnitCmpController.getIronDemandRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class IronDemandRecordsOnUnitCmp extends LightningElement {
    @api recordId;
    lstIronDemandrecords;
    isHideCheckBox = true;
    isShowRowNumber = true;
    numberOfRecordsPerPage = "10";
    showSpinner = false;
    showData = false;
    isShowSelected = true;
    totalRecords;
    errorMessage;

    connectedCallback() {
        this.Init();
    }

    Init() {
        getIronDemandRecords({ recordId: this.recordId }).then(result => {
            this.showSpinner = true;
            if (result.isSuccess) {
                this.lstIronDemandrecords = result.lstIronDemand.map(record => {
                    return {
                        ...record,
                        url: '/' + record.Id,
                        urlContact: '/' + record.ContactId
                    };
                });
                this.showSpinner = false;
                this.totalRecords = result.lstIronDemand.length;
                this.showData = true;

            }
            else {
                this.showSpinner = false;
                this.errorMessage = result.message;
                //this.showToast('Error', 'Error', result.message);
            }
        }).catch(error => {
            this.showSpinner = false;
           // this.showToast('Error', 'Error', error.message);
        });
    }

    renderedCallback() {
        this.loadCustomStyles();
    }
    columns = [
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
        { label: 'Equipment', fieldName: 'Equipment', type: 'text' },
        { label: 'IsActive', fieldName: 'IsActive', type: 'text' },
        // { label: 'Make', fieldName: 'Make', type: 'text' },
        { label: 'Model', fieldName: 'Model', type: 'text' },
        {
            label: 'ContactName',
            fieldName: 'urlContact',
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'ContactName'
                },
                target: '_blank'
            }
        }
        // { label: 'ContactName', fieldName: 'ContactName', type: 'text' },
    ];

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