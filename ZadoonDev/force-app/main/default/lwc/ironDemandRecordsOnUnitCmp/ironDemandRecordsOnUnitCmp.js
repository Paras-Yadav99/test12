import { LightningElement,api } from 'lwc';
import comboBoxStyle from '@salesforce/resourceUrl/comboBoxStyle';
import { loadStyle } from "lightning/platformResourceLoader";
import getIronDemandRecords from '@salesforce/apex/IronDemandRecordsOnUnitCmpController.getIronDemandRecords';
export default class IronDemandRecordsOnUnitCmp extends LightningElement {
    @api recordId;
    lstIronDemandrecords;
    isHideCheckBox = true;
    isShowRowNumber = true;
    numberOfRecordsPerPage = "10";
    showSpinner = false;
    showData = false;
    totalRecords;
    connectedCallback() {
         getIronDemandRecords({ recordId: this.recordId}).then(result => {
            this.showSpinner = true;
            console.log('result::' + JSON.stringify(result));
            console.log('resultlstIronDemand::' + JSON.stringify(result.lstIronDemand));
            if (result.isSuccess) {
                this.lstIronDemandrecords = result.lstIronDemand.map(record => {
                        return {
                            ...record,
                            url: '/' + record.Id 
                        };
                    });              ;
                console.log('this.lstIronDemandrecords::'+JSON.stringify(this.lstIronDemandrecords));
                this.showSpinner = false;
                this.totalRecords = result.lstIronDemand.length;
                this.showData = true;
                console.log('this.showData::'+this.showData);

            }
            else{
                this.showSpinner = false;
            }
        }).catch(error => {
            this.showSpinner = false;
        
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
        { label: 'Make', fieldName: 'Make', type: 'text' },
        { label: 'Model', fieldName: 'Model', type: 'text' },
    ];

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
}