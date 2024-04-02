public class VFComponentContactName {

    public String thisContactString {get;set;}

    //get the zids into the list
    public String getThisContact() {
        
        List<String> exploded = thisContactString.split(';', 0);
        
        
        
        return exploded[3];   
       
    }
    
}