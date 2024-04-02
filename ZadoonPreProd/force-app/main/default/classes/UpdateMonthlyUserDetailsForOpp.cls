public class UpdateMonthlyUserDetailsForOpp implements Database.Batchable<sObject>, Database.Stateful  {
	public map<String,id> mapOfRecordTypeDeveloperNameVsId = new map<String,id>(); 
    public list<Monthly_Goal_For_User__c>lstMonthlyGoalForUser = new list<Monthly_Goal_For_User__c>();
    public boolean YearlyData1;
    public integer year1;
    
    public UpdateMonthlyUserDetailsForOpp(boolean YearlyData,integer year) {
        YearlyData1 = YearlyData;
        year1 = year;
        system.debug('YearlyData1'+YearlyData);
        system.debug('YearlyData1'+YearlyData1);
       // boolean YearlyData ;
        //map<String,id> mapOfRecordTypeDeveloperNameVsId = new map<String,id>();
        list<RecordType> lstRecordType =[SELECT Id, Name, DeveloperName, SobjectType, IsActive 
                                         FROM RecordType 
                                         WHERE SobjectType = 'Opportunity'];
        
        if(lstRecordType!=null && !lstRecordType.isEmpty()){
            for(RecordType eachRecordType : lstRecordType){
                mapOfRecordTypeDeveloperNameVsId.put(eachRecordType.DeveloperName,eachRecordType.Id);
            }
        }
        //integer year = system.today().year();
        string monthlyUserQuery = 'SELECT Id, User__c, Units_Purchased__c, Owned_Units_Purchase_Age__c, Units_Brokered__c, Units_Added__c,';
        monthlyUserQuery += ' Total_Units_Purchared_or_Brokered__c, Total_Actual_Gross_Profit_Procured__c,Number_of_Won_Sales_Opps__c, ';       
        monthlyUserQuery += ' Realized_Gross_Profit_Owned_Units__c,Realized_Gross_Profit_Brokered_Units__c,Number_of_New_Sales_Opps__c, ';
        monthlyUserQuery += ' Potential_Gross_Profit_Owned_Units__c ,Year__c,Month__c,Cost_of_Goods__c ';
        monthlyUserQuery += ' FROM Monthly_Goal_For_User__c ';
        if(YearlyData1){
            monthlyUserQuery += ' WHERE Year__c != ' +year1 ;
        }else{
         monthlyUserQuery += 'WHERE Year__c ='+year1 ;
        }
        system.debug('monthlyUserQuery'+monthlyUserQuery);
        lstMonthlyGoalForUser = database.query(monthlyUserQuery);
        /*lstMonthlyGoalForUser = [SELECT Id, User__c, Units_Purchased__c, Owned_Units_Purchase_Age__c, Units_Brokered__c, Units_Added__c, 
                                                             Total_Units_Purchared_or_Brokered__c, Total_Actual_Gross_Profit_Procured__c, 
                                                             Realized_Gross_Profit_Owned_Units__c,Realized_Gross_Profit_Brokered_Units__c, 
                                                             Potential_Gross_Profit_Owned_Units__c ,Year__c,Month__c,Cost_of_Goods__c
                                                             FROM Monthly_Goal_For_User__c WHERE Year__c =: system.today().year()]; */
        system.debug('lstMonthlyGoalForUser'+lstMonthlyGoalForUser.size());
        if(lstMonthlyGoalForUser!=null && !lstMonthlyGoalForUser.isEmpty()){
            for(Monthly_Goal_For_User__c eachMonthlyGoalForUser : lstMonthlyGoalForUser){
                eachMonthlyGoalForUser.Revenue__c = 0;
                eachMonthlyGoalForUser.Deals_Closed__c  = 0;
                eachMonthlyGoalForUser.Gross_Profit__c = 0;
                eachMonthlyGoalForUser.Realized_Gross_Profit_Owned_Units__c = 0;
                eachMonthlyGoalForUser.Realized_Gross_Profit_Brokered_Units__c = 0;
                eachMonthlyGoalForUser.Units_Brokered__c = 0;
                
                //eachMonthlyGoalForUser.POs_Created__c = 0;
                
                eachMonthlyGoalForUser.Cost_of_Goods__c = 0;
                eachMonthlyGoalForUser.Unit_Owned__c = 0;
                eachMonthlyGoalForUser.Units_Added__c  = 0;
                eachMonthlyGoalForUser.Units_Purchased__c = 0;
                eachMonthlyGoalForUser.Potential_Gross_Profit_Owned_Units__c = 0;
                eachMonthlyGoalForUser.Owned_Units_Purchase_Age__c = 0;
                eachMonthlyGoalForUser.POs_Created__c = 0;
            }
            
        }
    }
    		
    public Database.QueryLocator Start(DataBase.BatchableContext dbc){
        String query ='SELECT Id,ForecastCategoryName,Pro_Forma_Shipping_Cost__c, ';
               query += ' Pro_Forma_Price_Sent__c,Port_ready_fee_intl_port_freight_only__c,OwnerId,CreatedDate,  ';
               query += ' CloseDate,Zadoon_s_Final_Sale_Price__c,Total_Cost__c ,Amount,RecordTypeId, ';
               query += ' Product__r.Unit_Owner__c, Product__r.Inventory_Status__c,Product__r.CreatedAt__c ';
               query += ' FROM Opportunity ';
        
        if(YearlyData1){
            query += ' WHERE ( CloseDate!= null AND CALENDAR_YEAR(CloseDate) >= 2020 AND CALENDAR_YEAR(CloseDate) < ' +year1 +' ) ';
            query += ' OR  ( Product__r.CreatedAt__c!= null AND CALENDAR_YEAR(Product__r.CreatedAt__c) >= 2020 AND CALENDAR_YEAR(Product__r.CreatedAt__c) < ' +year1 +' ) ';
           
        }else{
           query += ' WHERE CALENDAR_YEAR(CloseDate) = ' +year1 +' OR CALENDAR_YEAR(Product__r.CreatedAt__c) =' +year1 + 'OR CALENDAR_YEAR(CreatedDate) = ' +year1 ; 
        }
        
        return Database.getQueryLocator(query);
    }
    public void Execute (Database.BatchableContext dbc , list<Opportunity>lstOpportunity){
  		system.debug('lstOpportunity:'+lstOpportunity);
        if(lstOpportunity!=null && !lstOpportunity.isEmpty() && lstMonthlyGoalForUser!=null && !lstMonthlyGoalForUser.isEmpty()){
        	UpdateMonthlyUserDetailsForOppController.updateMonthUserDetails(lstOpportunity,lstMonthlyGoalForUser,mapOfRecordTypeDeveloperNameVsId);
        }
    }
    public void finish(Database.BatchableContext dbc){
        if(lstMonthlyGoalForUser!=null && !lstMonthlyGoalForUser.isEmpty()){
            system.debug('lstMonthlyGoalForUser'+lstMonthlyGoalForUser);
            UpdateMonthLyUserDetailsForUnit batchInstance = NEW UpdateMonthLyUserDetailsForUnit(YearlyData1,year1,lstMonthlyGoalForUser);
            DataBase.executeBatch(batchInstance, 200);
            //update lstMonthlyGoalForUser;
        }
        
       
    }

}