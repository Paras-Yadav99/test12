import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveUnits from '@salesforce/apex/CreateUnitsController.saveUnits';
import pickListValueDynamically from '@salesforce/apex/CreateUnitsController.pickListValueDynamically';

export default class Visitors extends LightningElement {
    columns = [
        {
            label: 'Unit Name',
            fieldName: 'nameUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}
        },
        { label: 'ZId', fieldName: 'ZID__c', type: 'text' }
    ];
    showZIds = false;
    @api recordId;
    @track savedUnits = [];
    @track unitList = {
        year: null,
        storageCity : null,
        serialNumber : null,
        storageState : null,
        hours : null,
        sellersAskingPrice : null,
        startingAdRetailPrice : null,
        mileage : null,
        vin : null,
        showOnHighwayFields : false,
        showOffHighwayFields : false,
        accObj : {
            label : null,
            value : null
        },
        equipObj : {
            label : null,
            value : null
        },
        userObj : {
            label : null,
            value : null
        },
        country : null,
        inventoryStatus : '',
        unitStage : '',
        active : false,
        unitDetail : null,
        sourcedFromLink : null
    };
    @track listUnit =[];

    showSpinner = false;

    @wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'Product2'},
    selectPicklistApi: 'Unit_Stage__c'}) selectTargetValues;

    @wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'Product2'},
    selectPicklistApi: 'Inventory_Status__c'}) inventoryStatusOptions;

    connectedCallback(){
        this.listUnit.push(JSON.parse(JSON.stringify(this.unitList)));
    }
    addRow() {
        this.listUnit.push(JSON.parse(JSON.stringify(this.unitList)));
    }

    deleteRow(event) {
        var rowIndex = event.currentTarget.dataset.index;
        console.log(rowIndex);
        if(this.listUnit.length > 1) {
            this.listUnit.splice(rowIndex, 1);
        } 
    }

    cloneRow(event){
        var rowIndex = event.currentTarget.dataset.index;
        let tempRow = Object.assign({}, this.listUnit[rowIndex]);
        this.listUnit.push(JSON.parse(JSON.stringify(tempRow)));
    }

    handleChange(event) {
        console.log(JSON.stringify(this.unitMetadata));
        var rowIndex = event.currentTarget.dataset.index;
        if(event.target.name === 'year') {
            this.listUnit[rowIndex].year = event.target.value;
        } else if(event.target.name === 'storageCity') {
            this.listUnit[rowIndex].storageCity = event.target.value;
        } else if(event.target.name === 'serialNumber') {
            this.listUnit[rowIndex].serialNumber = event.target.value;
        } else if(event.target.name === 'storageState') {
            this.listUnit[rowIndex].storageState = event.target.value;
        } else if(event.target.name === 'vin') {
            this.listUnit[rowIndex].vin = event.target.value;
        } else if(event.target.name === 'hours') {
            this.listUnit[rowIndex].hours = event.target.value;
        } else if(event.target.name === 'sellersAskingPrice') {
            this.listUnit[rowIndex].sellersAskingPrice = event.target.value;
        } else if(event.target.name === 'startingAdRetailPrice') {
            this.listUnit[rowIndex].startingAdRetailPrice = event.target.value;
        } else if(event.target.name === 'mileage') {
            this.listUnit[rowIndex].mileage = event.target.value;
        } else if(event.target.name === 'unitDetail') {
            this.listUnit[rowIndex].unitDetail = event.target.value;
        } else if(event.target.name === 'sourcedFromLink') {
            this.listUnit[rowIndex].sourcedFromLink = event.target.value;
        }else if(event.target.name === 'country') {
            this.listUnit[rowIndex].country = event.target.value;
        }else if(event.target.name === 'inventoryStatus') {
            this.listUnit[rowIndex].inventoryStatus = event.target.value;
        }else if(event.target.name === 'active') {
            this.listUnit[rowIndex].active = event.target.checked;
        }else if(event.target.name === 'unitStage') {
            this.listUnit[rowIndex].unitStage = event.target.value;
        }
    }

    handleLookupEvent(event){
        var rowIndex = event.currentTarget.dataset.index;
        console.log(rowIndex);
        console.log(JSON.stringify(event));
        if(event.detail.objName === 'Equipment__c') {
            this.listUnit[rowIndex].equipObj.value = event.detail.value;
            this.listUnit[rowIndex].equipObj.label = event.detail.label;
            if(event.detail.onOffHighway == 'On Highway'){
                this.listUnit[rowIndex].showOnHighwayFields = true;
                this.listUnit[rowIndex].showOffHighwayFields = false;
                
            }else{
                this.listUnit[rowIndex].showOffHighwayFields = true;
                this.listUnit[rowIndex].showOnHighwayFields = false;
            }
        } else if(event.detail.objName === 'Account') {
            this.listUnit[rowIndex].accObj.value = event.detail.value;
            this.listUnit[rowIndex].accObj.label = event.detail.label;
        }else if(event.detail.objName === 'User') {
            this.listUnit[rowIndex].userObj.value = event.detail.value;
            this.listUnit[rowIndex].userObj.label = event.detail.label;
        }
        
    }

    handleRemoveLookup(event){
        var rowIndex = event.currentTarget.dataset.index;
        console.log(rowIndex);
        console.log(JSON.stringify(event));
        if(event.detail.objName === 'Equipment__c' && this.listUnit[rowIndex]) {
            this.listUnit[rowIndex].showOnHighwayFields = false;
            this.listUnit[rowIndex].showOffHighwayFields = false;
        }
    }

    isUrlValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }


    handleSave() { 
        if(this.isUrlValid()){
            this.showSpinner = true;
            console.log(JSON.stringify(this.listUnit));
            var emptyCheck = false; 
            for(let rowIndex in this.listUnit) { 
                console.log(JSON.stringify(this.listUnit[rowIndex]));
                if(this.listUnit[rowIndex].accObj.value == null ||    
                    this.listUnit[rowIndex].equipObj.value == null ||
                    this.listUnit[rowIndex].userObj.value == null ||
                    this.listUnit[rowIndex].accObj.value == '' ||
                    this.listUnit[rowIndex].equipObj.value == '' ||
                    this.listUnit[rowIndex].userObj.value == '' ||
                    this.listUnit[rowIndex].equipObj.value.length < 15 ||
                    this.listUnit[rowIndex].userObj.value.length < 15 ||  
                    this.listUnit[rowIndex].accObj.value.length < 15
                ) {
                    emptyCheck = true;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'Please fill all Mandatory fields',
                        variant: 'error',
                    }));
                    this.showSpinner = false;
                    return false;
                } else {
                    console.log('pass');
                }
            }
        
            if(emptyCheck === false) {
                saveUnits({unitsDataString: JSON.stringify(this.listUnit)})
                .then(result => {
                    this.showSpinner = false;
                    if(result !== undefined) { 
                        for(let rowIndex in this.listUnit) {
                            
                        }
                        this.listUnit = [];
                        let lookupCmps = this.template.querySelectorAll('c-custom-lookup');
                        lookupCmps.forEach(element => 
                            element.removeItem()
                        );

                        this.listUnit.push(JSON.parse(JSON.stringify(this.unitList)));
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success',
                            message: 'Units created Successfully',
                            variant: 'success',
                        }));

                        result.forEach((record) => {
                            let tempRec = Object.assign({}, record);  
                            tempRec.nameUrl = '/' + tempRec.Id;
                            this.savedUnits.push(tempRec);
                            
                        });
            
                        this.showZIds = true;
                    }
                    
                })
                .catch(error => {
                    this.showSpinner = false;
                    console.log(error)
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }));
                });
            }
        }
        
    }

}