import { LightningElement , track} from 'lwc';
import getAllFields from '@salesforce/apex/CreateCustomUnitController.getAllFields';
import saveUnitData from '@salesforce/apex/CreateCustomUnitController.saveUnitData';
export default class CreateCustomUnit extends LightningElement {

    @track ObjectName = 'Product2';
    @track lstFields = []; 
    @track datatype = false;
    @track inputAndOutputData = [];
    @track allData =[];
    showLookup = true;
    disablecheck
    selectedid

    connectedCallback(){
        this.init();
    }
    onChildCall(event){
        for (let element of this.lstFields){
            if(element.fieldApiName == event.detail.name){  
                element.answer = event.detail.fieldvalue;
            //     console.log(JSON.stringify(this.allData));
            //    console.log('on Patrent Side Data ');
            //     console.log('name  : ' + event.detail.name);
                
            //     console.log('fieldvalue :' + event.detail.fieldvalue);
            //     console.log('element.answer' + JSON.stringify(element.answer));
            //     this.inputAndOutputData.push(JSON.stringify(element.fieldApiName));
            //     this.inputAndOutputData.push(JSON.stringify(element.answer));
            //    console.log('inputAndOutputData' + JSON.stringify(this.lstFields));
            }  
        }
        this.allData = JSON.stringify(this.lstFields);
    }
    init(){
        getAllFields({YOURSOBJECTNAME : this.ObjectName})
        .then(result => {
            if (result.isSuccess) {
                this.lstFields = JSON.parse(result.response);
                this.datatype =  JSON.parse(this.lstFields.dataType);
            }
        else {
                console.log("Error Occured");
             }
            })
            .catch(error => {
                console.log('Error occoured' + error);
            });
        }
        handleSave(){
         
            saveUnitData({allData : this.allData})
            .then(result => {
                if (result.isSuccess) {

                    console.log('SucessFully Response Recived')

                }
            else {
                    console.log("Error Occured");
                 }
                })
                .catch(error => {

                    console.log('Error occoured' + error);
                });
            }
        }