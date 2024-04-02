public class VFEmailSignature {

    public String thisUserFirstName {get;set;}
    
    //get the zids into the list
    public List<User> getThisUserInfo() {
        
        String filterstring = '%' + thisUserFirstName + '%'; 
       
        List<User> thisUserInfo =  [
            Select FirstName, LastName, Name, MobilePhone, Title 
            From User 
            WHERE Name Like :filterstring
            Limit 1
            
            ];  
        return thisUserInfo;    
       
       
    }
    
}