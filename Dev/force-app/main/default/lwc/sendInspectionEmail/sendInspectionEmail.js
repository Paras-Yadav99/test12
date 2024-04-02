import { LightningElement ,track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContactData from '@salesforce/apex/sendInspectionEmailController.getContactData'; 
import sendEmailToUser from '@salesforce/apex/sendInspectionEmailController.sendEmailToUser'; 
import getUnitData from '@salesforce/apex/sendInspectionEmailController.getUnitData'; 

const columns = [
    {label:'Name',fieldName:'recordLink', type:'url',
    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    { label: 'Phone', fieldName: 'Phone', type: 'text', sortable: true },
    { label: 'Email', fieldName: 'Email', type: 'text', sortable: true },
];
export default class sendInspectionEmail extends LightningElement {
    columns = columns;
    /*closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }*/
     @track showSpinner = false;
    @api recordId;
    @track searchContactKey;
    @track lstSearchContact=[];
    @track showSearchContact = false;
    @track lstContactId = [];
    @track SendInspectionReport = true;
    @track showContact = false;
    @track showEmail = false;
    @track emailId ;
    @track showBool = false;
    @track showBool1 = false;
    @track showSendEmailButton = false;
    @track showNextButton = true;
    @track showPreviousButton = false;
    handelContactSearchKey(event){
        this.searchContactKey = event.target.value;
    }
    @track value;


    get options() {
        return [
            { label: 'Enter Email Id', value: 'option1' },
            { label: 'Select Contact', value: 'option2' },
        ];
    }

    connectedCallback() {
        this.spinnerToggle();
        this.checkForGoogleDriveLink();
    }

    checkForGoogleDriveLink (){
        getUnitData({recordId : this.recordId})
        .then(result =>{
                if(result.isSuccess) {
                    //this.showToast('error', result.message, result.response);
                    //this.showToast('SUCCESS',  result.message, result.response);
                    this.spinnerToggle();
                }else{
                    this.showToast('error', result.message, result.response);
                    this.closeQuickAction();
                    this.spinnerToggle();
                    
                }
            })
            .catch( error=>{
                this.spinnerToggle();
                this.showToast('error', error.message, error.body);
            });
    }
    handelChange(t) {
                if (t.target.label == "Enter Email Id") {
                    this.value = 'option1';
                    this.showBool = true;
                    this.showBool1 = false;
                } else if (t.target.label == "Select Contact") {
                    this.value = 'option2';
                    this.showBool = false;
                    this.showBool1 = true;
                }
            }
    handleCancelButton(){
        this.closeQuickAction();
    }
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
    handleNextButton(){
        
        if(this.value=='option1'){
            this.SendInspectionReport = false;
            this.showEmail = true;
            this.showContact = false;
            this.showPreviousButton = true;
            this.showSendEmailButton = true;
            this.showNextButton = false;
        }else if(this.value == 'option2'){
            this.SendInspectionReport = false;
            this.showContact = true;
            this.showEmail = false;
            this.showSendEmailButton = true;
            this.showNextButton = false;
            this.showPreviousButton = true;
        }
    }
    handleSendemailButton(){
        
        if(this.showEmail == true){
            this.sendEmail();
            
        }else if(this.showContact == true){
            this.selectedContact();
           
        }
    }
    handlePreviousButton(){
        this.resetVariables();
    }
    handleEmailChange(event){
        this.emailId = event.target.value;
    }
    sendEmail(){
        sendEmailToUser({EmailId : this.emailId, recordId : this.recordId,lstContactId: this.lstContactId})
            .then(result =>{
                if(result.isSuccess) {
                    this.closeQuickAction();
                    this.showToast('SUCCESS',  result.message, result.response);
                    this.spinnerToggle();
                }else{
                    this.spinnerToggle();
                    this.showToast('error', result.message, result.response);
                }
            })
            .catch( error=>{
                this.spinnerToggle();
                this.showToast('error', error.message, error.body);
            });
    }
    resetVariables(){
        this.SendInspectionReport = true;
        this.showEmail = false;
        this.showContact = false;
        this.showNextButton = true;
        this.showSendEmailButton = false;
        this.value = '';
        this.showBool = false;
        this.showBool1 = false;
        this.showPreviousButton = false;
        this.lstContactId = [];
    }
    SearchContactHandler(){
        this.spinnerToggle();
        //call Apex method.
        if(this.searchContactKey){
            getContactData({ContactName: this.searchContactKey})
            .then(result =>{
                if(result.isSuccess) {
                    var test12 = JSON.parse(result.response);
                    this.lstSearchContact = this.createCustomUrlRecord(test12);
                    this.showSearchContact = true;
                    this.spinnerToggle();
                }
            })
            .catch( error=>{
                this.spinnerToggle();
                this.showToast('error', error.message, error.body);
            });
        }else{
            this.spinnerToggle();
            this.showToast('error', 'error', 'Add details');
        }
    }
    createCustomUrlRecord(data){

        var tempLeadList = [];  
        for (var i = 0; i < data.length; i++) {  
            let tempRecord = Object.assign({},data[i]); //cloning object  
            tempRecord.recordLink = "/" + tempRecord.Id;  
            tempLeadList.push(tempRecord);  
        }  
        return tempLeadList;
    }
    showToast( variant,
                title,
                message) {
        const event = new ShowToastEvent({
                                        variant : variant,
                                        title: title,
                                        message: message,
                                        });
        this.dispatchEvent(event);
    }
    spinnerToggle() {
        this.showSpinner = !this.showSpinner;
    }

    selectedContact()
    {
        this.spinnerToggle();
        var selectedContactRecords =  this.template.querySelector("[data-id =SearchContacts]").getSelectedRows();
    
        if(selectedContactRecords.length > 0){
            for (let i = 0; i < selectedContactRecords.length; i++) {
                if(selectedContactRecords[i].Id){
                    this.lstContactId.push(selectedContactRecords[i].Id);
                }
                
            }

            this.sendEmail();
        }else{
            this.spinnerToggle();
            this.showToast('Error', 'Error', 'Select or Create an Contact');
            
        }
    }
}