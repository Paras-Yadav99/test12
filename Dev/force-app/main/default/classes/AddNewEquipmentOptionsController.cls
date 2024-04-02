public class AddNewEquipmentOptionsController {
    public static final String SOBJECT_API_NAME = 'Equipment_Options__c';
    public static final String TEXT_CATEGORY = 'Category';
    public static final String TEXT_ALL_OTHER_CATEGORY = 'All_Other_Category';
    public static final String TEXT_FIELD_SET = 'fieldSet';
    /**
     * Param      : Unit/Product2 RecordId 
     * Return     : Map of <String, List<String>>
     * Description: Take the Unit RecordId as input return the Map of Name and Values for Equipment Options which
     *              are dependent on Unit Like category, FieldSet etc.. 
     *  
     */
    @AuraEnabled(cacheable=true)
    public static Map<String,List<String>> getRequiredValues(String recordId) {
        Map<String,List<String>> mapToReturn = new Map<String,List<String>>();
        system.debug('recordId'+recordId);
        if(recordId != null){
            List<Product2> unitList = [SELECT Id, Name, Category__c FROM Product2 where Id =:recordId];
            system.debug('unitList'+unitList);
            //Get Object Describe for Equipment_Options__c
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(SOBJECT_API_NAME);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            String fieldSetName;
            system.debug('DescribeSObjectResultObj'+DescribeSObjectResultObj);
            //Update the FieldSet Name as per the Category value on Unit Record
            if(unitList!= null && unitList.size()>0 && unitList[0].Category__c != null){
                system.debug('unitList[0].Category__c'+unitList[0].Category__c);
                mapToReturn.put(TEXT_CATEGORY, new List<String>{unitList[0].Category__c});
                fieldSetName = unitList[0].Category__c.trim().replace(' ','_');
            	system.debug('fieldSetName'+fieldSetName);
            }else{
                system.debug('TEXT_ALL_OTHER_CATEGORY'+TEXT_ALL_OTHER_CATEGORY);
                fieldSetName = TEXT_ALL_OTHER_CATEGORY;
            }
            system.debug('fieldSetName'+fieldSetName);
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            system.debug('fieldSetObj'+fieldSetObj);
            //If no fieldSet Found then Use the Default one which is All_Other_Category
            if(fieldSetObj == null){
                fieldSetName = TEXT_ALL_OTHER_CATEGORY;
                fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            }
            system.debug('fieldSetObj'+fieldSetObj);
            //Populate the FieldList Using the FieldSet Values
            List<String> fieldList = new List<String>();
            system.debug('fieldSetObj.getFields()'+fieldSetObj.getFields());
            for(Schema.FieldSetMember fsm: fieldSetObj.getFields() ){
                fieldList.add(fsm.getFieldPath());
            
            }
            system.debug('fieldList'+fieldList);
            if(fieldList.size()>0){
                mapToReturn.put(TEXT_FIELD_SET, fieldList);
            }
        }
        return mapToReturn;
    }
   /**
     * Param      : Equipment Option RecordId as recordId & Unit/Product2 RecordId as parentId
     * Return     : Void
     * Description: Update the EquipmentUnit__c On Equipment_Options__c Record If which the Id is passed in Param
     *  
     */
    @AuraEnabled
    public static void updateParentId(String recordId, String parentId) {
        List<Equipment_Options__c> eoList = [SELECT Id, EquipmentUnit__c FROM Equipment_Options__c where Id =:recordId];
        eoList[0].EquipmentUnit__c = Id.valueOf(parentId);
        System.debug(eoList[0]);
        update eoList[0];
    }

}