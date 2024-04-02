import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/FileUploaderClass.uploadFile'
export default class FileUploaderCompLwc extends LightningElement {
    @api recordId;
    fileData;

    connectedCallback() {
        console.log('rec id on load : : '+ this.recordId);
    }
    openfileUpload(event) {
         console.log(' file upload is called on file uploads: : '+ this.recordId);
        const file = event.target.files[0]
        console.log('filesize:::'+file.size);
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
            console.log(JSON.stringify(this.fileData));
        }
        reader.readAsDataURL(file)
    }
    
    @api handleClick(){
        console.log('handle click is called on file uploads: : '+ this.recordId);
        if(this.fileData != null){
        const {base64, filename, recordId} = this.fileData
        uploadFile({ base64, filename, recordId }).then(result=>{
            this.fileData = null
            let title = `${filename} uploaded successfully!!`
            this.toast(title)
        }
        ).catch(error => {
            console.log('Error ::::'+JSON.stringify(error));
                //this.showToast('error', error.message, error.body);
            });
        }
    }

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
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