import { LightningElement,api,wire, track } from 'lwc';
import leadConvertController from '@salesforce/apex/CustomLeadConvertController.leadConvertController';
import leadConverter from '@salesforce/apex/CustomLeadConvertController.leadConverter'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountData from '@salesforce/apex/CustomLeadConvertController.getAccountData'; 
import getContactData from '@salesforce/apex/CustomLeadConvertController.getContactData'; 
import createAccount from '@salesforce/apex/CustomLeadConvertController.createAccount';

import { NavigationMixin } from 'lightning/navigation';
import createContact from '@salesforce/apex/CustomLeadConvertController.createContact';
const columns = [
    {label:'Name',fieldName:'recordLink', type:'url',
    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    { label: 'Phone', fieldName: 'Phone', type: 'text', sortable: true },
    { label: 'Email', fieldName: 'Email', type: 'text', sortable: true },
];
export default class CustomleadConvert extends NavigationMixin(LightningElement) {
    @track showSpinner = false;
    @api recordId;
    @track firstName;
    @track lastName;
    @track mobile;
    @track CreateRecord = false;
    @track CreateRecordName;
    columns = columns;
    @track lstContact=[];
    @track accountData = false;
    @track contactData = false;
    @track lstAccount=[];
    @track lstSearchAccount=[];
    @track lstSearchContact=[];
    @track leadRecord ;
    @track accountId;
    @track contactId;
    @track showSave=false;
    @track currentvalue;
    @track selectedvalue ;
    @track OpportunityId ;
    @track searchAccountKey;
    @track showSearchContact = false;
    @track searchContactKey;
    @track showSearchAccount = false;
    @track accountName='';
    @track accountMobile = '';
    @track options = [];
    @track ClientRegionOptions ;
    @track AuthorizedDealerOptions;
    @track selectedValue;
    @track showMatchingContact=false;
    @track showMatchingAccount=false;
    @track company ;
    @track AuthorizedDealerFor=[] ;
    @track ClientType ;
    @track ClientRegion=[] ;
    @track showAccountField = false;
    @track showContactField = false;
    pathHandler(event) {
        let targetValue = event.currentTarget.value;
        let selectedvalue = event.currentTarget.label;
        this.currentvalue = targetValue;
        this.selectedvalue = selectedvalue;
        if(event.currentTarget.value=="Account"){
            this.accountData = true;
            this.contactData=false;
            this.CreateRecord = false;
            this.showMatchingAccount = true;
        }else if(event.currentTarget.value=="Contact"){
            this.accountData = false;
            this.contactData=true;
            this.CreateRecord = false;
            this.showMatchingContact = true;
        }else if(event.currentTarget.value=="Converted"){
            this.accountData = false;
            this.contactData=false;
            this.CreateRecord = false;
        }
        
    }
    /*@wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA', // Default record type Id
        fieldApiName: Client_Type__c
    })
    getClientTypePicklistValues({ error, data }) {
        if (data) {
             .options = data.values.map( objPL => {
                return {
                    label: `${objPL.label}`,
                    value: `${objPL.value}`
                };
            });
            console.log( 'Options are ' + JSON.stringify( this.options ) );

        } else if (error) {
            // Handle error
        }
    }*/
     
    connectedCallback(){
        debugger;
        this.spinnerToggle();
        this.init();    
    }
    init() {
        leadConvertController({recordId : this.recordId})
        .then(result =>{
            if(result.isSuccess) {
                if(result.message=='ShowTable'){
                    let parentWrapper = JSON.parse(result.response);
                    this.lstAccount =this.createCustomUrlRecord( parentWrapper.lstAccountWrapper);
                    this.lstContact =this.createCustomUrlRecord(  parentWrapper.lstContactWrapper);
                    this.options = parentWrapper.lstClientType;
                    this.ClientRegionOptions = parentWrapper.lstClientRegion;
                    this.AuthorizedDealerOptions = parentWrapper.lstAuthorizedDealer;
                    this.leadRecord = parentWrapper.recordLead;
                    this.accountData = true;
                    this.showMatchingAccount=true;
                    this.contactData = false;
                    this.spinnerToggle();    
                }
            }else {
                this.spinnerToggle();
                this.showToast('error', result.message, result.response);
            }
        })
        .catch(error =>{
            this.spinnerToggle();
            this.showToast('error', error.message, error.body);
        });
    }
    handelAccountSearchKey(event){
        
        this.searchAccountKey = event.target.value;
    }
        
    handelContactSearchKey(event){
            this.searchContactKey = event.target.value;
    }
    handelRecordValueChange(event){
        if(event.target.name == 'firstName'){
            this.firstName = event.target.value;
        }else if(event.target.name == 'lastName'){
            this.lastName = event.target.value;
        }/*else if(event.target.name = 'emailAddress'){
            this.email = event.target.value;
        }*/else if(event.target.name == 'mobile'){
            this.mobile = event.target.value;
        }else if(event.target.name == 'companyName'){
            this.company = event.target.value;
        }else if(event.target.name == 'ClientType'){
            this.ClientType = event.target.value;
        }else if(event.target.name == 'ClientRegion'){
            console.log('event.target::'+event.target);
            console.log('event.target::'+event.target.value);
            this.ClientRegion = event.target.value;
            console.log('event.target::'+ this.ClientRegion);
        }else if(event.target.name == 'AuthorizedDealerFor'){
            console.log('event.target::'+event.target);
            console.log('event.target::'+event.target.value);
            this.AuthorizedDealerFor = event.target.value;

            console.log('event.target::'+ this.AuthorizedDealerFor);
        }
    }
    /*checkLstSearchAccountSize(){
        //let lstSize = this.lstSearchAccount.length;
        if( this.lstSearchAccount.length>0){
            this.showSearchAccount = true;
        }
    }*/
    /*checkLstSearchContactSize(){
        if(this.lstSearchContact.length>0){
            this.showSearchContact = true;
        }
    }*/
    handleNewContact(){
        this.CreateRecordName ='Contact';
        this.CreateRecord = true;
        this.showContactField = true;
        this.showSearchContact=false;
        this.showMatchingContact= false;
    } 
    handleNewAccount(){
        this.showAccountField = true;
        this.CreateRecordName ='Account';
        this.CreateRecord = true;
        this.showSearchAccount = false;
        this.showMatchingAccount = false;
    }  
    handleViewMatchingAccount(){
        this.showSearchAccount = false;
        this.showMatchingAccount=true;
        this.CreateRecord=false;
    } 
    handleViewMatchingContact(){
        this.showMatchingContact=true;
        this.showSearchContact=false;
        this.CreateRecord=false;
    }
    SearchAccountHandler(){
        this.spinnerToggle();
        this.showMatchingAccount=false;
        this.CreateRecord = false;
        this.showSearchAccount =false;
        debugger;
        //call Apex method.
        if(this.searchAccountKey){
            getAccountData({AccountName: this.searchAccountKey})
            .then(result =>{
                if(result.isSuccess) {
                    this.spinnerToggle();
                    this.lstSearchAccount = this.createCustomUrlRecord(JSON.parse(result.response));
                    this.showSearchAccount = true;
                    //this.checkLstSearchAccountSize();
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
    SearchContactHandler(){
        this.spinnerToggle();
        this.showMatchingContact=false;
        this.CreateRecord = false;
        this.showSearchAccount =false;
        //call Apex method.
        if(this.searchContactKey){
            getContactData({ContactName: this.searchContactKey})
            .then(result =>{
                if(result.isSuccess) {
                    this.lstSearchContact = this.createCustomUrlRecord(JSON.parse(result.response));
                    this.showSearchContact = true;
                    //this.checkLstSearchContactSize();
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
    handleSave(){
        this.spinnerToggle();
        leadConverter({LeadId : this.recordId, accountId : this.accountId, contactId : this.contactId})
        .then(result =>{
            if(result.isSuccess) {
                this.spinnerToggle();
                this.currentvalue = 'Converted';
                this.selectedvalue = 'Lead Converted';
                
                this.OpportunityId = result.response;
                this.navigateToOpportunityPage();
                this.closeQuickAction();
                this.showToast('SUCCESS', 'SUCCESS', 'Lead Converted');
                
                
            }else {
                this.spinnerToggle();
                this.showToast('error', result.message, result.response);
            }
        })
        .catch(error =>{
            this.spinnerToggle();
            this.showToast('error', error.message, error.body);
        });
    }
    handleNextButton(){
        this.spinnerToggle();
        
        if(this.contactData ){
            //this.resetVariables();
            if(this.showMatchingContact){
                var selectedContactRecords =  this.template.querySelector("[data-id =Contacts]").getSelectedRows();
                if(selectedContactRecords.length == 1){
                    this.contactId = selectedContactRecords[0].Id;
                    this.contactData  = false;
                    this.accountData = false;
                    this.spinnerToggle();
                    this.handleSave();
                   // this.spinnerToggle();
                }else if(selectedContactRecords.length > 1){
                    this.spinnerToggle();
                    this.showToast('Error', 'Error', 'Multiple Record selected');
                }else{
                    this.spinnerToggle();
                    this.showToast('Error', 'Error', 'Select or Create an Contact');
                    //this.contactId ='' ;
                }
            }else if(this.showSearchContact){
                var selectedSearchContactRecords =  this.template.querySelector("[data-id =SearchContacts]").getSelectedRows();
                if(selectedSearchContactRecords.length == 1){
                    this.contactId = selectedSearchContactRecords[0].Id;
                    this.contactData  = false;
                    this.accountData = false;
                    this.spinnerToggle();
                    this.handleSave();
                    //this.spinnerToggle();

                }else if(selectedSearchContactRecords.length > 1){
                    this.spinnerToggle();
                    this.showToast('Error', 'Error', 'Multiple Record selected');
                }else{
                    //this.contactId='' ;
                    this.spinnerToggle();
                    this.showToast('Error', 'Error', 'Select or Create an Contact');
                }
            }else if(this.CreateRecord){
                this.showAccountField = false;
                this.showContactField = true;
                
                let isValid = this.validityCheck();
                if(isValid) {
                    if(this.accountId!=null){
                        //this.spinnerToggle();
                        this.createNewContact();
                    }else{
                        this.spinnerToggle();
                        this.showToast('Error', 'Error', 'First Select or Create Account'); 
                    }
                    
                }else{
                        this.spinnerToggle();
                }
            }else{
                this.spinnerToggle();
                this.showToast('Error', 'Error', 'Select or Create an Contact');
            }
            /*var selectedContactRecords =  this.template.querySelector("[data-id =Contacts]").getSelectedRows();
            var selectedSearchContactRecords=[];
            if(this.showSearchAccount){
                selectedSearchContactRecords =  this.template.querySelector("[data-id =SearchContacts]").getSelectedRows();
            }
            if(selectedContactRecords.length == 1 && selectedSearchContactRecords.length ==0){
                if(this.accountId ){
                    this.contactId = selectedContactRecords[0].Id;
                    this.handleSave();
                }else{
                    if(this.accountName || this.mobile){
                        this.contactId = selectedContactRecords[0].Id;
                        this.createNewAccount();
                        
                    }else{
                        this.contactId = selectedContactRecords[0].Id;
                        this.accountId =selectedContactRecords[0].accountId;
                        this.handleSave();
                    }
                    
                }
                
                //this.contactData  = false;
                //this.handleSave();
                //this.spinnerToggle();
            }else if(selectedContactRecords.length == 0 && selectedSearchContactRecords.length ==1){
                if(this.accountId != null ){
                    this.contactId = selectedSearchContactRecords[0].Id;
                    this.handleSave();
                }else{
                    if(this.accountName || this.mobile){
                        this.contactId = selectedSearchContactRecords[0].Id;
                        this.createNewAccount();
                        
                    }else{
                        this.accountId =selectedSearchContactRecords[0].accountId;
                        this.contactId = selectedSearchContactRecords[0].Id;
                        this.handleSave();
                    }
                }
                //this.contactData  = false;
                //this.spinnerToggle();
            }else if(selectedContactRecords.length >1 || selectedSearchContactRecords.length > 1){
                this.spinnerToggle();
                this.showToast('Error', 'Error', 'Multiple Record selected');
            }else if(selectedContactRecords.length > 0 && selectedContactRecords.length > 0 ){
                this.spinnerToggle();
                this.showToast('Error', 'Error', 'Multiple Record selected');
            }else if(this.CreateRecord ){
                let isValid = this.validityCheck();
                if(isValid) {
                    if(this.accountId){
                        this.createNewContact();
                        //this.contactData  = false;
                        //this.handleSave();
                        //this.spinnerToggle();
                    }else{
                        this.createNewAccount();
                        //this.createNewContact();
                        //this.contactData  = false;
                        //this.handleSave();
                        //this.spinnerToggle();
                    }
                    
                }
                this.spinnerToggle();
            }else{
                this.contactId = '';
                this.createNewAccount();
                //this.contactData  = false;
                //this.handleSave();
                //this.spinnerToggle();
                
            }
        }*/
        }else if(this.accountData){
            if(this.showMatchingAccount){
                var selectedAccountRecords =  this.template.querySelector("[data-id =Accounts]").getSelectedRows();
                 if(selectedAccountRecords.length == 1){
                    this.accountId = selectedAccountRecords[0].Id;
                    this.contactData  = true;
                    this.showMatchingContact = true;
                    this.accountData = false;
                    this.resetVariables();
                    this.spinnerToggle();
                 }else if(selectedAccountRecords.length > 1){
                    this.spinnerToggle();
                    this.showToast('Error', 'Error', 'Multiple Record selected');
                 }else{
                    //this.accountId ='' ;
                    this.spinnerToggle();
                    this.showToast('Error', 'Error', 'Select or Create an account');
                 }
            }else if(this.showSearchAccount){
                var selectedSerchAccountRecords =  this.template.querySelector("[data-id =SearchAccounts]").getSelectedRows();
                if(selectedSerchAccountRecords.length == 1){
                    this.accountId = selectedSerchAccountRecords[0].Id;
                    this.contactData  = true;
                    this.showMatchingContact = true;
                    this.accountData = false;
                    this.resetVariables();
                    this.spinnerToggle();
                }else if(selectedSerchAccountRecords.length > 1){
                    this.spinnerToggle();
                    this.showToast('Error', 'Error', 'Multiple Record selected');
                }else{
                    //this.accountId='' ;
                    this.spinnerToggle();
                    this.showToast('Error', 'Error', 'Select or Create an account');
                }
            }else if(this.CreateRecord){
                
                let isValid = this.validityCheck();
                
                if(isValid) {
                    this.createNewAccount();
                    /*this.contactData  = true;
                    this.accountData = false;
                    this.CreateRecord = false;
                    this.resetVariables();
                    this.spinnerToggle();*/
                }else{
                        this.spinnerToggle();
                }
            }else{
                this.spinnerToggle();
                this.showToast('Error', 'Error', 'Select or Create an account');
            }
            //var selectedAccountRecords =  this.template.querySelector("[data-id =Accounts]").getSelectedRows();
            /*var selectedSerchAccountRecords=[];
            if(this.showSearchAccount){
                selectedSerchAccountRecords =  this.template.querySelector("[data-id =SearchAccounts]").getSelectedRows();
            }
            
            if(selectedAccountRecords.length == 1 && selectedSerchAccountRecords.length ==0){
                this.accountId = selectedAccountRecords[0].Id;
                this.contactData  = true;
                this.accountData = false;
                this.spinnerToggle();
            }else if(selectedAccountRecords.length == 0 && selectedSerchAccountRecords.length ==1){
                this.accountId = selectedSerchAccountRecords[0].Id;
                this.contactData  = true;
                this.accountData = false;
                this.spinnerToggle();
            }else if(selectedAccountRecords.length >1 || selectedSerchAccountRecords.length > 1){
                this.spinnerToggle();
                this.showToast('Error', 'Error', 'Multiple Record selected');
            }else if(selectedAccountRecords.length > 0 && selectedSerchAccountRecords.length > 0 ){
                this.spinnerToggle();
                this.showToast('Error', 'Error', 'Multiple Record selected');
            }else if(this.CreateRecord ){
                let isValid = this.validityCheck();
                if(isValid) {
                    
                    if(this.firstName != null && this.lastName !=null){
                        this.accountName = this.firstName +' ' +this.lastName; 
                    }else if(this.firstName != null && this.lastName ==null){
                        this.accountName = this.firstName;
                    }else if(this.firstName == null && this.lastName !=null){
                        this.accountName = this.lastName;
                    }
                
                    if(this.mobile != null){
                        this.accountMobile=this.mobile;
                    }
                    this.contactData  = true;
                    this.accountData = false;
                    this.CreateRecord = false;
                    this.resetVariables();
                    this.spinnerToggle();*/
                    /*this.createNewAccount();
                    this.contactData  = true;
                    this.accountData = false;
                    this.CreateRecord = false;
                    this.resetVariables();
                    this.spinnerToggle();*/
                //}
            /*}else{
                   // else{
                        this.accountName= this.leadRecord.Company;
                        this.mobile=this.leadRecord.Phone;
                    //}
                    //this.accountId = '';
                    this.contactData  = true;
                    this.accountData = false;
                    this.spinnerToggle();
                
                }
            }*/
            
            
        }
    }
    resetVariables(){
        this.company='' ;
        this.ClientRegion='';
        this.ClientType='';
        this.AuthorizedDealerFor='';
        this.mobile='';
        this.email='';
        this.firstName='';
        this.lastName='';
    }
    validityCheck(){
        let validity;
            let elements = Array.from(this.template.querySelectorAll('[data-id =checkValidity]'));
                if(elements!= undefined &&
                    elements!=null) {
                    validity =  elements.reduce((validSoFar,inputcmp) => {
                        inputcmp.reportValidity();
                        return validSoFar && inputcmp.checkValidity();
                    },true );
                }
        return validity;
    }
    handleCancelButton(){
        this.closeQuickAction();
    }
    handleClose() {
        this.CreateRecord = false;
        this.resetVariables();
        
    }
    
    createNewAccount(){
        var fullName=''; 
        //var phone='';
        
            if(this.firstName != null && this.lastName !=null){
                this.fullName = this.firstName +' ' +this.lastName; 
            }else if(this.firstName != null && this.lastName ==null){
                this.fullName = this.firstName;
            }else if(this.firstName == null && this.lastName !=null){
                this.fullName = this.lastName;
            }
        
            /*if(this.mobile != null){
                this.phone=this.mobile;
            }*/
        
        
    createAccount({company : this.company, ClientType : this.ClientType,ClientRegion: this.ClientRegion,
                        AuthorizedDealerFor: this.AuthorizedDealerFor,fullName:this.fullName,mobile : this.phone})
            .then(result =>{
                if(result.isSuccess) {
                    this.accountId = result.response;
                    this.resetVariables();
                    this.contactData  = true;
                    this.showMatchingContact = true;
                    this.accountData = false;
                    this.showAccountField = false;
                    this.CreateRecord = false;
                    this.resetVariables();
                    this.spinnerToggle();
                }else {
                    this.spinnerToggle();
                    this.showToast('error', result.message, result.response);
                }
            })
            .catch(error =>{
                this.spinnerToggle();
                this.showToast('error', error.message, error.body);
            });
    }
    createNewContact(){
        createContact({firstName : this.firstName, lastName : this.lastName, mobile : this.mobile, accountId : this.accountId})
                    .then(result =>{
                        if(result.isSuccess) {
                            this.contactId = result.response;
                            this.resetVariables();
                            this.contactData  = false;
                            this.handleSave();
                            //this.resetVariables();
                            //this.CreateRecord = false;
                        }else {
                            this.spinnerToggle();
                            this.showToast('error', result.message, result.response);
                        }
                    })
                    .catch(error =>{
                        this.spinnerToggle();
                        this.showToast('error', error.message, error.body);
                    });
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
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
    
    spinnerToggle() {
        this.showSpinner = !this.showSpinner;
    }

    navigateToOpportunityPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.OpportunityId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
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
}