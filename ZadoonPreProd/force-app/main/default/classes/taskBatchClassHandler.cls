public class taskBatchClassHandler {
     
    public static void run(list<task>totaltaskToDelete){
        list<id> taskNotDeleted = new list<id>();
		if(totaltaskToDelete!=null && !totaltaskToDelete.isEmpty()){
            Database.DeleteResult[] taskToDelete = Database.delete(totaltaskToDelete,false);
            for(Database.DeleteResult eachDeleteResult :taskToDelete){
                if(!eachDeleteResult.isSuccess()){
                    taskNotDeleted.add(eachDeleteResult.getId());
                }
            }
   		}
   }
}