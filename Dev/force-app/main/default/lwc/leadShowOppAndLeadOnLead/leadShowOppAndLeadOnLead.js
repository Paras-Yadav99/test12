import { LightningElement,track,api,wire } from 'lwc';
import getOpportunityDetails from '@salesforce/apex/LeadShowLstOppController.getOpportunityDetails';

const columns=[{label:'Name',fieldName:'recordLink', type:'url',
typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
},
{label:'Buyer Account Name',fieldName:'AccountName',type:'text'},
{label:'Unit Name',fieldName:'UnitName',type:'text'},
{label:'Starting Retail Price ',fieldName:'StartingRetailPrice',type:'decimal'},
{label:'Loss Reason',fieldName:'LossReason',type:'text'},
{label:'Primary Contact',fieldName:'PrimaryContact',type:'text'},
{label:'CloseDate',fieldName:'CloseDate',type:'date'},
];

export default class showOppOnLead extends LightningElement {
       
    
    @api recordId;
    @track wonOppRecords;
    @track lostOppRecords;
    @track leadRecords;
    @track error;
    @track showSpinner = false;
    columns = columns;

    connectedCallback(){
        this.spinnerToggle();
        this.init();    
        this.spinnerToggle();   
    }

    init() {
        getOpportunityDetails({recordId : this.recordId})
        .then(result =>{
            if(result.isSuccess) {
                let parentWrapper = JSON.parse(result.response);
                    this.wonRecords = parentWrapper.closeWonOpportunity;
                    this.wonOppRecords = this.createCustomUrlRecord(this.wonRecords); 
                    this.lostRecords = parentWrapper.closeLostOpportunity;
                    this.lostOppRecords = this.createCustomUrlRecord(this.lostRecords);  
                    this.error = undefined;  
            } else {
                this.showToast('error', result.message, result.response);
            }
         
        })
        .catch(error =>{
            this.showToast('error', error.message, error.body);
        });
 
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
    
}