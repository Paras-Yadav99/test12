public class EquipmentRelatedListBaseMatches {     

    public List<equipment__c> baseMatches{get;set;} 

    public equipment__c equip {get;set;} 

    public equipment__c base {get;set;} 

     

    //Constructor 

    public EquipmentRelatedListBaseMatches(ApexPages.StandardController controller) { 

        equip = (equipment__c)controller.getRecord();      

        base = [SELECT id,  Base_New__c FROM equipment__c WHERE id= :equip.id LIMIT 1]; 

        baseMatches = [SELECT id,Base_New__c, Name, Number_of_Active_ZIDs__c, Number_of_Iron_Demands__c FROM equipment__c WHERE Base_New__c = :base.Base_New__c ORDER BY Name];     

    } 


}