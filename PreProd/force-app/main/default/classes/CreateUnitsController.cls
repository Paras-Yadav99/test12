public class CreateUnitsController {
    @AuraEnabled
    public static List<Product2> saveUnits(String unitsDataString){
        //add Aura response
        System.debug(unitsDataString);
        List<Product2> unitListToInsert  = new List<Product2>();
        Set<Id> unitIds = new Set<Id>();
        if(String.isNotBlank(unitsDataString)){
            List<unitWrapper> unitList = (List<unitWrapper>)System.JSON.deserialize(unitsDataString, List<unitWrapper>.Class);
            for(unitWrapper wrapper : unitList){
                Product2 unitData = new Product2();
                unitData.Year__c = wrapper.year;
                unitData.Mileage__c = Integer.valueOf(wrapper.mileage);
                unitData.Account__c = wrapper.accObj.value;
                unitData.equipment__c = wrapper.equipObj.value;
                unitData.Hour__c = Integer.valueOf(wrapper.hours);
                unitData.Storage_City__c = wrapper.storageCity;
                unitData.Vin__c = wrapper.vin;
                unitData.Storage_State__c = wrapper.storageState;
                unitData.Serial_Number__c = wrapper.serialNumber;
                unitData.Name = 'Test';
                unitData.Sellers_Original_Asking_Price__c = Integer.valueOf(wrapper.sellersAskingPrice);
                unitData.Starting_Advertised_Retail_Price__c = wrapper.startingAdRetailPrice;
                unitData.Old_SF_Unit_Details__c = wrapper.unitDetail;
                unitData.Sourced_From_Link__c = wrapper.sourcedFromLink;
                unitData.IsActive = wrapper.active;
                unitData.Storage_Country__c = wrapper.country;
                unitData.Inventory_Status__c = wrapper.inventoryStatus;
                unitData.Unit_Owner__c = wrapper.userObj.value;
                unitData.Unit_Stage__c = wrapper.unitStage;
                unitListToInsert.add(unitData);
            }
            Database.insert(unitListToInsert);
        }

        for(Product2 unit : unitListToInsert){
            unitIds.add(unit.Id);
        }
        unitListToInsert = [SELECT Id, ZID__c, Name FROM Product2 WHERE Id IN :unitIds];
        
        return unitListToInsert;
        
    }

    @AuraEnabled(cacheable=true)
     public static List < customValueWrapper > pickListValueDynamically(sObject customObjInfo, string selectPicklistApi) {
        Schema.DescribeSObjectResult objDescribe = customObjInfo.getSObjectType().getDescribe();     
        map < String, Schema.SObjectField > customFieldMap = objDescribe.fields.getMap();      
        list < Schema.PicklistEntry > custPickValues = customFieldMap.get(selectPicklistApi).getDescribe().getPickListValues();
        list < customValueWrapper > customObjWrapper = new list < customValueWrapper > ();
        for (Schema.PicklistEntry myCustPick: custPickValues) {
          customValueWrapper selectOptionValueWrapper = new customValueWrapper();
            selectOptionValueWrapper.label = myCustPick.getLabel();
            selectOptionValueWrapper.value = myCustPick.getValue();
            customObjWrapper.add(selectOptionValueWrapper);
        }
        
        return customObjWrapper;
  
      }

    public class customValueWrapper {
        @auraEnabled public string label {get;set;}
        @auraEnabled public string value {get;set;}
    }

    public class unitWrapper{
        public String year;
        public String storageCity;
        public String serialNumber;
        public String storageState;
        public Integer hours;
        public Integer sellersAskingPrice;
        public Integer startingAdRetailPrice;
        public Integer mileage;
        public String vin;
        public objWrapper accObj;
        public objWrapper equipObj;
        public String sourcedFromLink;
        public String unitDetail;
        public Boolean active;
        public String country;
        public String inventoryStatus;
        public objWrapper userObj;
        public String unitStage;
    }

    public class objWrapper{
        public String label;
        public String value;
    }
}