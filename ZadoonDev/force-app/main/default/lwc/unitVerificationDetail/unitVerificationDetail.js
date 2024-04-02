import { LightningElement ,api,track} from 'lwc';
import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import WrappedHeaderTable from "@salesforce/resourceUrl/WrappedHeaderTable";
import getUnitVerificationLineItems from '@salesforce/apex/UnitVerificationDetailController.getUnitVerificationLineItems';
import saveUpdatedLineItems from '@salesforce/apex/UnitVerificationDetailController.saveUpdatedLineItems';

const columns = [{ label: '', fieldName: 'emptyColumn', fixedWidth: 0.01,  hideDefaultActions: true },
    { label: 'Marketing Site', fieldName: 'siteName', type: 'text', editable: false  },
    {label:'Marketing Site Url',fieldName:'siteURL', type:'url', editable: false },
{ label: 'Price is Correct', fieldName: 'isPriceCorrect', type: 'boolean', editable: true  },
{ label: 'Photo Count is Correct', fieldName: 'isPhootoCountCorrect', type: 'boolean', editable: true },
{ label: 'Unit Details are Complete', fieldName: 'areUnitDetailsCompleted', type: 'boolean' , editable: true},
{ label: 'Unit Location is Correct', fieldName: 'isUnitLocationCorrect', type: 'boolean', editable: true },
{ label: 'Photos of Good Quality', fieldName: 'arePhotoQualityGood',type: 'boolean', editable: true },

];

const columns1 = [{ label: '', fieldName: 'emptyColumn', fixedWidth: 0.01,  hideDefaultActions: true },
    { label: 'Marketing Site', fieldName: 'siteName', type: 'text', editable: false  },
    {label:'Marketing Site Url',fieldName:'siteURL', type:'url', editable: false },
{ label: 'Price is Correct', fieldName: 'isPriceCorrect', type: 'boolean', editable: true  },
{ label: 'Photo Count is Correct', fieldName: 'isPhootoCountCorrect', type: 'boolean', editable: true },
{ label: 'Unit Details are Complete', fieldName: 'areUnitDetailsCompleted', type: 'boolean' , editable: true},
{ label: 'Unit Location is Correct', fieldName: 'isUnitLocationCorrect', type: 'boolean', editable: true },
];
export default class UnitVerificationDetail extends LightningElement {
    @api recordId;
    @track draftValues = [];
    @track data = [];
    @track isOwned = false;
    @track showSpinner = false;
    @track columns =[];// columns;

    connectedCallback() {
        this.spinnerToggle();
     //   this.loadCustomStyles();
        this.getDataonLoad();
        this.initColumns();
    }

    initColumns(){
        if(this.isOwned){
            this.columns = columns;
        }else{
            this.columns = columns1;
        }
        
    }


    getDataonLoad(){
         getUnitVerificationLineItems({recordId : this.recordId})
        .then(result =>{
            if(result.isSuccess) {
                let parentWrapper = JSON.parse(result.response);
                    this.data = parentWrapper.UnitVerificationWrapperData;
                    this.isOwned =parentWrapper.isOwned; 
                    this.initColumns(); 
                    this.spinnerToggle();
                    this.error = undefined;  
            } else {
                this.spinnerToggle();
                this.showToast('error', result.message, result.response);
            }
         
        })
        .catch(error =>{
            this.showToast('error', error.message, error.body);
            this.spinnerToggle();
        });
    }

     

    handleSave(event) {
        this.spinnerToggle();
        console.log('Save ic clicked with ::::'+JSON.stringify(event.detail.draftValues));
        this.draftValues = event.detail.draftValues;
         saveUpdatedLineItems({wrapperData : JSON.stringify(this.draftValues)})
        .then(result =>{
            if(result.isSuccess) {
                this.spinnerToggle();
                this.closeQuickAction();
                this.showToast('Success', result.message, result.response);
            } else {
                this.spinnerToggle();
                this.showToast('error', result.message, result.response);
            }
         
        })
        .catch(error =>{
            this.showToast('error', error.message, error.body);
            this.spinnerToggle();
        });
        // You can perform save operations here and update the records in the data array
    }
    /*  handleSave(event) {
        const updatedFields = event.detail.draftValues;
        // Apply changes to the data array
        this.data = this.data.map((row) => {
            const matchingField = updatedFields.find((item) => item.id === row.id);
            if (matchingField) {
                return { ...row, ...matchingField };
            }
            return row;
        });
    }*/

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    spinnerToggle() {
        this.showSpinner = !this.showSpinner;
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
    
    createCustomUrlRecord(data){

        var tempOppList = [];  
        for (var i = 0; i < data.length; i++) {  
            let tempRecord = Object.assign({},data[i]); //cloning object  
            tempRecord.recordLink = "/" + tempRecord.Id;  
            tempOppList.push(tempRecord);  
        }  
        return tempOppList;
    }

    
    loadCustomStyles(){
         if (!this.stylesLoaded) {
            Promise.all([loadStyle(this, WrappedHeaderTable)])
                .then(() => {
                    console.log("Custom styles loaded");
                    this.stylesLoaded = true;
                })
                .catch((error) => {
                    console.error("Error loading custom styles",error);
                });
        }
    }

}