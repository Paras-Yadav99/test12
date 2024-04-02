import { LightningElement, api ,track} from 'lwc';
export default class ShowLeaderReportQuarterData extends LightningElement {
    @api reportData;
    @api isData;
    @track pageMessage = 'No Record Found(s).';

    connectedCallback() {
        console.log('Child Quarter Data Called ......::'+JSON.stringify(this.reportData));
    }
}