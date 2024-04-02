global class emailUnitContactIronDemand {
 	public static set<String> SetOfForecastCategory;
    public static map<Id,list<Opportunity>>MapOfContactIdVsOpportunity;
    
   WebService static list<string> EmailMethod(list<Id> UnitId) {
        list<string> message = new list<string>();
        system.debug('UnitId::'+UnitId[0]);
        try{
            
            EmailTemplate templateId = [Select id from EmailTemplate where name = 'Z2 Unit to Iron Demand Contact Email'];
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
           
            
            Product2 equipmentID = [SELECT equipment__c FROM Product2 WHERE ID = :UnitId[0]];
            System.debug('equipmentID' + equipmentID);
            
            List<Contact> clist = [SELECT Id FROM Contact WHERE Id IN (SELECT IronDemand_Contact__c FROM Iron_Demand__c 
                                                                       WHERE IronDemand_Iron__c = :equipmentID.equipment__c 
                                                                       AND IsActive__c = TRUE
                                                                       )];
            string ForecastCategoryValues = System.Label.Forecast_Category_For_Matching_Email;
            if(string.isNotBlank(ForecastCategoryValues)){
                list<String> lstString = ForecastCategoryValues.split(',');
                SetOfForecastCategory = new set<string>();
                SetOfForecastCategory.addAll(lstString);
              	system.debug('SetOfForecastCategory'+SetOfForecastCategory);  
            }
            System.debug('UnitID' + UnitId[0]);
            System.debug('c' + clist);
            list<Opportunity> lstOpportunity = [SELECT id,
                                                stageName,ForecastCategoryName,
                                                Buyer_Primary_Contact__c
                                                FROM Opportunity 
                                                WHERE ForecastCategoryName IN : SetOfForecastCategory AND 
                                               	Product__c =: UnitId[0] AND 
                                               	Buyer_Primary_Contact__c!=null];
            system.debug('lstOpportunity'+lstOpportunity);
            MapOfContactIdVsOpportunity = new map<id,list<Opportunity>>();
            /*if(lstOpportunity==null && lstOpportunity.isEmpty()){
                message='List of Opportunity is Null';
            }*/
            if(lstOpportunity!=null && !lstOpportunity.isEmpty()){
                for(opportunity eachOpportunity : lstOpportunity){
                    if(!MapOfContactIdVsOpportunity.containsKey(eachOpportunity.Buyer_Primary_Contact__c)){
                        MapOfContactIdVsOpportunity.put(eachOpportunity.Buyer_Primary_Contact__c, new list<Opportunity>{eachOpportunity});
                    }else{
                        MapOfContactIdVsOpportunity.get(eachOpportunity.Buyer_Primary_Contact__c).add(eachOpportunity);
                    }
                }
            }
            
            system.debug('MapOfContactIdVsOpportunity'+MapOfContactIdVsOpportunity);
            
            	for(contact con : clist)
                {
                    if(MapOfContactIdVsOpportunity.containsKey(con.id)){
                        system.debug('MapOfContactIdVsOpportunity.get(con.id)'+MapOfContactIdVsOpportunity.get(con.id));
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTemplateID(templateId.Id); 
                        mail.setTargetObjectId(con.Id);
                        mail.setWhatId(UnitId[0]);
                        system.debug('mail.setWhatId(UnitId)'+UnitId[0]);
                        system.debug('con'+con);
                        system.debug('con.id'+con.id);
                        mail.setSaveAsActivity(true);
                        mail.setUseSignature(false);
                        allmsg.add(mail);
                        System.debug('mail '+mail);
                    }
                }
            if(allmsg!=null && !allmsg.isEmpty()){
                Messaging.sendEmail(allmsg,false);
                 message.add('Message Send Successfully.');
            }else{
                message.add('Error occur.');
            }
        }catch (Exception e) {
            system.debug('e.getMessage()'+e.getMessage());
            message.add('Error :'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        return message;
    }
    
    /*public class message {
        @InvocableVariable public String Message;
        
        public message(String Message) {
            this.Message = Message;
            
        }
    }*/
   
 
}