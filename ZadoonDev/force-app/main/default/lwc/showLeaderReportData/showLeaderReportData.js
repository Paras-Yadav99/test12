import { LightningElement, api, track } from 'lwc';
export default class ShowLeaderReportData extends LightningElement {
    @api reportData;
    @api quarter;
    @api isData;
    @track pageMessage = 'No Record Found(s).';

    //@track pageMessage;
    @track month1Name;
    @track month2Name;
    @track month3Name;

    connectedCallback() {
        console.log('Child Called ......');
        this.getCurrentQuarter(this.quarter);
    }

    @api getCurrentQuarter(quater) {
        this.quarter = quater;
        //let thisMonth = today.toLocaleString('default', { month: 'long' });

        if (this.quarter == 'Quarter 1') {
            this.month1Name = 'January';
            this.month2Name = 'February';
            this.month3Name = 'March';
        } else if (this.quarter == 'Quarter 2') {
            this.month1Name = 'April';
            this.month2Name = 'May';
            this.month3Name = 'June';
        } else if (this.quarter == 'Quarter 3') {

            this.month1Name = 'July ';
            this.month2Name = 'August';
            this.month3Name = 'September';
        } else if (this.quarter == 'Quarter 4') {
            this.month1Name = 'October';
            this.month2Name = 'November';
            this.month3Name = 'December';
        }
    }
}