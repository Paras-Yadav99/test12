public class emailUnitContactIronDemandInvoc {
    @InvocableMethod(label=' Email Method' description='Send Email' category='Email')
    public static List<message> EmailMethod(list<Id> UnitId) {
        //String recId;
        list<message> lstmessage = new list<message>();
        List<String> lstString = emailUnitContactIronDemand.EmailMethod(UnitId);
        if(lstString!=null && ! lstString.IsEmpty()){
            for(string eachString : lstString){
                lstmessage.add(new message(eachString));
            }
        }
        return lstmessage;
    }
    public class message {
        @InvocableVariable public String Message;
        
        public message(String Message) {
            this.Message = Message;
            
        }
    }
    

}