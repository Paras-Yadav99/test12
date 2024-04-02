import { LightningElement, track, api, wire } from 'lwc';
import getDuplicateAccounts from '@salesforce/apex/ShowDuplicateAccountController.getDuplicateAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [{
    label: 'Name', fieldName: 'recordLink', type: 'url',
    typeAttributes: { label: { fieldName: 'name' }, target: '_blank' }
},
{ label: 'Phone', fieldName: 'phone', type: 'text' },
{ label: 'Client Region', fieldName: 'clientRegion', type: 'text' },
{ label: 'Client Type', fieldName: 'clientType', type: 'text' },
];
export default class ShowDuplicateAccount extends LightningElement {

    @api recordId;
    @track columns = [];
    @track lstRecords = [];
    @track lstAllRecords = [];
    @track numberOfRecordsPerPage = "10";
    @track showSpinner = false;
    @track isData = false;
    @track isShowMore = false;
    @track isShowLess = false;
    @track title = 'Duplicate Accounts';
    columns = columns;

    connectedCallback() {
        this.spinnerToggle();
        this.init();
        this.spinnerToggle();

    }
    handleWonOppShowMore() {
        this.isShowLess = true;
        this.lstRecords = this.lstAllRecords;
        this.isShowMore = false;

    }
    handleWonOppShowLess() {
        this.isShowLess = false;
        this.lstRecords = this.lstAllRecords.slice(0, 5);
        this.isShowMore = true;
    }

    initColumns() {
        this.columns = columns;
    }

    init() {
          this.spinnerToggle();
          getDuplicateAccounts({ recordId: this.recordId })
              .then(result => {
                  if (result.isSuccess) {
                      let wrapperData = JSON.parse(result.response);
                      this.lstAllRecords = this.createCustomUrlRecord(wrapperData);
                      console.log('List is  not empty:::' + JSON.stringify(this.lstAllRecords));
                      this.validateData(this.lstAllRecords);
                      this.spinnerToggle();
                      this.error = undefined;
                  } else {
                      this.spinnerToggle();
                      this.showToast('error', result.message, result.response);
                  }
  
              })
              .catch(error => {
                  this.showToast('error', error.message, error.body);
                  this.spinnerToggle();
              });
    }

    validateData(wrappedData) {

        if (wrappedData != null && wrappedData.length > 0) {
            this.isData = true;
            var strTilte ='Duplicate Accounts ('+ wrappedData.length  +')';
            this.title = strTilte;
            if (wrappedData.length > 5) {
                this.isShowMore = true;
                this.lstRecords = wrappedData.slice(0, 5);
            } else {
                this.lstRecords = wrappedData;
            }
        }
    }

    spinnerToggle() {
        this.showSpinner = !this.showSpinner;
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

    createCustomUrlRecord(data) {

        var tempOppList = [];
        for (var i = 0; i < data.length; i++) {
            let tempRecord = Object.assign({}, data[i]); //cloning object  
            tempRecord.recordLink = "/" + tempRecord.id;
            tempOppList.push(tempRecord);
        }
        return tempOppList;
    }

}