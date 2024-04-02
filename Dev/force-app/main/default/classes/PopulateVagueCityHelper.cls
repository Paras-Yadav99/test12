public class PopulateVagueCityHelper {
    public static List<Unit_Location_Setting__c> locationSettings;
    public static Map<String, String> stateToCapitalMap;
    public static Map<String, String> capitalToAnotherCityMap;

    public PopulateVagueCityHelper(){
        System.debug('4sdftsd6fyuudf PopulateVagueCityHelper is Called .');
        locationSettings = [SELECT Id, Name, Another_City__c, Capital__c, State__c FROM Unit_Location_Setting__c LIMIT 9000];
        stateToCapitalMap = getStateToCapitalMap();
        capitalToAnotherCityMap = getcapitalToAnotherCityMap();
    }
    
    public String getCity(Product2 unit){
        String city = '';
        if(unit.Inventory_Status__c == 'Owned'){
            city = unit.Storage_City__c;
        }else{
            city = String.isBlank(getVagueCity(unit.Storage_City__c, unit.Storage_State__c)) ? unit.Storage_City__c : getVagueCity(unit.Storage_City__c, unit.Storage_State__c);
        }

        return city;
    } 
    
    public String getVagueCity(String storageCity, String storageState){
        String vagueCity = '';
        system.debug('capitalToAnotherCityMap : ' + capitalToAnotherCityMap);
        system.debug('storageCity : ' + storageCity);
        system.debug('storageState : ' + storageState);
        if(String.isNotBlank(storageCity) && 
            capitalToAnotherCityMap.keySet().contains(storageCity) &&
            capitalToAnotherCityMap.get(storageCity) != null){

            vagueCity = capitalToAnotherCityMap.get(storageCity);
            
        } else if(String.isNotBlank(storageState) && 
            stateToCapitalMap.keySet().contains(storageState) &&
            stateToCapitalMap.get(storageState) != null){
            
            vagueCity = stateToCapitalMap.get(storageState);
        }

        return vagueCity;
    }

    private Map<String, String> getStateToCapitalMap(){
        Map<String, String> stateToCapitalMap = new Map<String, String>();
        for(Unit_Location_Setting__c locationSetting : locationSettings){
            stateToCapitalMap.put(locationSetting.State__c, locationSetting.Capital__c);
        }

        return stateToCapitalMap;
    }

    private Map<String, String> getcapitalToAnotherCityMap(){
       
        Map<String, String> capitalToAnotherCityMap = new Map<String, String>();
        for(Unit_Location_Setting__c locationSetting : locationSettings){
            capitalToAnotherCityMap.put(locationSetting.Capital__c, locationSetting.Another_City__c);
        }

        return capitalToAnotherCityMap;
    }
}