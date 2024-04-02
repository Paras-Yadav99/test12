import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FreightFilterScreen extends LightningElement {
    @api clientTypeValue;
    clientTValue;

    connectedCallback() {
        this.clientTValue = this.clientTypeValue;
    }

    get clientTypeOption() {
        return [
            { label: "Shipping/Logistics - Domestic - Trucker", value: "Shipping/Logistics - Domestic - Trucker" },
            { label: "Shipping/Logistics - Domestic - Broker", value: "Shipping/Logistics" },
            { label: "Shipping/Logistics - Int'l", value: "Shipping/Logistics - Int'l" }
        ];
    }

    handleChange(event) {
        if (event.currentTarget.name === "clientType") {
            this.clientTValue = event.currentTarget.value;
            console.log('this.numberOfRecordsPerPage ::: ' + this.clientTValue);
            //this.assignPageAttributes();
        } else if (event.currentTarget.name === "currentpage") {
            this.currentPage = event.currentTarget.value;
        }
    }

    handlePreviousButton(){
        this.handleFireEvent('previous', '');
    }

    cancleEdit(){
        this.clientTValue = '';
        this.handleFireEvent('close', '');
    }

    handleNextClick(){
        if(this.clientTValue != null && this.clientTValue !=''){
            this.sendFilterWrapperToWrapper();
        }else{
            
                this.showToast('error', 'HeadsUp!!','Please Select the Filter Value First.');
        }
         
    }



    sendFilterWrapperToWrapper() {

        //this.isSelected = true;
                const valueselected = new CustomEvent("select",{
                    detail:{"clientType": this.clientTValue}
                });
                this.dispatchEvent(valueselected);
                console.log('valueselected : :'+JSON.stringify(valueselected));
      // this.isSelected = true;
      }

      handleFireEvent(eventName, value) {
        const customEvent = new CustomEvent(eventName, {
            detail: {
                value: value
            }
        });
        this.dispatchEvent(customEvent);
    }

     showToast(variant,
        title,
        message) {
        const event = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message,
        });
        this.dispatchEvent(event);
    }
}