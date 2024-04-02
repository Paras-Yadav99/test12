global class DailyIronDemandMatchingEmail4Scheduled implements Schedulable {

    global void execute(SchedulableContext ctx){
        DailyIronDemandMatchingEmail4 be = new DailyIronDemandMatchingEmail4();
        be.DailyIronDemandMatchingEmail_Production = true;
        database.executeBatch(be, 1000);
    }
}