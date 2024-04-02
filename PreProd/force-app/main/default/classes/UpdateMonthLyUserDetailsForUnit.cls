public class UpdateMonthLyUserDetailsForUnit implements Database.Batchable<sObject>, Database.Stateful  { 
	public list<Monthly_Goal_For_User__c>lstMonthlyGoalForUser = new list<Monthly_Goal_For_User__c>();
    public boolean YearlyData1;
    public integer year1;
    string RecTypeProcurement = system.label.Opp_Rec_type_Dev_Name_procurement_opp; 
        RecordType ProcurementRecordType =[SELECT Id, Name, DeveloperName, SobjectType, IsActive 
                                         FROM RecordType 
                                         WHERE DeveloperName =: RecTypeProcurement LIMIT 1];
    public UpdateMonthLyUserDetailsForUnit(boolean YearlyData, integer year,list<Monthly_Goal_For_User__c>lstMonthlyGoalForUser1) {
        //integer year = system.today().year();
        YearlyData1 = YearlyData;
        year1 = year;
        lstMonthlyGoalForUser = lstMonthlyGoalForUser1;
        /*string monthlyUserQuery = 'SELECT Id, User__c, Units_Purchased__c, Owned_Units_Purchase_Age__c, Units_Brokered__c, Units_Added__c,';
        monthlyUserQuery += 'Total_Units_Purchared_or_Brokered__c, Total_Actual_Gross_Profit_Procured__c, ';       
        monthlyUserQuery += 'Realized_Gross_Profit_Owned_Units__c,Realized_Gross_Profit_Brokered_Units__c, ';
        monthlyUserQuery += 'Potential_Gross_Profit_Owned_Units__c ,Year__c,Month__c,Cost_of_Goods__c ';
        monthlyUserQuery += 'FROM Monthly_Goal_For_User__c ';
        if(YearlyData1){
            monthlyUserQuery += ' WHERE Year__c != ' +year ;
        }else{
         monthlyUserQuery += 'WHERE Year__c ='+year ;
        }
        lstMonthlyGoalForUser = database.query(monthlyUserQuery);*/
        /*lstMonthlyGoalForUser = [SELECT Id, User__c, Units_Purchased__c, Owned_Units_Purchase_Age__c, Units_Brokered__c, Units_Added__c, 
                                 Total_Units_Purchared_or_Brokered__c, Total_Actual_Gross_Profit_Procured__c, 
                                 Realized_Gross_Profit_Owned_Units__c,Realized_Gross_Profit_Brokered_Units__c, POs_Created__c,
                                 Potential_Gross_Profit_Owned_Units__c ,Year__c,Month__c,Cost_of_Goods__c,Unit_Owned__c
                                 FROM Monthly_Goal_For_User__c WHERE Year__c =: system.today().year()]; */
        /*if(lstMonthlyGoalForUser!=null && !lstMonthlyGoalForUser.isEmpty()){
            for(Monthly_Goal_For_User__c eachMonthlyGoalForUser : lstMonthlyGoalForUser){
                eachMonthlyGoalForUser.Cost_of_Goods__c = 0;
                eachMonthlyGoalForUser.Unit_Owned__c = 0;
                eachMonthlyGoalForUser.Units_Added__c  = 0;
                eachMonthlyGoalForUser.Units_Purchased__c = 0;
                eachMonthlyGoalForUser.Potential_Gross_Profit_Owned_Units__c = 0;
                eachMonthlyGoalForUser.Owned_Units_Purchase_Age__c = 0;
                eachMonthlyGoalForUser.POs_Created__c = 0;
                
            }
            
        }*/
    }
    public Database.QueryLocator Start(DataBase.BatchableContext dbc){
        
        String query ='SELECT Id, Account__c, Account__r.Name,CreatedAt__c,Unit_Purchase_Age__c,Purchase_Date__c, ';
            query +=' Potential_Gross_Profit__c,Inventory_Status__c,Zadoon_s_Final_Purchase_Price__c, ';
            query +=' Unit_Owner__c, Sold_Deactivated_Date__c,IsActive,Days_to_Turn__c ';
            
        if(ProcurementRecordType!=null){
           query += ' ,(SELECT id,name,recordTypeid FROM Opportunities__r  where recordTypeid =' + '\''+ ProcurementRecordType.id + '\'' +')';  
        }
        
            query +=' FROM Product2 WHERE Unit_Owner__c != null AND ';
        if(YearlyData1){
            query +='( ( Purchase_Date__c!= null AND CALENDAR_YEAR(Purchase_Date__c) >= 2020 AND Purchase_Date__c < THIS_YEAR ) ';
            query +=' OR ( CreatedAt__c!= null AND CALENDAR_YEAR(CreatedAt__c) >= 2020 AND CreatedAt__c < THIS_YEAR ) ';
            query +=' OR ( Sold_Deactivated_Date__c!= null AND CALENDAR_YEAR(Sold_Deactivated_Date__c) >= 2020 AND Sold_Deactivated_Date__c < THIS_YEAR ) ) ';
        }else{
            query +='( CALENDAR_YEAR(Purchase_Date__c) = ' +year1 ;
            query +=' OR CALENDAR_YEAR(CreatedAt__c) =' +year1 + 'OR  CALENDAR_YEAR(Sold_Deactivated_Date__c) =' + year1 +' ) ';
        }
        return Database.getQueryLocator(query);
    }
    public void Execute (Database.BatchableContext dbc , list<Product2>lstUnit){
  		system.debug('lstUnit:'+lstUnit);
        if(lstUnit!=null && !lstUnit.isEmpty()){
        	UpdateMonthlyUserDetailForUnitController.updateMonthUserDetails(lstUnit,lstMonthlyGoalForUser);
        }
    }
    public void finish(Database.BatchableContext dbc){
        if(lstMonthlyGoalForUser!=null && !lstMonthlyGoalForUser.isEmpty()){
            system.debug('lstMonthlyGoalForUser'+lstMonthlyGoalForUser);
            update lstMonthlyGoalForUser;
        }
    }
}