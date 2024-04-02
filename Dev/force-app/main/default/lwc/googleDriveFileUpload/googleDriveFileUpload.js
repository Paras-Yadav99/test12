import { LightningElement, api} from 'lwc';

export default class GoogleDriveFileUpload extends LightningElement {

    uploadedFileDetail;
    @api fileType;
    @api fileName;

    getUploadedFile(event) {
        console.log('File Uploaded');
        if (event.target.files.length > 0) {
            const file = event.target.files[0];
            var reader = new FileReader();
            reader.readAsDataURL(file);
            reader.onloadend = () => {
                let fileTypeInfo = reader.result.split(',')[0];
                fileTypeInfo = fileTypeInfo.replace('data:', '');
                fileTypeInfo = fileTypeInfo.replace(';base64', '');
                this.uploadedFileDetail = {
                    fileName: file.name,
                    fileData: reader.result.split(',')[1],
                    fileTypeInfo: fileTypeInfo,
                    fileType: this.fileType,
                    uploadedFileName: this.fileName
                }
            }
        }
    }

    handleRemove(event) {
        this.uploadedFileDetail = null;
    }

    uploadFile(event) {
        this.isLoading = true;
        this.template.querySelector('.InputFFileUpload').click();
    }

    
    @api
    getUploadedFileDetail() {
        return this.uploadedFileDetail;
    }
}