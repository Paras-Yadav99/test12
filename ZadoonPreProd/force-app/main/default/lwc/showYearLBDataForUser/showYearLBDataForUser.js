import { LightningElement, api, track } from 'lwc';
export default class showYearLBDataForUser extends LightningElement {
    @api reportData;
    @api isData;
    @api userName;
    @track pageMessage = 'No Record Found(s).';
    @track lstFieldData = [];
    @track tableHeaders = ['January','February' ,'March','April' ,'May','June','July','August' ,'September','October','November','December','TOTAL'];

   

    connectedCallback() {
        console.log('Child Called ......'+JSON.stringify(this.reportData));

        this.setFieldsData(this.reportData);
    }

    setFieldsData(data) {
        for (let i = 0; i < data[0].salesData.length; i++) {
            this.lstFieldData = this.lstFieldData.concat( data[0].salesData[i].label) ;
        }
       console.log('Child Called lstFieldData......'+JSON.stringify(this.lstFieldData)); 
    }

   
}