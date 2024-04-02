import { LightningElement, track } from 'lwc';

export default class DealerAndMatchingEmail extends LightningElement {
    @track showPicklist1 = false;
    @track showPicklist2 = false;
    
    // Options for the multi-select picklists
    options1 = [
        { label: 'Option A', value: 'A' },
        { label: 'Option B', value: 'B' },
        { label: 'Option C', value: 'C' },
    ];

    options2 = [
        { label: 'Option X', value: 'X' },
        { label: 'Option Y', value: 'Y' },
        { label: 'Option Z', value: 'Z' },
    ];

    @track selectedOptions1 = [];
    @track selectedOptions2 = [];

    handlePicklistChange(event) {
        // Handle changes in the selected options of the multi-select picklists
        if (event.target.label === 'Select Options' && this.showPicklist1) {
            this.selectedOptions1 = event.detail.value;
        } else if (event.target.label === 'Select Options' && this.showPicklist2) {
            this.selectedOptions2 = event.detail.value;
        }
    }

    // Add any additional logic or methods as needed
}