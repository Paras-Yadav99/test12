//This Class is used to provide data to the LeaderReports LWC
public class LeaderReportsController {
    
    @AuraEnabled
    public static AuraResponse getMonthlyUserData(integer Year,String Quarter){
        AuraResponse AuraResponse;
        
        try{
            //Check for input Value
            
            if(Year !=null && String.IsNotBlank(Quarter) ){
                AuraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(handleGetMonthlyUserData(Year,Quarter)));
                
            }else{
                AuraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'Year OR Quarter is not found.');
                
            }
            
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
            System.debug('At LINE'+ex.getLineNumber());
        }
        
        SYSTEM.debug('AuraResponse : :: '+AuraResponse);
        
        // Returning Aura-Response to LWC
        return AuraResponse;
    }
    /*
* To get Quarter Data Based on Year : :: : : : : : : : : :  :: : : : : :  :
*/
    @AuraEnabled
    public static AuraResponse getMonthlyUserQuarterData(integer Year){
        AuraResponse AuraResponse;
        
        try{
            //Check for input Value
            
            if(Year !=null && Year>0 ){
                AuraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(handleGetQuarterUserData(Year)));
                
            }else{
                AuraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'Year is not found.');
                
            }
            
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
            System.debug('At LINE'+ex.getLineNumber());
        }
        
        SYSTEM.debug('AuraResponse : :: '+AuraResponse);
        
        // Returning Aura-Response to LWC
        return AuraResponse;
    }

        /*
* To get Refresh Data Based on Year : :: : : : : : : : : :  :: : : : : :  :
*/
    @AuraEnabled
    public static AuraResponse refreshData(integer Year){
        AuraResponse AuraResponse;
        
        try{
            //Check for input Value
            
            if(Year !=null && Year>0 ){
                AuraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(handleRefreshData(Year)));
                
            }else{
                AuraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'Year is not found.');
                
            }
            
        } catch (Exception ex) {
            AuraResponse = new AuraResponse(false,
                                            'ERROR',
                                            ex.getMessage());
            System.debug('At LINE'+ex.getLineNumber());
        }
        
        SYSTEM.debug('AuraResponse : :: '+AuraResponse);
        
        // Returning Aura-Response to LWC
        return AuraResponse;
    }

    // Method to handle refresh monthly Data based on year
    private static String handleRefreshData(integer Year){
        System.debug('Year :::'+Year);
          String message = 'Record are ready to update.';
          System.debug('message :::'+message);
          UpdateMonthlyUserDetailsForOpp batchInstance = NEW UpdateMonthlyUserDetailsForOpp(false,Year);
        //batchInstance.YearlyData = true;
        id BatchId = DataBase.executeBatch(batchInstance, 200);
         message = 'Record updated successfully.';
         System.debug('message :::'+message);
        return message;
    }
    //Method get Quareter data based on Year
    public static map<id,string>mapUserIdName = new map <id,string>();
    private static ParentWrapperQuarter handleGetQuarterUserData(integer Year){
        ParentWrapperQuarter newParentWrapperQuarter = new ParentWrapperQuarter();
        set<id>setUserId = new set<id>();
        list<Monthly_Goal_For_User__c>lstMonthlyGoalForUser = new list<Monthly_Goal_For_User__c>();
        //Get Monthly User Data as per Year and Quarter
        lstMonthlyGoalForUser = [SELECT Id, 
                                 User__c,
                                 Month__c,
                                 Quarter__c,
                                 User__r.Name,
                                 Gross_Profit__c, 
                                 Gross_Profit_Goal__c, 
                                 GP_Procured_Goal__c, 
                                 GP_Percentage_to_goal__c, 
                                 Total_Actual_Gross_Profit_Procured__c,
                                 Potential_Gross_Profit_Owned_Units__c ,
                                 Percentage_of_Gross_Profit_Goal__c,
                                 Year__c
                                 FROM Monthly_Goal_For_User__c 
                                 WHERE Year__c =: Year AND 
                                 User__c!=null ]; 
        
        if(lstMonthlyGoalForUser!=null && !lstMonthlyGoalForUser.IsEmpty()){
            list<WrapperData> quarter1Sales = new list<WrapperData>();
            list<WrapperData> quarter2Sales = new list<WrapperData>();
            list<WrapperData> quarter3Sales = new list<WrapperData>();
            list<WrapperData> quarter4Sales = new list<WrapperData>();
            list<WrapperData> quarterTotalSales = new list<WrapperData>();
            
            list<WrapperData> quarter1Procurement = new list<WrapperData>();
            list<WrapperData> quarter2Procurement = new list<WrapperData>();
            list<WrapperData> quarter3Procurement = new list<WrapperData>();
            list<WrapperData> quarter4Procurement = new list<WrapperData>();
            list<WrapperData> quarterTotalProcurement = new list<WrapperData>();
            
            
            map<id,WrapperData> mapQuarter1LstMonthly_Goal_For_User = new map<id,WrapperData>();
            map<id,WrapperData> mapQuarter2LstMonthly_Goal_For_User = new map<id,WrapperData>();
            map<id,WrapperData> mapQuarter3LstMonthly_Goal_For_User = new map<id,WrapperData>();
            map<id,WrapperData> mapQuarter4LstMonthly_Goal_For_User = new map<id,WrapperData>();
            map<id,WrapperData> mapQuarterTotalLstMonthly_Goal_For_User = new map<id,WrapperData>();
            
            map<id,WrapperData> mapQuarter1LstMonthly_Goal_For_UserProcurement = new map<id,WrapperData>();
            map<id,WrapperData> mapQuarter2LstMonthly_Goal_For_UserProcurement = new map<id,WrapperData>();
            map<id,WrapperData> mapQuarter3LstMonthly_Goal_For_UserProcurement = new map<id,WrapperData>();
            map<id,WrapperData> mapQuarter4LstMonthly_Goal_For_UserProcurement = new map<id,WrapperData>();
            map<id,WrapperData> mapQuarterTotalLstMonthly_Goal_For_UserProcurement = new map<id,WrapperData>();
            
            
            for(Monthly_Goal_For_User__c eachMonthly_Goal_For_User : lstMonthlyGoalForUser){
                setUserId.add(eachMonthly_Goal_For_User.User__c);
                mapUserIdName.put(eachMonthly_Goal_For_User.User__c,eachMonthly_Goal_For_User.User__r.Name);
                WrapperData newWrapperData = new WrapperData (eachMonthly_Goal_For_User.User__c,
                                                              eachMonthly_Goal_For_User.User__r.Name,
                                                              eachMonthly_Goal_For_User.Month__c,
                                                              false,
                                                              eachMonthly_Goal_For_User.Gross_Profit__c,
                                                              eachMonthly_Goal_For_User.Gross_Profit_Goal__c,
                                                              setUnitWrapper(eachMonthly_Goal_For_User.Percentage_of_Gross_Profit_Goal__c));
                
               // String userQuarterKey = eachMonthly_Goal_For_User.User__c+'&&'+eachMonthly_Goal_For_User.Quarter__c;
                if(eachMonthly_Goal_For_User.Quarter__c =='Quarter 1'){
                    if(!mapQuarter1LstMonthly_Goal_For_User.containsKey(eachMonthly_Goal_For_User.User__c)){
                        mapQuarter1LstMonthly_Goal_For_User.put(eachMonthly_Goal_For_User.User__c,newWrapperData);
                         System.debug('eachMonthly_Goal_For_User.User__r.Name in if :::'+eachMonthly_Goal_For_User.User__r.Name);
                         System.debug('mapQuarter1LstMonthly_Goal_For_User in if :::'+mapQuarter1LstMonthly_Goal_For_User);
                    }else{
                         System.debug('eachMonthly_Goal_For_User.User__r.Name in else :::'+eachMonthly_Goal_For_User.User__r.Name);
                        System.debug('mapQuarter1LstMonthly_Goal_For_User  in else :::'+mapQuarter1LstMonthly_Goal_For_User);
                        mapQuarter1LstMonthly_Goal_For_User = getTotalWrapperData(mapQuarter1LstMonthly_Goal_For_User,newWrapperData,eachMonthly_Goal_For_User.User__c);
                    }
                }else if(eachMonthly_Goal_For_User.Quarter__c == 'Quarter 2'){
                    if(!mapQuarter2LstMonthly_Goal_For_User.containsKey(eachMonthly_Goal_For_User.User__c)){
                        mapQuarter2LstMonthly_Goal_For_User.put(eachMonthly_Goal_For_User.User__c,newWrapperData);
                    }else{
                        mapQuarter2LstMonthly_Goal_For_User = getTotalWrapperData(mapQuarter2LstMonthly_Goal_For_User,newWrapperData,eachMonthly_Goal_For_User.User__c);
                    }
                }else if(eachMonthly_Goal_For_User.Quarter__c =='Quarter 3'){
                    if(!mapQuarter3LstMonthly_Goal_For_User.containsKey(eachMonthly_Goal_For_User.User__c)){
                        mapQuarter3LstMonthly_Goal_For_User.put(eachMonthly_Goal_For_User.User__c,newWrapperData);
                    }else{
                        mapQuarter3LstMonthly_Goal_For_User = getTotalWrapperData(mapQuarter3LstMonthly_Goal_For_User,newWrapperData,eachMonthly_Goal_For_User.User__c);
                    }
                }else if(eachMonthly_Goal_For_User.Quarter__c =='Quarter 4'){
                    if(!mapQuarter4LstMonthly_Goal_For_User.containsKey(eachMonthly_Goal_For_User.User__c)){
                        mapQuarter4LstMonthly_Goal_For_User.put(eachMonthly_Goal_For_User.User__c,newWrapperData);
                    }else{
                        mapQuarter4LstMonthly_Goal_For_User = getTotalWrapperData(mapQuarter4LstMonthly_Goal_For_User,newWrapperData,eachMonthly_Goal_For_User.User__c);
                    }
                }
                
                if(!mapQuarterTotalLstMonthly_Goal_For_User.containsKey(eachMonthly_Goal_For_User.User__c)){
                    mapQuarterTotalLstMonthly_Goal_For_User.put(eachMonthly_Goal_For_User.User__c,newWrapperData);
                }else{
                    mapQuarterTotalLstMonthly_Goal_For_User = getTotalWrapperData(mapQuarterTotalLstMonthly_Goal_For_User,newWrapperData,eachMonthly_Goal_For_User.User__c);
                }
                
                WrapperData newWrapperDataProcurement = new WrapperData (eachMonthly_Goal_For_User.User__c,
                                                                         eachMonthly_Goal_For_User.User__r.Name,
                                                                         eachMonthly_Goal_For_User.Month__c,
                                                                         false,
                                                                         eachMonthly_Goal_For_User.Total_Actual_Gross_Profit_Procured__c,
                                                                         eachMonthly_Goal_For_User.GP_Procured_Goal__c,
                                                                         setUnitWrapper(eachMonthly_Goal_For_User.GP_Percentage_to_goal__c));
                if(eachMonthly_Goal_For_User.Quarter__c =='Quarter 1'){
                    if(!mapQuarter1LstMonthly_Goal_For_UserProcurement.containsKey(eachMonthly_Goal_For_User.User__c)){
                        mapQuarter1LstMonthly_Goal_For_UserProcurement.put(eachMonthly_Goal_For_User.User__c,newWrapperDataProcurement);
                    }else{
                        mapQuarter1LstMonthly_Goal_For_UserProcurement = getTotalWrapperData(mapQuarter1LstMonthly_Goal_For_UserProcurement,newWrapperDataProcurement,eachMonthly_Goal_For_User.User__c);
                    }
                }else if(eachMonthly_Goal_For_User.Quarter__c == 'Quarter 2'){
                    if(!mapQuarter2LstMonthly_Goal_For_UserProcurement.containsKey(eachMonthly_Goal_For_User.User__c)){
                        mapQuarter2LstMonthly_Goal_For_UserProcurement.put(eachMonthly_Goal_For_User.User__c,newWrapperDataProcurement);
                    }else{
                        mapQuarter2LstMonthly_Goal_For_UserProcurement = getTotalWrapperData(mapQuarter2LstMonthly_Goal_For_UserProcurement,newWrapperDataProcurement,eachMonthly_Goal_For_User.User__c);
                    }
                }else if(eachMonthly_Goal_For_User.Quarter__c =='Quarter 3'){
                    if(!mapQuarter3LstMonthly_Goal_For_UserProcurement.containsKey(eachMonthly_Goal_For_User.User__c)){
                        mapQuarter3LstMonthly_Goal_For_UserProcurement.put(eachMonthly_Goal_For_User.User__c,newWrapperDataProcurement);
                    }else{
                        mapQuarter3LstMonthly_Goal_For_UserProcurement = getTotalWrapperData(mapQuarter3LstMonthly_Goal_For_UserProcurement,newWrapperDataProcurement,eachMonthly_Goal_For_User.User__c);
                    }
                }else if(eachMonthly_Goal_For_User.Quarter__c =='Quarter 4'){
                    if(!mapQuarter4LstMonthly_Goal_For_UserProcurement.containsKey(eachMonthly_Goal_For_User.User__c)){
                        mapQuarter4LstMonthly_Goal_For_UserProcurement.put(eachMonthly_Goal_For_User.User__c,newWrapperDataProcurement);
                    }else{
                        mapQuarter4LstMonthly_Goal_For_UserProcurement = getTotalWrapperData(mapQuarter4LstMonthly_Goal_For_UserProcurement,newWrapperDataProcurement,eachMonthly_Goal_For_User.User__c);
                    }
                }
                
                if(!mapQuarterTotalLstMonthly_Goal_For_UserProcurement.containsKey(eachMonthly_Goal_For_User.User__c)){
                    mapQuarterTotalLstMonthly_Goal_For_UserProcurement.put(eachMonthly_Goal_For_User.User__c,newWrapperDataProcurement);
                }else{
                    mapQuarterTotalLstMonthly_Goal_For_UserProcurement = 
                        getTotalWrapperData(mapQuarterTotalLstMonthly_Goal_For_UserProcurement,
                                            newWrapperDataProcurement,
                                            eachMonthly_Goal_For_User.User__c);
                }
            }
            
            
            if(setUserId!=null && setUserId.size()>0){
                for(Id eachUserId : setUserId){
                    quarter1Sales=handleDataMaptoList(mapQuarter1LstMonthly_Goal_For_User,quarter1Sales,eachUserId);
                    quarter2Sales=handleDataMaptoList(mapQuarter2LstMonthly_Goal_For_User,quarter2Sales,eachUserId);
                    quarter3Sales=handleDataMaptoList(mapQuarter3LstMonthly_Goal_For_User,quarter3Sales,eachUserId);
                    quarter4Sales=handleDataMaptoList(mapQuarter4LstMonthly_Goal_For_User,quarter4Sales,eachUserId);
                    quarterTotalSales=handleDataMaptoList(mapQuarterTotalLstMonthly_Goal_For_User,quarterTotalSales,eachUserId);
                    
                    //
                    quarter1Procurement=handleDataMaptoList(mapQuarter1LstMonthly_Goal_For_UserProcurement,quarter1Procurement,eachUserId);
                    quarter2Procurement=handleDataMaptoList(mapQuarter2LstMonthly_Goal_For_UserProcurement,quarter2Procurement,eachUserId);
                    quarter3Procurement=handleDataMaptoList(mapQuarter3LstMonthly_Goal_For_UserProcurement,quarter3Procurement,eachUserId);
                    quarter4Procurement=handleDataMaptoList(mapQuarter4LstMonthly_Goal_For_UserProcurement,quarter4Procurement,eachUserId);
                    quarterTotalProcurement=handleDataMaptoList(mapQuarterTotalLstMonthly_Goal_For_UserProcurement,quarterTotalProcurement,eachUserId);
                    
                }
            }
            WrapperQuarterData saleLeaderData = new WrapperQuarterData(setTotalValuesData(quarter1Sales),
                                                                       setTotalValuesData(quarter2Sales),
                                                                       setTotalValuesData(quarter3Sales),
                                                                       setTotalValuesData(quarter4Sales),
                                                                       setTotalValuesData(quarterTotalSales));
            WrapperQuarterData ProcurementLeaderData = new WrapperQuarterData(setTotalValuesData(quarter1Procurement),
                                                                              setTotalValuesData(quarter2Procurement),
                                                                              setTotalValuesData(quarter3Procurement),
                                                                              setTotalValuesData(quarter4Procurement),
                                                                              setTotalValuesData(quarterTotalProcurement));
            //ParentWrapper instance
            newParentWrapperQuarter = new ParentWrapperQuarter(saleLeaderData,
                                                               ProcurementLeaderData);
            System.debug('newParentWrapperQuarter :: :'+newParentWrapperQuarter);
            System.debug('saleLeaderData :: :'+saleLeaderData);
            System.debug('ProcurementLeaderData :: :'+ProcurementLeaderData);
        }
        return newParentWrapperQuarter;
    }
    
    //Method to Get Monthly Data based on Year and Quarter
    private static ParentWrapper handleGetMonthlyUserData(integer Year,String Quarter){
        ParentWrapper newParentWrapper = new ParentWrapper();
        list<Monthly_Goal_For_User__c>lstMonthlyGoalForUser = new list<Monthly_Goal_For_User__c>();
        //Get Monthly User Data as per Year and Quarter
        lstMonthlyGoalForUser = [SELECT Id, 
                                 User__c,
                                 Month__c,
                                 Quarter__c,
                                 User__r.Name,
                                 Gross_Profit__c, 
                                 Gross_Profit_Goal__c, 
                                 GP_Procured_Goal__c, 
                                 GP_Percentage_to_goal__c, 
                                 Total_Actual_Gross_Profit_Procured__c,
                                 Potential_Gross_Profit_Owned_Units__c ,
                                 Percentage_of_Gross_Profit_Goal__c,
                                 Year__c
                                 FROM Monthly_Goal_For_User__c 
                                 WHERE Year__c =: Year AND
                                 Quarter__c =:Quarter AND 
                                 //Month__c!=null AND 
                                 User__c!=null ]; 
        //ParentWrapper instance
        if(lstMonthlyGoalForUser!=null  && lstMonthlyGoalForUser.size()>0){
            newParentWrapper= handleGetMonthlyUserData1(lstMonthlyGoalForUser);
        }
        // to return Data
        return newParentWrapper;
        
    }
    
    
    // methood to handle Monthly Data records
    private static ParentWrapper handleGetMonthlyUserData1(list<Monthly_Goal_For_User__c>lstMonthlyGoalForUser){
        Set<id>setUserId = new Set<Id>();
        
        //To set all users data per month
        list<WrapperData> Month1Sales = new list<WrapperData>();
        list<WrapperData> Month2Sales = new list<WrapperData>();
        list<WrapperData> Month3Sales = new list<WrapperData>();
        list<WrapperData> MonthlyTotalSales = new list<WrapperData>();
        
        list<WrapperData> Month1Procurement = new list<WrapperData>();
        list<WrapperData> Month2Procurement = new list<WrapperData>();
        list<WrapperData> Month3Procurement = new list<WrapperData>();
        list<WrapperData> MonthTotalProcurement = new list<WrapperData>();
        
        //To set Monthly Data per user
        map<id,WrapperData> MapUserIdMonth1Sales = new map<id,WrapperData>();
        map<id,WrapperData> MapUserIdMonth2Sales = new map<id,WrapperData>();
        map<id,WrapperData> MapUserIdMonth3Sales = new map<id,WrapperData>();
        map<id,WrapperData> MapUserIdMonthTotalSales = new map<id,WrapperData>();
        
        
        map<id,WrapperData> MapUserIdMonth1Procurement = new map<id,WrapperData>();
        map<id,WrapperData> MapUserIdMonth2Procurement = new map<id,WrapperData>();
        map<id,WrapperData> MapUserIdMonth3Procurement = new map<id,WrapperData>();
        map<id,WrapperData> MapUserIdMonthTotalProcurement = new map<id,WrapperData>();
        
        
        if(lstMonthlyGoalForUser!=null && !lstMonthlyGoalForUser.IsEmpty()){
            
            for(Monthly_Goal_For_User__c eachMonthly_Goal_For_User :lstMonthlyGoalForUser){
                //Fill Data to the Sales Lrader Data list
                setUserId.add(eachMonthly_Goal_For_User.User__c);
                
                mapUserIdName.put(eachMonthly_Goal_For_User.User__c,eachMonthly_Goal_For_User.User__r.Name);
                System.debug('eachMonthly_Goal_For_User : : :'+eachMonthly_Goal_For_User);
                WrapperData newWrapperData = new WrapperData (eachMonthly_Goal_For_User.User__c,
                                                              eachMonthly_Goal_For_User.User__r.Name,
                                                              eachMonthly_Goal_For_User.Month__c,
                                                              false,
                                                              eachMonthly_Goal_For_User.Gross_Profit__c,
                                                              eachMonthly_Goal_For_User.Gross_Profit_Goal__c,
                                                              setUnitWrapper(eachMonthly_Goal_For_User.Percentage_of_Gross_Profit_Goal__c));
                
                if(eachMonthly_Goal_For_User.Month__c =='January' ||eachMonthly_Goal_For_User.Month__c =='April' ||eachMonthly_Goal_For_User.Month__c =='July' || eachMonthly_Goal_For_User.Month__c =='October'){
                    MapUserIdMonth1Sales.put(eachMonthly_Goal_For_User.User__c,newWrapperData); 
                }else if(eachMonthly_Goal_For_User.Month__c =='February' ||eachMonthly_Goal_For_User.Month__c =='May' ||eachMonthly_Goal_For_User.Month__c =='August' || eachMonthly_Goal_For_User.Month__c =='November'){
                    MapUserIdMonth2Sales.put(eachMonthly_Goal_For_User.User__c,newWrapperData);
                }else if(eachMonthly_Goal_For_User.Month__c =='March' ||eachMonthly_Goal_For_User.Month__c =='June' ||eachMonthly_Goal_For_User.Month__c =='September' || eachMonthly_Goal_For_User.Month__c =='December'){
                    MapUserIdMonth3Sales.put(eachMonthly_Goal_For_User.User__c,newWrapperData); 
                }
                
                
                if(!MapUserIdMonthTotalSales.containsKey(eachMonthly_Goal_For_User.User__c)){
                    WrapperData newWrapperData1= new WrapperData(newWrapperData);
                    //newWrapperData1 = newWrapperData;
                    newWrapperData1.isQuarter = false;
                    MapUserIdMonthTotalSales.put(eachMonthly_Goal_For_User.User__c,newWrapperData1);
                }else{
                    MapUserIdMonthTotalSales = getTotalWrapperData(MapUserIdMonthTotalSales,newWrapperData,eachMonthly_Goal_For_User.User__c);
                }
                
                //Fill Data to the Procurement Leader data List
                WrapperData newWrapperDataProcurement = new WrapperData (eachMonthly_Goal_For_User.User__c,
                                                                         eachMonthly_Goal_For_User.User__r.Name,
                                                                         eachMonthly_Goal_For_User.Month__c,
                                                                         false,
                                                                         eachMonthly_Goal_For_User.Total_Actual_Gross_Profit_Procured__c,
                                                                         eachMonthly_Goal_For_User.GP_Procured_Goal__c,
                                                                         setUnitWrapper(eachMonthly_Goal_For_User.GP_Percentage_to_goal__c));
                
                if(eachMonthly_Goal_For_User.Month__c =='January' ||eachMonthly_Goal_For_User.Month__c =='April' ||eachMonthly_Goal_For_User.Month__c =='July' || eachMonthly_Goal_For_User.Month__c =='October'){
                    MapUserIdMonth1Procurement.put(eachMonthly_Goal_For_User.User__c,newWrapperDataProcurement); 
                }else if(eachMonthly_Goal_For_User.Month__c =='February' ||eachMonthly_Goal_For_User.Month__c =='May' ||eachMonthly_Goal_For_User.Month__c =='August' || eachMonthly_Goal_For_User.Month__c =='November'){
                    MapUserIdMonth2Procurement.put(eachMonthly_Goal_For_User.User__c,newWrapperDataProcurement);
                }else if(eachMonthly_Goal_For_User.Month__c =='March' ||eachMonthly_Goal_For_User.Month__c =='June' ||eachMonthly_Goal_For_User.Month__c =='September' || eachMonthly_Goal_For_User.Month__c =='December'){
                    MapUserIdMonth3Procurement.put(eachMonthly_Goal_For_User.User__c,newWrapperDataProcurement); 
                }
                
                
                if(!MapUserIdMonthTotalProcurement.containsKey(eachMonthly_Goal_For_User.User__c)){
                    WrapperData newWrapperData2= new WrapperData(newWrapperDataProcurement);
                    newWrapperData2.isQuarter = false;
                    MapUserIdMonthTotalProcurement.put(eachMonthly_Goal_For_User.User__c,newWrapperData2);
                }else{
                    MapUserIdMonthTotalProcurement = getTotalWrapperData(MapUserIdMonthTotalProcurement,newWrapperDataProcurement,eachMonthly_Goal_For_User.User__c);
                }
            }
        }
        
        if(setUserId!=null && setUserId.size()>0){
            for(Id eachUserId : setUserId){
                Month1Sales=handleDataMaptoList(MapUserIdMonth1Sales,Month1Sales,eachUserId);
                Month2Sales=handleDataMaptoList(MapUserIdMonth2Sales,Month2Sales,eachUserId);
                Month3Sales=handleDataMaptoList(MapUserIdMonth3Sales,Month3Sales,eachUserId);
                MonthlyTotalSales=handleDataMaptoList(MapUserIdMonthTotalSales,MonthlyTotalSales,eachUserId);
                
                //
                Month1Procurement=handleDataMaptoList(MapUserIdMonth1Procurement,Month1Procurement,eachUserId);
                Month2Procurement=handleDataMaptoList(MapUserIdMonth2Procurement,Month2Procurement,eachUserId);
                Month3Procurement=handleDataMaptoList(MapUserIdMonth3Procurement,Month3Procurement,eachUserId);
                MonthTotalProcurement=handleDataMaptoList(MapUserIdMonthTotalProcurement,MonthTotalProcurement,eachUserId);
                
            }
        }
        WrapperMonthlyData saleLeaderData = new WrapperMonthlyData(setTotalValuesData(Month1Sales),
                                                                   setTotalValuesData(Month2Sales),
                                                                   setTotalValuesData(Month3Sales),
                                                                   setTotalValuesData(MonthlyTotalSales));
        WrapperMonthlyData ProcurementLeaderData = new WrapperMonthlyData(setTotalValuesData(Month1Procurement),
                                                                          setTotalValuesData(Month2Procurement),
                                                                          setTotalValuesData(Month3Procurement),
                                                                          setTotalValuesData(MonthTotalProcurement));
        //ParentWrapper instance
        ParentWrapper newParentWrapper= new ParentWrapper(saleLeaderData,
                                                          ProcurementLeaderData);
        // to return Data
        return newParentWrapper;
        
    }
    
    // to get TOTAL ROW data
    private static map<id,WrapperData> getTotalWrapperData(map<id,WrapperData>MapUserIdMonthTotalSales,WrapperData newWrapperData,id userId){
        
        
        WrapperData newWrapperDataTotalSales = new WrapperData(newWrapperData);
        newWrapperDataTotalSales.isQuarter = false;
        if(newWrapperData.gp!=null){
            if(MapUserIdMonthTotalSales.containsKey(userId) && MapUserIdMonthTotalSales.get(userId).gp!=null){
                newWrapperDataTotalSales.gP=MapUserIdMonthTotalSales.get(userId).gp + newWrapperData.gp;
                
            }else{
                newWrapperDataTotalSales.gP=newWrapperData.gp;
                
            }
            
        }
        if(newWrapperData.goal!=null){
            if(MapUserIdMonthTotalSales.containsKey(userId) &&  MapUserIdMonthTotalSales.get(userId).goal!=null){
                newWrapperDataTotalSales.goal=MapUserIdMonthTotalSales.get(userId).goal + newWrapperData.goal;
            }else{
                newWrapperDataTotalSales.goal =  newWrapperData.goal;
            }
        }
        if(newWrapperDataTotalSales.goal!=null && newWrapperDataTotalSales.goal>0 && newWrapperDataTotalSales.gP!=null && newWrapperDataTotalSales.gP>0)
        {
            newWrapperDataTotalSales.toGoal =setUnitWrapper((newWrapperDataTotalSales.gP/newWrapperDataTotalSales.goal)*100);//setUnitWrapper( eachMonthly_Goal_For_User.Percentage_of_Gross_Profit_Goal__c);
        }else{
            newWrapperDataTotalSales.toGoal= setUnitWrapper(0);
        }
        
        MapUserIdMonthTotalSales.put(userId,newWrapperDataTotalSales);
        
        return MapUserIdMonthTotalSales;
    }
    
    
    //To check data 
    
    private static list<WrapperData> handleDataMaptoList(map<id,WrapperData> MapUserIdMonthlySales,list<WrapperData> MonthData , id UserId){
        if(MapUserIdMonthlySales.containsKey(UserId)&&
           MapUserIdMonthlySales.get(UserId)!=null ){
               MapUserIdMonthlySales.get(UserId).Name = mapUserIdName.get(UserId);
               MonthData.add(MapUserIdMonthlySales.get(UserId));
           }else{
               MonthData.add(new WrapperData(UserId,mapUserIdName.get(UserId),'',false,0,0,setUnitWrapper(0)));
           }
        return MonthData;
    }
    
    private static list<WrapperData> setTotalValuesData(list<WrapperData> MonthlyData){
        WrapperData totalWrapperData = new WrapperData ();
        decimal gPTotal = 0;
        decimal goalTotal = 0;
        decimal toGaolTotal = 0;
        
        if(MonthlyData!=null && !MonthlyData.isEmpty()){
            for(WrapperData eachWrapperData : MonthlyData){
                if(eachWrapperData.gP !=null){
                   gPTotal += eachWrapperData.gP; 
                }
                if(eachWrapperData.gP !=null){
                    goalTotal += eachWrapperData.goal;
                }
                //GaolTotal += eachWrapperData.toGoal.value;
                
            }
            if(goalTotal!=null && goalTotal>0 && gPTotal!=null){
                toGaolTotal =(gPTotal/goalTotal)*100; 
            }else{
                toGaolTotal = 0;
            }
            
            MonthlyData.add(new wrapperData('','TOTAL','',false,gPTotal,goalTotal,setUnitWrapper(toGaolTotal)));
        }
        return MonthlyData;
    }
    
    private static UnitWrapper setUnitWrapper(decimal value){
        String redColour = System.Label.Leader_Board_Red_Colour_When_to_Goal_is_lessthan_80;
        String greenColour = System.Label.Leader_Board_Green_Colour;
        String orangeColour = System.Label.Leader_Board_Orange_Colour_When_to_Goal_is_in_between_80_to_90;
        UnitWrapper newUnitWrapper= new UnitWrapper();
        if(value != null && value >0){
            if(value > 90){
                newUnitWrapper.value = value;
                newUnitWrapper.colour =greenColour;
            }else if(90>= value && value >=80){
                newUnitWrapper.value = value;
                newUnitWrapper.colour = orangeColour;
            }else if(value<80){
                newUnitWrapper.value = value;
                newUnitWrapper.colour = redColour;
            }
        }else{
            newUnitWrapper.value = 0.0;
            newUnitWrapper.colour = redColour;
        }
        
        return newUnitWrapper;
    }
    public class ParentWrapper{
        @AuraEnabled
        public WrapperMonthlyData saleLeaderData;
        @AuraEnabled
        public WrapperMonthlyData ProcurementLeaderData;
        
        ParentWrapper(){
            
        }
        ParentWrapper( WrapperMonthlyData  saleLeaderData,
                      WrapperMonthlyData  ProcurementLeaderData){
                          this.saleLeaderData = saleLeaderData;
                          this.ProcurementLeaderData = ProcurementLeaderData;
                          
                      }
        
    }
    //WrapperMonthly Data
    
    public class WrapperMonthlyData{
        @AuraEnabled
        public list<WrapperData> Month1;
        @AuraEnabled
        public list<WrapperData> Month2;
        @AuraEnabled
        public list<WrapperData> Month3;
        @AuraEnabled
        public list<WrapperData> MonthTotal;
        
        WrapperMonthlyData( list<WrapperData> Month1,
                           list<WrapperData> Month2,
                           list<WrapperData> Month3,
                           list<WrapperData> MonthTotal){
                               this.Month1 = Month1;
                               this.Month2 = Month2;
                               this.Month3 = Month3;
                               this.MonthTotal = MonthTotal;
                               
                           }
        
        
    }
    
    public class ParentWrapperQuarter{
        @AuraEnabled
        public WrapperQuarterData saleLeaderData;
        @AuraEnabled
        public WrapperQuarterData ProcurementLeaderData;
        
        ParentWrapperQuarter(){
            
        }
        ParentWrapperQuarter( WrapperQuarterData  saleLeaderData,
                             WrapperQuarterData  ProcurementLeaderData){
                                 this.saleLeaderData = saleLeaderData;
                                 this.ProcurementLeaderData = ProcurementLeaderData;
                                 
                             }
        
    }
    
    
    public class WrapperQuarterData{
        @AuraEnabled
        public list<WrapperData> Quarter1;
        @AuraEnabled
        public list<WrapperData> Quarter2;
        @AuraEnabled
        public list<WrapperData> Quarter3;
        @AuraEnabled
        public list<WrapperData> Quarter4;
        @AuraEnabled
        public list<WrapperData> QuarterTotal;
        
        WrapperQuarterData( list<WrapperData> Quarter1,
                           list<WrapperData> Quarter2,
                           list<WrapperData> Quarter3,
                           list<WrapperData> Quarter4,
                           list<WrapperData> QuarterTotal){
                               this.Quarter1 = Quarter1;
                               this.Quarter2 = Quarter2;
                               this.Quarter3 = Quarter3;
                               this.Quarter4 = Quarter4;
                               this.QuarterTotal = QuarterTotal;
                               
                           }
        
        
    }
    //Wrapper to hold Data
    public class WrapperData{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public boolean isQuarter;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Month;
        @AuraEnabled
        public decimal gP =0.00;
        @AuraEnabled
        public decimal goal =0.00;
        @AuraEnabled
        public UnitWrapper toGoal;
        
        WrapperData(){
            this.toGoal=new UnitWrapper();
        }
        WrapperData(WrapperData newWrapperData){
            this.Id = newWrapperData.Id;
            this.Name = newWrapperData.Name;
            this.Month = newWrapperData.Month;
            this.isQuarter = newWrapperData.isQuarter;
            this.gP = newWrapperData.gP; 
            this.goal = newWrapperData.goal;
            this.toGoal=newWrapperData.toGoal;
        }
        WrapperData( String Id,
                    String Name,
                    String Month,
                    Boolean isQuarter,
                    decimal gP,
                    decimal goal,
                    UnitWrapper toGoal){
                        this.Id = Id;
                        this.Name = Name;
                        this.Month = Month;
                        this.isQuarter = isQuarter;
                        if(gP!=null){
                            this.gP = gP;  
                        }
                        if(goal!=null){
                            this.goal = goal;
                        }
                        if(toGoal!=null){
                            // this.toGoal = toGoal;
                            this.toGoal=new UnitWrapper(toGoal.value,toGoal.colour);
                        }
                    }
    }
    public class UnitWrapper{
        @AuraEnabled
        public decimal value = 0.0;
        @AuraEnabled
        public String colour;
        @AuraEnabled
        public boolean isQuarter;
        
        UnitWrapper(){
            
        }
        UnitWrapper(decimal value,
                    String colour){
                        if(value!=null){
                            this.value = value;
                        }
                        
                        this.colour = colour;
                    }
    }
    
    // Aura-Response 
    Public class AuraResponse{
        @AuraEnabled 
        public Boolean isSuccess;
        @AuraEnabled 
        public string message;
        @AuraEnabled 
        public string response;
        
        AuraResponse(Boolean isSuccess,
                     String message,
                     String response) {
                         
                         this.isSuccess = isSuccess;
                         this.message = message;
                         this.response = response;
                     }
    }
    
    /*public class RecordsData {
@AuraEnabled public String label;
@AuraEnabled public String value;

public RecordsData(String label, String value) {
this.label = label;
this.value = value;
}
}*/
}