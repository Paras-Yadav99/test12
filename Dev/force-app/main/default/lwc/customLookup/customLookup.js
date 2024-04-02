import { LightningElement, api, track } from 'lwc';
import fetchRecords from '@salesforce/apex/CustomLookupController.fetchRecords';

export default class CustomLookup extends LightningElement {

    @api objectName;
    @api fieldName;
    @api value;
    @api iconName;
    @api label;
    @api placeholder;
    @api className;
    @api required = false;
    @track searchString;
    @api selectedRecord;
    @track recordsList;
    @track message;
    @track showPill = false;
    @track showSpinner = false;
    @track showDropdown = false;

    connectedCallback() {
        if(this.value)
            this.fetchData();

        if(this.selectedRecord.label != null){
            this.showPill = true;
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
                
                    //this.value = this.selectedRecord.value;
                
                
                console.log(JSON.stringify(this.selectedRecord))
                this.showDropdown = false;
                this.showPill = true;
                const changeLookUpEvent = new CustomEvent('changelookupevent',{
                    detail:{
                        'objName':this.objectName,
                        'value':this.selectedRecord.value,
                        'onOffHighway':this.selectedRecord.onOffHighway,
                        'label':this.selectedRecord.label,
                        'selectedRecord' : this.selectedRecord
                    }
                });
                this.dispatchEvent(changeLookUpEvent);
            }
        }
    }

    @api removeItem() {
        this.showPill = false;
        if(this.objectName != 'Contact'){
            this.value = '';
        }
       
        this.selectedRecord = '';
        this.searchString = '';
        const removeLookUpEvent = new CustomEvent('removelookupevent',{
            detail:{
                'objName':this.objectName
            }   
        });
        this.dispatchEvent(removeLookUpEvent);
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
        console.log(this.searchString);
        console.log(this.value);
        fetchRecords({
            objectName : this.objectName,
            filterField : this.fieldName,
            searchString : this.searchString,
            value : this.value
        })
        .then(result => {
            console.log(result);
            if(result && result.length > 0) {
                if(this.value && this.objectName != 'Contact') {
                    this.selectedRecord = result[0];
                    this.showPill = true;
                } else {
                    this.recordsList = result;
                }
            } else {
                this.message = "No Records Found for '" + this.searchString + "'";
            }
            this.showSpinner = false;
        }).catch(error => {
            this.message = error.message;
            this.showSpinner = false;
        })
        if(!this.value || this.objectName == 'Contact') {
            this.showDropdown = true;
        }
    }
}