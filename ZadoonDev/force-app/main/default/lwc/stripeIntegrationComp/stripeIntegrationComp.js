import { LightningElement } from 'lwc';
import stripeFile from '@salesforce/resourceUrl/StripeJavaScipt';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class StripeIntegrationComp extends LightningElement {
    libInitialized = false;

    connectedCallback() {


    }

    handleSubmit1() {

        loadScript(this, stripeFile).then(() => {
             
            //this is the name of the function that’s present
            //in the uploaded static resource.
            stripe.createToken('bank_account', {
            country: 'US',
            currency: 'usd',
            routing_number: '110000000',
            account_number: '000123456789',
            account_holder_name: 'Jenny Rosen',
            account_holder_type: 'individual',
        })
            .then(function (result) {
                console.log(result);
                 console.log(stripeFile);
                // Handle result.error or result.token
            });
            
        })
         .catch((error) => {
             console.log(error);
             console.log(stripeFile);
                });
        


    }
    handleSubmit(){
        
        if (this.libInitialized) {
            return;
        }
        this.libInitialized = true;

        Promise.all([
            loadScript(this, stripeFile + '/v3/stripeFile1')
        ])
            .then(() => {
                // do your stuff when library is loaded successfully.
            })
            .catch(error => {
                // handle the error
            });
    

    }
}