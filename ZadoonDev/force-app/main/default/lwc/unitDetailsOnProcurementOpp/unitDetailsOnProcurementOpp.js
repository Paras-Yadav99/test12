import {api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class LwcComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    startFlow() {
        // Pass recordId to the flow as a parameter
        const flowParams = {
            recordId: recordId // Replace with the actual record ID
        };

        // Navigate to the flow
        this[NavigationMixin.Navigate]({
            type: 'standard__flow',
            attributes: {
                flowApiName: 'Unit_details_on_Procurement_opportunity' // Replace with the actual flow API name
            },
             parameters: {
                ...flowParams
            }
        });
    }
}