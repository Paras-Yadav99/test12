import { LightningElement, api, track } from 'lwc';
export default class ShowDataLeaderBoardForUser extends LightningElement {
    @api reportData;
    @api quarter;
    @api isData;
    @api userName;
    @track pageMessage = 'No Record Found(s).';
    @track lstFieldData = [];

    //@track pageMessage;
    @track month1Name;
    @track month2Name;
    @track month3Name;

    connectedCallback() {
        console.log('Child Called ......'+JSON.stringify(this.reportData));
        this.getCurrentQuarter(this.quarter);
        this.setFieldsData(this.reportData);
    }

    setFieldsData(data) {
        for (let i = 0; i < data[0].salesData.length; i++) {
            this.lstFieldData = this.lstFieldData.concat( data[0].salesData[i].label) ;
        }
       console.log('Child Called lstFieldData......'+JSON.stringify(this.lstFieldData)); 
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