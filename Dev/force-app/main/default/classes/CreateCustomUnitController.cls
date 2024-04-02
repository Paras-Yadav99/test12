public class CreateCustomUnitController { 
    
    @AuraEnabled
    
    public static AuraResponse getAllFields(string YOURSOBJECTNAME){ //Aura Method 

        AuraResponse AuraResponse;
        
        try{
            
            if(string.isNotEmpty(YOURSOBJECTNAME)){  			 // try method
                AuraResponse = new AuraResponse(true ,
                                                'Success',
                                                JSON.serialize(getFields(YOURSOBJECTNAME)));         
            }
            
            else {
                AuraResponse = new AuraResponse(false ,
                                                'error',
                                                'FieldName is not Found');   
            }
            
        }
        catch (exception ex){				//catch method
            
            AuraResponse = new AuraResponse(false ,
                                            'Error',
                                            ex.getMessage());
        }
        
        return AuraResponse;
    } 
    
    @AuraEnabled
        public static AuraResponse saveUnitData(string allData){ //Aura Method 
        
        
        AuraResponse AuraResponse;
        
        try{
            
            if(string.isNotEmpty(allData)){  			 // try method
                AuraResponse = new AuraResponse(true ,
                                                'Success',
                                                JSON.serialize(saveUnit(allData)));         
            }
            
            else {
                AuraResponse = new AuraResponse(false ,
                                                'error',
                                                'Data is not Found');   
            }
            
        }
        catch (exception ex){				//catch method
            
            AuraResponse = new AuraResponse(false ,
                                            'Error',
                                            ex.getMessage());
            
        }
        
        return AuraResponse;
        
    } 

    @AuraEnabled
    
    public static list<wrapper> getFields(String YOURSOBJECTNAME){
        String objType;
        
        if(YOURSOBJECTNAME != null){
         objType= YOURSOBJECTNAME;
        }
        
        list<wrapper> lstWrapper = new list<wrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        // system.debug('All fielddataType :::' + fieldMap);
        for (String fieldName: fieldMap.keySet()) {
            //get all the fields label for Account Object
            String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            //get data types for each fieldsss
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
             Schema.DisplayType fieldType = fielddataType;
            system.debug('fieldName ::  '  + fieldName);
            system.debug('fieldType  ::  '  + fieldType);

            string fieldApiName = fieldName;
            //    lstWrapper.add(new wrapper(fieldName,fieldType ));
            // system.debug('fielddataName :::' + fieldName);
            // system.debug('fielddataType' + fielddataType);
            
            string refrenceName =getReferenceName(fieldMap.get(fieldName));
            system.debug('refrenceName ' + refrenceName);
            lstWrapper.add(new wrapper (fieldLabel , fieldType , refrenceName , fieldApiName));
        }
        
        return lstWrapper;
        
    }

    private static string getReferenceName(Schema.SObjectField currentValue){
        string refrenceName='';
        
        Schema.DescribeFieldResult fd = currentValue.getDescribe(); // describe each field (fd)
                    for(Schema.SObjectType reference : fd.getReferenceTo()) {
                        
                        refrenceName = reference.getDescribe().getName();
                        
                       // System.debug('Lookup reference object name:' + reference.getDescribe().getName());
                       // System.debug('Lookup reference object label:'+ reference.getDescribe().getLabel());
                        
                    }
        

        return refrenceName;
    }

    public class AuraResponse{

        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public string message;
        @AuraEnabled public string response;
        
        AuraResponse(Boolean isSuccess,
                     String message,
                     string response){
                         
                         this.isSuccess = isSuccess;
                         this.message = message;
                         this.response = response;
                     }
    }
    public class Wrapper{
        
        @AuraEnabled public string fieldLabel;
        @AuraEnabled public Schema.DisplayType dataType;
        @AuraEnabled public string RefrenceName;
        @AuraEnabled public string fieldApiName;
        @AuraEnabled public string Question;
        @AuraEnabled public string answer;

        
        wrapper(string fieldLabel , Schema.DisplayType dataType , string RefrenceName , string fieldApiName ){
            
            system.debug('answer' + answer);
            this.fieldLabel = fieldLabel;
            this.dataType  = dataType;
            this.RefrenceName = RefrenceName;
            this.fieldApiName = fieldApiName;
        }
    }
    
    public class saveRecords{
        
        public String RefrenceName;	
        public String Question;
        public String fieldLabel;	
        public String fieldApiName;	
        public String dataType;	
        public String answer;
        
    }

    @AuraEnabled
    public static list<saveRecords> saveUnit(string allData){
        
        list<saveRecords> deseralizedData;
        system.debug('allData' + allData);
        list<saveRecords> dataWrapper = (list<saveRecords>)JSON.deserialize(allData, list<saveRecords>.class);
        system.debug('dataWrapper' + dataWrapper);
        deseralizedData = dataWrapper;
        system.debug('deseralizedData' + deseralizedData); 
        if(deseralizedData != null){
            product2 productInstance = new product2();
            for(saveRecords eachProduct : deseralizedData){
                system.debug('eachProduct' + eachProduct);
                system.debug('productInstance' + productInstance);
                productInstance.put(eachProduct.fieldApiName , eachProduct.answer);
                //eachProduct.fieldApiName = eachProduct.answer;
                system.debug('productInstance' + productInstance);
            }
            system.debug('productInstance' + productInstance);
            insert productInstance; 
        }
        return deseralizedData;
    }
}
/*
public static void getObjectFields(String YOURSOBJECTNAME){

List<SelectOption> childObjectFields = new List<SelectOption>();

Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getmap();

List<String> sortedKeyset = new List<String>();

for (String fieldName: mapFields.keyset()){
sortedKeyset.add(fieldName);
}
sortedKeyset.sort();
for (String fieldName: sortedKeyset){
childObjectFields.add(new SelectOption(fieldName, fieldName));
system.debug('childObjectFields Map Data In Loop : : : '+mapFields.get(fieldName));
}
system.debug('childObjectFields Map Data : : : '+mapFields);
System.debug('childObjectFields' + childObjectFields);
return ;
} 

*/

