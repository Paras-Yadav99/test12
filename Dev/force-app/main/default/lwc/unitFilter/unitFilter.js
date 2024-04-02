import { LightningElement, track, wire } from 'lwc';
import { getPicklistValues, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getProducts from '@salesforce/apex/UnitFilterController.getProducts';
import getFieldsList from '@salesforce/apex/UnitFilterController.getFieldsList';
import CATEGORY_FIELD from '@salesforce/schema/Equipment__c.Category__c';


export default class UnitFilter extends LightningElement {
    @track inputValues =[];
    @track units;
    @track showUnitList = false;
    @track unitsStringified;
    @track filters = {};
    @track adFilters = {};
    @track childFieldsList = [];
    @track childFiltersList = [];
    isLoading = false;
    showEOPage = false;
    selectedCategory;
    isCategorySelected = true;
    adFiltersStrinfied = '{}';
    error;

    @track booleanOptions = [
        //{ label: 'None', value: 'none' },
        { label: 'Yes', value: 'true' },
        { label: 'No', value: 'false' },
    ];

    
    connectedCallback(){
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: CATEGORY_FIELD })
    categories;

    @wire(getPicklistValuesByRecordType, { objectApiName: 'Equipment_Options__c', recordTypeId: '012000000000000AAA' })
    allPicklistValues;

    search(){
        //this.inputValues = 'blank';
        this.isLoading = true;
        this.inputValues = [];
        let listOfInputs = this.template.querySelectorAll('lightning-input');
        
        let index = 0;
        for(index = 0; index< listOfInputs.length; index++){
            let field = {};
            field.lable = ''+listOfInputs[index].label;
            field.name = ''+listOfInputs[index].name;
            field.value = ''+listOfInputs[index].value;
            field.type = ''+listOfInputs[index].type;
            this.inputValues.push(field);
        }
        this.inputValues.push(
            {
                "label" : this.selectedCategory,
                "name"  : "category__c",
                "value" : this.selectedCategory,
                "type"  : "Picklist"
            }
        );
        
        
        let filterListParent = {"filterList": JSON.parse(JSON.stringify(this.inputValues))};
        let filtersChild = Object.values(this.adFilters);
        let filterListChild = {"filterList": JSON.parse(JSON.stringify(filtersChild))};
        getProducts({ stringifiedList: JSON.stringify(filterListParent), stringifiedListChild: JSON.stringify(filterListChild)} )
            .then(result => {
               
                this.showUnitList = false;
                this.units = result;
                this.unitsStringified = JSON.stringify(result);
               
                this.showUnitList = true;
                this.isLoading = false;
                let chilCmp = this.template.querySelector('c-show-units');
                chilCmp.refreshData(this.unitsStringified);
            })
            .catch(error => {
                
                this.error = error;;
                
            });
    }

    handleCategoryChange(event){
        
        this.showEOPage = false;
        this.isCategorySelected = true;
        this.adFiltersStrinfied = '{}';
        this.adFilters = [];
        this.selectedCategory = event.detail.value;
        getFieldsList({category: this.selectedCategory})
            .then(result => {
                this.childFieldsList = result;
            }).then(()=>{
                this.populateChildFilterList();
            }).then(()=>{
                this.isCategorySelected = false;
            }).catch(error => {
                this.error = error;
            });
    }

    changeAdditionalFilteres(){
        this.showEOPage = !this.showEOPage;
    }
    handleInputChange(event){
        //this.filters[event.target.label] = event.detail.value;
    }
    
    handleChildInputChange(event){
        let evtDetails = JSON.parse(JSON.stringify(event.detail));
        let field = {};
        field.lable = evtDetails.inputLabel;
        field.name = evtDetails.inputName;
        if(evtDetails.inputType == 'MULTIPICKLIST'){
            field.listOfValue = evtDetails.inputValue;
        }else{
            field.value = evtDetails.inputValue;
        }
        field.type = evtDetails.inputType;
        this.adFilters[evtDetails.inputName] = field;
        this.adFiltersStrinfied = JSON.stringify(this.adFilters);
        
    }
    
    populateChildFilterList(){
        this.childFiltersList = [];
        this.childFieldsList.forEach(fieldObj => {
            let tempObj = {};
            tempObj.label = fieldObj.label;
            tempObj.name = fieldObj.name;
            tempObj.placeholder = '...';
            if(fieldObj.type == 'BOOLEAN'){
                tempObj.inputType = "BOOLEAN-PICKLIST";
                tempObj.pickListOptions = this.booleanOptions;
            }else{
                tempObj.inputType = fieldObj.type;
            }
            if(fieldObj.type == 'PICKLIST'){
                let pick = this.allPicklistValues.data.picklistFieldValues;
                tempObj.pickListOptions = this.allPicklistValues.data.picklistFieldValues[fieldObj.name].values;
            }else if(fieldObj.type == 'MULTIPICKLIST'){
                let pick = this.allPicklistValues.data.picklistFieldValues;
                tempObj.pickListOptions = this.allPicklistValues.data.picklistFieldValues[fieldObj.name].values;
                console.debug('this.allPicklistValues.data.picklistFieldValues[fieldObj.name].values;'+this.allPicklistValues.data.picklistFieldValues[fieldObj.name].values);
            }
            console.debug('tempObj'+tempObj);
            this.childFiltersList.push(tempObj);
            
        });
    }

}