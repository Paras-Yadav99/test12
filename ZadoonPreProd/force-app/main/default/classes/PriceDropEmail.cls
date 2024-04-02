/*
This future method class is called from unitcategoryDetailsTriggerHandler afterupdate event.
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          18-Nov-2023         Kizzy Consulting      	 Paras               Initial Version
------------------------------------------------------------------------------------------------
*/
public class PriceDropEmail {

    @future(callOut = true)
    public static void futureUnitCategoryDetails(list<id> setOfUnitId ){
        list<product2> lstProduct;
        set<Id> setOfContactId = new set <Id>();
        map<id,Contact> mapOfContact ;
        map<string,set<Id>> mapofUnitVsSetOfContact = new Map<string,set<Id>>();
        if(setOfUnitId!=null && !setOfUnitId.isEmpty()){
            lstProduct = [SELECT id,Year__c,Manufacturer__c,Name,Model__c,Hour__c,Storage_State__c,ZID__c,
                          Number_of_Images_in_Google_Drive__c,Number_of_Videos_in_Google_Drive__c,
                          Starting_Advertised_Retail_Price__c,Old_SF_Unit_Details__c,
                          Google_Drive_LInk__c,Google_Drive_Videos_Link__c,
                          (SELECT id,User_Requirement_ID__r.contact__c FROM Iron_Demand__r)
                          FROM product2 
                          WHERE id in : setOfUnitId AND ZID__c != null];
            
        }
        if(lstProduct!= null && !lstProduct.isEmpty()){
            
           
            for(Product2 eachProduct2 : lstProduct ){
                if(string.isNotBlank(eachProduct2.ZID__c) &&
                   eachProduct2.Iron_Demand__r!=null && !eachProduct2.Iron_Demand__r.IsEmpty()){
                    for(Iron_Demand__c eachIronDemand : eachProduct2.Iron_Demand__r){
                        if(string.isNotBlank (eachIronDemand.User_Requirement_ID__c) && 
                          string.isNotBlank (eachIronDemand.User_Requirement_ID__r.contact__c)){
                              if(!mapofUnitVsSetOfContact.ContainsKey(eachProduct2.ZID__c)){
                                  mapofUnitVsSetOfContact.put(eachProduct2.ZID__c,new set<Id>());
                              }
                              mapofUnitVsSetOfContact.get(eachProduct2.ZID__c).add(eachIronDemand.User_Requirement_ID__r.contact__c);
                            
                              setOfContactId.add(eachIronDemand.User_Requirement_ID__r.contact__c);
                        }
                    } 
                }
            }
        }
        if(setOfContactId!=null && !setOfContactId.isEmpty()){
            
             mapOfContact = new Map<ID, Contact>([SELECT ID, FirstName , LastName , Email FROM Contact WHERE ID IN : setOfContactId AND Email !=null]);
            MarketingCloudIntegration.EventDataWrapper EventDataWrapper ;
            string accessToken = '';
        	//list<DataWrapper> lstDataWrapper = new list<DataWrapper>();
            Marketing_Cloud_Info__mdt MarketingCloudMdt = [SELECT Client_ID__c,Client_Secret__c,Data_Extension__c,Get_Access_Token_URL__c,
                                                             IsActive__c,Event_Definition_Key__c
                                                             FROM Marketing_Cloud_Info__mdt
                                                             WHERE IsActive__c = true AND DeveloperName= 'Price_Drop_Email' LIMIT 1 ];
              if(MarketingCloudMdt != null){
                  accessToken =  MarketingCloudIntegration.getAccessToken(MarketingCloudMdt.Get_Access_Token_URL__c,MarketingCloudMdt.Client_ID__c,MarketingCloudMdt.Client_Secret__c,MarketingCloudMdt.Data_Extension__c);
              } 
            for(id eachContactId : setOfContactId){
                MarketingCloudIntegration.DataWrapper DataWrapper ;
                string UnitZids = '';
                if(mapofUnitVsSetOfContact.KeySet()!=null && !mapofUnitVsSetOfContact.KeySet().isEmpty()){
                    for(string eachUnitZidId : mapofUnitVsSetOfContact.KeySet()){
                        if(mapofUnitVsSetOfContact.get(eachUnitZidId) !=null && !mapofUnitVsSetOfContact.get(eachUnitZidId).IsEmpty()
                          && mapofUnitVsSetOfContact.get(eachUnitZidId).Contains(eachContactId)){
                            UnitZids +=  eachUnitZidId + ',';
                        }
                    }
                }
                if(string.isNotBlank(UnitZids) && mapOfContact.ContainsKey(eachContactId)){
                    UnitZids = removeLastChar.removeChars(UnitZids,1);
                    
                    DataWrapper = new MarketingCloudIntegration.DataWrapper(mapOfContact.Get(eachContactId).email,mapOfContact.Get(eachContactId).firstname,
                                                  mapOfContact.Get(eachContactId).lastname,UnitZids,eachContactId);
                    //lstDataWrapper.add(DataWrapper);
                    EventDataWrapper = new MarketingCloudIntegration.EventDataWrapper(eachContactId ,MarketingCloudMdt.Event_Definition_Key__c, DataWrapper);
                  MarketingCloudIntegration.createRecord(accessToken, MarketingCloudMdt.Data_Extension__c,EventDataWrapper);
                }
                
                
            }
        }
    }
    
}