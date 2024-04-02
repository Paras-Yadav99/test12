public class VFComponentContactType {

    public String thisContactTypeString {get;set;}

    //get the zids into the list
    public String getThisContactType() {
        
        List<String> exploded = thisContactTypeString.split(';', 0);
        
        
        
        return exploded[7];   
       
    }
    
}