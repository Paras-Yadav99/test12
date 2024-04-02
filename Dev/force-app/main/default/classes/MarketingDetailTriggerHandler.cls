/*
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          14-Aug-2023         Kizzy Consulting        Paras Yadav             Initial Version
------------------------------------------------------------------------------------------------
*/
public class MarketingDetailTriggerHandler implements ITriggerHandler{
	private static final string DEVELOPER_NAME = 'MarketingDetail';
     public Trigger_Setting__mdt setTriggerSettings() {
       
        
        return [select Active__c,Max_Loop_Count__c,Stop_Recursion__c FROM Trigger_Setting__mdt 
                Where DeveloperName=:DEVELOPER_NAME LIMIT 1];
    
    } 
    
    Public void beforeInsert(List<SObject> triggerNew){
		//handleBeforeInsert((List<opportunity>)triggerNew);
           
    }
    //By implementing this method trigger can handle all the before Update events
    Public void beforeUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){    
        handleBeforeUpdate((List<Marketing_Detail__c>) triggerNew, (Map<Id, Marketing_Detail__c>) triggerOldMap);
    }
    //By implementing this method trigger can handle all the before Delete events
    Public void beforeDelete(List<SObject> triggerOld){
        
    }   
    //By implementing this method trigger can handle all the after Insert events
    Public void afterInsert(List<SObject> triggerNew){
        handleafterInsert((List<Marketing_Detail__c>)triggerNew);
    }
    //By implementing this method trigger can handle all the after Update events
    Public void afterUpdate(List<SObject> triggerNew, Map<Id, SObject> triggerOldMap){
       handleAfterUpdate((List<Marketing_Detail__c>) triggerNew, (Map<Id, Marketing_Detail__c>) triggerOldMap);
	}
    //By implementing this method trigger can handle all the after Delte events
    Public void afterDelete(List<SObject> triggerOld){
      
    }
    //By implementing this method trigger can handle all the after UnDelete events
    Public void afterUndelete(List<SObject> triggerNew){
     
    }
    private static void handleBeforeUpdate(
        List<Marketing_Detail__c> triggerNew, 
        Map<Id, Marketing_Detail__c> triggerOldMap
    ){
        if(triggerNew!=null && !triggerNew.isEmpty()){
            
         	map<Id,list<Marketing_Detail__c>>mapOfAccountIdVsLstMarketingDetail = new map<Id,list<Marketing_Detail__c>>();
            map<Id,list<Marketing_Detail__c>>mapOfUnitIdVsLstMarketingDetail = new map<Id,list<Marketing_Detail__c>>();
            map<Id,Id> mapOfOpportunityIdVsUnitId = new map<Id,Id>();
            list<Marketing_Detail__c> lstMarketingDetailToUpdate = new list<Marketing_Detail__c>();
            list<Marketing_Detail__c> lstMarketingDetailOnOpportunity;
            //set<Id> setOfOpportunityProductId = new set<Id>();
            set<Id> setOfAccountId = new set<Id>();
            set<Id> setOfOpportunityId = new set<Id>();
            set<Id> setOfUnitId = new set<Id>();
            list<Product2> lstUnit ;
            list<Opportunity> lstOpportunityForAccount;
            list<Product2> lstOpportunityUnit ;
            list<Opportunity> lstOpportunity ;
            map<ID,List<Marketing_Detail__c>>mapOFAccountIdVsLstOpportunityMD = new map<ID,List<Marketing_Detail__c>>();
            for(Marketing_Detail__c eachMarketingDetail : triggerNew){
                //if(string.isBlank(staticVariable.UpdatedFromObject)){
                Marketing_Detail__c oldMarketingDetail = triggerOldMap.get(eachMarketingDetail.id);
                
                if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Do_not_market_anywhere__c') 
                   && eachMarketingDetail.Do_not_market_anywhere__c ){
                       eachMarketingDetail.Call_Won_Lost_Opps_Checked__c = False;
                       eachMarketingDetail.Marketed_On_Craigslist__c = False ;
                       //eachMarketingDetail.Marketed_On_Facebook__c = False ;
                       eachMarketingDetail.Marketed_On_FB_Marketplace__c = False ;
                       eachMarketingDetail.Marketed_On_Fleet_Up_Marketplace__c = False ;
                       //eachMarketingDetail.Marketed_On_GearFlow__c = False ;
                       eachMarketingDetail.Marketed_On_Instagram__c = False ;
                       eachMarketingDetail.Marketed_On_LinkedIn__c = False ;
                       eachMarketingDetail.Marketed_On_Machinio__c = False ;
                       eachMarketingDetail.Marketed_On_Mascus__c = False ;
                       eachMarketingDetail.Marketed_on_MT_Crane_Truck__c =False ;
                       eachMarketingDetail.Marketed_On_MyLittleSalesman__c = False ;
                       //eachMarketingDetail.Marketed_On_Terrapoint__c = False ;
                       eachMarketingDetail.Marketed_On_TradeMachines__c = False ;
                       //eachMarketingDetail.Marketed_On_Used_Equip_Guide__c = False ;
                       //eachMarketingDetail.Marketed_On_Zonapesada__c = False ;
                       eachMarketingDetail.Marketed_On_Iron_Connect__c = False ;
                       eachMarketingDetail.Market_on_FB_Group__c = False ;
                       eachMarketingDetail.Marketed_On_Equipment_Trader__c = false;
                       eachMarketingDetail.Marketed_On_RitchieList__c = false;
                       eachMarketingDetail.Marketed_On_Rock_Dirt__c = false;
                       eachMarketingDetail.Marked_On_Email_Blast__c = false ;
                       
                }
                Map<String, Object> fieldMap = eachMarketingDetail.getPopulatedFieldsAsMap();
                                
                String sObjectType = String.valueOf(eachMarketingDetail.getSObjectType());
                if(string.isBlank(staticVariable.UpdatedFromObject) && (string.isNotBlank(eachMarketingDetail.Opportunity__c) ||
                  string.isNotBlank(eachMarketingDetail.Unit__c))){
                    
                    for (String fieldName : fieldMap.keySet()) {
                        Schema.SObjectField sfield = eachMarketingDetail.getSObjectType().getDescribe().fields.getMap().get(fieldName);
                        String dataType = String.valueOf(sfield.getDescribe().getType());
                        if(dataType == 'boolean'  
                           && hasFieldChanged(eachMarketingDetail, triggerOldMap.get(eachMarketingDetail.Id) , fieldName)
                          ){
                              if(string.isNotBlank(eachMarketingDetail.Opportunity__c)){
                                  eachMarketingDetail.Updated_From__c = 'Opportunity';
                              }else If (string.isNotBlank(eachMarketingDetail.Unit__c)){
                                  eachMarketingDetail.Updated_From__c = 'Manually';
                              }
                                   
                          }
                    }
                }
            }
        }/*
                        
                    if(string.isNotBlank(eachMarketingDetail.Account__c) 
                       && string.isBlank(eachMarketingDetail.Updated_From__c)){
                           setOfAccountId.add(eachMarketingDetail.Account__c);   
                           
                       }else if(string.isNotBlank(eachMarketingDetail.Opportunity__c)
                                && string.isBlank(eachMarketingDetail.Updated_From__c)){
                                    setOfOpportunityId.add(eachMarketingDetail.Opportunity__c);
                                    
                                }else if(string.isNotBlank(eachMarketingDetail.Unit__c)
                                         && string.isNotBlank(eachMarketingDetail.Updated_From__c)){
                                             setOfUnitId.add(eachMarketingDetail.Unit__c);
                                             
                                         }
//}
                
            }
            system.debug('setOfAccountId::'+setOfAccountId);
            system.debug('setOfOpportunityId::'+setOfOpportunityId);
            system.debug('setOfUnitId::'+setOfUnitId);
            if(setOfAccountId!= null && !setOfAccountId.isEmpty()){
                lstUnit = [SELECT Id,Account__c,
                               (SELECT Id,  
                                Marketed_On_Craigslist__c,  Marketed_On_FB_Marketplace__c, Call_Won_Lost_Opps_Checked__c,
                                Marketed_On_Fleet_Up_Marketplace__c,  Marketed_On_Instagram__c, 
                                Marketed_On_LinkedIn__c, Marketed_On_Machinio__c, Marketed_On_Mascus__c,
                                Marketed_on_MT_Crane_Truck__c, Marketed_On_MyLittleSalesman__c,
                                 Marketed_On_TradeMachines__c, Do_not_market_anywhere__c,Marketed_On_Iron_Connect__c,
                                Unit__c,Opportunity__c,Account__c,Updated_From__c,Marketed_On_RitchieList__c, 
                                Marketed_On_Rock_Dirt__c, Marketed_On_Equipment_Trader__c
                                FROM Marketing_Details__r WHERE Updated_From__c ='Account' AND id != : triggerNew ) 
                           FROM Product2 
                           WHERE Account__c IN : setOfAccountId];

                lstOpportunityForAccount = [SELECT Id,Account__c,
                                        (SELECT Id,  
                                            Marketed_On_Craigslist__c,  Marketed_On_FB_Marketplace__c, Call_Won_Lost_Opps_Checked__c,
                                            Marketed_On_Fleet_Up_Marketplace__c,  Marketed_On_Instagram__c, 
                                            Marketed_On_LinkedIn__c, Marketed_On_Machinio__c, Marketed_On_Mascus__c,
                                            Marketed_on_MT_Crane_Truck__c, Marketed_On_MyLittleSalesman__c,
                                            Marketed_On_TradeMachines__c, Do_not_market_anywhere__c,Marketed_On_Iron_Connect__c,
                                            Unit__c,Opportunity__c,Account__c,Updated_From__c,Marketed_On_RitchieList__c, 
                                            Marketed_On_Rock_Dirt__c, Marketed_On_Equipment_Trader__c
                                            FROM Marketing_Details__r WHERE Opportunity__c!=null
                                         AND id != : triggerNew AND Updated_From__c = 'Account' ) 
                                    FROM Opportunity 
                                    WHERE Seller_Account__c IN : setOfAccountId AND ID NOT IN : setOfOpportunityId];
            }
            system.debug('lstUnit'+lstUnit);
            //system.debug('lstUnit'+lstUnit.size());
            if(lstUnit!=null && !lstUnit.isEmpty()){
                for(Product2 eachUnit : lstUnit){
                    system.debug('eachUnit.Marketing_Details__r:'+eachUnit.Marketing_Details__r);
                    system.debug('eachUnit.Marketing_Details__r:::'+eachUnit.Marketing_Details__r.size());
                    if(eachUnit.Marketing_Details__r!=null && !eachUnit.Marketing_Details__r.isEmpty()){
                        for(Marketing_Detail__c eachMarketingDetail : eachUnit.Marketing_Details__r){
                        	if(!mapOfAccountIdVsLstMarketingDetail.containsKey(eachUnit.Account__c)){
                        		mapOfAccountIdVsLstMarketingDetail.put(eachUnit.Account__c,new list<Marketing_Detail__c>());
                                mapOfAccountIdVsLstMarketingDetail.get(eachUnit.Account__c).add(eachMarketingDetail);
                            }else{
                                mapOfAccountIdVsLstMarketingDetail.get(eachUnit.Account__c).add(eachMarketingDetail);
                            }
                        }
                    }
                    
                    
                }
            }
            if(lstOpportunityForAccount!=null && !lstOpportunityForAccount.isEmpty()){
                for(Opportunity eachOpportunity : lstOpportunityForAccount){
                    if(String.isNotBlank(eachOpportunity.Account__c) ){

                        if(!mapOfAccountIdVsLstMarketingDetail.containsKey(eachOpportunity.Account__c)){
                            mapOfAccountIdVsLstMarketingDetail.put(eachOpportunity.Account__c,new list<Marketing_Detail__c>());
                            mapOfAccountIdVsLstMarketingDetail.get(eachOpportunity.Account__c).add(eachOpportunity.Marketing_Details__r);
                        }else{
                            mapOfAccountIdVsLstMarketingDetail.get(eachOpportunity.Account__c).add(eachOpportunity.Marketing_Details__r);
                        }*/
                       /* if(!mapOFAccountIdVsLstOpportunityMD.ContainsKey(eachOpportunity.Account__c)){
                            mapOFAccountIdVsLstOpportunityMD.put(eachOpportunity.Account__c,new list<Marketing_Detail__c>());
                            mapOFAccountIdVsLstOpportunityMD.get(eachOpportunity.Account__c).addAll(eachOpportunity.Marketing_Details__r);
                        }else{
                            mapOFAccountIdVsLstOpportunityMD.get(eachOpportunity.Account__c).addAll(eachOpportunity.Marketing_Details__r);
                        }*/
                    }/*
                }
            }
            system.debug('mapOfAccountIdVsLstMarketingDetail::'+mapOfAccountIdVsLstMarketingDetail);
            if(setOfOpportunityId!= null && !setOfOpportunityId.isEmpty()){
                lstOpportunity = [SELECT Id, AccountId,Product__c, Amount 
                                  FROM Opportunity 
                                  WHERE Id IN : setOfOpportunityId 
                                  AND Product__c!=null];
            }
            system.debug('lstOpportunity:::'+lstOpportunity);
            if(lstOpportunity!=null && !lstOpportunity.isEmpty()){
                for(Opportunity eachOpportunity : lstOpportunity){
                    mapOfOpportunityIdVsUnitId.put(eachOpportunity.id,eachOpportunity.Product__c);
                    //setOfOpportunityProductId.add(eachOpportunity.Product__c);
                }
                
            }
            if(mapOfOpportunityIdVsUnitId.values()!=null && !mapOfOpportunityIdVsUnitId.values().isEmpty()){
                lstOpportunityUnit = [SELECT Id,Account__c,
                                       (SELECT Id , Marketed_On_Iron_Connect__c,Marked_On_Email_Blast__c,
                                        Marketed_On_Craigslist__c,  Marketed_On_FB_Marketplace__c, 
                                        Marketed_On_Fleet_Up_Marketplace__c,  Marketed_On_Instagram__c, 
                                        Marketed_On_LinkedIn__c, Marketed_On_Machinio__c, Marketed_On_Mascus__c,
                                        Marketed_on_MT_Crane_Truck__c, Marketed_On_MyLittleSalesman__c,
                                         Marketed_On_TradeMachines__c, Do_not_market_anywhere__c,Marketed_On_RitchieList__c, 
                                        Marketed_On_Rock_Dirt__c, Marketed_On_Equipment_Trader__c,
                                        Unit__c,Opportunity__c,Account__c,Updated_From__c, Call_Won_Lost_Opps_Checked__c
                                        FROM Marketing_Details__r WHERE Updated_From__c !='Manually')//WHERE Updated_From__c ='Opportunity' ) 
                                   FROM Product2 
                                   WHERE Id IN : mapOfOpportunityIdVsUnitId.values()];
            }
            system.debug('lstOpportunityUnit:::'+lstOpportunityUnit);
            if(lstOpportunityUnit!=null && !lstOpportunityUnit.isEmpty()){
                for(Product2 eachUnit : lstOpportunityUnit){
                    if(eachUnit.Marketing_Details__r!=null && !eachUnit.Marketing_Details__r.isEmpty()){
                        for(Marketing_Detail__c eachMarketingDetail : eachUnit.Marketing_Details__r){
                        	if(!mapOfUnitIdVsLstMarketingDetail.containsKey(eachUnit.id)){
                        		mapOfUnitIdVsLstMarketingDetail.put(eachUnit.id,new list<Marketing_Detail__c>());
                                mapOfUnitIdVsLstMarketingDetail.get(eachUnit.id).add(eachMarketingDetail);
                            }else{
                                mapOfUnitIdVsLstMarketingDetail.get(eachUnit.id).add(eachMarketingDetail);
                            }
                        }
                    }
                    
                    
                }
            }*/
            /*list<Marketing_Detail__c>lstMarketingDetail = [SELECT Id, Marketed_On_Construction_Equip_Guide__c, 
                                                               Marketed_On_Craigslist__c, Marketed_On_Facebook__c, Marketed_On_FB_Marketplace__c, 
                                                               Marketed_On_Fleet_Up_Marketplace__c, Marketed_On_GearFlow__c, Marketed_On_Instagram__c, 
                                                               Marketed_On_LinkedIn__c, Marketed_On_Machinio__c, Marketed_On_Mascus__c,
                                                               Marketed_on_MT_Crane_Truck__c, Marketed_On_MyLittleSalesman__c,
                                                               Marketed_On_Terrapoint__c, Marketed_On_TradeMachines__c, 
                                                               Marketed_On_Used_Equip_Guide__c, Marketed_On_Zonapesada__c, 
                                                               Do_not_market_anywhere__c,
                                                               Unit__c,Opportunity__c,Account__c,Updated_From__c
                                                           FROM Marketing_Detail__c WHERE Account__c IN : setOfAccountId 
                                                           OR Opportunity__c IN : setOfOpportunityId 
                                                           OR Unit__c IN : setOfUnitId ];
            if(lstMarketingDetail!=Null && !lstMarketingDetail.isEmpty()){
                for(Marketing_Detail__c eachMarketingDetail : lstMarketingDetail){
                   mapOfAccountIdVsMarketingDetail.put(eachMarketingDetail.Account__c,eachMarketingDetail);
                }
            }*/
        /*
            for(Marketing_Detail__c eachMarketingDetail : triggerNew ){
                if(string.isNotBlank(eachMarketingDetail.Account__c) && 
                   string.isBlank(eachMarketingDetail.Updated_From__c )){

                   if(mapOfAccountIdVsLstMarketingDetail.containsKey(eachMarketingDetail.Account__c) &&
                    mapOfAccountIdVsLstMarketingDetail.get(eachMarketingDetail.Account__c)!=null && 
                   !mapOfAccountIdVsLstMarketingDetail.get(eachMarketingDetail.Account__c).isempty()){
                       staticVariable.UpdatedFromObject='Account';
                       for(Marketing_Detail__c eachMarketingDetail1 : mapOfAccountIdVsLstMarketingDetail.get(eachMarketingDetail.Account__c)){
                           //eachMarketingDetail1.Marketed_On_Construction_Equip_Guide__c = eachMarketingDetail.Marketed_On_Construction_Equip_Guide__c;
                           eachMarketingDetail1.Marketed_On_Craigslist__c = eachMarketingDetail.Marketed_On_Craigslist__c ;
                           //eachMarketingDetail1.Marketed_On_Facebook__c = eachMarketingDetail.Marketed_On_Facebook__c ;
                           eachMarketingDetail1.Marketed_On_FB_Marketplace__c = eachMarketingDetail.Marketed_On_FB_Marketplace__c;
                           eachMarketingDetail1.Marketed_On_Fleet_Up_Marketplace__c = eachMarketingDetail.Marketed_On_Fleet_Up_Marketplace__c;
                           //eachMarketingDetail1.Marketed_On_GearFlow__c = eachMarketingDetail.Marketed_On_GearFlow__c;
                           eachMarketingDetail1.Marketed_On_Instagram__c = eachMarketingDetail.Marketed_On_Instagram__c;
                           eachMarketingDetail1.Marketed_On_LinkedIn__c = eachMarketingDetail.Marketed_On_LinkedIn__c;
                           eachMarketingDetail1.Marketed_On_Machinio__c = eachMarketingDetail.Marketed_On_Machinio__c;
                           eachMarketingDetail1.Marketed_On_Mascus__c = eachMarketingDetail.Marketed_On_Mascus__c;
                           eachMarketingDetail1.Marketed_on_MT_Crane_Truck__c =eachMarketingDetail.Marketed_on_MT_Crane_Truck__c;
                           eachMarketingDetail1.Marketed_On_MyLittleSalesman__c = eachMarketingDetail.Marketed_On_MyLittleSalesman__c;
                           //eachMarketingDetail1.Marketed_On_Terrapoint__c = eachMarketingDetail.Marketed_On_Terrapoint__c ;
                           eachMarketingDetail1.Marketed_On_TradeMachines__c =eachMarketingDetail.Marketed_On_TradeMachines__c;
                           //eachMarketingDetail1.Marketed_On_Used_Equip_Guide__c = eachMarketingDetail.Marketed_On_Used_Equip_Guide__c;
                          // eachMarketingDetail1.Marketed_On_Zonapesada__c = eachMarketingDetail.Marketed_On_Zonapesada__c;
                           eachMarketingDetail1.Do_not_market_anywhere__c =eachMarketingDetail.Do_not_market_anywhere__c;
                           eachMarketingDetail1.Market_on_FB_Group__c = eachMarketingDetail.Market_on_FB_Group__c;
                           eachMarketingDetail1.Marketed_On_Iron_Connect__c =eachMarketingDetail.Marketed_On_Iron_Connect__c;
                           eachMarketingDetail1.Marketed_On_Equipment_Trader__c = eachMarketingDetail.Marketed_On_Equipment_Trader__c;
                           eachMarketingDetail1.Marketed_On_RitchieList__c = eachMarketingDetail.Marketed_On_RitchieList__c;
                           eachMarketingDetail1.Marketed_On_Rock_Dirt__c = eachMarketingDetail.Marketed_On_Rock_Dirt__c;
                           
                           lstMarketingDetailToUpdate.add(eachMarketingDetail1);
                       }
                    }*//*else If (mapOFAccountIdVsLstOpportunityMD.ContainsKey(eachMarketingDetail.Account__c) &&
                    mapOFAccountIdVsLstOpportunityMD.get(eachMarketingDetail.Account__c)!= null&&
                    !mapOFAccountIdVsLstOpportunityMD.get(eachMarketingDetail.Account__c).IsEmpty()){
                        staticVariable.UpdatedFromObject='Account';
                        for(Marketing_Detail__c eachMarketingDetail1 : mapOFAccountIdVsLstOpportunityMD.get(eachMarketingDetail.Account__c)){
                            eachMarketingDetail1.Call_Won_Lost_Opps_Checked__c = eachMarketingDetail.Call_Won_Lost_Opps_Checked__c;
                                eachMarketingDetail1.Marketed_On_Craigslist__c = eachMarketingDetail.Marketed_On_Craigslist__c ;
                                // eachMarketingDetail1.Marketed_On_Facebook__c = eachMarketingDetail.Marketed_On_Facebook__c ;
                                eachMarketingDetail1.Marketed_On_FB_Marketplace__c = eachMarketingDetail.Marketed_On_FB_Marketplace__c;
                                eachMarketingDetail1.Marketed_On_Fleet_Up_Marketplace__c = eachMarketingDetail.Marketed_On_Fleet_Up_Marketplace__c;
                                // eachMarketingDetail1.Marketed_On_GearFlow__c = eachMarketingDetail.Marketed_On_GearFlow__c;
                                eachMarketingDetail1.Marketed_On_Instagram__c = eachMarketingDetail.Marketed_On_Instagram__c;
                                eachMarketingDetail1.Marketed_On_LinkedIn__c = eachMarketingDetail.Marketed_On_LinkedIn__c;
                                eachMarketingDetail1.Marketed_On_Machinio__c = eachMarketingDetail.Marketed_On_Machinio__c;
                                eachMarketingDetail1.Marketed_On_Mascus__c = eachMarketingDetail.Marketed_On_Mascus__c;
                                eachMarketingDetail1.Marketed_on_MT_Crane_Truck__c =eachMarketingDetail.Marketed_on_MT_Crane_Truck__c;
                                eachMarketingDetail1.Marketed_On_MyLittleSalesman__c = eachMarketingDetail.Marketed_On_MyLittleSalesman__c;
                                //  eachMarketingDetail1.Marketed_On_Terrapoint__c = eachMarketingDetail.Marketed_On_Terrapoint__c ;
                                eachMarketingDetail1.Marketed_On_TradeMachines__c =eachMarketingDetail.Marketed_On_TradeMachines__c;
                                // eachMarketingDetail1.Marketed_On_Used_Equip_Guide__c = eachMarketingDetail.Marketed_On_Used_Equip_Guide__c;
                                // eachMarketingDetail1.Marketed_On_Zonapesada__c = eachMarketingDetail.Marketed_On_Zonapesada__c;
                                eachMarketingDetail1.Do_not_market_anywhere__c =eachMarketingDetail.Do_not_market_anywhere__c;
                                eachMarketingDetail1.Market_on_FB_Group__c = eachMarketingDetail.Market_on_FB_Group__c;
                                eachMarketingDetail1.Marketed_On_Iron_Connect__c =eachMarketingDetail.Marketed_On_Iron_Connect__c;
                                eachMarketingDetail1.Marketed_On_Equipment_Trader__c = eachMarketingDetail.Marketed_On_Equipment_Trader__c;
                                eachMarketingDetail1.Marketed_On_RitchieList__c = eachMarketingDetail.Marketed_On_RitchieList__c;
                                eachMarketingDetail1.Marketed_On_Rock_Dirt__c = eachMarketingDetail.Marketed_On_Rock_Dirt__c;
                                eachMarketingDetail1.Marked_On_Email_Blast__c = eachMarketingDetail.Marked_On_Email_Blast__c;
                                eachMarketingDetail1.Call_Won_Lost_Opps_Checked__c = eachMarketingDetail.Call_Won_Lost_Opps_Checked__c;
                                
                                eachMarketingDetail1.Updated_From__c = 'Account';
                                lstMarketingDetailToUpdate.add(eachMarketingDetail1);
                        }
                    }*/
                    /*   
                   }else if(string.isNotBlank(eachMarketingDetail.Opportunity__c)&& 
                            string.isBlank(eachMarketingDetail.Updated_From__c )&&
                            mapOfOpportunityIdVsUnitId.get(eachMarketingDetail.Opportunity__c)!=null && 
                            mapOfUnitIdVsLstMarketingDetail.get(mapOfOpportunityIdVsUnitId.get(eachMarketingDetail.Opportunity__c)) !=null &&
                            !mapOfUnitIdVsLstMarketingDetail.get(mapOfOpportunityIdVsUnitId.get(eachMarketingDetail.Opportunity__c)).isempty()){
                                staticVariable.UpdatedFromObject='Opportunity';
                                for(Marketing_Detail__c eachMarketingDetail1 : mapOfUnitIdVsLstMarketingDetail.get(mapOfOpportunityIdVsUnitId.get(eachMarketingDetail.Opportunity__c))){
                                    eachMarketingDetail1.Call_Won_Lost_Opps_Checked__c = eachMarketingDetail.Call_Won_Lost_Opps_Checked__c;
                                    eachMarketingDetail1.Marketed_On_Craigslist__c = eachMarketingDetail.Marketed_On_Craigslist__c ;
                                   // eachMarketingDetail1.Marketed_On_Facebook__c = eachMarketingDetail.Marketed_On_Facebook__c ;
                                    eachMarketingDetail1.Marketed_On_FB_Marketplace__c = eachMarketingDetail.Marketed_On_FB_Marketplace__c;
                                    eachMarketingDetail1.Marketed_On_Fleet_Up_Marketplace__c = eachMarketingDetail.Marketed_On_Fleet_Up_Marketplace__c;
                                   // eachMarketingDetail1.Marketed_On_GearFlow__c = eachMarketingDetail.Marketed_On_GearFlow__c;
                                    eachMarketingDetail1.Marketed_On_Instagram__c = eachMarketingDetail.Marketed_On_Instagram__c;
                                    eachMarketingDetail1.Marketed_On_LinkedIn__c = eachMarketingDetail.Marketed_On_LinkedIn__c;
                                    eachMarketingDetail1.Marketed_On_Machinio__c = eachMarketingDetail.Marketed_On_Machinio__c;
                                    eachMarketingDetail1.Marketed_On_Mascus__c = eachMarketingDetail.Marketed_On_Mascus__c;
                                    eachMarketingDetail1.Marketed_on_MT_Crane_Truck__c =eachMarketingDetail.Marketed_on_MT_Crane_Truck__c;
                                    eachMarketingDetail1.Marketed_On_MyLittleSalesman__c = eachMarketingDetail.Marketed_On_MyLittleSalesman__c;
                                  //  eachMarketingDetail1.Marketed_On_Terrapoint__c = eachMarketingDetail.Marketed_On_Terrapoint__c ;
                                    eachMarketingDetail1.Marketed_On_TradeMachines__c =eachMarketingDetail.Marketed_On_TradeMachines__c;
                                   // eachMarketingDetail1.Marketed_On_Used_Equip_Guide__c = eachMarketingDetail.Marketed_On_Used_Equip_Guide__c;
                                   // eachMarketingDetail1.Marketed_On_Zonapesada__c = eachMarketingDetail.Marketed_On_Zonapesada__c;
                                    eachMarketingDetail1.Do_not_market_anywhere__c =eachMarketingDetail.Do_not_market_anywhere__c;
                                    eachMarketingDetail1.Market_on_FB_Group__c = eachMarketingDetail.Market_on_FB_Group__c;
                                    eachMarketingDetail1.Marketed_On_Iron_Connect__c =eachMarketingDetail.Marketed_On_Iron_Connect__c;
                                    eachMarketingDetail1.Marketed_On_Equipment_Trader__c = eachMarketingDetail.Marketed_On_Equipment_Trader__c;
                                    eachMarketingDetail1.Marketed_On_RitchieList__c = eachMarketingDetail.Marketed_On_RitchieList__c;
                                    eachMarketingDetail1.Marketed_On_Rock_Dirt__c = eachMarketingDetail.Marketed_On_Rock_Dirt__c;
                                   	eachMarketingDetail1.Marked_On_Email_Blast__c = eachMarketingDetail.Marked_On_Email_Blast__c;
                                    eachMarketingDetail1.Call_Won_Lost_Opps_Checked__c = eachMarketingDetail.Call_Won_Lost_Opps_Checked__c;
                                    eachMarketingDetail.Updated_From__c = 'Opportunity';
                                    eachMarketingDetail1.Updated_From__c = 'Opportunity';
                                    lstMarketingDetailToUpdate.add(eachMarketingDetail1);
                       }
                       //eachMarketingDetail.Updated_From__c = 'Opportunity';
                       
                   }else if(string.isNotBlank(eachMarketingDetail.Unit__c)&&
                            string.isNotBlank(eachMarketingDetail.Updated_From__c )
                            && !string.isNotBlank(staticVariable.UpdatedFromObject)
                            ){
                                
                                Map<String, Object> fieldMap = eachMarketingDetail.getPopulatedFieldsAsMap();
                                String sObjectType = String.valueOf(eachMarketingDetail.getSObjectType());
                                for (String fieldName : fieldMap.keySet()) {
                                        Schema.SObjectField sfield = eachMarketingDetail.getSObjectType().getDescribe().fields.getMap().get(fieldName);
                                        String dataType = String.valueOf(sfield.getDescribe().getType());
                                        if(dataType == 'boolean' && hasFieldChanged(eachMarketingDetail, triggerOldMap.get(eachMarketingDetail.Id) , fieldName)){
                                            staticVariable.UpdatedFromObject='Manually';         
                                            eachMarketingDetail.Updated_From__c = 'Manually';//need to update this 
                                        }
                                    }
                                
                                
                   }
            }*/
           /* if(mapOfAccountIdVsLstMarketingDetail.KeySet()!=null && !mapOfAccountIdVsLstMarketingDetail.KeySet().isempty()){
                for(id eachId : mapOfAccountIdVsLstMarketingDetail.KeySet()){
                    if(mapOfAccountIdVsLstMarketingDetail.get(eachId)!= null && !mapOfAccountIdVsLstMarketingDetail.get(eachId).isEmpty()){
                        system.debug('mapOfAccountIdVsLstMarketingDetail.get(eachId)'+mapOfAccountIdVsLstMarketingDetail.get(eachId));
                        lstMarketingDetailToUpdate.addAll(mapOfAccountIdVsLstMarketingDetail.get(eachId));
                    }
                }
            }
            if(mapOfUnitIdVsLstMarketingDetail.KeySet()!=null && !mapOfUnitIdVsLstMarketingDetail.KeySet().isempty()){
                for(id eachId : mapOfUnitIdVsLstMarketingDetail.KeySet()){
                    if(mapOfUnitIdVsLstMarketingDetail.get(eachId)!= null && !mapOfUnitIdVsLstMarketingDetail.get(eachId).isEmpty()){
                        system.debug('mapOfUnitIdVsLstMarketingDetail.get(eachId)'+mapOfUnitIdVsLstMarketingDetail.get(eachId));
                        lstMarketingDetailToUpdate.addAll(mapOfUnitIdVsLstMarketingDetail.get(eachId));
                    }
                }
            }*//*
            if(lstMarketingDetailToUpdate!=null && !lstMarketingDetailToUpdate.isempty()){
                system.debug('lstMarketingDetailToUpdate'+lstMarketingDetailToUpdate);
                system.debug('lstMarketingDetailToUpdate'+lstMarketingDetailToUpdate.size());
               // staticVariable.UpdatedFromObject='';
                update lstMarketingDetailToUpdate;
                staticVariable.UpdatedFromObject='';  
            }
        }
    }
*/    
    
    
    
    private static void handleafterInsert(List<Marketing_Detail__c> triggerNew){
        list<user> lstUser = [SELECT id,Name FROM User WHERE IsActive = true];
        map<string, User> mapUserNameVsUser = new map<string, User>();
        if(lstUser!=null && !lstUser.isEmpty()){
            for(User eachUser : lstUser){
                mapUserNameVsUser.put(eachUser.name, eachUser);
            }
        }
        list<Task> lstTask = new list<Task>();
        /*list<Marketing_Checkbox_detail__mdt> lstMarketingCheckboxDetail = new list<Marketing_Checkbox_detail__mdt>();
        lstMarketingCheckboxDetail=[SELECT Id, 
                                    DeveloperName, 
                                    MasterLabel, 
                                    Label,
                                    site_url__c,
                                    Is_Active__c, 
                                    User_Name__c, 
                                    Unit_Verification_Line_Item_Name__c 
                                    FROM Marketing_Checkbox_detail__mdt 
                                    Where Is_Active__c = true];
        
        set<string>setFieldNameFromMDT = new set<String>();
        
       	map<String,String>mapCheckBoxFieldVsURLField = new map<String,String>();
        map<String,String>mapFieldAPINameLineItemName = new map<string,string>();
        map<String,String>mapMarketingIdAndUnitVerificationId = new map<string,string>();
        if(lstMarketingCheckboxDetail!=null && !lstMarketingCheckboxDetail.IsEmpty()){
            for(Marketing_Checkbox_detail__mdt eachMarketingCheckboxDetail : lstMarketingCheckboxDetail){
                setFieldNameFromMDT.add(eachMarketingCheckboxDetail.MasterLabel);
                mapFieldAPINameLineItemName.put(eachMarketingCheckboxDetail.MasterLabel,eachMarketingCheckboxDetail.Unit_Verification_Line_Item_Name__c);
                if(String.IsNotBlank(eachMarketingCheckboxDetail.site_url__c)){
                    mapCheckBoxFieldVsURLField.put(eachMarketingCheckboxDetail.MasterLabel,eachMarketingCheckboxDetail.site_url__c);
                }
            }
        }
        
        
        list<unit_Verification__c>lstUnitVerificationsToInsert = new list<unit_Verification__c>();
        list<unit_verification_line_item__c> lstUnitVerLineItemToInsert = new list<Unit_Verification_line_item__C>();
        //create a List for the Meta Data and query and a map o hold the data 
        */
        set<Id> setOfIds = new set<Id>();
        map<Id,Product2> mapOfIdVsProduct2 ;
        for (Marketing_Detail__c eachMarketingDetail : triggerNew) {
            if(string.isNotBlank(eachMarketingDetail.Unit__c)){
                setOfIds.add(eachMarketingDetail.Unit__c);
            }
        }
        if(setOfIds!=null && !setOfIds.ISEmpty()){
            mapOfIdVsProduct2 = new map<Id,Product2>([SELECT id, IsActive FROM Product2 WHERE ID IN : setOfIds ]);
        } 
        for (Marketing_Detail__c eachMarketingDetail : triggerNew) {
            if(!String.isBlank(eachMarketingDetail.Unit__c ) &&
              mapOfIdVsProduct2.containsKey(eachMarketingDetail.Unit__c) &&
              mapOfIdVsProduct2.get(eachMarketingDetail.Unit__c).isActive){
                if(mapUserNameVsUser.containsKey(System.Label.VA) && 
                eachMarketingDetail.Marketed_On_Craigslist__c == true){
                    //String subject,string whoId, string whatId, String AssignedToId
                    task newTask = createTask('Post this unit On Craigslist', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                    lstTask.add(newTask);
                }
                if(mapUserNameVsUser.containsKey(System.Label.VA) && 
                eachMarketingDetail.Marketed_On_Equipment_Trader__c == true){
                            task newTask = createTask('Post this unit On Equipment Trader', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                            lstTask.add(newTask);
                }
                       if(mapUserNameVsUser.containsKey(System.Label.VA) 
                       && eachMarketingDetail.Marketed_On_Iron_Connect__c == true){
                                  task newTask = createTask('Post this unit On Iron Connect', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }
                       if(mapUserNameVsUser.containsKey(System.Label.VA) &&
                       eachMarketingDetail.Marketed_on_MT_Crane_Truck__c == true){
                                  task newTask = createTask('Post this unit On MT', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }
                          
                       if(mapUserNameVsUser.containsKey(System.Label.VA) 
                       && eachMarketingDetail.Marketed_On_Rock_Dirt__c == true){
                                  task newTask = createTask('Post this unit On Rock Dirt', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }
                       if(mapUserNameVsUser.containsKey(System.Label.Admin2) && 
                       eachMarketingDetail.Marketed_On_FB_Marketplace__c == false ){
                                  task newTask = createTask('Remove this unit from FB Marketplace', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.Admin2).id );
                                  lstTask.add(newTask);
                              }
                        
                       if(mapUserNameVsUser.containsKey(System.Label.VA) && 
                       eachMarketingDetail.Marketed_On_RitchieList__c == true){
                                  task newTask = createTask('Post this unit On RitchieList', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }
                        if(mapUserNameVsUser.containsKey(System.Label.Admin1) && 
                        eachMarketingDetail.Market_on_FB_Group__c == false ){
                                task newTask = createTask('Remove this unit from FB Group', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.Admin1).id );
                                lstTask.add(newTask);
                            }
                          
                //to create Unit Verification record
               /* unit_Verification__c newUnit_Verification = new unit_Verification__c();
                newUnit_Verification.Name = eachMarketingDetail.Name;
                newUnit_Verification.Marketing_Detail__c = eachMarketingDetail.Id;
                newUnit_Verification.Unit__c = eachMarketingDetail.unit__c;
                lstUnitVerificationsToInsert.add(newUnit_Verification);*/
            }
        }
        /*
        //Insert Data here Unit Verification and Line Items for the true value
        if(lstUnitVerificationsToInsert != null && !lstUnitVerificationsToInsert.IsEmpty()){
            insert lstUnitVerificationsToInsert;
            
            for(unit_Verification__c eachUnit_Verification : lstUnitVerificationsToInsert){
                mapMarketingIdAndUnitVerificationId.put(eachUnit_Verification.Marketing_Detail__c,eachUnit_Verification.Id);                
            }
        }*/
        // //set<string>setOfIds = new set<string>();*/
      /*  for (Marketing_Detail__c eachMarketing_Detail : triggerNew) {
            setOfIds.add(eachMarketing_Detail.Id);
        }*/
       // // System.debug('setOfIds ::::'+setOfIds);
           // list<Marketing_Detail__c>lstMarketing_DetailData = [SELECT Id, Name, Unit__c FROM Marketing_Detail__c Where Id IN: setOfIds AND Unit__c!=null];
       /* if(!triggerNew.isEmpty()){    
            for (Marketing_Detail__c eachMarketing_Detail : triggerNew) {
                if(!String.isBlank(eachMarketing_Detail.Unit__c )){
                    
                    // Get a map of field names and their values for the current record
                    Map<String, Object> fieldMap = eachMarketing_Detail.getPopulatedFieldsAsMap();
                    String sObjectType = String.valueOf(eachMarketing_Detail.getSObjectType());
                    // Loop through the field map to access field names and values
                    System.debug('fieldMap.keySet() SIZE::::'+fieldMap.keySet().size());
                    for (String fieldName : fieldMap.keySet()) {
                        if(setFieldNameFromMDT.contains(fieldName)){
                            Schema.SObjectField sfield = eachMarketing_Detail.getSObjectType().getDescribe().fields.getMap().get(fieldName);
                            String dataType = String.valueOf(sfield.getDescribe().getType());
                            if(dataType == 'boolean'&& fieldMap.get(fieldName)==true){
                                if(mapFieldAPINameLineItemName.containsKey(fieldName) && String.IsNotBlank(mapFieldAPINameLineItemName.get(fieldName))){
                                    unit_verification_line_item__c newUnitVerificationLineItem = new unit_verification_line_item__c();
                                    newUnitVerificationLineItem.Name = mapFieldAPINameLineItemName.get(fieldName); 
                                    if(mapCheckBoxFieldVsURLField.containsKey(fieldName) && String.IsNotBlank(mapCheckBoxFieldVsURLField.get(fieldName))){
                                        if(eachMarketing_Detail.get(mapCheckBoxFieldVsURLField.get(fieldName))!=null){
                                            string urlFieldName=mapCheckBoxFieldVsURLField.get(fieldName);
                                            newUnitVerificationLineItem.Site_URL__c = String.valueOf(eachMarketing_Detail.get(urlFieldName));
                                        }
                                    }
                                    
                                    if(mapMarketingIdAndUnitVerificationId.containsKey(eachMarketing_Detail.Id) && String.IsNotBlank(mapMarketingIdAndUnitVerificationId.get(eachMarketing_Detail.Id))){
                                        newUnitVerificationLineItem.Unit_Verification__c = mapMarketingIdAndUnitVerificationId.get(eachMarketing_Detail.Id);
                                    }
                                    newUnitVerificationLineItem.Is_Active__c = true;
                                    lstUnitVerLineItemToInsert.add(newUnitVerificationLineItem);
                                }
                                
                            }
                        } 
                    }
                }
            }
        }
        //Insert Data here Unit Verification and Line Items for the true value
        
        if(lstUnitVerLineItemToInsert != null && !lstUnitVerLineItemToInsert.IsEmpty()){
            insert lstUnitVerLineItemToInsert;
        }*/
        if(lstTask!=null && !lstTask.isEmpty()){
            insert lstTask;
        }
    }
    
    
    private static void handleAfterUpdate(
        List<Marketing_Detail__c> triggerNew, 
        Map<Id, Marketing_Detail__c> triggerOldMap
    ){
        System.debug('handleAfterUpdate Is called with unit size ::'+triggerNew.size());
        if(triggerNew != null && !triggerNew.isEmpty() ){
            
            set<string>setMartkeingDetailsId = new set<string>();
            // Map to store the updated fields and their new values
            Map<String, Object> updatedFieldsMap = new Map<String, Object>();
            
            // Get all the field names dynamically from Account object
            Set<String> sObjFieldSet = new Set<String>();
            Schema.SObjectType sObjType = Marketing_Detail__c.SObjectType;
            set<Id> setOfAccountId = new set<Id>();
            set<Id> setOfOpportunityId = new set<Id>();
            set<Id> setOfUnitId = new set<Id>();
            list<Product2> lstUnit = new list<Product2>();
            list<Opportunity> lstOpportunityForAccount= new list<Opportunity>();
            list<Product2> lstOpportunityUnit = new list<Product2>();
            list<Opportunity> lstOpportunity = new list<Opportunity>();
            map<Id,list<Marketing_Detail__c>>mapOfAccountIdVsLstMarketingDetail = new map<Id,list<Marketing_Detail__c>>();
            map<Id,list<Marketing_Detail__c>>mapOfUnitIdVsLstMarketingDetail = new map<Id,list<Marketing_Detail__c>>();
            map<Id,Id> mapOfOpportunityIdVsUnitId = new map<Id,Id>();
            list<Marketing_Detail__c> lstMarketingDetailToUpdate = new list<Marketing_Detail__c>();
            list<Marketing_Detail__c> lstMarketingDetailOnOpportunity;
            map<id,Product2> mapOfProduct2IdVsProduct2 ;
            set<id> setOfUnitIds = new set<id>();
            list<opportunity> lstOppForUnit = new list<opportunity>();
            map<id,id> mapOfUnitIdVsAccountId = new map<id,id>();
            /*Map<String, Schema.SObjectField> fieldMap = sObjType.getDescribe().fields.getMap();
            for (String fieldName : fieldMap.keySet()) {
                sObjFieldSet.add(fieldName);
            }*/
             
            /*
            list<Marketing_Checkbox_detail__mdt> lstMarketingCheckboxDetail = new list<Marketing_Checkbox_detail__mdt>();
            lstMarketingCheckboxDetail=[SELECT Id, 
                                        DeveloperName, 
                                        MasterLabel, 
                                        Label, 
                                        site_url__c,
                                        Is_Active__c, 
                                        User_Name__c, 
                                        Unit_Verification_Line_Item_Name__c 
                                        FROM Marketing_Checkbox_detail__mdt 
                                        Where Is_Active__c = true];
            */
            set<string>setFieldNameFromMDT = new set<String>();   
            set<string>setURLFieldNameFromMDT = new set<String>();  
            map<String,String>mapCheckBoxFieldVsURLField = new map<String,String>();
            map<String,String>mapURLFieldVsCheckBoxField = new map<String,String>();
            //list<unit_verification_line_item__c> lstUnitVerLineItemToInsert = new list<Unit_Verification_line_item__C>();            
            //list<unit_verification_line_item__c> lstUnitVerLineItemToUpdate = new list<Unit_Verification_line_item__C>();
            //map<String,String>mapFieldAPINameLineItemName = new map<string,string>();
            map<String,String>mapMarketingIdAndUnitVerificationId = new map<string,string>();
            /*if(lstMarketingCheckboxDetail!=null && !lstMarketingCheckboxDetail.IsEmpty()){
                for(Marketing_Checkbox_detail__mdt eachMarketingCheckboxDetail : lstMarketingCheckboxDetail){
                    setFieldNameFromMDT.add(eachMarketingCheckboxDetail.MasterLabel);
                    mapFieldAPINameLineItemName.put(eachMarketingCheckboxDetail.MasterLabel,eachMarketingCheckboxDetail.Unit_Verification_Line_Item_Name__c);
                    if(String.IsNotBlank(eachMarketingCheckboxDetail.site_url__c)){
                        setURLFieldNameFromMDT.add(eachMarketingCheckboxDetail.site_url__c);
                        mapCheckBoxFieldVsURLField.put(eachMarketingCheckboxDetail.MasterLabel,eachMarketingCheckboxDetail.site_url__c);
                        mapURLFieldVsCheckBoxField.put(eachMarketingCheckboxDetail.site_url__c,eachMarketingCheckboxDetail.MasterLabel);
                    }
                }
            }*/
            //System.debug('mapFieldAPINameLineItemName::'+mapFieldAPINameLineItemName);
            list<Task> lstTask = new list<Task>();
            //set<String> setUserName = new set<String>();
            //list<user> lstUser;
            map<string, User> mapUserNameVsUser = new map<string, User>();
            /*if(string.isNotBlank(System.Label.VA)){
                setUserName.add(System.Label.VA);
            }
            if(string.isNotBlank(System.Label.admin1)){
                setUserName.add(System.Label.admin1);
            }
            if(string.isNotBlank(System.Label.admin2)){
                setUserName.add(System.Label.admin2);
            }*/
            /* if(string.isNotBlank(System.Label.VA)){
setUserName.add(System.Label.VA);
}*/
            //if(setUserName!=null && !setUserName.isEmpty()){
                list<user> lstUser = [SELECT id,Name FROM User WHERE IsActive = true];
           // }
            if(lstUser!=null && !lstUser.isEmpty()){
                for(User eachUser : lstUser){
                    mapUserNameVsUser.put(eachUser.name, eachUser);
                }
            }
            set<id>setOfIds = new set<id>();
            for(Marketing_Detail__c eachMarketingDetail : triggerNew){
                System.debug('eachMarketingDetail.Unit__c :::'+eachMarketingDetail.Unit__c);
                //eachMarketingDetail.Marketed_on_MT_Crane_Truck__c
                if(string.isNotBlank(eachMarketingDetail.Unit__c)){
                    setOfIds.add(eachMarketingDetail.Unit__c);
                }
                
               
                
                system.debug('eachMarketingDetail.Opportunity__c'+eachMarketingDetail.Opportunity__c);
                system.debug('eachMarketingDetail.Updated_From__c'+eachMarketingDetail.Updated_From__c);
                
                if(string.IsBlank(staticVariable.UpdatedFromObject) &&
                   string.isNotBlank(eachMarketingDetail.Account__c) 
                   && string.isBlank(eachMarketingDetail.Updated_From__c)){
                       setOfAccountId.add(eachMarketingDetail.Account__c);   
                       
                   }else if(string.IsBlank(staticVariable.UpdatedFromObject) &&
                            string.isNotBlank(eachMarketingDetail.Opportunity__c)
                            && string.isNotBlank(eachMarketingDetail.Updated_From__c) ){
                                setOfOpportunityId.add(eachMarketingDetail.Opportunity__c);
                                
                            }else if(string.IsBlank(staticVariable.UpdatedFromObject) && 
                                     string.isNotBlank(eachMarketingDetail.Unit__c)
                                     && string.isNotBlank(eachMarketingDetail.Updated_From__c)){
                                         setOfUnitId.add(eachMarketingDetail.Unit__c);
                                         
                                     }
            }
            if(setOfIds!=null && !setOfIds.isEmpty()){
                mapOfProduct2IdVsProduct2  = new map<id,Product2>([SELECT id, Unit_Owner__c ,IsActive FROM Product2 WHERE ID IN : setOfIds ]);
            }
            system.debug('setOfAccountId::'+setOfAccountId);
            if(setOfAccountId!= null && !setOfAccountId.isEmpty()){
                lstUnit = [SELECT Id,Account__c,
                           (SELECT Id,  
                            Marketed_On_Craigslist__c,  Marketed_On_FB_Marketplace__c, Call_Won_Lost_Opps_Checked__c,
                            Marketed_On_Fleet_Up_Marketplace__c,  Marketed_On_Instagram__c, 
                            Marketed_On_LinkedIn__c, Marketed_On_Machinio__c, Marketed_On_Mascus__c,
                            Marketed_on_MT_Crane_Truck__c, Marketed_On_MyLittleSalesman__c,Dealer_Email__c,
                            Marketed_On_TradeMachines__c, Do_not_market_anywhere__c,Marketed_On_Iron_Connect__c,
                            Unit__c,Opportunity__c,Account__c,Updated_From__c,Marketed_On_RitchieList__c, 
                            Marketed_On_Rock_Dirt__c, Marketed_On_Equipment_Trader__c
                            FROM Marketing_Details__r WHERE Updated_From__c ='Account' AND id != : triggerNew ) 
                           FROM Product2 
                           WHERE Account__c IN : setOfAccountId];
                
               /* lstOpportunityForAccount = [SELECT Id,Account__c,Seller_Account__c ,Product__c,
                                            (SELECT Id,  
                                             Marketed_On_Craigslist__c,  Marketed_On_FB_Marketplace__c, Call_Won_Lost_Opps_Checked__c,
                                             Marketed_On_Fleet_Up_Marketplace__c,  Marketed_On_Instagram__c, Dealer_Email__c,
                                             Marketed_On_LinkedIn__c, Marketed_On_Machinio__c, Marketed_On_Mascus__c,
                                             Marketed_on_MT_Crane_Truck__c, Marketed_On_MyLittleSalesman__c,
                                             Marketed_On_TradeMachines__c, Do_not_market_anywhere__c,Marketed_On_Iron_Connect__c,
                                             Unit__c,Opportunity__c,Account__c,Updated_From__c,Marketed_On_RitchieList__c, 
                                             Marketed_On_Rock_Dirt__c, Marketed_On_Equipment_Trader__c
                                             FROM Marketing_Details__r WHERE Opportunity__c!=null
                                             AND id != : triggerNew AND Updated_From__c = 'Account' ) 
                                            FROM Opportunity 
                                            WHERE Seller_Account__c IN : setOfAccountId ];*/
            }
            system.debug('lstUnit:::'+lstUnit);
            system.debug('lstUnitsize:::'+lstUnit.size());
            system.debug('lstOpportunityForAccount:::'+lstOpportunityForAccount);
            system.debug('lstOpportunityForAccountsize:::'+lstOpportunityForAccount.size());
            if(lstUnit!=null && !lstUnit.isEmpty()){
                for(Product2 eachUnit : lstUnit){
                    setOfUnitIds.add(eachUnit.Id);
                    if(string.isnotblank(eachUnit.Account__c) && !mapOfUnitIdVsAccountId.containsKey(eachUnit.Id)){
                        mapOfUnitIdVsAccountId.put(eachUnit.Id,eachUnit.Account__c);
                    }
                    system.debug('eachUnit.Marketing_Details__r:::'+eachUnit.Marketing_Details__r);
                    if(eachUnit.Marketing_Details__r!=null && !eachUnit.Marketing_Details__r.isEmpty()){
                        //for(Marketing_Detail__c eachMarketingDetail : eachUnit.Marketing_Details__r){
                        	if(!mapOfAccountIdVsLstMarketingDetail.containsKey(eachUnit.Account__c)){
                        		mapOfAccountIdVsLstMarketingDetail.put(eachUnit.Account__c,new list<Marketing_Detail__c>());
                                mapOfAccountIdVsLstMarketingDetail.get(eachUnit.Account__c).addAll(eachUnit.Marketing_Details__r);
                            }else{
                                mapOfAccountIdVsLstMarketingDetail.get(eachUnit.Account__c).addAll(eachUnit.Marketing_Details__r);
                            }
                       // }
                    }
                    
                    
                }
            }
            system.debug('setOfUnitIds::'+setOfUnitIds);
            if(setOfUnitIds != null && !setOfUnitIds.isEmpty()){
                lstOppForUnit = [SELECT id,Account__c,Seller_Account__c ,Product__c,
                                 (SELECT Id,  
                                  Marketed_On_Craigslist__c,  Marketed_On_FB_Marketplace__c, Call_Won_Lost_Opps_Checked__c,
                                  Marketed_On_Fleet_Up_Marketplace__c,  Marketed_On_Instagram__c, Dealer_Email__c,
                                  Marketed_On_LinkedIn__c, Marketed_On_Machinio__c, Marketed_On_Mascus__c,
                                  Marketed_on_MT_Crane_Truck__c, Marketed_On_MyLittleSalesman__c,
                                  Marketed_On_TradeMachines__c, Do_not_market_anywhere__c,Marketed_On_Iron_Connect__c,
                                  Unit__c,Opportunity__c,Account__c,Updated_From__c,Marketed_On_RitchieList__c, 
                                  Marketed_On_Rock_Dirt__c, Marketed_On_Equipment_Trader__c
                                  FROM Marketing_Details__r WHERE Opportunity__c!=null
                                  AND id != : triggerNew AND Updated_From__c = 'Account' ) 
                                 FROM Opportunity
                                 WHERE Product__c != null AND Product__c in :setOfUnitIds  ];
            }
            
            system.debug('lstOppForUnit:::'+lstOppForUnit);
            
            if(lstOppForUnit != null && !lstOppForUnit.isEmpty()){
                for(opportunity eachOpp : lstOppForUnit){
                    if(eachOpp.Marketing_Details__r!=NULL 
                       && !eachOpp.Marketing_Details__r.isEmpty()){
                           for(Marketing_Detail__c eachMarketingDetail : eachOpp.Marketing_Details__r ){
                               system.debug('eachMarketingDetail:::'+eachMarketingDetail);
                               if(eachMarketingDetail.Updated_From__c == 'Account' && mapOfUnitIdVsAccountId.containsKey(eachOpp.Product__c) && String.IsNotBlank(mapOfUnitIdVsAccountId.get(eachOpp.Product__c))){
                                   Id AccountId = mapOfUnitIdVsAccountId.get(eachOpp.Product__c);
                                   if(!mapOfAccountIdVsLstMarketingDetail.containsKey(AccountId)){
                                       mapOfAccountIdVsLstMarketingDetail.put(AccountId,new list<Marketing_Detail__c>());
                                       mapOfAccountIdVsLstMarketingDetail.get(AccountId).add(eachMarketingDetail);
                                   }else{
                                       mapOfAccountIdVsLstMarketingDetail.get(AccountId).add(eachMarketingDetail);
                                   }  
                               }
                               else if (eachMarketingDetail.Updated_From__c == 'Opportunity'){
                                   
                               }
                           }   
                       }  
                }
            }
            
            
            system.debug('mapOfAccountIdVsLstMarketingDetail::'+mapOfAccountIdVsLstMarketingDetail);
            /*if(lstOpportunityForAccount!=null && !lstOpportunityForAccount.isEmpty()){
                for(Opportunity eachOpportunity : lstOpportunityForAccount){
                    if(String.isNotBlank(eachOpportunity.Seller_Account__c) && eachOpportunity.Marketing_Details__r!=NULL 
                       && !eachOpportunity.Marketing_Details__r.isEmpty()){
                           for(Marketing_Detail__c eachMarketingDetail : eachOpportunity.Marketing_Details__r ){
                               if(eachMarketingDetail.Updated_From__c == 'Account' ){
                                   if(!mapOfAccountIdVsLstMarketingDetail.containsKey(eachOpportunity.Seller_Account__c)){
                                       mapOfAccountIdVsLstMarketingDetail.put(eachOpportunity.Seller_Account__c,new list<Marketing_Detail__c>());
                                       mapOfAccountIdVsLstMarketingDetail.get(eachOpportunity.Seller_Account__c).add(eachMarketingDetail);
                                   }else{
                                       mapOfAccountIdVsLstMarketingDetail.get(eachOpportunity.Seller_Account__c).add(eachMarketingDetail);
                                   }
                               }else if (eachMarketingDetail.Updated_From__c == 'Opportunity'){
                                   
                               }
                           }
                           
                           
                        
                    }
                }
            }*/
            system.debug('setOfOpportunityId:::'+setOfOpportunityId);
			if(setOfOpportunityId!= null && !setOfOpportunityId.isEmpty()){
                lstOpportunity = [SELECT Id, AccountId,Product__c, Amount 
                                  FROM Opportunity 
                                  WHERE Id IN : setOfOpportunityId 
                                  AND Product__c!=null];
            }
            system.debug('lstOpportunity::::'+lstOpportunity);
            if(lstOpportunity!=null && !lstOpportunity.isEmpty()){
                for(Opportunity eachOpportunity : lstOpportunity){
                    mapOfOpportunityIdVsUnitId.put(eachOpportunity.id,eachOpportunity.Product__c);
                    //setOfOpportunityProductId.add(eachOpportunity.Product__c);
                }
                
            }
            system.Debug('mapOfOpportunityIdVsUnitId::'+mapOfOpportunityIdVsUnitId);
            if(mapOfOpportunityIdVsUnitId.values()!=null && !mapOfOpportunityIdVsUnitId.values().isEmpty()){
                lstOpportunityUnit = [SELECT Id,Account__c,
                                       (SELECT Id , Marketed_On_Iron_Connect__c,Marked_On_Email_Blast__c,
                                        Marketed_On_Craigslist__c,  Marketed_On_FB_Marketplace__c, Dealer_Email__c,
                                        Marketed_On_Fleet_Up_Marketplace__c,  Marketed_On_Instagram__c, 
                                        Marketed_On_LinkedIn__c, Marketed_On_Machinio__c, Marketed_On_Mascus__c,
                                        Marketed_on_MT_Crane_Truck__c, Marketed_On_MyLittleSalesman__c,
                                         Marketed_On_TradeMachines__c, Do_not_market_anywhere__c,Marketed_On_RitchieList__c, 
                                        Marketed_On_Rock_Dirt__c, Marketed_On_Equipment_Trader__c,
                                        Unit__c,Opportunity__c,Account__c,Updated_From__c, Call_Won_Lost_Opps_Checked__c
                                        FROM Marketing_Details__r WHERE Updated_From__c !='Manually')//WHERE Updated_From__c ='Opportunity' ) 
                                   FROM Product2 
                                   WHERE Id IN : mapOfOpportunityIdVsUnitId.values()];
            }
            system.debug('lstOpportunityUnit::'+lstOpportunityUnit);
            if(lstOpportunityUnit!=null && !lstOpportunityUnit.isEmpty()){
                for(Product2 eachUnit : lstOpportunityUnit){
                    if(eachUnit.Marketing_Details__r!=null && !eachUnit.Marketing_Details__r.isEmpty()){
                        for(Marketing_Detail__c eachMarketingDetail : eachUnit.Marketing_Details__r){
                        	if(!mapOfUnitIdVsLstMarketingDetail.containsKey(eachUnit.id)){
                        		mapOfUnitIdVsLstMarketingDetail.put(eachUnit.id,new list<Marketing_Detail__c>());
                                mapOfUnitIdVsLstMarketingDetail.get(eachUnit.id).add(eachMarketingDetail);
                            }else{
                                mapOfUnitIdVsLstMarketingDetail.get(eachUnit.id).add(eachMarketingDetail);
                            }
                        }
                    }
                    
                    
                }
            }            
            for(Marketing_Detail__c eachMarketingDetail : triggerNew ){
                system.debug('eachMarketingDetailFinal:::'+eachMarketingDetail);
                system.debug('eachMarketingDetail::1::'+eachMarketingDetail.Marketed_On_Iron_Connect__c);
                if(string.isNotBlank(eachMarketingDetail.Account__c) && 
                   string.isBlank(eachMarketingDetail.Updated_From__c )){ //&& 
                  //string.IsBlank(staticVariable.UpdatedFromObject)){
                       system.debug('mapOfAccountIdVsLstMarketingDetail::'+mapOfAccountIdVsLstMarketingDetail.KeySet());
                       if(mapOfAccountIdVsLstMarketingDetail.containsKey(eachMarketingDetail.Account__c) &&
                          mapOfAccountIdVsLstMarketingDetail.get(eachMarketingDetail.Account__c)!=null && 
                          !mapOfAccountIdVsLstMarketingDetail.get(eachMarketingDetail.Account__c).isempty()){
                              staticVariable.UpdatedFromObject='Account';
                              system.debug('mapOfAccountIdVsLstMarketingDetail.get(eachMarketingDetail.Account__c'+ mapOfAccountIdVsLstMarketingDetail.get(eachMarketingDetail.Account__c));
                              system.debug('.get(eachMarketingDetail.Account__c'+ mapOfAccountIdVsLstMarketingDetail.get(eachMarketingDetail.Account__c).size());
                              
                              for(Marketing_Detail__c eachMarketingDetail1 : mapOfAccountIdVsLstMarketingDetail.get(eachMarketingDetail.Account__c)){
                                  //eachMarketingDetail1.Marketed_On_Construction_Equip_Guide__c = eachMarketingDetail.Marketed_On_Construction_Equip_Guide__c;
                                  eachMarketingDetail1.Marketed_On_Craigslist__c = eachMarketingDetail.Marketed_On_Craigslist__c ;
                                  //eachMarketingDetail1.Marketed_On_Facebook__c = eachMarketingDetail.Marketed_On_Facebook__c ;
                                  eachMarketingDetail1.Marketed_On_FB_Marketplace__c = eachMarketingDetail.Marketed_On_FB_Marketplace__c;
                                  eachMarketingDetail1.Marketed_On_Fleet_Up_Marketplace__c = eachMarketingDetail.Marketed_On_Fleet_Up_Marketplace__c;
                                  //eachMarketingDetail1.Marketed_On_GearFlow__c = eachMarketingDetail.Marketed_On_GearFlow__c;
                                  eachMarketingDetail1.Marketed_On_Instagram__c = eachMarketingDetail.Marketed_On_Instagram__c;
                                  eachMarketingDetail1.Marketed_On_LinkedIn__c = eachMarketingDetail.Marketed_On_LinkedIn__c;
                                  eachMarketingDetail1.Marketed_On_Machinio__c = eachMarketingDetail.Marketed_On_Machinio__c;
                                  eachMarketingDetail1.Marketed_On_Mascus__c = eachMarketingDetail.Marketed_On_Mascus__c;
                                  eachMarketingDetail1.Marketed_on_MT_Crane_Truck__c =eachMarketingDetail.Marketed_on_MT_Crane_Truck__c;
                                  eachMarketingDetail1.Marketed_On_MyLittleSalesman__c = eachMarketingDetail.Marketed_On_MyLittleSalesman__c;
                                  //eachMarketingDetail1.Marketed_On_Terrapoint__c = eachMarketingDetail.Marketed_On_Terrapoint__c ;
                                  eachMarketingDetail1.Marketed_On_TradeMachines__c =eachMarketingDetail.Marketed_On_TradeMachines__c;
                                  //eachMarketingDetail1.Marketed_On_Used_Equip_Guide__c = eachMarketingDetail.Marketed_On_Used_Equip_Guide__c;
                                  eachMarketingDetail1.Dealer_Email__c = eachMarketingDetail.Dealer_Email__c;
                                  eachMarketingDetail1.Do_not_market_anywhere__c =eachMarketingDetail.Do_not_market_anywhere__c;
                                  eachMarketingDetail1.Market_on_FB_Group__c = eachMarketingDetail.Market_on_FB_Group__c;
                                  eachMarketingDetail1.Marketed_On_Iron_Connect__c =eachMarketingDetail.Marketed_On_Iron_Connect__c;
                                  eachMarketingDetail1.Marketed_On_Equipment_Trader__c = eachMarketingDetail.Marketed_On_Equipment_Trader__c;
                                  eachMarketingDetail1.Marketed_On_RitchieList__c = eachMarketingDetail.Marketed_On_RitchieList__c;
                                  eachMarketingDetail1.Marketed_On_Rock_Dirt__c = eachMarketingDetail.Marketed_On_Rock_Dirt__c;
                                  
                                  lstMarketingDetailToUpdate.add(eachMarketingDetail1);
                                  system.debug('eachMarketingDetail1Final:::'+eachMarketingDetail1);
                              }
                          }
                   }else if(string.isNotBlank(eachMarketingDetail.Opportunity__c)&& 
                            string.isNotBlank(eachMarketingDetail.Updated_From__c )&&
                           // string.IsBlank(staticVariable.UpdatedFromObject)&&
                            mapOfOpportunityIdVsUnitId.ContainsKey(eachMarketingDetail.Opportunity__c)&&
                            mapOfOpportunityIdVsUnitId.get(eachMarketingDetail.Opportunity__c)!=null && 
                            mapOfUnitIdVsLstMarketingDetail.ContainsKey(mapOfOpportunityIdVsUnitId.get(eachMarketingDetail.Opportunity__c))&&
                            mapOfUnitIdVsLstMarketingDetail.get(mapOfOpportunityIdVsUnitId.get(eachMarketingDetail.Opportunity__c)) !=null &&
                            !mapOfUnitIdVsLstMarketingDetail.get(mapOfOpportunityIdVsUnitId.get(eachMarketingDetail.Opportunity__c)).isempty()){
                                staticVariable.UpdatedFromObject='Opportunity';
                                for(Marketing_Detail__c eachMarketingDetail1 : mapOfUnitIdVsLstMarketingDetail.get(mapOfOpportunityIdVsUnitId.get(eachMarketingDetail.Opportunity__c))){
                                    eachMarketingDetail1.Call_Won_Lost_Opps_Checked__c = eachMarketingDetail.Call_Won_Lost_Opps_Checked__c;
                                    eachMarketingDetail1.Marketed_On_Craigslist__c = eachMarketingDetail.Marketed_On_Craigslist__c ;
                                    // eachMarketingDetail1.Marketed_On_Facebook__c = eachMarketingDetail.Marketed_On_Facebook__c ;
                                    eachMarketingDetail1.Marketed_On_FB_Marketplace__c = eachMarketingDetail.Marketed_On_FB_Marketplace__c;
                                    eachMarketingDetail1.Marketed_On_Fleet_Up_Marketplace__c = eachMarketingDetail.Marketed_On_Fleet_Up_Marketplace__c;
                                    // eachMarketingDetail1.Marketed_On_GearFlow__c = eachMarketingDetail.Marketed_On_GearFlow__c;
                                    eachMarketingDetail1.Marketed_On_Instagram__c = eachMarketingDetail.Marketed_On_Instagram__c;
                                    eachMarketingDetail1.Marketed_On_LinkedIn__c = eachMarketingDetail.Marketed_On_LinkedIn__c;
                                    eachMarketingDetail1.Marketed_On_Machinio__c = eachMarketingDetail.Marketed_On_Machinio__c;
                                    eachMarketingDetail1.Marketed_On_Mascus__c = eachMarketingDetail.Marketed_On_Mascus__c;
                                    eachMarketingDetail1.Marketed_on_MT_Crane_Truck__c =eachMarketingDetail.Marketed_on_MT_Crane_Truck__c;
                                    eachMarketingDetail1.Marketed_On_MyLittleSalesman__c = eachMarketingDetail.Marketed_On_MyLittleSalesman__c;
                                    //  eachMarketingDetail1.Marketed_On_Terrapoint__c = eachMarketingDetail.Marketed_On_Terrapoint__c ;
                                    eachMarketingDetail1.Marketed_On_TradeMachines__c =eachMarketingDetail.Marketed_On_TradeMachines__c;
                                    // eachMarketingDetail1.Marketed_On_Used_Equip_Guide__c = eachMarketingDetail.Marketed_On_Used_Equip_Guide__c;
                                     eachMarketingDetail1.Dealer_Email__c = eachMarketingDetail.Dealer_Email__c;
                                    eachMarketingDetail1.Do_not_market_anywhere__c =eachMarketingDetail.Do_not_market_anywhere__c;
                                    eachMarketingDetail1.Market_on_FB_Group__c = eachMarketingDetail.Market_on_FB_Group__c;
                                    eachMarketingDetail1.Marketed_On_Iron_Connect__c =eachMarketingDetail.Marketed_On_Iron_Connect__c;
                                    eachMarketingDetail1.Marketed_On_Equipment_Trader__c = eachMarketingDetail.Marketed_On_Equipment_Trader__c;
                                    eachMarketingDetail1.Marketed_On_RitchieList__c = eachMarketingDetail.Marketed_On_RitchieList__c;
                                    eachMarketingDetail1.Marketed_On_Rock_Dirt__c = eachMarketingDetail.Marketed_On_Rock_Dirt__c;
                                    eachMarketingDetail1.Marked_On_Email_Blast__c = eachMarketingDetail.Marked_On_Email_Blast__c;
                                    eachMarketingDetail1.Call_Won_Lost_Opps_Checked__c = eachMarketingDetail.Call_Won_Lost_Opps_Checked__c;
                                    //eachMarketingDetail.Updated_From__c = 'Opportunity';
                                    Map<String, Object> fieldMap = eachMarketingDetail.getPopulatedFieldsAsMap();
                                    for (String fieldName : fieldMap.keySet()){
                                                Schema.SObjectField sfield = eachMarketingDetail.getSObjectType().getDescribe().fields.getMap().get(fieldName);
                                                String dataType = String.valueOf(sfield.getDescribe().getType());
                                                if(dataType == 'boolean'  
                                                   && hasFieldChanged(eachMarketingDetail, triggerOldMap.get(eachMarketingDetail.Id) , fieldName)
                                                  ){
                                                      eachMarketingDetail1.Updated_From__c = 'Opportunity';
                                                  }
                                    }
                                    
                                    lstMarketingDetailToUpdate.add(eachMarketingDetail1);
                                }
                            }/*else if(string.isNotBlank(eachMarketingDetail.Unit__c)&&
                                     string.isNotBlank(eachMarketingDetail.Updated_From__c )
                                     && !string.isNotBlank(staticVariable.UpdatedFromObject)
                                    ){
                                        
                                        Map<String, Object> fieldMap = eachMarketingDetail.getPopulatedFieldsAsMap();
                                        String sObjectType = String.valueOf(eachMarketingDetail.getSObjectType());
                                        for (String fieldName : fieldMap.keySet()) {
                                            Schema.SObjectField sfield = eachMarketingDetail.getSObjectType().getDescribe().fields.getMap().get(fieldName);
                                            String dataType = String.valueOf(sfield.getDescribe().getType());
                                            if(dataType == 'boolean' && hasFieldChanged(eachMarketingDetail, triggerOldMap.get(eachMarketingDetail.Id) , fieldName)){
                                                staticVariable.UpdatedFromObject='Manually';         
                                                //eachMarketingDetail.Updated_From__c = 'Manually';//need to update this 
                                                
                                                //lstMarketingDetailToUpdate.add(eachMarketingDetail);
                                            }
                                        }
                                        
                                    }*/   
                Marketing_Detail__c oldMarketingDetail = triggerOldMap.get(eachMarketingDetail.id);
                if((hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Craigslist__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Equipment_Trader__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Iron_Connect__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_on_MT_Crane_Truck__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_RitchieList__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_FB_Marketplace__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Fleet_Up_Marketplace__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Rock_Dirt__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Instagram__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_LinkedIn__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Machinio__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Mascus__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_MyLittleSalesman__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Call_Won_Lost_Opps_Checked__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_TradeMachines__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Dealer_Email__c') ||
                    hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Market_on_FB_Group__c') ||
                   hasFieldChanged(eachMarketingDetail, oldMarketingDetail ,'Marked_On_Email_Blast__c')) &&
                   string.isNotBlank(eachMarketingDetail.Unit__c) && 
                  mapOfProduct2IdVsProduct2.ContainsKey(eachMarketingDetail.Unit__c) &&
                   mapOfProduct2IdVsProduct2.get(eachMarketingDetail.Unit__c).IsActive){
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Craigslist__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA) ){
                              if(eachMarketingDetail.Marketed_On_Craigslist__c == true){
                                  //String subject,string whoId, string whatId, String AssignedToId
                                  task newTask = createTask('Post this unit On Craigslist', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }else{
                                  task newTask = createTask('Remove this unit from Craigslist', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Equipment_Trader__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA) ){
                              if(eachMarketingDetail.Marketed_On_Equipment_Trader__c == true){
                                  task newTask = createTask('Post this unit On Equipment Trader', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }else{
                                  task newTask = createTask('Remove this unit from Equipment Trader', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Iron_Connect__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA)){
                              if(eachMarketingDetail.Marketed_On_Iron_Connect__c == true){
                                  task newTask = createTask('Post this unit On Iron Connect', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }else{
                                  task newTask = createTask('Remove this unit from Iron Connect', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_on_MT_Crane_Truck__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA)){
                              if(eachMarketingDetail.Marketed_on_MT_Crane_Truck__c == true){
                                  task newTask = createTask('Post this unit On MT', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }else{
                                  task newTask = createTask('Remove this unit from MT', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Rock_Dirt__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA) ){
                              
                              if(eachMarketingDetail.Marketed_On_Rock_Dirt__c == true){
                                  task newTask = createTask('Post this unit On Rock Dirt', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }else{
                                  task newTask = createTask('Remove this unit from Rock Dirt', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }
                          } 
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_FB_Marketplace__c') && 
                          mapUserNameVsUser.containsKey(System.Label.Admin2) ){
                              if(eachMarketingDetail.Marketed_On_FB_Marketplace__c == false ){
                                  task newTask = createTask('Remove this unit from FB Marketplace', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.Admin2).id );
                                  lstTask.add(newTask);
                              }else if(eachMarketingDetail.Marketed_On_FB_Marketplace__c == true ){
                                  task newTask = createTask('Post this unit from FB Marketplace', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.Admin2).id );
                                  lstTask.add(newTask);
                              }
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Fleet_Up_Marketplace__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA) && eachMarketingDetail.Marketed_On_Fleet_Up_Marketplace__c == false ){
                              task newTask = createTask('Remove this unit from Fleet Up Marketplace', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                              lstTask.add(newTask);
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_RitchieList__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA) ){
                              if(eachMarketingDetail.Marketed_On_RitchieList__c == true){
                                  task newTask = createTask('Post this unit On RitchieList', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }else{
                                  task newTask = createTask('Remove this unit from RitchieList', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                                  lstTask.add(newTask);
                              }
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Instagram__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA) && eachMarketingDetail.Marketed_On_Instagram__c == false ){
                              task newTask = createTask('Remove this unit from Instagram', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                              lstTask.add(newTask);
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_LinkedIn__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA) && eachMarketingDetail.Marketed_On_LinkedIn__c == false ){
                              task newTask = createTask('Remove this unit from LinkedIn', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                              lstTask.add(newTask);
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Machinio__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA) && eachMarketingDetail.Marketed_On_Machinio__c == false ){
                              task newTask = createTask('Remove this unit from Machinio', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                              lstTask.add(newTask);
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_Mascus__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA) && eachMarketingDetail.Marketed_On_Mascus__c == false ){
                              task newTask = createTask('Remove this unit from Mascus', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                              lstTask.add(newTask);
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marketed_On_MyLittleSalesman__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA) && eachMarketingDetail.Marketed_On_MyLittleSalesman__c == false ){
                              task newTask = createTask('Remove this unit from My Little Salesman', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                              lstTask.add(newTask);
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Call_Won_Lost_Opps_Checked__c') && 
                        /*  mapUserNameVsUser.containsKey(System.Label.Admin2)*/ 
                        mapOfProduct2IdVsProduct2.ContainsKey(eachMarketingDetail.Unit__c) &&
                        string.isNotBlank(mapOfProduct2IdVsProduct2.get(eachMarketingDetail.Unit__c).Unit_Owner__c) &&
                         eachMarketingDetail.Call_Won_Lost_Opps_Checked__c == true ){
                                    //task for charity
                            task newTask = createTask('Call won lost opps', '' ,eachMarketingDetail.Unit__c,mapOfProduct2IdVsProduct2.get(eachMarketingDetail.Unit__c).Unit_Owner__c);//mapUserNameVsUser.get(System.Label.Admin2).id );
                            newTask.Description = 'https://docs.google.com/document/d/1-zG9LWhf6NVohGM-5Fu7GZE1D2tvzYlrh_2LJ-xUhEc/edit';
                            lstTask.add(newTask);
                        }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Dealer_Email__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA)  && eachMarketingDetail.Dealer_Email__c == true ){
                              task newTask = createTask('Send dealer email', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                              lstTask.add(newTask);
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Marked_On_Email_Blast__c') && 
                          mapUserNameVsUser.containsKey(System.Label.VA) && eachMarketingDetail.Marked_On_Email_Blast__c == true ){
                              task newTask = createTask('Send MC email', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.VA).id );
                              lstTask.add(newTask);
                          }
                       if(hasFieldChanged(eachMarketingDetail, oldMarketingDetail , 'Market_on_FB_Group__c') && 
                          mapUserNameVsUser.containsKey(System.Label.Admin1) ){
                              if(eachMarketingDetail.Market_on_FB_Group__c == false ){
                                  task newTask = createTask('Remove this unit from FB Group', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.Admin1).id );
                                  lstTask.add(newTask);
                              }else if(eachMarketingDetail.Market_on_FB_Group__c == true ){
                                  task newTask = createTask('Post this unit from FB Group', '' ,eachMarketingDetail.Unit__c,mapUserNameVsUser.get(System.Label.Admin1).id );
                                  lstTask.add(newTask);
                              }
                          } 
                       
                       
                   }
            }
            if(lstMarketingDetailToUpdate!=null && !lstMarketingDetailToUpdate.isempty()){
                system.debug('lstMarketingDetailToUpdate'+lstMarketingDetailToUpdate);
                system.debug('lstMarketingDetailToUpdate'+lstMarketingDetailToUpdate.size());
               // staticVariable.UpdatedFromObject='';
                update lstMarketingDetailToUpdate;
                staticVariable.UpdatedFromObject='';  
            }
            
            /*
        // //    System.debug('setOfIds ::::'+setOfIds);
        // //    list<Marketing_Detail__c>lstMarketing_DetailData = [SELECT Id, Name, Unit__c FROM Marketing_Detail__c Where Id IN: setOfIds AND Unit__c!=null];
            	list<Marketing_Detail__c>lstMarketing_DetailData = triggerNew;
        // //    System.debug('lstMarketing_DetailData :::::'+lstMarketing_DetailData);
            if(lstMarketing_DetailData!=null && !lstMarketing_DetailData.IsEmpty()){
                for(Marketing_Detail__c eachMarketing_Detail : lstMarketing_DetailData){
                    if(!String.isBlank(eachMarketing_Detail.Unit__c )){
                        setMartkeingDetailsId.add(eachMarketing_Detail.Id);
                    }
                } 
            }
         // //   System.debug('setMartkeingDetailsId :::::'+setMartkeingDetailsId);
         // //   System.debug('setMartkeingDetailsId size :::::'+setMartkeingDetailsId.size());
            map<string,Unit_Verification_line_item__c > mapMarketinIdFieldKeyAndUnitVerificationLineItem = new map<string,Unit_Verification_line_item__c >();
            list<Unit_Verification_line_item__c>lstUnitVerificationLineItems = [SELECT Name, Id, Is_Active__c, 
                                                                                Unit_Verification__c,
                                                                                Site_URL__c,
                                                                                Unit_Verification__r.Marketing_Detail__c 
                                                                                FROM Unit_Verification_line_item__c
                                                                                Where Unit_Verification__r.Marketing_Detail__c IN : setMartkeingDetailsId];
            
            if(lstUnitVerificationLineItems!= null && !lstUnitVerificationLineItems.isEmpty()){
                for(Unit_Verification_line_item__c eachUnit_Verification_line_item : lstUnitVerificationLineItems){
                    string key = eachUnit_Verification_line_item.Unit_Verification__r.Marketing_Detail__c+'&&'+eachUnit_Verification_line_item.Name;
                    
                    mapMarketinIdFieldKeyAndUnitVerificationLineItem.put(key,eachUnit_Verification_line_item);
                }
            }
            list<Unit_Verification__c> lstUnit_Verification = new list<Unit_Verification__c>();
             if(setMartkeingDetailsId!= null && !setMartkeingDetailsId.isEmpty()){
            lstUnit_Verification =[SELECT Id,Marketing_Detail__c
                                   FROM Unit_Verification__c
                                   Where Marketing_Detail__c IN : setMartkeingDetailsId];
             }
            if(lstUnit_Verification!= null && !lstUnit_Verification.isEmpty()){
                for(Unit_Verification__c eachUnit_Verification : lstUnit_Verification){
               	 mapMarketingIdAndUnitVerificationId.put(eachUnit_Verification.Marketing_Detail__c,eachUnit_Verification.Id);
                    
                }
            }	
            for(Marketing_Detail__c eachMarketing_Detail : triggerNew){
                if(!String.isBlank(eachMarketing_Detail.Unit__c )){
                    // Get a map of field names and their values for the current record
                    Map<String, Object> fieldMap = eachMarketing_Detail.getPopulatedFieldsAsMap();
                    String sObjectType = String.valueOf(eachMarketing_Detail.getSObjectType());
                    System.debug('eachMarketing_Detail :::::'+eachMarketing_Detail);
                    // Loop through the field map to access field names and values
                    // //  System.debug('fieldMap.keySet() SIZE::::'+fieldMap.keySet().size());
                    for (String fieldName : fieldMap.keySet()) {
                        
                        if(eachMarketing_Detail.get(fieldName)!=triggerOldMap.get(eachMarketing_Detail.Id).get(fieldName)){
                             System.debug('fieldName :::::'+fieldName);
                            string key = eachMarketing_Detail.Id +'&&'+ mapFieldAPINameLineItemName.get(fieldName);
                            if(setFieldNameFromMDT.contains(fieldName.capitalize())){
                                // // System.debug('setFieldNameFromMDT.contains(fieldName) ::::::::::::::::::::::::::::::::'+setFieldNameFromMDT.contains(fieldName));
                                Schema.SObjectField sfield = eachMarketing_Detail.getSObjectType().getDescribe().fields.getMap().get(fieldName);
                                String dataType = String.valueOf(sfield.getDescribe().getType());
                                if(mapFieldAPINameLineItemName.containsKey(fieldName) && String.IsNotBlank(mapFieldAPINameLineItemName.get(fieldName))){
                                    
                                    
                                    if(dataType == 'boolean'&& eachMarketing_Detail.get(fieldName)==false && triggerOldMap.get(eachMarketing_Detail.Id).get(fieldName)==true){
                                        // // System.debug('True to false on ::'+fieldName);
                                        if(mapMarketinIdFieldKeyAndUnitVerificationLineItem.containsKey(key) && mapMarketinIdFieldKeyAndUnitVerificationLineItem.get(key)!=null){
                                            mapMarketinIdFieldKeyAndUnitVerificationLineItem.get(key).Is_Active__c = false;
                                            lstUnitVerLineItemToUpdate.add(mapMarketinIdFieldKeyAndUnitVerificationLineItem.get(key));
                                        }
                                    }else if(dataType == 'boolean'&& eachMarketing_Detail.get(fieldName)==true && triggerOldMap.get(eachMarketing_Detail.Id).get(fieldName)==false){
                                        System.debug('false to true on ::'+fieldName);
                                        if(mapMarketinIdFieldKeyAndUnitVerificationLineItem.containsKey(key) && mapMarketinIdFieldKeyAndUnitVerificationLineItem.get(key)!=null){
                                            mapMarketinIdFieldKeyAndUnitVerificationLineItem.get(key).Is_Active__c = true;
                                            if(mapCheckBoxFieldVsURLField.containsKey(fieldName.capitalize()) && String.IsNotBlank(mapCheckBoxFieldVsURLField.get(fieldName.capitalize()))){
                                                if(eachMarketing_Detail.get(mapCheckBoxFieldVsURLField.get(fieldName))!=null){
                                                    string urlFieldName = mapCheckBoxFieldVsURLField.get(fieldName);
                                                    mapMarketinIdFieldKeyAndUnitVerificationLineItem.get(key).Site_URL__c  = String.valueOf(eachMarketing_Detail.get(urlFieldName));
                                                }
                                            }
                                            
                                            lstUnitVerLineItemToUpdate.add(mapMarketinIdFieldKeyAndUnitVerificationLineItem.get(key));
                                        }else{
                                            // //   System.debug('new on ::'+fieldName);
                                            unit_verification_line_item__c newUnitVerificationLineItem = new unit_verification_line_item__c();
                                            newUnitVerificationLineItem.Name = mapFieldAPINameLineItemName.get(fieldName); 
                                            // //  System.debug('mapMarketingIdAndUnitVerificationId.get(eachMarketing_Detail.Id) :::::Before'+mapMarketingIdAndUnitVerificationId.get(eachMarketing_Detail.Id));
                                            if(mapMarketingIdAndUnitVerificationId.containsKey(eachMarketing_Detail.Id) && String.IsNotBlank(mapMarketingIdAndUnitVerificationId.get(eachMarketing_Detail.Id))){
                                                System.debug('mapMarketingIdAndUnitVerificationId.get(eachMarketing_Detail.Id) :::::'+mapMarketingIdAndUnitVerificationId.get(eachMarketing_Detail.Id));
                                                newUnitVerificationLineItem.Unit_Verification__c = mapMarketingIdAndUnitVerificationId.get(eachMarketing_Detail.Id);
                                            }
                                            newUnitVerificationLineItem.Is_Active__c = true;
                                            lstUnitVerLineItemToInsert.add(newUnitVerificationLineItem);
                                            
                                        }
                                    }
                                }
                            }else if(setURLFieldNameFromMDT.contains(fieldName.capitalize()) && eachMarketing_Detail.get(fieldName) !=triggerOldMap.get(eachMarketing_Detail.Id).get(fieldName)){
                                System.debug('URL FIELD CHANGE IS CALLED WITH THE FIELD ::::'+fieldName);
                                
                                String strKey = '';
                                if(mapURLFieldVsCheckBoxField.containsKey(fieldName.capitalize()) && mapURLFieldVsCheckBoxField.get(fieldName.capitalize()) !=null ){
                                   strKey = eachMarketing_Detail.Id +'&&'+ mapFieldAPINameLineItemName.get(mapURLFieldVsCheckBoxField.get(fieldName.capitalize()));
                                }
                                 System.debug('URL FIELD CHANGE IS CALLED WITH THE FIELD mapMarketinIdFieldKeyAndUnitVerificationLineItem.get(strKey)::::'+mapMarketinIdFieldKeyAndUnitVerificationLineItem.get(strKey)); 
                                System.debug('URL FIELD CHANGE IS CALLED WITH THE FIELD mapCheckBoxFieldVsURLField::::'+mapCheckBoxFieldVsURLField);
                                System.debug('URL FIELD CHANGE IS CALLED WITH THE FIELD mapFieldAPINameLineItemName ::::'+mapFieldAPINameLineItemName);
                                System.debug('URL FIELD CHANGE IS CALLED WITH THE FIELD fieldName.capitalize() ::::'+fieldName.capitalize());
                                System.debug('URL FIELD CHANGE IS CALLED WITH THE FIELD mapFieldAPINameLineItemName ::::'+mapURLFieldVsCheckBoxField.get(fieldName.capitalize()));
                               // System.debug('URL FIELD CHANGE IS CALLED WITH THE FIELD mapFieldAPINameLineItemName ::::'+eachMarketing_Detail.get(mapCheckBoxFieldVsURLField.get(fieldName)));
                                if(mapMarketinIdFieldKeyAndUnitVerificationLineItem.containsKey(strKey) && mapMarketinIdFieldKeyAndUnitVerificationLineItem.get(strKey)!=null){
                                 */  /* if(mapURLFieldVsCheckBoxField.containsKey(fieldName.capitalize()) && String.IsNotBlank(mapURLFieldVsCheckBoxField.get(fieldName.capitalize()))){
                                        if(eachMarketing_Detail.get(mapCheckBoxFieldVsURLField.get(fieldName))!=null){
                                            string urlFieldName = mapCheckBoxFieldVsURLField.get(fieldName);*/
                                    /*        System.debug('Site URL  DATA :::::'+String.valueOf(eachMarketing_Detail.get(fieldName)));
                                            mapMarketinIdFieldKeyAndUnitVerificationLineItem.get(strKey).Site_URL__c  = String.valueOf(eachMarketing_Detail.get(fieldName));
                                       // }
                                        lstUnitVerLineItemToUpdate.add(mapMarketinIdFieldKeyAndUnitVerificationLineItem.get(strKey));
                                   // }
                                }
                            }
                        }
                    }
                }
            }
            // //System.debug('new on ::'+lstUnitVerLineItemToUpdate);
            if(lstUnitVerLineItemToUpdate!= null && !lstUnitVerLineItemToUpdate.isEmpty()){
                update lstUnitVerLineItemToUpdate;
            }
            // //System.debug('new on ::'+lstUnitVerLineItemToInsert);
            if(lstUnitVerLineItemToInsert!= null && !lstUnitVerLineItemToInsert.isEmpty()){
                insert lstUnitVerLineItemToInsert;
            }*/
            // //System.debug('new on ::'+lstTask);
            if(lstTask!= null && !lstTask.isEmpty()){
                  insert lstTask;
            }
            System.debug('new on ::');
            
        }
        System.debug('new on ::131');
    }
    
    public static task createTask(String subject,string whoId, string whatId, String AssignedToId ){
        task newTask = new task();
        newTask.Subject = subject;
        newTask.ActivityDate = system.TODAY();
        newTask.OwnerId = AssignedToId;
        newTask.WhatId = whatId;
        if(string.isNotBlank(whoId)){
            newTask.WhoId = whoId;
        }
        
        
        return newTask;
    }
    private static Boolean hasFieldChanged(
        Marketing_Detail__c newMarketingDetail, Marketing_Detail__c oldMarketingDetail, String fieldName
    ){
        return hasValueChanged(
            newMarketingDetail.get(fieldName),
            oldMarketingDetail.get(fieldName)
        );
    }
    
    private static Boolean hasValueChanged(Object newValue, Object oldValue){
        return newValue != oldValue;
    }
    
}