public without sharing  class LeaderBoardForUserController {
    @AuraEnabled
    public static AuraResponse getUserOptions(integer Year){
        AuraResponse AuraResponse;
        
        try{
            //Check for input Value
            
            if(Year !=null ){
                AuraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(handleGetUserOptions(Year)));
                
            }else{
                AuraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'Year  is not found.');
                
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
    
    @AuraEnabled
    public static AuraResponse getUserQuarterData(integer Year,String UserId,String Quarter,boolean IsQuarter){
        AuraResponse AuraResponse;
        
        try{
            //Check for input Value
            
            if(Year !=null && String.isNotBlank(UserId)){
                AuraResponse = new AuraResponse(true,
                                                'SUCCESS',
                                                JSON.serialize(handleGetUserQuarterData(Year,UserId,Quarter,IsQuarter)));
                
            }else{
                AuraResponse = new AuraResponse(false,
                                                'ERROR',
                                                'Year OR UserId  is not found.');
                
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
    
    private static list<PicklistOption> handleGetUserOptions(Integer Year){
        list<PicklistOption> lstPicklistOption = new list<PicklistOption>();
        list<Monthly_Goal_For_User__c>lstMonthlyGoalForUser = new list<Monthly_Goal_For_User__c>();
        //Get Monthly User Data as per Year and Quarter
        lstMonthlyGoalForUser = [SELECT Id, 
                                 User__c,
                                 User__r.Name,
                                 Year__c
                                 FROM Monthly_Goal_For_User__c 
                                 WHERE Year__c =: Year 
                                 AND User__c!=null ]; 
        //ParentWrapper instance
        set<id>UserIds = new set<id>();
        map<String,String> mapIdUserName = new map<String,String>();
        if(lstMonthlyGoalForUser!=null  && lstMonthlyGoalForUser.size()>0){
            for(Monthly_Goal_For_User__c eachMonthly_Goal_For_User : lstMonthlyGoalForUser){
                UserIds.add(eachMonthly_Goal_For_User.User__c);
                mapIdUserName.put(eachMonthly_Goal_For_User.User__c,eachMonthly_Goal_For_User.User__r.Name);
                // lstPicklistOption.add(new PicklistOption(eachMonthly_Goal_For_User.User__r.Name,eachMonthly_Goal_For_User.User__c));
            }
            
        }
        if(UserIds!=null  && UserIds.size()>0){
            for(id UserId : UserIds){
                if(mapIdUserName.containsKey(UserId) && mapIdUserName.get(UserId)!=null){
                    lstPicklistOption.add(new PicklistOption(mapIdUserName.get(UserId),UserId));
                }
            }
            
        }
        // to return Data
        
        return lstPicklistOption;
    }
    
    
    //to get Qureter Data for the user
    private static ParentWrapper handleGetUserQuarterData(integer Year,String UserId,String Quarter,boolean IsQuarter){
        List<String> lstMonths = new list<String>();
        
        List<MonthlyWrapperData> lstSalesMonthlyWrapperData = new list<MonthlyWrapperData>();
        List<MonthlyWrapperData> lstProcurementMonthlyWrapperData = new list<MonthlyWrapperData>();
        
        List<WrapperData> lstWrapperDataSales = new list<WrapperData>();
        List<WrapperData> lstWrapperDataProcurement = new list<WrapperData>();
        list<Monthly_Goal_For_User__c>lstMonthlyGoalForUser = new list<Monthly_Goal_For_User__c>();
        //Get Monthly User Data as per Year and Quarter
        
        
        String soqlQuery = 'SELECT Id, User__c, Month__c, Quarter__c, User__r.Name, Units_Added__c, Unit_Owned__c, ' +
            'POs_Created__c, Units_Owned_turn_rate__c, Units_Purchased__c, Units_Brokered__c, ' +
            'Total_Units_Purchared_or_Brokered__c, Close_Rate__c, Cost_of_Goods__c, ' +
            'Realized_Gross_Profit_Owned_Units__c, Realized_Gross_Profit_Brokered_Units__c, ' +
            'Total_Actual_Gross_Profit_Procured__c, Revenue__c, Revenue_Goal__c, Average_Revenue__c,Average_Gross_Profit__c, ' +
            'Deals_Closed__c, Gross_Profit__c, Gross_Profit_Goal__c, GP_Procured_Goal__c, ' +
            'GP_Percentage_to_goal__c, Percentage_of_Revenue_Goal__c, Potential_Gross_Profit_Owned_Units__c, ' +
            'Percentage_of_Gross_Profit_Goal__c, Year__c ' +
            'FROM Monthly_Goal_For_User__c ' +
            'WHERE Year__c = ' + Year + ' AND ' +
            'User__c != null AND ' +
            ' User__c =  \''+ UserId + '\'';
        if(IsQuarter == true){
            soqlQuery = soqlQuery + ' AND ' + 'Quarter__c =\''+ Quarter + '\'' ;
            
            
            
            
            if(Quarter =='Quarter 1'){
                lstMonths = new list<String>{'January','February' ,'March'};
                    }else if(Quarter =='Quarter 2'){
                        lstMonths = new List<String>{'April' ,'May','June'};
                            }else if(Quarter =='Quarter 3'){
                                lstMonths = new List<String>{'July','August' ,'September'};
                                    }else if(Quarter =='Quarter 4'){
                                        lstMonths = new List<String>{'October','November','December'};
                                            }
        }else{
            lstMonths = new list<String>{'January','February' ,'March','April' ,'May','June','July','August' ,'September','October','November','December'}; 
                }
        System.debug('soqlQuery :::'+soqlQuery);
        lstMonthlyGoalForUser = Database.query(soqlQuery);
        
        map<String,WrapperData> mapMonthWrappedDataSales = new map<String,WrapperData>();
        map<String,WrapperData> mapMonthWrappedDataProcurement = new map<String,WrapperData>();
        
        map<String,MonthlyWrapperData> mapMonthNewWrapperDataSales = new map<String,MonthlyWrapperData>();
        map<String,MonthlyWrapperData> mapMonthNewWrapperDataProcurment = new map<String,MonthlyWrapperData>();
        
        if(lstMonthlyGoalForUser!=null  && lstMonthlyGoalForUser.size()>0){
            for(Monthly_Goal_For_User__c eachMonthly_Goal_For_User : lstMonthlyGoalForUser){
                list<PicklistOption> lstSalesWrapperData = new list<PicklistOption> ();
                list<PicklistOption> lstProcurmentWrapperData = new list<PicklistOption> ();
                
                WrapperData newWrapperDataSales = new WrapperData (eachMonthly_Goal_For_User.Month__c,
                                                                   eachMonthly_Goal_For_User.Gross_Profit__c,
                                                                   eachMonthly_Goal_For_User.Gross_Profit_Goal__c);
                
                lstSalesWrapperData.add(new PicklistOption('Revenue Goal',String.valueOf(eachMonthly_Goal_For_User.Revenue_Goal__c),false,false));
                lstSalesWrapperData.add(new PicklistOption('GP Goal',String.valueOf(eachMonthly_Goal_For_User.Gross_Profit_Goal__c),false,false));
                lstSalesWrapperData.add(new PicklistOption('Revenue',String.valueOf(eachMonthly_Goal_For_User.Revenue__c),false,false));
                lstSalesWrapperData.add(new PicklistOption('GP',String.valueOf(eachMonthly_Goal_For_User.Gross_Profit__c),false,false));
                lstSalesWrapperData.add(new PicklistOption('% to Rev Goal',String.valueOf(eachMonthly_Goal_For_User.Percentage_of_Revenue_Goal__c),true,true));
                lstSalesWrapperData.add(new PicklistOption('% to GP Goal',String.valueOf(eachMonthly_Goal_For_User.Percentage_of_Gross_Profit_Goal__c),true,true));
                lstSalesWrapperData.add(new PicklistOption('Average Revenue',String.valueOf(eachMonthly_Goal_For_User.Average_Revenue__c),false,false));
                lstSalesWrapperData.add(new PicklistOption('Average GP',String.valueOf(eachMonthly_Goal_For_User.Average_Gross_Profit__c),false,false));
                lstSalesWrapperData.add(new PicklistOption('Deals Closed',String.valueOf(eachMonthly_Goal_For_User.Deals_Closed__c),true,false));
                
                WrapperData newWrapperDataProcurement = new WrapperData (eachMonthly_Goal_For_User.Month__c,
                                                                         eachMonthly_Goal_For_User.Total_Actual_Gross_Profit_Procured__c,
                                                                         eachMonthly_Goal_For_User.GP_Procured_Goal__c);
                
                lstProcurmentWrapperData.add(new PicklistOption('Unit Added',String.valueOf(eachMonthly_Goal_For_User.Units_Added__c),true,false));
                lstProcurmentWrapperData.add(new PicklistOption('POs Created',String.valueOf(eachMonthly_Goal_For_User.POs_Created__c),true,false));
                lstProcurmentWrapperData.add(new PicklistOption('Unit Purchased',String.valueOf(eachMonthly_Goal_For_User.Units_Purchased__c),true,false));
                lstProcurmentWrapperData.add(new PicklistOption('Unit Brokered',String.valueOf(eachMonthly_Goal_For_User.Units_Brokered__c),true,false));
                lstProcurmentWrapperData.add(new PicklistOption('Total Unit Purchased or Brokered',String.valueOf(eachMonthly_Goal_For_User.Total_Units_Purchared_or_Brokered__c),true,false));
                lstProcurmentWrapperData.add(new PicklistOption('Unit Owned turn rate',String.valueOf(eachMonthly_Goal_For_User.Units_Owned_turn_rate__c),true,false));
                lstProcurmentWrapperData.add(new PicklistOption('Close Rate',String.valueOf(eachMonthly_Goal_For_User.Close_Rate__c),true,true));
                lstProcurmentWrapperData.add(new PicklistOption('Cost of Goods',String.valueOf(eachMonthly_Goal_For_User.Cost_of_Goods__c),false,false));
                lstProcurmentWrapperData.add(new PicklistOption('Realized GP (Owned Units)',String.valueOf(eachMonthly_Goal_For_User.Realized_Gross_Profit_Owned_Units__c),false,false));
                lstProcurmentWrapperData.add(new PicklistOption('Realized GP (Brokered Units)',String.valueOf(eachMonthly_Goal_For_User.Realized_Gross_Profit_Brokered_Units__c),false,false));
                lstProcurmentWrapperData.add(new PicklistOption('Potential GP (Owned Units)',String.valueOf(eachMonthly_Goal_For_User.Potential_Gross_Profit_Owned_Units__c),false,false));
                lstProcurmentWrapperData.add(new PicklistOption('Total Actual GP Procured',String.valueOf(eachMonthly_Goal_For_User.Total_Actual_Gross_Profit_Procured__c),false,false));
                lstProcurmentWrapperData.add(new PicklistOption('GP Procured Goal',String.valueOf(eachMonthly_Goal_For_User.GP_Procured_Goal__c),false,false));
                lstProcurmentWrapperData.add(new PicklistOption('GP % to Goal',String.valueOf(eachMonthly_Goal_For_User.GP_Percentage_to_goal__c),true,true));
                
                mapMonthWrappedDataSales.put(eachMonthly_Goal_For_User.Month__c,newWrapperDataSales);
                mapMonthWrappedDataProcurement.put(eachMonthly_Goal_For_User.Month__c,newWrapperDataProcurement);
                
                MonthlyWrapperData newMonthlyWrapperData = new MonthlyWrapperData(eachMonthly_Goal_For_User.Month__c,lstSalesWrapperData);
                MonthlyWrapperData newMonthlyWrapperDataPrcurment = new MonthlyWrapperData(eachMonthly_Goal_For_User.Month__c,lstProcurmentWrapperData);
                
                mapMonthNewWrapperDataSales.put(eachMonthly_Goal_For_User.Month__c,newMonthlyWrapperData);
                mapMonthNewWrapperDataProcurment.put(eachMonthly_Goal_For_User.Month__c,newMonthlyWrapperDataPrcurment);
                
            }
        }
        
        if(lstMonths!=null  && lstMonths.size()>0){
            for(String eachMonth : lstMonths){
                lstWrapperDataSales.add(validateData(mapMonthWrappedDataSales,eachMonth));
                lstWrapperDataProcurement.add(validateData(mapMonthWrappedDataProcurement,eachMonth));
                if(mapMonthNewWrapperDataSales.containsKey(eachMonth) && mapMonthNewWrapperDataSales.get(eachMonth)!=null){
                    lstSalesMonthlyWrapperData.add(mapMonthNewWrapperDataSales.get(eachMonth));
                }else{
                    lstSalesMonthlyWrapperData.add(new MonthlyWrapperData(eachMonth, prePairEmptyList()));
                }
                if(mapMonthNewWrapperDataProcurment.containsKey(eachMonth) && mapMonthNewWrapperDataProcurment.get(eachMonth)!=null){
                    lstProcurementMonthlyWrapperData.add(mapMonthNewWrapperDataProcurment.get(eachMonth));
                }else{
                    lstProcurementMonthlyWrapperData.add(new MonthlyWrapperData(eachMonth, prepairProcurmentEmptyList()));
                }
            }
        }
        ParentWrapper newParentWrapper = new ParentWrapper(lstWrapperDataSales,lstWrapperDataProcurement,handleTotalData(lstSalesMonthlyWrapperData,IsQuarter,true),handleTotalData(lstProcurementMonthlyWrapperData,IsQuarter,false));
        return newParentWrapper;
        
    }
    //To Validate Monthly Data
    private static WrapperData validateData(map<String,WrapperData>mapData,String month){
        WrapperData newWrapperData = new WrapperData();
        if(mapData.containsKey(month) && mapData.get(month)!=null){
            newWrapperData = mapData.get(month);
        }else{
            newWrapperData = new WrapperData(month,0,0);
        }
        return newWrapperData;         
    }
    private static list<PicklistOption> prePairEmptyList(){
        
        list<PicklistOption> lstSalesWrapperData = new list<PicklistOption> ();
        lstSalesWrapperData.add(new PicklistOption('Revenue Goal','0.00',false,false));
        lstSalesWrapperData.add(new PicklistOption('GP Goal','0.00',false,false));
        lstSalesWrapperData.add(new PicklistOption('Revenue','0.00',false,false));
        lstSalesWrapperData.add(new PicklistOption('GP','0.00',false,false));
        lstSalesWrapperData.add(new PicklistOption('% to Rev Goal','0.00',true,true));
        lstSalesWrapperData.add(new PicklistOption('% to GP Goal','0.00',true,true));
        lstSalesWrapperData.add(new PicklistOption('Average Revenue','0.00',false,false));
        lstSalesWrapperData.add(new PicklistOption('Average GP','0.00',false,false));
        lstSalesWrapperData.add(new PicklistOption('Deals Closed','0.00',true,false));
        return lstSalesWrapperData;
    }
    
    private static list<PicklistOption>prepairProcurmentEmptyList(){
        
        list<PicklistOption> lstProcurmentWrapperData = new list<PicklistOption> ();
        lstProcurmentWrapperData.add(new PicklistOption('Unit Added','0.00',true,false));
        lstProcurmentWrapperData.add(new PicklistOption('POs Created','0.00',true,false));
        lstProcurmentWrapperData.add(new PicklistOption('Unit Purchased','0.00',true,false));
        lstProcurmentWrapperData.add(new PicklistOption('Unit Brokered','0.00',true,false));
        lstProcurmentWrapperData.add(new PicklistOption('Total Unit Purchased or Brokered','0.00',true,false));
        lstProcurmentWrapperData.add(new PicklistOption('Unit Owned turn rate','0.00',true,false));
        lstProcurmentWrapperData.add(new PicklistOption('Close Rate','0.00',true,true));
        lstProcurmentWrapperData.add(new PicklistOption('Cost of Goods','0.00',false,false));
        lstProcurmentWrapperData.add(new PicklistOption('Realized GP (Owned Units)','0.00',false,false));
        lstProcurmentWrapperData.add(new PicklistOption('Realized GP (Brokered Units)','0.00',false,false));
        lstProcurmentWrapperData.add(new PicklistOption('Potential GP (Owned Units)','0.00',false,false));
        lstProcurmentWrapperData.add(new PicklistOption('Total Actual GP Procured','0.00',false,false));
        lstProcurmentWrapperData.add(new PicklistOption('GP Procured Goal','0.00',false,false));
        lstProcurmentWrapperData.add(new PicklistOption('GP % to Goal','0.00',true,true));
        
        return lstProcurmentWrapperData;
    }
    private static decimal getTotalPercentData(decimal value1, decimal value2){
        decimal precentData = 0.00;
        precentData = value1==value2 ? 100 : ((value1 / (value2==0 ? 1 : value2)) * 100).setScale(2);
        return precentData;
    }
    private static List<MonthlyWrapperData> handleTotalData(List<MonthlyWrapperData> lstSaleLeaderData,Boolean IsQuarter,boolean IsSales){
        map<String,decimal> mapMonthlyTotalData = new map<String,decimal> ();
        if(lstSaleLeaderData!=null && lstSaleLeaderData.size()>0){
            for(MonthlyWrapperData eachMonthlyWrapperData : lstSaleLeaderData){
                
                if(eachMonthlyWrapperData.salesData!=null &&! eachMonthlyWrapperData.salesData.isEmpty() ){
                    
                    for(PicklistOption eachField : eachMonthlyWrapperData.salesData){
                        if(!mapMonthlyTotalData.containsKey(eachField.label)){
                            mapMonthlyTotalData.put(eachField.label,Decimal.valueOf(eachField.value));
                        }else{
                            decimal num = mapMonthlyTotalData.get(eachField.label)+Decimal.valueOf(eachField.value);
                            mapMonthlyTotalData.put(eachField.label,num);
                        }
                    }
                }
                
            }
            if(IsSales){
                // if(mapMonthlyTotalData.containsKey('% to Rev Goal')){
                mapMonthlyTotalData.put('% to Rev Goal', getTotalPercentData(mapMonthlyTotalData.get('Revenue'),mapMonthlyTotalData.get('Revenue Goal')));   
                // }
                mapMonthlyTotalData.put('% to GP Goal', getTotalPercentData(mapMonthlyTotalData.get('GP'),mapMonthlyTotalData.get('GP Goal')));
                mapMonthlyTotalData.put('Average Revenue', getTotalPercentData(mapMonthlyTotalData.get('Revenue'),mapMonthlyTotalData.get('Deals Closed')*100));
                mapMonthlyTotalData.put('Average GP', getTotalPercentData(mapMonthlyTotalData.get('GP'),mapMonthlyTotalData.get('Deals Closed')*100));
            }else{
                mapMonthlyTotalData.put('Close Rate', getTotalPercentData(mapMonthlyTotalData.get('Unit Brokered')+mapMonthlyTotalData.get('Unit Purchased'),mapMonthlyTotalData.get('POs Created')));  
                mapMonthlyTotalData.put('GP % to Goal', getTotalPercentData(mapMonthlyTotalData.get('Total Actual GP Procured'),mapMonthlyTotalData.get('GP Procured Goal')));
            }
           
            
            
            list<PicklistOption> lstSalesWrapperData = new list<PicklistOption> ();
            for(PicklistOption eachField : lstSaleLeaderData[0].salesData){
                if(eachField.isPrecent ){
                    if(eachField.isPrecent1){
                    if(IsQuarter){
                        lstSalesWrapperData.add(new PicklistOption(eachField.label,String.valueOf((mapMonthlyTotalData.get(eachField.label))),true,true));
                    }else{
                        lstSalesWrapperData.add(new PicklistOption(eachField.label,String.valueOf((mapMonthlyTotalData.get(eachField.label))),true,true));
                        
                    }
                    }else{
                        lstSalesWrapperData.add(new PicklistOption(eachField.label,String.valueOf(mapMonthlyTotalData.get(eachField.label)),true,false));
                    }
                    
                }else{
                    
                    lstSalesWrapperData.add(new PicklistOption(eachField.label,String.valueOf(mapMonthlyTotalData.get(eachField.label)),false,false));
                }
                
            }
            MonthlyWrapperData newMonthlyWrapperData = new MonthlyWrapperData('MONTH TOTAL',lstSalesWrapperData);
            lstSaleLeaderData.add(newMonthlyWrapperData);
        }
        system.debug('lstSaleLeaderData :::+'+lstSaleLeaderData);
        return lstSaleLeaderData;
        
    }
    public class MonthlyWrapperData{
        @AuraEnabled
        public String Month;
        @AuraEnabled
        public list<PicklistOption> salesData;
        
        MonthlyWrapperData(String month,list<PicklistOption> salesData ){
            this.Month = month;
            this.salesData = salesData;
        }
    }
    
    public class PicklistOption {
        @AuraEnabled
        public String label;
        @AuraEnabled 
        public String value ='0.00';
        @AuraEnabled 
        public Boolean isPrecent = false;
        @AuraEnabled 
        public Boolean isPrecent1 = false;
        
        public PicklistOption(String label, String value) {
            this.label = label;
            if(value!=null){
                this.value = value;
            }
        }
        public PicklistOption(String label, String value,Boolean isPrecent,Boolean isPrecent1) {
            this.label = label;
            this.isPrecent = isPrecent;
            this.isPrecent1 = isPrecent1;
            if(value!=null){
                this.value = value;
            }
        }
    }
    
    public class ParentWrapper{
        @AuraEnabled
        public List<WrapperData> saleLeaderData;
        @AuraEnabled
        public List<WrapperData> ProcurementLeaderData;
        @AuraEnabled
        public List<MonthlyWrapperData> lstSaleLeaderData;
        @AuraEnabled
        public List<MonthlyWrapperData> lstProcurmentLeaderData;
        ParentWrapper(){
            
        }
        ParentWrapper( List<WrapperData>  saleLeaderData,
                      List<WrapperData>  ProcurementLeaderData,
                      List<MonthlyWrapperData> lstSaleLeaderData,
                      List<MonthlyWrapperData> lstProcurmentLeaderData){
                          this.saleLeaderData = saleLeaderData;
                          this.ProcurementLeaderData = ProcurementLeaderData;
                          this.lstSaleLeaderData = lstSaleLeaderData;
                          this.lstProcurmentLeaderData = lstProcurmentLeaderData;
                          
                      }
    }
    
    //Wrapper to hold Data
    public class WrapperData{
        @AuraEnabled
        public String Month;
        @AuraEnabled
        public decimal gP =0.00;
        @AuraEnabled
        public decimal goal =0.00;
        WrapperData(){
            
        }
        WrapperData(String Month,
                    decimal gP,
                    decimal goal){
                        this.Month = Month;
                        if(gP!=null){
                            this.gP = gP;  
                        }
                        if(goal!=null){
                            this.goal = goal;
                        }
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
}