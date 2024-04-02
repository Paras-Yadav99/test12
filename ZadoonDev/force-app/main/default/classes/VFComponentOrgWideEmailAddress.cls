public class VFComponentOrgWideEmailAddress {
 
    
     public String thisOWASender {get;set;}

    //get the zids into the list
    public String getThisOWA() {
        
        List<String> exploded = thisOWASender.split(';', 0);
        
        
        
        return exploded[5];   
       
    }
}