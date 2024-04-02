import { LightningElement, api, track } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/Zadoonlogo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createIntialData from "@salesforce/apex/FreightProcessFormController.createIntialData";
import updateFreightData from "@salesforce/apex/FreightProcessFormController.updateFreightData";

export default class FreightProcessForm extends LightningElement {
    zadoonLogo = My_Resource + '/logo.png';
    viewMode1 = true;
    viewMode2 = true;
    viewMode3 = false;
    @track freightRecord = { unitName: null };
    showFormPage = false;
    disableSubmit = true;
    loader = false;
    isData = false;

    bottomMessage = 'Please note: You can submit this form only once. and Quote Amount is required to submit the Response.';
    @api recordId;
    freightRecords;
    finalMessage = 'Loading...';
    test;
    test0;

    connectedCallback() {
        this.init();
    }
    renderedCallback() {
        // this.init();
    }

    init() {
        this.spinnerToggle();
        createIntialData({ wrapperKey: this.recordId })
            .then(result => {
                if (result.isSuccess) {
                    console.log('Freight Data on Loadshsddhsdhd :::::::' + result.response);
                    this.freightRecord = JSON.parse(result.response);
                    this.vaidateData(this.freightRecord);
                    this.spinnerToggle();
                    this.error = undefined;
                    console.log('Freight Data on Load on Load:::::::' + JSON.stringify(this.freightRecord));
                    console.log('Freight Data on Load :::::::' + JSON.stringify(this.freightRecord.unitName));
                } else {
                    this.spinnerToggle();
                    this.finalMessage = result.response;
                    console.log('Error ::::0' + JSON.stringify(result));
                    console.log('msg ::::0' + this.finalMessage);
                    //this.showToast('error', result.message, result.response);
                }

            })
            .catch(error => {
                console.log('Error ::::1' + JSON.stringify(error));
                this.finalMessage = 'Something gone Wrong, connect to the Zadoon once!!';
                //this.showToast('error', error.message, error.body);
               // this.showFormPage = true;
                this.spinnerToggle();
            });
    }
    vaidateData(data) {
        console.log('Data validation is called before condition');
        if (data.unitName != null) {
            this.isData = true;
            if (data.freightReadyToMove) {
                this.viewMode3 = true;
            }
            if (data.isQuoteSbmitted) {
                this.showFormPage = true;
                this.finalMessage = 'You have already responded. Thank you!';
            } else if (data.isLinkExpired) {
                this.showFormPage = true;
                this.finalMessage = 'The Freight is all-ready Selected for the Job. Thank you!';
            }
            console.log('Data validation is called in condition with ::::' + this.isData);
        }
    }

    handleSubmit() {
        //this.handleOpenPrompt();
        if (this.freightRecord.quoteAmount !== null && this.freightRecord.quoteAmount !=="") {
            this.handleSubmit1();
        } else {
            this.showFormPage = true;
            this.finalMessage = 'HeadsUp!! You missed Quote Amount, fill the form again. Thank you!';
        }

    }
    handleSubmit1() {

        console.log('Data on Sbmitt ::::0' + JSON.stringify(this.freightRecord));
        this.spinnerToggle();
        updateFreightData({ wrapperKey: JSON.stringify(this.freightRecord) })
            .then(result => {
                if (result.isSuccess) {
                    this.spinnerToggle();
                    this.finalMessage = result.response;
                    // this.showToast('Success', result.message, result.response);
                    this.showFormPage = true;
                } else {
                    this.spinnerToggle();
                    this.finalMessage = result.response;
                    console.log('Error ::::0' + JSON.stringify(result));
                    //this.showToast('error', result.message, result.response);
                    this.showFormPage = true;
                }

            })
            .catch(error => {
                console.log('Error ::::01' + JSON.stringify(error));
                this.spinnerToggle();
                this.finalMessage = 'Something gone Wrong, connect to the Zadoon once!!';
                //this.showToast('error', error.message, error.body);
                this.showFormPage = true;
            });
    }

    async handleOpenPrompt() {

        const result = await LightningConfirm.open({
            message: 'Just an headsUp!! You can submit this form only once for an singe Process.',
            variant: 'header',
            label: 'Please Confirm',
            theme: 'error',
        });

        if (result == true) {
            this.handleSubmit1();

        }
    }


    handleValueChange(event) {
        if (event.target.name == 'quoteAmount') {

            this.freightRecord.quoteAmount = event.target.value;
            if (this.freightRecord.quoteAmount !== null && this.freightRecord.quoteAmount !=="" ) {
                this.disableSubmit = false;
            } else {
                this.disableSubmit = true;
            }
        }
    }
    handleDateValueChange(event) {
        if (event.target.name == 'pickUpDate') {
            this.freightRecord.pickUpDate = event.target.value;
        }
    }


    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    spinnerToggle() {
        this.loader = !this.loader;
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