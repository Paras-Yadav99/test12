public class VFComponentContactRegion {

    public String thisContactRegionString {get;set;}

    //get the zids into the list
    public String getThisContactRegion() {
        
        List<String> exploded = thisContactRegionString.split(';', 0);
        
        
        
        return exploded[9];   
       
    }
    
}