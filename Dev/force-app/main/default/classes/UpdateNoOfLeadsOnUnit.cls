public class  UpdateNoOfLeadsOnUnit	implements Database.Batchable<sObject> {
	public Database.QueryLocator Start(DataBase.BatchableContext dbc){
        String query ='SELECT id, name, ';
                query +='                     Number_of_Active_leads__c ,Number_of_Closed_leads__c,Number_of_Open_leads__c,CreatedAt__c,';
                     query +='                   (SELECT id,Name,Status,IsConverted,Unit__c FROM Leads__r where IsConverted = true)';
                   query +='      FROM Product2 ';
                      
         return Database.getQueryLocator(query);
    }
    public void Execute (Database.BatchableContext dbc , list<Product2>lstProduct2){
        map<id,list<Lead>> mapOfUnitIdVsListOfOpenLead = new map <id,list<Lead>>();
        map<id,list<Lead>> mapOfUnitIdVsListOfClosedLead = new map <id,list<Lead>>();
        map<id,list<Lead>> mapOfUnitIdVsListOfActiveLead = new map <id,list<Lead>>();
  		system.debug('lstOpportunity:'+lstProduct2);
        if(lstProduct2!=null && !lstProduct2.isEmpty()){
            for(Product2 eachUnit : lstProduct2){
                    if(eachUnit.Leads__r!=null && !eachUnit.Leads__r.isEmpty()){
                        for(lead eachLead : eachUnit.Leads__r){
                            if(eachLead.status != 'Qualified'){
                                if(!mapOfUnitIdVsListOfOpenLead.containsKey(eachLead.Unit__c)){
                                    mapOfUnitIdVsListOfOpenLead.put(eachLead.Unit__c,new list<Lead>());
                                    mapOfUnitIdVsListOfOpenLead.get(eachLead.Unit__c).add(eachLead);
                                }else{
                                    mapOfUnitIdVsListOfOpenLead.get(eachLead.Unit__c).add(eachLead);
                                }
                            }else If(eachLead.status == 'Qualified'){
                                if(!mapOfUnitIdVsListOfClosedLead.containsKey(eachLead.Unit__c)){
                                    mapOfUnitIdVsListOfClosedLead.put(eachLead.Unit__c,new list<Lead>());
                                    mapOfUnitIdVsListOfClosedLead.get(eachLead.Unit__c).add(eachLead);
                                }else{
                                    mapOfUnitIdVsListOfClosedLead.get(eachLead.Unit__c).add(eachLead);
                                }
                            }
                            if(eachLead.Status!='Unqualified' && eachLead.IsConverted !=True){
                               if(!mapOfUnitIdVsListOfActiveLead.containsKey(eachLead.Unit__c)){
                                    mapOfUnitIdVsListOfActiveLead.put(eachLead.Unit__c,new list<Lead>());
                                    mapOfUnitIdVsListOfActiveLead.get(eachLead.Unit__c).add(eachLead);
                                }else{
                                    mapOfUnitIdVsListOfActiveLead.get(eachLead.Unit__c).add(eachLead);
                                } 
                            }
                        }
                        
                    }
                    if(mapOfUnitIdVsListOfActiveLead.get(eachUnit.id)!=null 
                       && !mapOfUnitIdVsListOfActiveLead.get(eachUnit.id).isEmpty()){
                        eachUnit.Number_of_Active_leads__c = mapOfUnitIdVsListOfActiveLead.get(eachUnit.id).size();
                    }
                    if(mapOfUnitIdVsListOfClosedLead.get(eachUnit.id)!=null 
                       && !mapOfUnitIdVsListOfClosedLead.get(eachUnit.id).isEmpty()){
                        eachUnit.Number_of_Closed_leads__c = mapOfUnitIdVsListOfClosedLead.get(eachUnit.id).size();
                    }
                    if(mapOfUnitIdVsListOfOpenLead.get(eachUnit.id)!=null 
                       && !mapOfUnitIdVsListOfOpenLead.get(eachUnit.id).isEmpty()){
                        eachUnit.Number_of_Open_leads__c = mapOfUnitIdVsListOfOpenLead.get(eachUnit.id).size();
                    }
                    
                }
            if(lstProduct2 != null && lstProduct2.size()>0){    
                update lstProduct2;
                
            }
        }
    }
    public void finish(Database.BatchableContext dbc){
    }
}