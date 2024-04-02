public with sharing class UnitFilterController {
    /**
     * Param       : stringified Product/Unit filters and stringified Equipment Options filters
     * Return      : List of Products/Units
     * Description : filter out the unit records and return list of Units
     */
    @AuraEnabled
    public static List<Product2> getProducts(String stringifiedList, String stringifiedListChild){
        try {
            OutputListWrapper filterListParent = (OutputListWrapper)JSON.deserialize(stringifiedList,OutputListWrapper.class);
            OutputListWrapper filterListChild = (OutputListWrapper)JSON.deserialize(stringifiedListChild,OutputListWrapper.class);
            System.debug('filterListParent: '+filterListParent);
            System.debug('filterListChild: '+filterListChild);

            String filter = '';
            //Create filter query for Product2/Unit records
            for(OutputFieldWrapper field: filterListParent.filterList){
                if(!(field.value == null || String.isBlank(field.value))){
                    if('Category__c'.equalsIgnoreCase(field.name)){
                        filter += ' '+field.name+' = '+' \'' + String.escapeSingleQuotes(field.value.trim()) + '\'' + ' AND '; 
                    }
                    else if('Min_Year__c'.equalsIgnoreCase(field.name)){
                        filter += 'Year__c >='+' \'' + String.escapeSingleQuotes(field.value.trim()) + '\'' + ' AND ';
                    }
                    else if('Max_Year__c'.equalsIgnoreCase(field.name)){
                        filter += 'Year__c <='+' \'' + String.escapeSingleQuotes(field.value.trim()) + '\'' + ' AND ';

                    }
                    else if('Make__c'.equalsIgnoreCase(field.name)){
                        filter += 'Manufacturer__c ='+' \'' + String.escapeSingleQuotes(field.value.trim()) + '\'' + ' AND ';
                    }
                    else if('Model__c'.equalsIgnoreCase(field.name)){
                        filter += 'Model__c ='+' \'' + String.escapeSingleQuotes(field.value.trim()) + '\'' + ' AND ';

                    }
                    else if('Min_Hour__c'.equalsIgnoreCase(field.name)){
                        filter += 'Hour__c >= '+String.escapeSingleQuotes(field.value.trim())  + ' AND ';
                    }
                    else if('Max_Hour__c'.equalsIgnoreCase(field.name)){
                        filter += 'Hour__c <= '+String.escapeSingleQuotes(field.value.trim())  + ' AND ';
                    }
                    else if('Min_Price__c'.equalsIgnoreCase(field.name)){
                        filter += 'Starting_Advertised_Retail_Price__c >= '+String.escapeSingleQuotes(field.value.trim())  + ' AND ';
                    }
                    else if('Max_Price__c'.equalsIgnoreCase(field.name)){
                        filter += 'Starting_Advertised_Retail_Price__c <= '+String.escapeSingleQuotes(field.value.trim())  + ' AND ';
                    }
                    else if('Unit_Name__c'.equalsIgnoreCase(field.name)){
                        filter += 'Name LIKE'+'\'%' + String.escapeSingleQuotes(field.value.trim()) + '%\'' + ' AND ';
                    }
                }
            }

            String query = 'SELECT Id, Name, ZID__c, Year__c, Hour__c, Last_Equipment_Status_Confirmation__c, Seller_Account_Name__c, Displayed_Vague_Location__c, Starting_Advertised_Retail_Price__c, Display_Lowest_Purchase_Price__c FROM Product2 ';
            if(filter != ''){
                query += 'WHERE ' + filter + ' isActive = true';
            }else {
                query += ' WHERE isActive = true';
            }
            System.debug('Query'+query);

            filter = '';

            //Create filter for child records

            for(OutputFieldWrapper field: filterListChild.filterList){
                if('MULTIPICKLIST'.equalsIgnoreCase(field.type) || !(field.value == null || String.isBlank(field.value))){
                    System.debug('field.value'+field.value);
                    if('STRING'.equalsIgnoreCase(field.type) || 'PICKLIST'.equalsIgnoreCase(field.type) ){
                        filter += ' '+field.name+' = '+' \'' + String.escapeSingleQuotes(field.value.trim()) + '\''; 
                        filter += ' AND';
                    }
                    else if('NUMBER'.equalsIgnoreCase(field.type) || 'BOOLEAN-PICKLIST'.equalsIgnoreCase(field.type)){
                        filter += ' '+field.name+' = ' + String.escapeSingleQuotes(field.value.trim()) + ''; 
                        filter += ' AND';
                    }else if('MULTIPICKLIST'.equalsIgnoreCase(field.type) && field.listOfValue != null && field.listOfValue.size() > 0){
                        filter += ' '+field.name+' IN ( \''+  String.join(field.listOfValue, '\' , \'') + '\' ) ';
                        filter += ' AND';
                    }else if('TEXTAREA'.equalsIgnoreCase(field.type)){
                        filter += ' ' + field.name + ' LIKE '+'\'%' + String.escapeSingleQuotes(field.value.trim()) + '%\'';
                        filter += ' AND';
                    }
                }
            }
                
            if(filter != ''){
                String queryChild = ' AND ID IN (SELECT EquipmentUnit__c FROM Equipment_Options__c ';
                filter = filter.removeEnd('AND');
                queryChild += 'WHERE ' + filter +' )';
                System.debug('Query'+queryChild);

                query += queryChild;
                System.debug('Whole Query: '+query);
            }
            List<Product2> listToReturn = Database.query(query);
            System.debug('listToReturn Size'+listToReturn.size());
            return listToReturn;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //Wrapper class for input fileds to Pass the field set to LWC component
    public class InputFieldWrapper {
        @AuraEnabled
        public string label{get;set;}
        @AuraEnabled
        public string type{get;set;}
        @AuraEnabled
        public string name{get;set;}
    }
    
    //Wrapper to hold list of OutputFieldWrapper
    public class OutputListWrapper{
        @AuraEnabled
        public List<OutputFieldWrapper> filterList{get;set;}
    }
    //Wrapper class for recevied filter Objects from LWC componenet
    public class OutputFieldWrapper {
        @AuraEnabled
        public String lable{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public List<String> listOfValue{get;set;}
        @AuraEnabled
        public String type{get;set;}
    }

   /**
     * Param       : String Category
     * Return      : List of Fields copied into list of InputFieldWrapper
     * Description : get the filed sets of Equipment option object as per the Category of parent object(Product2)
     */
    

    @AuraEnabled
    public static List<InputFieldWrapper> getFieldsList(String category){
        try {
            system.debug('category'+category);
            //Get Object Describe for Equipment_Options__c
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Equipment_Options__c');
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            String fieldSetName;
            system.debug('fieldSetName'+fieldSetName);
            if(category == null || category == ''){
                fieldSetName = 'All_Other_Category';
            }else{
                
                fieldSetName = category.trim().replace(' ','_');
                system.debug('fieldSetName'+fieldSetName);
            }
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            system.debug('fieldSetObj'+fieldSetObj);
            //If no fieldSet Found then Use the Default one which is All_Other_Category
            if(fieldSetObj == null){
                fieldSetName = 'All_Other_Category';
                fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            }
            system.debug('fieldSetObj'+fieldSetObj);
            
            //Populate the FieldList Using the FieldSet Values
            List<InputFieldWrapper> fieldsList = new List<InputFieldWrapper>();
            InputFieldWrapper tempObj;
            for(Schema.FieldSetMember fsm: fieldSetObj.getFields() ){
                system.debug('fsm'+fsm);
                tempObj = new InputFieldWrapper();
                tempObj.label = fsm.getLabel();
                tempObj.name = fsm.getFieldPath();
                tempObj.type = fsm.getType()+'';
                fieldsList.add(tempObj);
            }
            system.debug('fieldsList'+fieldsList);
            return fieldsList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Get List of contacts in system
    @AuraEnabled
    public static list<contact> getContactList() {
		
       // create contact list to store search result 
        list<contact> contactListRecord = new list<contact>();
        contactListRecord = [Select Id,Name,Email,FirstName,LastName,Phone,Secondary_Email__c,
                             Client_Email_Opt_Out__c,Account_Client_Type__c,Account.billingstatecode From Contact where Client_Email_Opt_Out__c = false
                            and Not_A_Client_We_Want_To_Do_Business_With__c = false and email != null ORDER BY CreatedDate Limit 1000];
        
         if(contactListRecord.size() == 0){
            throw new AuraHandledException('No Record Found..'); 
         }
         
        return contactListRecord;
    }
    //Get List of contacts in system
    @AuraEnabled
    public static LightningResponse getFilteredContactList(String accountBillingState,String accountClientTypes,String searchString) {
        LightningResponse response = new LightningResponse();
       // create contact list to store search result 
       list<contact> contactListRecord = new list<contact>();
       String filter = '';
          if(accountBillingState != ''){
                   filter += 'Account.BillingStateCode ='+' \'' + accountBillingState + '\'' + ' AND ';
                   }
                    if(accountClientTypes != ''){
                       filter += 'Account_Client_Type__c ='+' \'' + accountClientTypes + '\'' + ' AND ';
                   }
                    if(searchString != ''){
                       filter += ' (Name LIKE '+'\'%' + searchString + '%\'';
                       filter += ' OR Email LIKE '+'\'%' + searchString + '%\'';
                       filter += ' OR Secondary_Email__c LIKE '+'\'%' + searchString + '%\') AND';
                   }
           String query = 'Select Id,Name,Email,FirstName,LastName,Phone,Secondary_Email__c,Client_Email_Opt_Out__c,Account_Client_Type__c,Account.billingstatecode From Contact ';
           if(filter != ''){
               query += 'WHERE ' + filter + ' Client_Email_Opt_Out__c = false and Not_A_Client_We_Want_To_Do_Business_With__c = false and Email != null';
           }else {
               query += 'WHERE Client_Email_Opt_Out__c = false and Not_A_Client_We_Want_To_Do_Business_With__c = false and Email != null';
           }
        System.debug('ff'+query);
        contactListRecord = Database.query(query);
        
         if(contactListRecord.size() != 0){
            response.bIsSuccess = true;
            response.put('objectName',contactListRecord); 
           
         }
         else{
            response.bIsSuccess = false;
            //response.put('objectName',sObjName); 

         }
         
        return response;
    }
   /**
     * Param       : List of Contact Ids and Unit Ids
     * Return      : Void
     * Description : Send Email to all the contactIds passed with the Details of Units 
     */
    @AuraEnabled
    public static void sendEmailToContact(List<String> conIds, List<String> unitIds) {
		 System.debug('Send Email To Contact Called');
         System.debug('ConIds : '+conIds);
         System.debug('unitIds : '+unitIds);
         String htmlBody = getHTMLBodyForEmail((Set<ID>)JSON.deserialize(JSON.serialize(unitIds), Set<ID>.class));
         Database.executeBatch(new SendUnitDetailsToContacts((Set<ID>)JSON.deserialize(JSON.serialize(conIds), Set<ID>.class),htmlBody), 1);
       
    }
    
    @AuraEnabled
    public static void sendEmailToIronDemandsContact(List<String> unitIds) {
        List<Iron_Demand__c> iDemandList = [Select Id, IronDemand_Contact__c,IronDemand_Contact__r.Client_Email_Opt_Out__c from Iron_Demand__c 
                                            where Unit_Currently_Interested_In__c in :unitIds and IronDemand_Contact__c != null];
        List<String> conIds = new List<String>();
        for(Iron_Demand__c idemand: iDemandList){
            conIds.add(''+idemand.IronDemand_Contact__c);
        }
        sendEmailToContact(conIds, unitIds);  
    }

    public static String getHTMLBodyForEmail(Set<Id> unitIds){
        String htmlBody = '';
        Integer counter = 1;
        for(Product2 unit: [SELECT Id, Name, ZID__C, Google_Drive_LInk__c,Old_SF_Unit_Details__c,Year__c,Storage_State__c, Display_Price__c, Hour__c FROM Product2 where Id in :unitIds]){
            String str = unit.Old_SF_Unit_Details__c;
            string unitDetails;
            list<String> lstString = new list<String>();
            lstString = str.split('-'); 
            if(lstString!=null && !lstString.isEmpty()){
                for(String eachStr : lstString ){
                    unitDetails += '<p>' +eachStr + +'</p> ';
                }
                
            }
            htmlBody += ' <body style="background-color:white"> <center> <img src = "https://zadoon1234--dev.sandbox.my.salesforce.com/sfc/p/2200000093BB/a/220000004M7V/PtqhCQz4GSWOBCs58YUt9r6iq_iOs_I_ErQSgAyu_C0"/>'
                     +unit.Year__c +' ' +unit.Name +' // $'+ unit.Display_Price__c+ ' // '+unit.Storage_State__c +')</b></p> '
                     +  '<p>&emsp;'+ 'Stock #ZID- ' +unit.ZID__c+' ' +'<a href = \''+unit.Google_Drive_LInk__c +'\'> Photos  </a> </p> '
                     

                     +  '<p>'+unitDetails +'</p> '
                     +'</center></body>' ;           
                    
                   
                
            counter+=1;
        }
        return htmlBody;
    }

}