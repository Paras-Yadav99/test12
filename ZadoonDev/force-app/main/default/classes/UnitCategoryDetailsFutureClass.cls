/*
This future method class is called from unitcategoryDetailsTriggerHandler afterupdate event.
------------------------------------------------------------------------------------------------
Version#     Date                   Organization         Author                    Description
------------------------------------------------------------------------------------------------
1.0          07-Aug-2023         Kizzy Consulting      	 Pushkar               Initial Version
------------------------------------------------------------------------------------------------
*/
public class UnitCategoryDetailsFutureClass {
    public static final string USERREQUIREMENT = 'User_Requirement_ID__r';
    public static final string UNIT = 'Unit__r';
    public static final string EQUIPMENT = 'equipment__r';
    @future(callOut = true)
    public static void futureUnitCategoryDetails(set<id> setUnitCategoryParentId,set<string> setOfCategoryDetailsToMdt,set<string> setOfCategoryDetails,set<id> setOfUnitId ) {
        system.debug('setUnitCategoryParentId::::'+setUnitCategoryParentId);
        system.debug('setOfCategoryDetailsToMdt:::'+setOfCategoryDetailsToMdt);
        system.debug('setOfCategoryDetails:::'+setOfCategoryDetails);
        //system.debug('setofRecordTypeId:::'+setofRecordTypeId);
        list<Unit_Category__mdt> lstUnitCategory;
        
        map<string,string> mapOfFieldApinameVsDataType;
        List<Unit_Category_Details__c> lstUnitCategoryDetail;
        map<string,set<string>> mapOfRecordDevNameVsSetOfField = new map<string,set<string>>();
        map<string,list<Unit_Category__mdt>> mapOfCategoryVsUnitMdt = new map<string,list<Unit_Category__mdt>>();
        //map<string,list<Unit_Category__mdt>> mapOfMultiselectRecordTypeVsUnitMdt = new map<string,list<Unit_Category__mdt>>();
        map<id,Unit_Category_Details__c> mapOfUridVsUcd = new map<id,Unit_Category_Details__c>();
        map<string,list<Unit_Category_Details__c>> mapOfDevnameVsUnitCategoryDetails = new map<string,list<Unit_Category_Details__c>>();
        list<Iron_Demand__c> lstIronDemandToInsert = new list<Iron_Demand__c>();
        if(setOfCategoryDetailsToMdt!=null && !setOfCategoryDetailsToMdt.isEmpty()){
            lstUnitCategory = [SELECT id,Field_API_Name__c,Category__c,IsActive__c,RecordTypeName__c,Unit__c,Value__c,Data_Type__c,Related_Object__c
                               FROM Unit_Category__mdt 
                               WHERE RecordTypeName__c IN : setOfCategoryDetailsToMdt AND IsActive__c=true];
        }
        system.debug('setOfCategoryDetailsToMdt:::'+setOfCategoryDetailsToMdt);
        system.debug('lstUnitCategory:::'+lstUnitCategory);
        
        set<string> setString = new set<string>();
        system.debug('lstUnitCategory::'+lstUnitCategory);
        
        
         /*string setOfUnitCategoryParentId = '(';
            integer cnt = 0;
            for(String key :setUnitCategoryParentId){
                if(cnt+1 !=setOfCategoryDetails.size() ){
                    setOfUnitCategoryParentId +='\''+key +'\''+', '; 
                }else{
                    setOfUnitCategoryParentId +=  '\''+key +'\''+') '; 
                }
                cnt++;
            }
        system.debug('setOfUnitCategoryParentId:::'+setOfUnitCategoryParentId);*/
        
        Boolean doQuery = false;
        string query = 'SELECT ID, RecordTypeId,Unit__c,Equipment__c,User_Requirement_ID__c,Category_Details__c,Unit__r.Account__c,User_Requirement_ID__r.Lead__r.name,User_Requirement_ID__r.opportunity__r.name,Unit__r.ProductCode ';
        query += ',User_Requirement_ID__r.Lead__c,User_Requirement_ID__r.Lead__r.contact__c,User_Requirement_ID__r.Opportunity__c,User_Requirement_ID__r.Contact__c,Unit__r.IsActive,User_Requirement_ID__r.Contact__r.AccountId,User_Requirement_ID__r.contact__r.name,User_Requirement_ID__r.name';
        
        if(lstUnitCategory!=null && !lstUnitCategory.isEmpty()){
            
            for(Unit_Category__mdt eachUnit : lstUnitCategory){
                system.debug('eachUnit.Field_API_Name__c:::'+eachUnit.Field_API_Name__c);
                system.debug('eachUnit.RecordTypeName__c:::'+eachUnit.RecordTypeName__c);
                if(eachUnit.RecordTypeName__c =='URID'){
                    system.debug('enter in urid');
                    if(!mapOfCategoryVsUnitMdt.containsKey(eachUnit.RecordTypeName__c)){
                        mapOfCategoryVsUnitMdt.put(eachUnit.RecordTypeName__c,new list<Unit_Category__mdt>());
                    }
                    mapOfCategoryVsUnitMdt.get(eachUnit.RecordTypeName__c).add(eachUnit);
                    system.debug('eachUnit.Field_API_Name__c::::'+eachUnit.Field_API_Name__c);
                    query += ', User_Requirement_ID__r.' + eachUnit.Field_API_Name__c;
                    system.debug('query inner:::' + query);
                    system.debug('eachUnit.Value__c::::'+eachUnit.Value__c);
                    if((string.isNotBlank(eachUnit.Unit__c) && eachUnit.Value__c =='Max' && eachUnit.Related_Object__c == null) ||
                       (string.isNotBlank(eachUnit.Unit__c) && eachUnit.Value__c ==null && eachUnit.Related_Object__c == null)){
                        query += ', unit__r.'+ eachUnit.Unit__c;
                    }
                    if(string.isNotBlank(eachUnit.Unit__c) && eachUnit.Value__c =='Max' && eachUnit.Related_Object__c == 'Equipment' ){
                        system.debug('eachUnit.Unit__c112233:::'+eachUnit.Unit__c);
                        query += ', unit__r.equipment__r.'+eachUnit.Unit__c;
                    }
                }else{
                    doQuery = true;
                    system.debug('eachUnit::'+eachUnit);
                    system.debug('eachUnit.Category__c:::'+eachUnit.Category__c);
                    if(!setString.contains(eachUnit.Field_API_Name__c)){
                        query += ' ,' + eachUnit.Field_API_Name__c ;
                        setString.add(eachUnit.Field_API_Name__c);
                    }
                    if(!mapOfRecordDevNameVsSetOfField.containsKey(eachUnit.Category__c)){
                        mapOfRecordDevNameVsSetOfField.put(eachUnit.Category__c,new set<string>());
                    }
                    mapOfRecordDevNameVsSetOfField.get(eachUnit.Category__c).add(eachUnit.Field_API_Name__c.tolowerCase());
                    system.debug('mapofrec::'+mapOfRecordDevNameVsSetOfField.get(eachUnit.Category__c)); 
                }
                
            }
        }
        if(setOfCategoryDetails!=null && !setOfCategoryDetails.isEmpty()){
            string setKey = '(';
            integer count = 0;
            for(String key :setOfCategoryDetails){
                if(count+1 !=setOfCategoryDetails.size() ){
                    setKey +='\''+key +'\''+', '; 
                }else{
                    setKey +=  '\''+key +'\''+') '; 
                }
                count++;
            }
            system.debug('setKey::'+setKey);
            //query +=' FROM Unit_Category_Details__c WHERE Category_Details__c =\'Drill\'' + ' AND Unit__r.IsActive = true' ;
            query +=' FROM Unit_Category_Details__c WHERE Category_Details__c IN ' + setKey ;//+ 'AND (Id NOT IN ' + setKey1 +')';//+'AND Unit__c!=null';//+ query1;
        }
        
        System.debug('query:::::'+query);
        //system.debug('query1::'+query1);
        
        if(doQuery ){
            //string queryAll = String.escapeSingleQuotes(query);
            lstUnitCategoryDetail = DataBase.query(query);
            System.debug('lstUnit_Category_Details :::'+lstUnitCategoryDetail);
            System.debug('lstUnit_Category_Details :::'+lstUnitCategoryDetail.size());
        }
        system.debug('lstUnitCategoryDetail::'+lstUnitCategoryDetail);
        //set<id> setOfContactId = new set<id>();
        if(lstUnitCategoryDetail!=null && !lstUnitCategoryDetail.isEmpty()){
            for(Unit_Category_Details__c eachUnitCategory : lstUnitCategoryDetail){	
                /*system.debug('eachUnitCategory::'+eachUnitCategory);
                system.debug('eachUnitCategoryunit:::'+eachUnitCategory.Unit__c);
                if(string.isNotBlank(eachUnitCategory.User_Requirement_ID__r.Lead__c) &&
                   string.isnotblank(eachUnitCategory.User_Requirement_ID__r.Lead__r.contact__c) 
                   && String.IsBlank(eachUnitCategory.Unit__c) && String.IsNotBlank(eachUnitCategory.User_Requirement_ID__c) &&
                   setOfUnitCategoryParentId.contains(eachUnitCategory.User_Requirement_ID__c)){
                    setOfContactId.add(eachUnitCategory.User_Requirement_ID__r.Lead__r.contact__c);
                }*/
                
                if(eachUnitCategory.unit__r.isActive == false){
                    system.debug('eachUnitCategoryActive::'+eachUnitCategory);
                    system.debug('eachUnitCategoryunitActive:::'+eachUnitCategory.Unit__c);   
                }
                if(String.IsNotBlank(eachUnitCategory.Unit__c) && string.isBlank(eachUnitCategory.User_Requirement_ID__c) 
                   && string.isNotBlank(eachUnitCategory.Category_Details__c) && String.IsNotBlank(eachUnitCategory.Equipment__c) ){
                       
                       //system.debug('strRecordDevName:::'+strRecordDevName);
                       if(!mapOfDevnameVsUnitCategoryDetails.containsKey(eachUnitCategory.Category_Details__c) && eachUnitCategory.unit__r.isActive == true){
                           mapOfDevnameVsUnitCategoryDetails.put(eachUnitCategory.Category_Details__c,new list<Unit_Category_Details__c>());
                       }
                       if(eachUnitCategory.unit__r.isActive == true && mapOfDevnameVsUnitCategoryDetails.containsKey(eachUnitCategory.Category_Details__c)){
                           system.debug('eachUnitCategoryInside::'+eachUnitCategory);
                           system.debug('eachUnitCategoryunitInside:::'+eachUnitCategory.Unit__c);
                           mapOfDevnameVsUnitCategoryDetails.get(eachUnitCategory.Category_Details__c).add(eachUnitCategory);
                       }
                    
                }else if(setUnitCategoryParentId.contains(eachUnitCategory.User_Requirement_ID__c)){
                    mapOfUridVsUcd.put(eachUnitCategory.User_Requirement_ID__c, eachUnitCategory);
                }
            }
        }
        system.debug('mapOfDevnameVsUnitCategoryDetails111::'+mapOfDevnameVsUnitCategoryDetails);
        // set<string> setDevNameString = new set<string>{'Common'};
        system.debug('mapOfUridVsUcd.values()::'+mapOfUridVsUcd.values());
        system.debug('mapOfUridVsUcd.values()size::'+mapOfUridVsUcd.values().size());
        //list<Iron_Demand__c> lstOfIronDemand = new list<Iron_Demand__c>();
        //Map<string,Iron_Demand__c> mapOfConIdUnitIdVsIronDemand = new Map<string,Iron_Demand__c>();
        //system.debug('setOfContactId:::'+setOfContactId);
        /*if(setOfContactId != null && !setOfContactId.isEmpty()){
            lstOfIronDemand = [SELECT id,Unit_Currently_Interested_In__c,IronDemand_Contact__c,IronDemand_Iron__c,User_Requirement_ID__c
                               FROM Iron_Demand__c
                               WHERE IronDemand_Contact__c in :setOfContactId AND Unit_Currently_Interested_In__c != null];
        }
        system.debug('lstOfIronDemand151:::'+lstOfIronDemand);
        if(lstOfIronDemand != null && !lstOfIronDemand.isEmpty()){
            for(Iron_Demand__c  eachIronDemand :lstOfIronDemand){
                string ConIdUnitId = '';
               ConIdUnitId += eachIronDemand.IronDemand_Contact__c;
                ConIdUnitId += eachIronDemand.Unit_Currently_Interested_In__c;
                system.debug('ConIdUnitIdin Map :::'+ ConIdUnitId);
                if(string.isnotblank(ConIdUnitId) && !mapOfConIdUnitIdVsIronDemand.containsKey(ConIdUnitId)){
                   mapOfConIdUnitIdVsIronDemand.put(ConIdUnitId,eachIronDemand); 
                }
            }
        }*/
        
        // system.debug('setDevNameString::'+setDevNameString);
        if(!mapOfUridVsUcd.values().isEmpty() && mapOfUridVsUcd.values()!=null){
            mapOfFieldApinameVsDataType=SobjectFieldDataType.sobjectFieldDataType('Unit_Category_Details__c');
            for(Unit_Category_Details__c eachUCD : mapOfUridVsUcd.values()){
                system.debug('eachUCDleadname::'+eachUCD.User_Requirement_ID__r.lead__r.name);
               system.debug('eachUCDleadnameopp::'+eachUCD.User_Requirement_ID__r.opportunity__r.name);
                system.debug('eachUCDleadnamecon::'+eachUCD.User_Requirement_ID__r.contact__r.name);
               
                //system.debug('eachUCD:::'+eachUCD.Blade_Width1__c);
                
                system.debug('eachUCD:::'+eachUCD.id);
                //String strRecordDevName = 
                //  Schema.SObjectType.Unit_Category_Details__c.getRecordTypeInfosById().get(eachUCD.RecordTypeId).getDeveloperName();
                set<string> setCategory = new set<string>();
                if( string.isNotBlank(eachUCD.Category_Details__c) && mapOfDevnameVsUnitCategoryDetails.containsKey(eachUCD.Category_Details__c) 
                   && mapOfDevnameVsUnitCategoryDetails.values()!=null 
                   && !mapOfDevnameVsUnitCategoryDetails.values().isEmpty()){
                       system.debug('mapOfDevnameVsUnitCategoryDetails.get(eachCategory)::'+mapOfDevnameVsUnitCategoryDetails.get(eachUCD.Category_Details__c));
                       system.debug('(eachCategory)::'+mapOfDevnameVsUnitCategoryDetails.get(eachUCD.Category_Details__c).size());
                       if(mapOfRecordDevNameVsSetOfField.containsKey('Common')){
                           setCategory.addAll(mapOfRecordDevNameVsSetOfField.get('Common'));
                       }
                       
                       for(Unit_Category_Details__c eachUnitCD : mapOfDevnameVsUnitCategoryDetails.get(eachUCD.Category_Details__c) ){
                           system.debug('Unit__r.ProductCode:::'+eachUnitCD.Unit__r.ProductCode);
                           system.debug('Unit__r.ProductCode11:::'+eachUnitCD.Unit__c);
                           //-----------------for range------------ 
                           Boolean isMatch = false;
                           Boolean isMatchRange = true;
                           Boolean isAllData = false;
                           system.debug('eachUnitCD::'+eachUnitCD);           
                           if(mapOfCategoryVsUnitMdt.containsKey('URID')){
                               system.debug('mapOfCategoryVsUnitMdt:::'+mapOfCategoryVsUnitMdt);
                               for(Unit_Category__mdt eachUnit : mapOfCategoryVsUnitMdt.get('URID')){
                                   system.debug('eachUnit:::'+eachUnit);
                                   if(eachUnit.Data_Type__c == 'Integer' && eachUnit.Related_Object__c == null){
                                       system.debug('entered in Integer');
                                       system.debug('mostouter break:::');
                                       if(Integer.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c)) != null
                                          &&  Integer.valueof(eachUnitCD.getSobject(UNIT).get(eachUnit.Unit__c))!= null){
                                              
                                              if(eachUnit.Value__c =='Min' && 
                                                 (integer.valueof(eachUnitCD.getSobject(UNIT).get(eachUnit.Unit__c))<integer.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c)))){
                                                     system.debug('min unit value::'+integer.valueof(eachUnitCD.getSobject(UNIT).get(eachUnit.Unit__c)));
                                                     system.debug('min user value:::'+integer.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c)));
                                                     system.debug('enter in min');
                                                     isMatchRange = false;
                                                     break;
                                                 }
                                              else if(eachUnit.Value__c =='Max' && 
                                                      (integer.valueof(eachUnitCD.getSobject(UNIT).get(eachUnit.Unit__c))>integer.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c)))){
                                                          system.debug('eachUnitCD.getSobject::::'+ eachUnitCD.getSobject(UNIT).get(eachUnit.Unit__c));
                                                          system.debug('eachUnit:inside:::'+eachUnit);
                                                          system.debug('eachUnitCD:inside::'+eachUnitCD);
                                                          system.debug('eachUCD.getSobject.get(eachUnit.Field_API_Name__c):::'+eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c));
                                                          system.debug('enter in max');
                                                          isMatchRange = false;
                                                          system.debug('before break:::');
                                                          break;
                                                          system.debug('after break:::');
                                                      }
                                          }
                                       else if(Integer.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c)) != null
                                               &&  Integer.valueof(eachUnitCD.getSobject(UNIT).get(eachUnit.Unit__c)) == null){
                                                   system.debug('enter in else if ::::');
                                                   IsMatchRange = false;
                                                   break;
                                               }
                                       
                                       
                                       /*if (!isMatchRange) {
system.debug('entered in if2:::');
break; // Exit the outer for loop if the flag is false
}*/
                                       
                                   }
                                   
                                   /*if (!isMatchRange) {
system.debug('entered in if2:::');
break; // Exit the outer for loop if the flag is false
}*/
                                   if(eachUnit.Data_Type__c == 'Integer' && 
                                      eachUnit.Related_Object__c =='Equipment' ){
                                          system.debug('entered in Integer from equipment');
                                          if(Integer.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c)) != null
                                             &&  Integer.valueof(eachUnitCD.getSobject(UNIT).getSobject(EQUIPMENT).get(eachUnit.Unit__c))!=null){
                                                 if(eachUnit.Value__c =='Min' && 
                                                    (integer.valueof(eachUnitCD.getSobject(UNIT).getSobject(EQUIPMENT).get(eachUnit.Unit__c))<integer.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c)))){
                                                        system.debug('min unit value::'+integer.valueof(eachUnitCD.getSobject(UNIT).getSobject(EQUIPMENT).get(eachUnit.Unit__c)));
                                                        system.debug('min user value:::'+integer.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c)));
                                                        system.debug('enter in min of eqp');
                                                        isMatchRange = false;
                                                        break;
                                                    }
                                                 else if(eachUnit.Value__c =='Max' && 
                                                         (integer.valueof(eachUnitCD.getSobject(UNIT).getSobject(EQUIPMENT).get(eachUnit.Unit__c))>integer.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c)))){
                                                             system.debug('eachUnitCD.getSobject'+ eachUnitCD.getSobject(UNIT).getSobject(EQUIPMENT).get(eachUnit.Unit__c));
                                                             system.debug('eachUCD.getSobject.get(eachUnit.Field_API_Name__c):::'+eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c));
                                                             system.debug('enter in max in eqp');
                                                             isMatchRange = false;
                                                             break;
                                                         }
                                             }
                                          else if(Integer.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c)) != null
                                                  && Integer.valueof(eachUnitCD.getSobject(UNIT).getSobject(EQUIPMENT).get(eachUnit.Unit__c)) == null){
                                                      system.debug('enter in else if of equipment ::::');
                                                      IsMatchRange = false;
                                                      break;
                                                  }
                                      }
                                  
                                   if(eachUnit.Data_Type__c == 'Multiselect Picklist' && 
                                      eachUnit.Related_Object__c == null){
                                          system.debug('entered in multi');
                                          if(string.isnotblank(string.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c))) 
                                             &&  string.isnotblank(string.valueof(eachUnitCD.getSobject(UNIT).get(eachUnit.Unit__c)))){
                                                 system.debug('userreq:::'+string.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c)));
                                                 system.debug('unitcat::::'+string.valueof(eachUnitCD.getSobject(UNIT).get(eachUnit.Unit__c)));
                                                 if(!string.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c)).contains(string.valueof(eachUnitCD.getSobject(UNIT).get(eachUnit.Unit__c)))){
                                                     isMatchRange = false; 
                                                     break;
                                                 }    
                                             }
                                          else if(string.isnotblank(string.valueof(eachUCD.getSobject(USERREQUIREMENT).get(eachUnit.Field_API_Name__c))) 
                                                  &&  string.isBlank(string.valueof(eachUnitCD.getSobject(UNIT).get(eachUnit.Unit__c)))){
                                                      system.debug('enter in multiselect::');
                                                      IsMatchRange = false;
                                                      break;
                                                  }
                                      }
                                   
                               }
                           }
                           //system.debug('isMatchContains:::'+isMatchContains);
                           system.debug('isMatchRange:::'+isMatchRange);
                           //---------------------------------------						
                           system.debug('eachUnitCD.Unit__r.IsActive::::' + eachUnitCD.Unit__r.IsActive);
                           //if(setDevNameString!=null && !setDevNameString.isEmpty()){
                           //system.debug('setDevNameString:::'+setDevNameString);
                           
                           if(mapOfRecordDevNameVsSetOfField.containsKey(eachUCD.Category_Details__c)){
                               setCategory.addAll(mapOfRecordDevNameVsSetOfField.get(eachUCD.Category_Details__c));
                           }
                           //for(string eachCategory : setDevNameString){
                           
                           if(IsMatchRange){
                           if(setCategory!=null && !setCategory.isEmpty()){
                               system.debug('setCategory:::'+setCategory);
                               for(string eachField : setCategory){
                                   system.debug('eachFieldLowerCase ::: '+eachField.toLowerCase());
                                   system.debug('eachfield::'+eachField);
                                   system.debug('eachUCD.get(eachMdt.Field_API_Name__c):::'+eachUCD.get(eachField));
                                   system.debug('mapOfFieldApinameVsDataType::'+mapOfFieldApinameVsDataType);
                                   system.debug('mapOfFieldApinameVsDataType6::'+mapOfFieldApinameVsDataType.get(eachField));
                                   system.debug('mapOfFieldApinameVsDataType6::'+mapOfFieldApinameVsDataType.get('Counterweight_Removal_System_Manual__c'));
                                   system.debug('mapOfFieldApinameVsDataType1::'+mapOfFieldApinameVsDataType.Keyset());
                                   system.debug('mapOfFieldApinameVsDataType2::'+mapOfFieldApinameVsDataType.values());
                                   system.debug('mapOfFieldApinameVsDataType3::'+ eachField + mapOfFieldApinameVsDataType.get(eachField));
                                   system.debug('eachUCD.get(eachField):::'+eachUCD.get(eachField));
                                   system.debug('eachField1122::'+eachField);
                                   system.debug('String.valueof(eachUCD.get(eachField)):::'+String.valueof(eachUCD.get(eachField)));
                                   system.debug('String.valueof(eachUnitCD.get(eachField))):::'+String.valueof(eachUnitCD.get(eachField)));
                                   if(mapOfFieldApinameVsDataType.containskey(eachField)){
                                       if(mapOfFieldApinameVsDataType.get(eachField)=='BOOLEAN' && eachUCD.get(eachField)==true /*&& eachUnitCD.get(eachField)==true*/
                                         ){
                                             system.debug('entered in Boolean');
                                             isAllData = false;
                                             System.debug('Matched data UCD UNIT::'+eachUnitCD.Id +'::::: UCD MDC:::::::'+eachUnitCD.Id);
                                             system.debug('eachUCD.get(eachMdt.Field_API_Name__c):::'+eachField+eachUCD.get(eachField));
                                             system.debug('eachUnitCD.get(eachMdt.Field_API_Name__c):::'+eachUnitCD.get(eachField));
                                             if(eachUCD.get(eachField)==eachUnitCD.get(eachField)){
                                                 isMatch=true;
                                             }
                                             else{
                                                 system.debug('eachField::'+eachField);
                                                 system.debug('eachUCD.get(eachField):::'+eachUCD.get(eachField));
                                                 system.debug('eachUnitCD.get(eachField):::'+eachUnitCD.get(eachField));
                                                 system.debug('entered in elseboolean');
                                                 isMatch=false;
                                                 break;
                                             }
                                         }
                                       else if((mapOfFieldApinameVsDataType.get(eachField)=='PICKLIST' || mapOfFieldApinameVsDataType.get(eachField)=='STRING') 
                                               && string.isnotblank(String.valueof(eachUCD.get(eachField))) /*&& string.isnotblank(String.valueof(eachUnitCD.get(eachField)))*/){
                                                   system.debug('entered in PICKLIST');
                                                   isAllData = false;
                                                   System.debug('Matched data UCD UNIT::'+eachUnitCD.Id +'::::: UCD MDC:::::::'+eachUnitCD.Id);
                                                   system.debug('eachUCD.get(eachMdt.Field_API_Name__c):::'+eachField+eachUCD.get(eachField));
                                                   system.debug('eachUnitCD.get(eachMdt.Field_API_Name__c):::'+eachUnitCD.get(eachField));
                                                   if(eachUCD.get(eachField)==eachUnitCD.get(eachField)){
                                                       isMatch=true;
                                                   }
                                                   else{
                                                       system.debug('entered in elsepicklist');
                                                       isMatch=false;
                                                       break;
                                                   }
                                               }
                                       
                                       else if(mapOfFieldApinameVsDataType.get(eachField)=='DOUBLE' && integer.valueof(eachUCD.get(eachField))!=null 
                                               /*&& integer.valueof(eachUnitCD.get(eachField))!=null*/){
                                                   system.debug('entered in double');
                                                   system.debug('eachUCD.get(eachField)double:::'+ eachUCD.get(eachField));
                                                   isAllData = false;
                                                   System.debug('Matched data UCD UNIT::'+eachUnitCD.Id +'::::: UCD MDC:::::::'+eachUnitCD.Id);
                                                   system.debug('eachUCD.get(eachMdt.Field_API_Name__c):::'+eachField+eachUCD.get(eachField));
                                                   system.debug('eachUnitCD.get(eachMdt.Field_API_Name__c):::'+eachUnitCD.get(eachField));
                                                   if(integer.valueof(eachUnitCD.get(eachField))!=null && eachUCD.get(eachField)==eachUnitCD.get(eachField)){
                                                       isMatch=true;
                                                   }
                                                   else{
                                                       system.debug('entered in elsedouble');
                                                       isMatch=false;
                                                       break;
                                                   }
                                               }
                                      
                                       else if(mapOfFieldApinameVsDataType.get(eachField)=='MULTIPICKLIST' && string.isNotBlank(String.valueof(eachUCD.get(eachField))) 
                                               /*&& string.isNotBlank(String.valueof(eachUnitCD.get(eachField)))*/){
                                                   system.debug('entered in MULTIPICKLIST');
                                                   isAllData = false;
                                                   System.debug('Matched data UCD UNIT::'+eachUnitCD.Id +'::::: UCD MDC:::::::'+eachUnitCD.Id);
                                                   system.debug('eachUCD.get(eachMdt.Field_API_Name__c):::'+eachField+eachUCD.get(eachField));
                                                   system.debug('eachUnitCD.get(eachMdt.Field_API_Name__c):::'+eachUnitCD.get(eachField));
                                                   system.debug('String.valueof(eachUCD.get(eachField))::'+String.valueof(eachUCD.get(eachField)));
                                                   system.debug('String.valueof(eachUnitCD.get(eachField))::'+String.valueof(eachUnitCD.get(eachField)));
                                                   if(string.isNotBlank(String.valueof(eachUnitCD.get(eachField))) && String.valueof(eachUnitCD.get(eachField)).contains(String.valueof(eachUCD.get(eachField)))){
                                                       isMatch=true;
                                                       system.debug('isMatchinpick::'+isMatch);
                                                   }
                                                   else{
                                                       system.debug('entered in elsemultiselect');
                                                       isMatch=false;
                                                       break;
                                                   }
                                               }
                                       else{
                                           system.debug('eachFieldelse112::'+eachField);
                                           isAllData = true; 
                                       }
                                   }
                               }
                           }//mapofrec
                           }
                           //}//eachCat
                           //}//setDEvName
                           //ifeachend
                           system.debug('isMatch::'+isMatch);
                           system.debug('isAllData:::'+isAllData);
                           //if(string.isNotBlank(eachUCD.User_Requirement_ID__r.Lead__c)){
                           system.debug('eachUCD.User_Requirement_ID__r.Contact__r.AccountId:::'+eachUCD.User_Requirement_ID__r.Contact__r.AccountId);
                           system.debug('eachUnitCD.Unit__r.Account__c:::'+eachUnitCD.Unit__r.Account__c);
                           if(string.isNotBlank(eachUCD.User_Requirement_ID__r.Lead__c) 
                              && isMatch /*&& isMatchContains*/ && isMatchRange && string.isNotBlank(eachUnitCD.Unit__c)
                              && string.isNotBlank(eachUnitCD.Equipment__c) && eachUnitCD.Unit__r.IsActive==true 
                              && (eachUnitCD.Unit__r.Account__c != eachUCD.User_Requirement_ID__r.Contact__r.AccountId) &&
                              string.isnotblank(eachUCD.User_Requirement_ID__r.lead__r.name)
                              /* && string.isNotBlank(eachUCD.User_Requirement_ID__r.Lead__r.contact__c) */){
                                  System.debug('Matched data UCD UNIT::'+eachUnitCD.Id +'::::: UCD MDC:::::::'+eachUCD.Id);
                                  string name = ' ';
                                  if(string.isnotblank(eachUCD.User_Requirement_ID__r.name)){
                                      name += eachUCD.User_Requirement_ID__r.name +' ' +'ID' +' ';
                                  }
                                  if(string.isnotblank(eachUnitCD.unit__r.ProductCode)){
                                      name += eachUnitCD.unit__r.ProductCode;
                                  }
                                  string conIdUnitId = '';
                                  conIdUnitId += eachUCD.User_Requirement_ID__r.Lead__r.contact__c;
                                  conIdUnitId += eachUnitCD.Unit__c;
                                  system.debug('conIdUnitId in loop ::'+conIdUnitId); 
                                  //system.debug('mapOfConIdUnitIdVsIronDem:::'+mapOfConIdUnitIdVsIronDemand.containsKey(conIdUnitId));
                                  //if(!mapOfConIdUnitIdVsIronDemand.containsKey(conIdUnitId)){
                                      Iron_Demand__c newIronDemands = 
                                          createIronDemand(name,eachUnitCD.Unit__c ,eachUCD.User_Requirement_ID__c ,eachUCD.User_Requirement_ID__r.Contact__c,eachUnitCD.Equipment__c );
                                      system.debug('newIronDemands::1:'+newIronDemands);
                                      lstIronDemandToInsert.add(newIronDemands);  
                                  //}
                                  
                              } 
                           //}
                           else if(string.isNotBlank(eachUCD.User_Requirement_ID__r.Opportunity__c)
                                   /*&& isMatchContains*/ && isMatchRange && isMatch && string.isNotBlank(eachUnitCD.Unit__c) 
                                   && string.isNotBlank(eachUnitCD.Equipment__c) && eachUnitCD.Unit__r.IsActive==true 
                                   && (eachUnitCD.Unit__r.Account__c != eachUCD.User_Requirement_ID__r.Contact__r.AccountId) /*&&
                                   string.isnotblank(eachUCD.User_Requirement_ID__r.opportunity__r.name)*/){
                                       //if(isMatch && string.isNotBlank(eachUnitCD.Unit__c) && string.isNotBlank(eachUnitCD.Equipment__c) ){
                                       string name = ' ';
                                       if(string.isnotblank(eachUCD.User_Requirement_ID__r.name)){
                                           name += eachUCD.User_Requirement_ID__r.name +' ' +'ID' +' ';
                                       }
                                       if(string.isnotblank(eachUnitCD.unit__r.ProductCode)){
                                           name += eachUnitCD.unit__r.ProductCode;
                                       }
                                       system.debug('entered in opportunity'); 
                                       System.debug('Matched data UCD UNIT::'+eachUnitCD.Id +'::::: UCD MDC:::::::'+eachUCD.Id);
                                       Iron_Demand__c newIronDemands =
                                           createIronDemand(name,eachUnitCD.Unit__c,eachUCD.User_Requirement_ID__c,eachUCD.User_Requirement_ID__r.Contact__c,eachUnitCD.Equipment__c);
                                       system.debug('newIronDemands::3:'+newIronDemands);
                                       lstIronDemandToInsert.add(newIronDemands);
                                   }
                           else if(string.isNotBlank(eachUCD.User_Requirement_ID__r.Contact__c) 
                                   /*&& isMatchContains*/ && isMatchRange && isMatch && string.isNotBlank(eachUnitCD.Unit__c) 
                                   && string.isNotBlank(eachUnitCD.Equipment__c) && eachUnitCD.Unit__r.IsActive==true
                                   && (eachUnitCD.Unit__r.Account__c != eachUCD.User_Requirement_ID__r.Contact__r.AccountId) /*&&
                                   string.isnotblank(eachUCD.User_Requirement_ID__r.contact__r.name)*/){
                                       //if(isMatch && string.isNotBlank(eachUnitCD.Unit__c) && string.isNotBlank(eachUnitCD.Equipment__c) ){
                                        string name =' ';
                                       if(string.isnotblank(eachUCD.User_Requirement_ID__r.name)){
                                           name += eachUCD.User_Requirement_ID__r.name +' ' +'ID' +' ';
                                       }
                                       if(string.isnotblank(eachUnitCD.unit__r.ProductCode)){
                                           name += eachUnitCD.unit__r.ProductCode;
                                       }
                                       system.debug('entered in contact'); 
                                       System.debug('Matched data UCD UNIT::'+eachUnitCD.Id +'::::: UCD MDC:::::::'+eachUCD.Id);
                                       Iron_Demand__c newIronDemands =
                                           createIronDemand(name,eachUnitCD.Unit__c,eachUCD.User_Requirement_ID__c,eachUCD.User_Requirement_ID__r.Contact__c,eachUnitCD.Equipment__c);
                                       system.debug('newIronDemands::2:'+newIronDemands);
                                       lstIronDemandToInsert.add(newIronDemands);
                                   }
                           
                           if(string.isNotBlank(eachUCD.User_Requirement_ID__r.Lead__c) && isMatchRange
                              /*&& isMatchContains*/ && isAllData && string.isNotBlank(eachUnitCD.Unit__c) 
                              && string.isNotBlank(eachUnitCD.Equipment__c) && eachUnitCD.Unit__r.IsActive==true
                              && (eachUnitCD.Unit__r.Account__c != eachUCD.User_Requirement_ID__r.Contact__r.AccountId)){
                                  system.debug('enter in all');
                                  
                                   string name =' ';
                                       if(string.isnotblank(eachUCD.User_Requirement_ID__r.name)){
                                           name += eachUCD.User_Requirement_ID__r.name +' ' +'ID' +' ';
                                       }
                                       if(string.isnotblank(eachUnitCD.unit__r.ProductCode)){
                                           name += eachUnitCD.unit__r.ProductCode;
                                       }
                                  
                                  string conIdUnitId = '';
                                  conIdUnitId += eachUCD.User_Requirement_ID__r.Lead__r.contact__c;
                                  conIdUnitId += eachUnitCD.Unit__c;
                                 // system.debug('mapOfConIdUnitIdVsIronDema::'+mapOfConIdUnitIdVsIronDemand.containsKey(conIdUnitId));
                                  //if(!mapOfConIdUnitIdVsIronDemand.containsKey(conIdUnitId)){
                                      Iron_Demand__c newIronDemands =
                                          createIronDemand(name,eachUnitCD.Unit__c ,eachUCD.User_Requirement_ID__c ,eachUCD.User_Requirement_ID__r.contact__c,eachUnitCD.Equipment__c );
                                      system.debug('newIronDemands::4:'+newIronDemands);
                                      lstIronDemandToInsert.add(newIronDemands);
                                  //}
                              }
                           
                           else if(string.isNotBlank(eachUCD.User_Requirement_ID__r.Opportunity__c) /*&& isMatchContains*/ 
                                   && isMatchRange && isAllData && string.isNotBlank(eachUnitCD.Unit__c) 
                                   && string.isNotBlank(eachUnitCD.Equipment__c) && eachUnitCD.Unit__r.IsActive==true
                                   && (eachUnitCD.Unit__r.Account__c != eachUCD.User_Requirement_ID__r.Contact__r.AccountId)){
                                        string name =' ';
                                       if(string.isnotblank(eachUCD.User_Requirement_ID__r.name)){
                                           name += eachUCD.User_Requirement_ID__r.name +' ' +'ID' +' ';
                                       }
                                       if(string.isnotblank(eachUnitCD.unit__r.ProductCode)){
                                           name += eachUnitCD.unit__r.ProductCode;
                                       }
                                       system.debug('entered in opportunity'); 
                                       Iron_Demand__c newIronDemands =
                                           createIronDemand(name,eachUnitCD.Unit__c,eachUCD.User_Requirement_ID__c,eachUCD.User_Requirement_ID__r.Contact__c,eachUnitCD.Equipment__c);
                                       system.debug('newIronDemands::6:'+newIronDemands);
                                       lstIronDemandToInsert.add(newIronDemands);
                                   }
                           else if(string.isNotBlank(eachUCD.User_Requirement_ID__r.Contact__c) /*&& isMatchContains*/ && isMatchRange && isAllData
                                   && string.isNotBlank(eachUnitCD.Unit__c) && string.isNotBlank(eachUnitCD.Equipment__c) && eachUnitCD.Unit__r.IsActive==true
                                   && (eachUnitCD.Unit__r.Account__c != eachUCD.User_Requirement_ID__r.Contact__r.AccountId)){
                                        string name = ' ';
                                       if(string.isnotblank(eachUCD.User_Requirement_ID__r.name)){
                                           name += eachUCD.User_Requirement_ID__r.name +' ' +'ID' +' ';
                                       }
                                       if(string.isnotblank(eachUnitCD.unit__r.ProductCode)){
                                           name += eachUnitCD.unit__r.ProductCode;
                                       }
                                       Iron_Demand__c newIronDemands =
                                           createIronDemand(name,eachUnitCD.Unit__c,eachUCD.User_Requirement_ID__c,eachUCD.User_Requirement_ID__r.Contact__c,eachUnitCD.Equipment__c);
                                       system.debug('newIronDemands::5:'+newIronDemands);
                                       lstIronDemandToInsert.add(newIronDemands);
                                   }
                       }
                   }  
                //  }//for eachcat end
                // }//if end
            }
        }
       
        map<string,Iron_Demand__c> mapOfProductIdVsIronDemand = new map<string,Iron_Demand__c>();
        if(lstIronDemandToInsert!=null && !lstIronDemandToInsert.isEmpty()){
            system.debug('lstIronDemandToInsert::'+lstIronDemandToInsert);
            for(Iron_Demand__c eachIronDemand : lstIronDemandToInsert){
                system.debug('eachIronDemand::'+eachIronDemand);
                string key = eachIronDemand.User_Requirement_ID__c;
                key += eachIronDemand.Unit_Currently_Interested_In__c;
                key += eachIronDemand.IronDemand_Iron__c;
                system.debug('keyput::::'+key);
                if(!mapOfProductIdVsIronDemand.containsKey(key)){
                    mapOfProductIdVsIronDemand.put(key,eachIronDemand);   
                }
            }
        }
        system.debug('mapOfProductIdVsIronDemand:::'+mapOfProductIdVsIronDemand);
       
        
        list<Iron_Demand__c> lstIronDemand;
        if(setUnitCategoryParentId !=null && !setUnitCategoryParentId.isEmpty()){
            lstIronDemand = [SELECT Id,User_Requirement_ID__c,Unit_Currently_Interested_In__c,IronDemand_Iron__c
                             FROM Iron_Demand__c 
                             WHERE User_Requirement_ID__c In : setUnitCategoryParentId WITH SECURITY_ENFORCED];
        }
        system.debug('lstIronDemand::'+lstIronDemand);
        //----------------
        list<Iron_Demand__c> lstIronDemandToRemove = new list<Iron_Demand__c>();
        list<Iron_Demand__c> lstIronDemandToSendEmail = new list<Iron_Demand__c>();
        if(lstIronDemand != null && !lstIronDemand.isEmpty()){
            for(Iron_Demand__c eachIronDemand : lstIronDemand ){
                string key = eachIronDemand.User_Requirement_ID__c;
                key += eachIronDemand.Unit_Currently_Interested_In__c ;
                key += eachIronDemand.IronDemand_Iron__c;
                system.debug('eachIronDemand:::'+eachIronDemand);
                system.debug('keyget:::'+key);
                if(mapOfProductIdVsIronDemand.containskey(key)){
                    //system.debug('getvaluessss:::'+mapOfProductIdVsIronDemand.get(key));
                    //Iron_Demand__c newIronDemand = mapOfProductIdVsIronDemand.get(key);
                    //system.debug('newIronDemand66272:::'+newIronDemand);
                    // if((eachIronDemand.Unit_Currently_Interested_In__c == newIronDemand.Unit_Currently_Interested_In__c) &&
                    // (eachIronDemand.IronDemand_Iron__c == newIronDemand.IronDemand_Iron__c) 
                    // && (eachIronDemand.User_Requirement_ID__c == newIronDemand.User_Requirement_ID__c)  ){
                    mapOfProductIdVsIronDemand.remove(key); 
                    //}
                }
                else if(!mapOfProductIdVsIronDemand.containskey(key)){
                    lstIronDemandToRemove.add(eachIronDemand);
                }
            }
        }
        if(lstIronDemandToRemove != null && !lstIronDemandToRemove.isEmpty()){
            system.debug('lstIronDemandToRemove::'+lstIronDemandToRemove);
            delete lstIronDemandToRemove;
        }
        if(mapOfProductIdVsIronDemand.values()!=null && !mapOfProductIdVsIronDemand.values().isEmpty()){
            system.debug('mapOfProductIdVsIronDemand.values()::'+mapOfProductIdVsIronDemand.values());
            insert mapOfProductIdVsIronDemand.values();
        }
      /*  If(setOfUnitId != null && !setOfUnitId.isEmpty()){
            lstIronDemandToSendEmail = [SELECT id,User_Requirement_ID__c,Unit_Currently_Interested_In__c
                                        FROM Iron_Demand__c
                                        WHERE Unit_Currently_Interested_In__c in : setOfUnitId]; 
        }*/
        If(setOfUnitId != null && !setOfUnitId.isEmpty()){
            List<Id> lstUnitID = new List<Id>(setOfUnitId);
            system.debug('lstUnitID::::'+lstUnitID);
            EmailUserRequirementContactFromUnitInvoc.sendEmailtoUserRequirementContact(lstUnitID);
        }

		        
        //----------------------
        
        //********
        /*system.debug('lstIronDemand::'+lstIronDemand);
if(lstIronDemand!=null && !lstIronDemand.isEmpty()){
delete lstIronDemand;
}
if(lstIronDemandToInsert!=null && !lstIronDemandToInsert.isEmpty()){
system.debug('lstIronDemandToInsert:::'+ lstIronDemandToInsert.size()+'::::'+lstIronDemandToInsert );
insert lstIronDemandToInsert;
}*/
        //***************
    }
    //This method is used to Created Iron demand record based on UnitCategoryDetails and called from FutureUnitCategoryDetails method
    public static Iron_Demand__c createIronDemand(string name,Id unitId , Id userRequirementID,Id contactId, Id equipmentId ){
        Iron_Demand__c newIronDemand = new Iron_Demand__c();
        if(string.isnotblank(unitId) && string.isnotblank(UserRequirementID) /*&& string.isnotblank(ContactId)*/ && string.isnotblank(EquipmentId)){
            newIronDemand.Name = name;
            newIronDemand.Unit_Currently_Interested_In__c =unitId;
            newIronDemand.User_Requirement_ID__c =UserRequirementID;
            newIronDemand.IronDemand_Contact__c =ContactId;
            newIronDemand.IronDemand_Iron__c = EquipmentId;
            system.debug('newIronDemand::'+newIronDemand);
        }
        return newIronDemand;
    }
    
}