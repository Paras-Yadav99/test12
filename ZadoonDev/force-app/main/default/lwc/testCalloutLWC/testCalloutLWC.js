import { LightningElement } from 'lwc';
import getTokenFromAuthProvider from '@salesforce/apex/inspectionReportMainController.getTokenFromAuthProvider';
import AUTH_PROVIDER_NAME from '@salesforce/label/c.AUTH_PROVIDER_NAME';
import FILE_UPLOAD_ENDPOINT_URL from '@salesforce/label/c.FILE_UPLOAD_ENDPOINT_URL';
import FOLDER_CREATE_ENDPOINT_URL from '@salesforce/label/c.FOLDER_CREATE_ENDPOINT_URL';

export default class TestCalloutLWC extends LightningElement {

    connectedCallback() {
        this.getAuthToken();
    }

    ///////////////////// Google Drive JS Method /////////////////
    getAuthToken() {
        getTokenFromAuthProvider({authProviderName: AUTH_PROVIDER_NAME}).then(result => {
            console.log('Auth Token : ' + JSON.stringify(result));
            if(result.isSuccess) {
                this.accessToken = result.result;
            }else {
                // Handle error.
            }
            this.isLoading = false;
        }).catch(error => {
            console.log('Error: ' + JSO.stringify(error));
            // Handle error.
            this.isLoading = false;
        });
    }
}