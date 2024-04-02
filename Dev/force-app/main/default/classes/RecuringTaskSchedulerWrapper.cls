public class RecuringTaskSchedulerWrapper {
    public String ObjectAPIName;
    public String TaskcheckinsAPIName;
    public String Date_Field_API_Name;
    public String Task_Subject;
    public String Task_Description;
    public String Additional_Fields;
    public String Assigned_To_ID;
    //public String TaskcheckinsAPIName;
    
    public RecuringTaskSchedulerWrapper(String ObjectAPIName, String TaskcheckinsAPIName, String Date_Field_API_Name,
                                        String Task_Subject, String Task_Description, String Additional_Fields,
                                       String Assigned_To_ID) {
                                            this.ObjectAPIName = ObjectAPIName;
                                            this.TaskcheckinsAPIName = TaskcheckinsAPIName;
                                            this.Date_Field_API_Name = Date_Field_API_Name;
                                            this.Task_Subject = Task_Subject;
                                            this.Task_Description = Task_Description;
                                            this.Additional_Fields = Additional_Fields;
                                            this.Assigned_To_ID = Assigned_To_ID;
                                        }
}