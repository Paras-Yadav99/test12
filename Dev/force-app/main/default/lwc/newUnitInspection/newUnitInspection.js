import { LightningElement,api, track } from 'lwc';
export default class NewUnitInspection extends LightningElement {
@api unitInspectionData;

@track unitInspectionRecord;
@track isData = false;

connectedCallback() {
    console.log('Unit InspectionData :::'+this.unitInspectionData);
    if(this.unitInspectionData!=null){
        this.unitInspectionRecord = JSON.parse(JSON.stringify(this.unitInspectionData));
        console.log('Unit unitInspectionRecord :::'+this.unitInspectionRecord);
        this.validateData(this.unitInspectionRecord);
    }
}
    @api refreshData(data) {
        this.unitInspectionRecord = JSON.parse(JSON.stringify(data));
        this.validateData(this.unitInspectionRecord);
         console.log('Unit unitInspectionRecord :::'+JSON.stringify(this.unitInspectionRecord));
    }


    validateData(data) {
        if (data != null) {
            this.isData = true;
        }else{

            this.isData = false;
        }
    }

handleOppSelect(event) {
        this.unitInspectionRecord.opportunityValue = event.detail.inputValue;
    }

    cancleEdit() {
        this.handleFireEvent('close', '');
    }

    handleNextClick() {
        this.handleFireEvent('next', this.unitInspectionRecord);
    }
    handleFireEvent(eventName, value) {
        const customEvent = new CustomEvent(eventName, {
            detail: {
                value: value
            }
        });
        this.dispatchEvent(customEvent);
    }



}