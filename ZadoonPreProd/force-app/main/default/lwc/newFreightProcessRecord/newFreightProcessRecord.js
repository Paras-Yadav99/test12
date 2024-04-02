import { LightningElement, api } from 'lwc';

export default class NewFreightProcessRecord extends LightningElement {
    @api freightReccords;
    isData = false;
    freightRecord;
    isNextDisabled = true;

    connectedCallback() {
        if (this.freightReccords != null) {
            this.freightRecord = JSON.parse(JSON.stringify(this.freightReccords));
            console.log('freightReccord ::::::' + JSON.stringify(this.freightRecord));
            this.validateIsNextDisabled()
        }
    }
    renderedCallback() {
        this.validateData();
    }

    @api refreshData(data) {
        this.freightRecord = data;
        this.validateData();
    }

    validateData() {
        if (this.freightRecord != null) {
            this.isData = true;
        }
    }



    handleOppSelect(event) {
        this.freightRecord.opportunityValue = event.detail.inputValue;
    }

    handleDestinationContactSelect(event) {
        this.freightRecord.destinationSiteContact = event.detail.inputValue;
    }

    genericInputChange(event) {
        if (event.target.street != null) {
            this.freightRecord.destinationStreet = event.target.street;
            this.validateIsNextDisabled();
        }
        if (event.target.province != null) {
            this.freightRecord.destinationState = event.target.province;
            this.validateIsNextDisabled();
        }
        if (event.target.city != null) {
            this.freightRecord.destinationCity = event.target.city;
            this.validateIsNextDisabled();
        }
        if (event.target.country != null) {
            this.freightRecord.destinationCountry = event.target.country;

            // this.validateIsNextDisabled();
        }
        if (event.target.postalCode != null) {
            this.freightRecord.destinationZipCode = event.target.postalCode;
             this.validateIsNextDisabled();
        }
    }
    handleRampsAvailableAtPickUpSite(event) {
        this.freightRecord.RampsAvailableAtPickUpSite = event.target.checked;
    }
    handleRampsAvailableAtDropOffSite(event) {
        this.freightRecord.RampsAvailableAtDropOffSite = event.target.checked;
    }
        

    validateIsNextDisabled() {
        if (! this.isEmpty(this.freightRecord.destinationStreet)
            && ! this.isEmpty(this.freightRecord.destinationState)
            && ! this.isEmpty(this.freightRecord.destinationCity )
            && ! this.isEmpty(this.freightRecord.destinationZipCode )) {
            this.isNextDisabled = false;
        } else {
            this.isNextDisabled = true;
        }
    }

    isEmpty(str) {
        return (!str || str.length === 0);
    }

    handleValueChange(event) {
        if (event.detail.name = 'destinationAddress') {
            this.freightRecord.destinationAddress = event.detail.value;
        }
    }

    cancleEdit() {
        this.handleFireEvent('close', '');
    }

    handleNextClick() {
        this.handleFireEvent('next', this.freightRecord);
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