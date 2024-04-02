public class GetUserMonthlyData {
	@AuraEnabled(cacheable=true)
    public static AuraResponse getMonthlyUser(){
        AuraResponse AuraResponse;
        Id UserId = '0056A000000T8OyQAK';
        List<Monthly_Goal_For_User__c> lstMonthlyGoalForUser = [SELECT ID , Name ,Month__c,User__c, Gross_Profit_Goal__c,Gross_Profit__c 
                                                                FROM Monthly_Goal_For_User__c
                                                                     WHERE User__c =: UserId  ];
        map<String,WrapperData> mapOfMonthVsData = new map<String,WrapperData>();
        for(Monthly_Goal_For_User__c eachMonthlyGoalForUser : lstMonthlyGoalForUser){
            WrapperData newWrapperData = new WrapperData(eachMonthlyGoalForUser.Month__c,
                                                        eachMonthlyGoalForUser.Gross_Profit__c,
                                                        eachMonthlyGoalForUser.Gross_Profit_Goal__c);
            mapOfMonthVsData.put(eachMonthlyGoalForUser.Month__c, newWrapperData);
        }
        //return mapOfMonthVsData;
        
        AuraResponse = new AuraResponse(true,
                                        'SUCCESS',
                                        JSON.serialize(mapOfMonthVsData));
        system.debug('AuraResponse:'+AuraResponse);
        
        return AuraResponse;                                
        
        /*return [SELECT SUM (revenue__c)Revenue , SUM (Gross_Profit__c) GrossProfit,  Month__c Month
                FROM Monthly_Goal_For_User__c GROUP BY Month__c LIMIT 20 ];*/
        //return [SELECT SUM(ExpectedRevenue) expectRevenue, SUM(Amount) amount, StageName stage 
           //    FROM Opportunity WHERE StageName NOT IN ('Closed Won') GROUP BY StageName LIMIT 20];
    }
    //Wrapper to hold Data
    public class ParentWrapperData{
     	@AuraEnabled 
        public String Month ;  
        @AuraEnabled 
        public WrapperData WrapperData ;
        ParentWrapperData(){
            
        }
        ParentWrapperData(String Month, 
                         WrapperData WrapperData){
                        this.Month = Month;
                        this.WrapperData = WrapperData;     
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
        /*WrapperData(WrapperData newWrapperData){
            this.Id = newWrapperData.Id;
            this.Name = newWrapperData.Name;
            this.Month = newWrapperData.Month;
            this.isQuarter = newWrapperData.isQuarter;
            this.gP = newWrapperData.gP; 
            this.goal = newWrapperData.goal;

        }*/
        WrapperData(String Month,
                    decimal gP,
                    decimal goal){
                        this.Month = Month;
                        
                            this.gP = gP;  
                        
                        
                            this.goal = goal;
                        
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