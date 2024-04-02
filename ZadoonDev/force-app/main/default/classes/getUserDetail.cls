public class getUserDetail {
    public static map<String,User> getUserDetails (Map<Id,User>mapOfUserIdVsUser){
       	map<String, User> mapOfUserNameVsUser = new map<String,User>();
        if(mapOfUserIdVsUser.Values()!=null && !mapOfUserIdVsUser.Values().IsEmpty()){
            for(user EachUser : mapOfUserIdVsUser.Values() ){
                mapOfUserNameVsUser.put(EachUser.Name,EachUser); 
                
            }
        }
        return mapOfUserNameVsUser;
    }
}