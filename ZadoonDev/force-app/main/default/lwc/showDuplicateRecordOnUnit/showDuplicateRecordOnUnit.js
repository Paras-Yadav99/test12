import { LightningElement , api , track} from 'lwc';
import getUnitDuplicateRecord from '@salesforce/apex/ShowDuplicateRecordOnUnitController.getUnitDuplicateRecord';  // Call Apex Class and Method
export default class ShowDuplicateRecordOnUnit extends LightningElement {

@api recordId;
@track lstRecords=[];
@track showData = false;
@track urlRecords =[];

@track columns = [      // DataTable Columns
    {label:'Name',fieldName:'recordLink', type:'url',
    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    { label: 'Serial Number', fieldName: 'serialNumber'},
    { label: 'Year', fieldName:'year'},
    { label: 'Make', fieldName:'Make'},
    { label: 'Model', fieldName:'Model'},
    { label: 'Hour', fieldName:'Hour' },
    { label: 'Equipment', fieldName:'recordEquipment' , type:'url',
    typeAttributes: { label: { fieldName: 'equipment' }, target: '_blank' }
    }   
];
connectedCallback(){  // call init function
    this.init();
}

init(){
    getUnitDuplicateRecord({recordId : this.recordId}) // Calling Apex  
    .then(result => {
        if (result.isSuccess) {
            this.lstRecords = JSON.parse(result.response);

             this.createCustomUrlRecord(this.lstRecords);

            if(this.lstRecords.length>0){
                this.showData = true;

            }else{
                this.showData = false;

            }
        }
    else {
            console.log("Error Occured to Get Record");   // Show Error
            this.showData = false;          // if error occured component cant view
         }
        })
        .catch(error => {

            console.log('Error Occured' + error);    // Show Error
            this.showData = false;   // if error occured component cant view
        });
    }
    
    createCustomUrlRecord(data){       // To Set Record id in Url

        var tempUnitList = [];
        for (var i = 0; i < data.length; i++) {
            let tempRecord = Object.assign({},data[i]); //cloning object  
            tempRecord.recordLink = "/" + tempRecord.Id; 
            tempRecord.recordEquipment = "/" + tempRecord.equipmentId; 
            tempUnitList.push(tempRecord);  
            
        }
        this.urlRecords = tempUnitList;  
    }
}