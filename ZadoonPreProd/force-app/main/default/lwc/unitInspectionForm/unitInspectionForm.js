import { LightningElement, api, track } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/Zadoonlogo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createIntialData from "@salesforce/apex/UnitInspectionEmailFormController.createIntialData";
import updateFreightData from "@salesforce/apex/UnitInspectionEmailFormController.updateFreightData";

export default class UnitInspectionForm extends LightningElement {
    zadoonLogo = My_Resource + '/logo.png';
    viewMode1 = true;
    viewMode2 = true;
    viewMode3 = false;
    @track freightRecord = { unitName: null };
    showFormPage = false;
    disableSubmit = true;
    loader = false;
    isData = false;
    @track fileIds = [];
    @track fileId = [];
    @track uploadedFiles = [];
    @track isUploadedFiles = false;

    bottomMessage = 'Please note: You can submit this form only once. and Quote Amount is required to submit the Response.';
    @api recordId ;
    freightRecords;
    finalMessage = 'Thank you for completing the form! Your submission has been received.';
    test;
    test0;

    connectedCallback() {
        this.init();
    }
    renderedCallback() {
        // this.init();
    }

    init() {
        console.log('record id on Load :::::::' + this.recordId );
        this.spinnerToggle();
        createIntialData({ wrapperKey:  this.recordId })
            .then(result => {
                console.log('result on Load :::::::' + JSON.stringify(result) );
                if (result.isSuccess) {
                    console.log('Inspection Data on Loadshsddhsdhd :::::::' + result.response);
                    this.freightRecord = JSON.parse(result.response);
                    this.vaidateData(this.freightRecord);
                    this.spinnerToggle();
                    //this.error = undefined;
                    console.log('Inspection Data on Load on Load:::::::' + JSON.stringify(this.freightRecord));
                    console.log('Inspection Data on Load :::::::' + JSON.stringify(this.freightRecord.unitName));
                } else {
                    this.spinnerToggle();
                    this.showFormPage = true;
                    this.finalMessage = result.response;
                    console.log('Error ::::0' + JSON.stringify(result));
                    //this.showToast('error', result.message, result.response);
                }

            })
            .catch(error => {
                console.log('Error ::::1' + JSON.stringify(error));
                this.showFormPage = true;
                this.finalMessage = error.response;
                //this.finalMessage = 'Something gone Wrong, connect to the Zadoon once!!';
                //this.showToast('error', error.message, error.body);
               // this.showFormPage = true;
                this.spinnerToggle();
            });
    }
    vaidateData(data) {
        console.log('Data validation is called before condition');
        if (data  != null && data.unitName != null) {
            console.log('Data 1 ::::' + JSON.stringify(this.isData));
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
            console.log('Data validation is called in condition with ::::' + JSON.stringify(this.isData));
        }   
    }

    handleSubmit() {
        //this.handleOpenPrompt();
        if (this.freightRecord.quoteAmount != null) {
            this.handleSubmit1();
        } else {
            this.showFormPage = true;
            this.finalMessage = 'HeadsUp!! You missed Quote Amount, fill the form again. Thank you!';
        }

    }

    handleFileChange(event) {
        console.log('File uplaod is called successfully..');
        this.fileIds = event.detail.files.map(file => file.documentId);
        this.uploadedFiles = event.detail.files;
        console.log('Uploaded file :::::' + JSON.stringify(this.uploadedFiles));
        if (this.uploadedFiles.length > 0) {
            this.isUploadedFiles = true;
            for (let i = 0; i < this.uploadedFiles.length; i++) {
                //  console.log('Attacment in Loop::::' + JSON.stringify(attment[i]));
                this.fileId.push(this.uploadedFiles[i].contentVersionId);
            }
        }
    }

   handleSubmit1() {
        this.handleuploadSave();
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
                this.showFormPage = true;
                this.finalMessage = error.response;
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
          //  this.handleSubmit1();

        }
    }

     handleuploadSave() {
        const childComponent = this.template.querySelector('c-file-uploader-comp-lwc');
        
            childComponent.handleClick();
    }


    handleValueChange(event) {
        if (event.target.name = 'quoteAmount') {

            this.freightRecord.quoteAmount = event.target.value;
            this.validateDisableSubmit();
        }
    }
    handleDateValueChange(event) {
        if (event.target.name = 'pickUpDate') {
            this.freightRecord.pickUpDate = event.target.value;
            this.validateDisableSubmit();
        }
    }



    validateDisableSubmit(){
        if (!this.isEmpty(this.freightRecord.pickUpDate)
            && !this.isEmpty(this.freightRecord.quoteAmount)) {
                this.disableSubmit = false;
            } else {
                this.disableSubmit = true;
            }
    }


    isEmpty(str) {
        return (!str || str.length === 0);
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