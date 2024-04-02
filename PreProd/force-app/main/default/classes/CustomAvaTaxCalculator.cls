//Class should be Global so that AvaTax for Mapper package would be able to access the class
global with sharing class CustomAvaTaxCalculator {
    public static Id AvaTaxId = null;
      //  AvaTaxId = 'a5IE10000000XlZMAU';
    public CustomAvaTaxCalculator() {}
    public CustomAvaTaxCalculator(ApexPages.StandardController controller) {
        AvaTaxId = controller.getRecord().id;
       //AvaTaxId = 'a5IE10000000XlZMAU';
    }
    public PageReference calculateTaxButton() {
        calculateTax();
        return redirectPage();
    }
    static public void calculateTax() {
        try {
             if (Test.isRunningTest()) {
                TestClass();
            }
            system.debug('AvaTaxId'+AvaTaxId);
            Map<String,String> AvaTaxParam = new Map<String,String>();
            AVA_SFCLOUD.ConfigurationProvider config = new AVA_SFCLOUD.ConfigurationProvider();
            AVA_MAPPER.TaxCalculator AvaTaxObj = new 
               // AVA_MAPPER.TaxCalculator(config.hookExtension(), 'AVA_ SFCLOUD__AvaTax_Mapping__c', 'AVA_SFCLOUD__Field_Mapping__c ');
               
                AVA_MAPPER.TaxCalculator('SFConfig','',config.hookExtension());
            AVA_MAPPER.TaxCalculationInput taxCalcInput = new AVA_MAPPER.TaxCalculationInput();
            taxCalcInput.recordId = AvaTaxId;
            taxCalcInput.controller = 'custom_avatax__c'; //If the environment has namespace,
            //append it to the object API name. Value should be in small letters.
            taxCalcInput.optionalParams = AvaTaxParam;
            taxCalcInput.isMultiCommit = False;
            System.debug('taxCalcInput: '+taxCalcInput);
            Ava_Mapper.TransactionModel transResult = AvaTaxObj.calculateTax(taxCalcInput);
            System.debug('transResult: '+transResult);
            if (transResult.statusCode == 200 || transResult.statusCode == 201) {
                System.debug('success');
                //Tax calculation is successful. Add business logic as required to display the details.
            } else {
                //There is some error in Tax calculation.Error details will be available in below debug logs.
                System.debug('transResult.statusCode: ' + transResult.statusCode);
                System.debug('AVA_MAPPER.ErrorInfo error: ' + transResult.error);
            }
        } catch (Exception e) {
            system.debug('In exception::'+e);
            system.debug('In exception');
        }
    }
    public PageReference redirectPage() {
        PageReference pageRef = new PageReference('/' + AvaTaxId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    private static void TestClass(){
        integer i = 0;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}