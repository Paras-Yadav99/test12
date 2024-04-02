import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

// Define the fields you want to retrieve
//const FIELDS = ['ObjectName__c.Field1__c', 'ObjectName__c.Field2__c'];

export default class SendMachineEmail extends LightningElement {
    @api recordId;
    objectData;

    
    @wire(CurrentPageReference)
    currentPageReference;


    @api async invoke(){
         if (this.currentPageReference) {
            const url = new URL(window.location.href);
            this.recordId = url.searchParams.get('recordId');
        }
        //this.recordId = getRecordIdFromUrl(this.currentPageReference);
        console.log('Record Id:::'+this.recordId);
       
        this.handleButtonClick();
    }

    // Load the record data
   /* @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.objectData = data;
        } else if (error) {
            // Handle error
        }
    }*/
  /*  connectedCallback(){
         if (this.currentPageReference) {
            const url = new URL(window.location.href);
            this.recordId = url.searchParams.get('recordId');
        }
        //this.recordId = getRecordIdFromUrl(this.currentPageReference);
        console.log('Record Id:::'+this.recordId);
       
        this.handleButtonClick();    
           
    }*/
    handleButtonClick() {
        console.log('recordId'+this.recordId);
        let url = 'https://zadoon1234--dev.sandbox.lightning.force.com/_ui/core/email/author/EmailAuthor?p3_lkid=01tD4000004Ti7dIAC&p5=&retURL=01tD4000004Ti7dIAC&template_id=00X6A000000crln';

        // Open URL in a new tab
       // this.closeAction();
        
        window.open(url);
        //window.open(url, '_blank');
       // this.closeAction();
        //window.location.reload(true);
       /* if (this.objectData) {
            // Access field data from objectData
            let field1Value = this.objectData.fields.Field1__c.value;
            let field2Value = this.objectData.fields.Field2__c.value;

            // Construct your URL with dynamic parameters
            let dynamicParam1 = 'value1';
            let dynamicParam2 = 'value2';
            let url = `https://example.com?param1=${dynamicParam1}&param2=${dynamicParam2}&recordId=${this.recordId}&field1=${field1Value}&field2=${field2Value}`;

            // Open URL in a new tab
            window.open(url, '_blank');
        }*/
    }

    closeAction(){
        console.log('close event is called>');
  this.dispatchEvent(new CloseActionScreenEvent());
}
}