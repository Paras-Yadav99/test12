import { LightningElement,api } from 'lwc';
import SendMatchingEmailToContact from '@salesforce/apex/SendMatchingEmailController.SendMatchingEmailToContact';
export default class SendMatchingEmail extends LightningElement {
    @api recordId;

    saveHandler(){
        
        SendMatchingEmailToContact({RecordId: this.recordId
                                })
        .then((result) => {
            
            console.debug(result);
            this.error = undefined;
            this.showNotification('SUCCESS', 'Email Send successfully!', 'success');
        })
        .catch((error) => {
            this.error = error;
            this.showNotification('ERROR', error.message , 'error');
            
        });
    }
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}