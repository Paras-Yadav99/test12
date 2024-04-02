public class VFComponentAccountName {

    public String thisAccountString {get;set;}

    //get the zids into the list
    public String getThisAccount() {
        
        List<String> exploded = thisAccountString.split(';', 0);
        
        
        
        return exploded[1];   
       
    }
    
}