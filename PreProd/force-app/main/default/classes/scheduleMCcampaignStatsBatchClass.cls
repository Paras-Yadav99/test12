global class scheduleMCcampaignStatsBatchClass implements Schedulable {
	global void execute(SchedulableContext ctx) {
	  	MCCampaignHourlyStatsBatchClass scheduleMCCampaign = new MCCampaignHourlyStatsBatchClass();
		database.executebatch(scheduleMCCampaign);
    }
}