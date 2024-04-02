import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class AddEquipmentOptions extends LightningElement {

    _recordId;
    set recordId(recordId) {
        if (recordId !== this._recordId) {
            this._recordId = recordId;
        }
    }

    /*
    @wire(getRecord, { recordId: '$_recordId', fields: FIELDS })
    unitRecord;*/
}