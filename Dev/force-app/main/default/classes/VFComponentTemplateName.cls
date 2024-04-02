public class VFComponentTemplateName {

    public String thisTemplateString {get;set;}

    //get the zids into the list
    public String getThisTemplate() {
        
        List<String> exploded = thisTemplateString.split(';', 0);
        
        
        
        return exploded[11];   
       
    }
    
}