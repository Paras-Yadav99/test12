import { api, LightningElement } from 'lwc';

export default class InputComponent extends LightningElement {

    @api
    inputType;
    isPicklist = false;
    isBoolean = false;
    isText = false;
    isNumber = false;
    isTextArea = false;
    isMultiPicklist = false;
    @api
    inputName;
    @api
    inputLabel;
    @api
    inputValue;
    @api
    inputMap;
    @api
    placeHolder;
    @api
    picklistOptions;

    connectedCallback(){
        let imap = JSON.parse(this.inputMap);
        if(imap[this.inputName]){
            this.inputValue = imap[this.inputName].value;
        }
        if(this.inputType == "PICKLIST"){
            this.isPicklist = true;
        }else if(this.inputType == "STRING"){
            this.isText = true;
        }else if(this.inputType == "NUMBER"){
            this.isNumber = true;
        }else if(this.inputType == "BOOLEAN-PICKLIST"){
            this.isPicklist = true;
        }
        else if(this.inputType == "TEXTAREA"){
            this.isTextArea = true;
        }
        else if(this.inputType == "MULTIPICKLIST"){
            if(imap[this.inputName]){
                this.inputValue = imap[this.inputName].listOfValue;
            }
            if(!this.inputValue || this.inputValue == undefined){
                this.inputValue = [];
            }
            this.isMultiPicklist = true;
        }
        
    }
    handleValueChange(event){
        this.inputValue = event.detail.value;
        const valuechange = new CustomEvent("valuechange",{
            detail:{ "inputLabel":this.inputLabel, "inputValue": this.inputValue, "inputType":this.inputType, "inputName":this.inputName}
        });
        this.dispatchEvent(valuechange);
    }


}