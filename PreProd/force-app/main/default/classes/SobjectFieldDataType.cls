public class SobjectFieldDataType {
    public static Map<string,string> sobjectFieldDataType(string sObj){
        Map<string,string> mapOfFieldAPInameVsDataType = new Map<string,string>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType objectType = gd.get(sObj);
        if (objectType != null) {
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            for (String fieldName : fieldMap.keySet()) {
                Schema.SObjectType objectName = Schema.getGlobalDescribe().get(sObj);
                Schema.SObjectField objectField = objectName.getDescribe().fields.getMap().get(fieldName);
                String dataType = objectField.getDescribe().getType().name();
                if(!mapOfFieldAPInameVsDataType.containsKey(fieldName) && string.isNotBlank(dataType) ){
                    mapOfFieldAPInameVsDataType.put(fieldName,dataType);
                }
            }
        } else {
            System.debug('Object not found: ' + sObj);
        }
        if(mapOfFieldAPInameVsDataType.values()!=null && !mapOfFieldAPInameVsDataType.Values().isEmpty()){
            set<String> setOfDataType = new set<string>();
            for(string eachString : mapOfFieldAPInameVsDataType.Values()){
                setOfDataType.add(eachString);
            }
        
            return mapOfFieldAPInameVsDataType;
        }
      return null;  
    }
}