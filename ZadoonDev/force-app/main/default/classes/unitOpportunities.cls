public with sharing class unitOpportunities{
    
    private Product2 prod {get; set;}
    public String equipmentId {get; private set;}
    //Read only list of opportunities for VF display
    public List<Opportunity> opportunities {get; private set;}
    public List<Equipment__c> equipment  { get; private set; }
    
    //Extension constructor
    public unitOpportunities(ApexPages.StandardController sc){
        Map<String,String> recIdsMap = apexPages.currentPage().getParameters(); 
        system.debug('recIdsMap: '+recIdsMap);
        if(recIdsMap.containsKey(label.Lookup_Id)){
            equipmentId = recIdsMap.get(label.Lookup_Id);
            List< String > equipmentFields = UtilityClass.getAllFields('Equipment__c');
            String query = 'Select '+String.join(equipmentFields, ',')+' From Equipment__c WHERE Id =:equipmentId';
            equipment = database.query(query);
            system.debug('equipment ===>'+equipment);
        } else if (recIdsMap.containsKey('id')) {
            equipmentId = recIdsMap.get('id');
        }
        system.debug('equipmentId====>'+equipmentId);
        
        prod = (Product2)sc.getRecord();
        opportunities = new List<Opportunity>();
        for(OpportunityLineItem oli : 
            [Select 
             Opportunity.Name, Opportunity.StageName, Product2Id, TotalPrice, Opportunity.Account.Name 
             From
             OpportunityLineItem 
             Where
             PriceBookEntry.Product2Id = :prod.Id]){
                 opportunities.add(oli.Opportunity);
             }
        
    }
    
    
    // Added by Akhtar Husain on 19-11-2020 to send emails
    public pageReference sendEmail(){
        pagereference ref =new pagereference('/apex/sendEmailUnitPage?id='+prod.id);
        ref.setredirect(true);
        return ref;
    }
    
    // Added by Akhtar Husain to clone the unit.
    public pageReference cloneApex() {
        system.debug('prod--->'+prod);
        try {
            Product2 cloneUnit = prod.clone(false, false, false, false);
            insert cloneUnit;
            system.debug('cloneUnit--->'+cloneUnit);
            pagereference ref =new pagereference('/'+cloneUnit.id);
            ref.setredirect(true);
            return ref;
        } catch ( Exception e ) {
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,e.getMessage()+' at line '+e.getLineNumber()));
        }
        return null;
    }
    
}