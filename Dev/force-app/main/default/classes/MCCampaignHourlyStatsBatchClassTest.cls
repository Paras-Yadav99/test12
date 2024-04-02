@isTest
public class MCCampaignHourlyStatsBatchClassTest {
    @istest	static void testMCCampainHourlyStatsBatch (){
    	list<MC4SF__MC_Campaign__c> LstOfMCCampaignRecords = testDataFactory.lstCampaign(1);
       	insert LstOfMCCampaignRecords;
        list<MC4SF__MC_Campaign_Hourly_Stats__c> lstOfRecordInserted =
            testDataFactory.noOfMCCampaignToCreate(900,LstOfMCCampaignRecords[0].id);
        
        insert lstOfRecordInserted;
        
        Datetime twentyDaysOld = Datetime.now().addDays(-20);
		Test.setCreatedDate(lstOfRecordInserted[0].id, twentyDaysOld);
        
        test.startTest();
        	String sch = '0 0 23 * * ?'; 
        	system.schedule('MCCampaignHourlyStats scheduler', sch, new scheduleMCcampaignStatsBatchClass());
        
        test.stopTest();
        
    }
}