/*
public static void getdatatype(String YOURSOBJECTNAME){

String objType= YOURSOBJECTNAME;
Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
Schema.SObjectType leadSchema = schemaMap.get(objType);
Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
for (String fieldName: fieldMap.keySet()) {
Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
}

system.debug('objType' + objType);
system.debug('schemaMap' + schemaMap);
system.debug('fieldMap' + fieldMap);
}
*/
/*  

SObject sObj = scon.getRecord();

Schema.DescribeSObjectResult objectDescribe = sObj.getSObjectType().getDescribe();

Map<String, Schema.SObjectField> fields = objectDescribe.fields.getMap();
Map<String, Object> result = new Map<String, Object>();

for(String fieldName : fields.keySet()) {
Schema.SObjectField field = fields.get(fieldName);
Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
if(fieldDescribe.getType() == Schema.DisplayType.Phone) {
result.put(fieldDescribe.getLabel(), sObj.get(field));
}
}

return JSON.Serialize(result);        
}

*/

/*       if(fielddataType != Schema.DisplayType.TextArea) {
}
if(fielddataType != Schema.DisplayType.String) {
}            
if(fielddataType != Schema.DisplayType.Integer) {
}
if(fielddataType != Schema.DisplayType.DateTime) {
} */
//  if(fielddataType == Schema.DisplayType.Reference) {
// Schema.DescribeFieldResult f = Schema.sObjectType.objType.fields.fieldMap.get(fieldName).getDescribe().getLabel().getName();
// String objectName = f.getDescribe().getName();
// System.debug('Field Object Name ::::'+objectName);
// describe of your lookup field
/*Schema.DescribeFieldResult f = Schema.sObjectType.Product2.fields.createdbyId;
System.debug('Relationship Name: ' + f.getRelationshipName());    
for(Schema.SObjectType reference : f.getReferenceTo()) {
System.debug('Lookup reference object name: ' + reference.getDescribe().getName());
System.debug('Lookup reference object label: ' + reference.getDescribe().getLabel());
}*/

/*
for (Schema.SObjectField ft : fieldMap.values()){ // loop through all field tokens (ft)

Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
for(Schema.SObjectType reference : fd.getReferenceTo()) {
System.debug('Lookup reference object name: ' + reference.getDescribe().getName());
System.debug('Lookup reference object label: ' + reference.getDescribe().getLabel());
}

}
*/