import { LightningElement } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class CloseScreenFlow extends LightningElement {
    connectedCallback() {
        console.log('twrgisfiisf23462');
    this.handleCloseFlow();
    }
    handleCloseFlow() {
/*
            const event = new FlowAttributeChangeEvent('RefreshPage', false);
        this.dispatchEvent(event);
*/
        console.log('twrgisfiisf');
       const event = new FlowAttributeChangeEvent('CloseFlow', false);
        this.dispatchEvent(event);
    }
}