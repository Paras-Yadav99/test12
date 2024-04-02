public class thisMassEmailEquipmentNeed {

    public Id thisEquipment {get;set;}
 
    //a list to hold this opps zids
    public List<Equipment__c> thisEquipmentZids = new List<Equipment__c>();
   
    
    //get the zids into the list
    public List<Equipment__c> getthisEquipmentZids() {
          
        List<Equipment__c> thisEquipmentZids = new List<Equipment__c>();
        
        thisEquipmentZids = [Select Name, model__c FROM Equipment__c 
                        WHERE Id = :thisEquipment];
         
        
        return thisEquipmentZids;   
       
        
    }
    
}