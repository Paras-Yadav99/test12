import { LightningElement , api ,track} from 'lwc';
import fetchRecords from '@salesforce/apex/CustomChildFieldController.fetchRecords';
import picklistOptionResponse from '@salesforce/apex/CustomChildFieldController.picklistOptionResponse';
export default class CustomFields extends LightningElement {

    @api objectName;
    @api fieldName;
    @api fieldType;
    @api value;
    @api iconName;
    @api label;
    @api placeholder;
    @api className;
    @api required = false;
    @track searchString;
    @track selectedRecord;
    @track recordsList;
    @track message;
    @track showPill = false;
    @track showSpinner = false;
    @track showDropdown = false;

    // input field api
    @api inputlabel;
    @api inputName;
    
    // Combobox fields
    @api objectComboboxName;
    @api fieldComboboxValue;
    @track options;
    @api comboboxLabel;

    // get Lookup
    @track isLookup = false;
    @track isPicklist = false;
    @track isInputType = false;
    @track isNumber = false;
    @track isUrl = false;
    @track isCheckbox = false;
    @track isDate = false;
    @track isTextArea = false;
    @track isDateTime = false;
    @track isCurrency= false;


    

    connectedCallback() {
        if(this.value)
            this.fetchData();
                   this.init();
                   this.chooseFieldType();

    }
    chooseFieldType(){
        if(this.fieldType === "REFERENCE"){
            this.isLookup = true;
        }else if(this.fieldType === "PICKLIST"){
            this.isPicklist = true;
        }else if(this.fieldType === 'STRING'){
            this.isInputType =true;
        } else if(this.fieldType === 'DOUBLE'){
            this.isNumber = true;
        }else if (this.fieldType === 'URL'){
            this.isUrl = true; 
        }else if(this.fieldType === 'BOOLEAN'){
            this.isCheckbox = true;
        }else if(this.fieldType === 'DATE'){
            this.isDate = true;
        }else if(this.fieldType === 'TEXTAREA'){
            this.isTextArea = true;
        }else if(this.fieldType === 'DATETIME'){
            this.isDataTime = true;
        }else if(this.fieldType === 'CURRENCY'){
            this.isCurrency = true;
        }
     }

    searchRecords(event) {
        this.searchString = event.target.value;
        if(this.searchString) {
            this.fetchData();
        } else {
            this.showDropdown = false;
        }
    }

    selectItem(event) {

        if(event.currentTarget.dataset.key) {
     var index = this.recordsList.findIndex(x => x.value === event.currentTarget.dataset.key)
            if(index != -1) {
                this.selectedRecord = this.recordsList[index];
                this.value = this.selectedRecord.value;
                console.log('this.selectedRecord :::'+JSON.stringify(this.selectedRecord) +' Value:::'+ this.value);
                const saveEvent = new CustomEvent('save',{ detail:{fieldvalue : this.value , name : this.fieldName}});
                this.dispatchEvent(saveEvent);
                this.showDropdown = false;
                this.showPill = true;
            }
        }
    }
    removeItem() {
        this.showPill = false;
        this.value = '';
        this.selectedRecord = '';
        this.searchString = '';
    }

    showRecords() {
        if(this.recordsList && this.searchString) {
            this.showDropdown = true;
        }
    }
 
    blurEvent() {
        this.showDropdown = false;
    }

    fetchData() {
        this.showSpinner = true;
        this.message = '';
        this.recordsList = [];
        fetchRecords({
            objectName : this.objectName,
            filterField : 'Name',
            searchString : this.searchString,
            value : this.value
        })
        .then(result => {
            if(result && result.length > 0) {
                if(this.value) {
                    this.selectedRecord = result[0];
                    this.showPill = true;
                } else {
                    this.recordsList = result;
                }
            } else {
                this.message = "No Records Found for'" + this.searchString + "'";
            }
            this.showSpinner = false;
        }).catch(error => {
            this.message = error.message;
            this.showSpinner = false;
        })
        if(!this.value) {
            this.showDropdown = true;
        }
    
    }
    init(){
        picklistOptionResponse({ObjectApi_name : this.objectComboboxName , Field_name : this.fieldComboboxValue })
        .then(result => {
            if (result.isSuccess) {
                this.options = JSON.parse(result.response)
            }
        else {
                console.log("Error Occured");
             }
            })
            .catch(error => {

                console.log('Error Eccoured' + error);
            });
        }
        handleChange(event){
            
                        let fieldName  = this.fieldName;
                        console.log('fieldName'+ fieldName);
                         this.value = event.target.value;
                         console.log('this.value'+ this.value);
                         const saveEvent = new CustomEvent('save',{ detail:{fieldvalue : this.value , name : fieldName}});
                         this.dispatchEvent(saveEvent);
                        }
                   } 

        //    let fieldName  = this.fieldName;
        //     this.value = event.target.value;
        //     this.value = this.selectedRecord.value;
        //     const saveEvent = new CustomEvent('save',{ detail:{fieldvalue : this.value , name : fieldName}});
        //     this.dispatchEvent(saveEvent);