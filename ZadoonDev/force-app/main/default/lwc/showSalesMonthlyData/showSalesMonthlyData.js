import { LightningElement,api,track } from 'lwc';

export default class ShowSalesMonthlyData extends LightningElement {
    @api parentData =[];
    @track isQuarter;
    connectedCallback(){
        
     console.log('Child Data : '+JSON.stringify(this.parentData));
    }
}