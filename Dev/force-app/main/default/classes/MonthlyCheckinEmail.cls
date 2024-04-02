global class MonthlyCheckinEmail Implements Schedulable  {

    public Set<String> EmailString;

    public boolean MonthlyCheckinEmail_Production {get; set;}
    public Date startdt;
    public Date enddt;
    public Map<Id, String> AccountName = new Map<Id, String>();
    public Map<Id, String> ContactName = new Map<Id, String>(); 
    public Map<Id, String> ClientType = new Map<Id, String>();
    public Map<Id, String> ClientRegion = new Map<Id, String>(); 
    public Map<String, Id> Templates = new Map<String, Id>(); 
    public Map<Id, String> ClientTemplate = new Map<Id, String>();
    
    public String OWASender; 
    public Integer isTest = 0;
    
    public boolean display{get; set;}
    
    global void execute(SchedulableContext sc) {
    
        MonthlyCheckinEmail_Production = true;
        startdt = null;
        enddt = null;
        GetMonthlyCheckinEmail();

    }
    
    public MonthlyCheckinEmail() {
         display = false;
    }
    
    Public PageReference GetRecordPage(){
    
        display = true;
        MonthlyCheckinEmail_Production = false;
        GetMonthlyCheckinEmail();
    
       return null;   
    }
    
    
    Public List<Messaging.SingleEmailMessage> GetMonthlyCheckinEmail(){
    
        EmailString =  new Set<String>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
    
        Set<Id> clist = new Set<Id>();

        
        if(startdt == null)
            startdt = date.newinstance(System.Today().Year(),System.Today().Month(),1);
        if(enddt == null)
            enddt = date.newinstance(System.Today().Year(),System.Today().Month(), System.Today().Day());
            
        date todayDate = system.today();
        Integer month = todayDate.month();

         
        Date tempdate = null;
        
        Integer i = Math.mod((date.newinstance(1985, 6, 24)).daysBetween(startdt),7); // 24/6/85 was a monday
        Map<Integer, Map<Integer, Integer>> m = new Map<Integer, Map<Integer, Integer>> {
        0 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 4 , 4 => 5 , 5 => 5 , 6 => 5 },
        1 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 4 , 4 => 4 , 5 => 4 , 6 => 5 },
        2 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 3 , 4 => 3 , 5 => 4 , 6 => 5 },
        3 => new Map<Integer, Integer> { 1 => 2 , 2 => 2 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },
        4 => new Map<Integer, Integer> { 1 => 1 , 2 => 1 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },
        5 => new Map<Integer, Integer> { 1 => 0 , 2 => 1 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },
        6 => new Map<Integer, Integer> { 1 => 1 , 2 => 2 , 3 => 3 , 4 => 4 , 5 => 5 , 6 => 5 }
        };
        Integer i2 = Math.mod((startdt.daysBetween(enddt)),7);
        Integer i3 = (m.get(i)).get(i2);
        if (i2 == null || i2 < 1 || i2 > 6) {
            if (i >= 0 && i <= 4) { i3 = 1; } 
            else  { i3 = 0; }
         }
        i3 = i3 + 5 * (Math.floor( ((Decimal) startdt.daysBetween(enddt)).divide(7,4))).intValue(); 
        if (tempdate != null) i3 *= -1; // negative number of days
    
        String [] firstLetters = new List<String>();
    
        if(i3 == 1) {
          firstLetters.add('A');
        }
        else if (i3 == 2) {
          firstLetters.add('B');
        }      
        else if (i3 == 3) {
          firstLetters.add('C');
        }      
        else if (i3 == 4) {
          firstLetters.add('D');
        }      
        else if (i3 == 5) {
          firstLetters.add('E');
        }      
        else if (i3 == 6) {
          firstLetters.add('F');
        }      
        else if (i3 == 7) {
          firstLetters.add('G');
        }      
        else if (i3 == 8) {
          firstLetters.add('H');
        }      
        else if (i3 == 9) {
          firstLetters.add('I');
          firstLetters.add('K');
        }      
        else if (i3 == 10) {
          firstLetters.add('J');
        }      
        else if (i3 == 11) {
          firstLetters.add('L');
        }      
        else if (i3 == 12) {
          firstLetters.add('M');
        }      
        else if (i3 == 13) {
          firstLetters.add('N');
          firstLetters.add('W');      
        }      
        else if (i3 == 14) {
          firstLetters.add('O');
          firstLetters.add('V');
          firstLetters.add('Q');      
        }      
        else if (i3 == 15) {
          firstLetters.add('P');
        }      
        else if (i3 == 16) {
          firstLetters.add('R');
        }      
        else if (i3 == 17) {
          firstLetters.add('S');
        }      
        else if (i3 == 18) {
          firstLetters.add('T');
        }      
        else if (i3 == 19) {
          firstLetters.add('U');
        }      
        else if (i3 == 20)  {
          firstLetters.add('X');
          firstLetters.add('Y');
          firstLetters.add('Z');
          firstLetters.add('1');
          firstLetters.add('2');
          firstLetters.add('3');
          firstLetters.add('4');
          firstLetters.add('5');
          firstLetters.add('6');
          firstLetters.add('7');
          firstLetters.add('8');
          firstLetters.add('9');
          firstLetters.add('10');
          
      }
      
      System.debug('******firstLetters*****' + firstLetters );
      if(isTest == 0 && (i3 >= 1 && i3 <= 20)) {
                  
          /* find accounts with units older than 30 days */
          for(List<Contact> AccountContacts : [
                SELECT 
                    Id, Name, Account.Name, Account.Id, Account.Client_Type__c, Account.Client_Region__c
                FROM 
                    Contact 
                WHERE Account_First_Letter__c IN :firstLetters AND 
                    Account.Not_A_Client_We_Want_To_Do_Business_With__c = FALSE AND 
                    Client_Email_Opt_Out__c = FALSE]) 
           {
           
           
               for(Contact AccountContact : AccountContacts) {
                   clist.add(AccountContact.Id);
                   AccountName.put(AccountContact.Id, AccountContact.Account.Name);
                   ContactName.put(AccountContact.Id, AccountContact.Name);
                   ClientRegion.put(AccountContact.Id, AccountContact.Account.Client_Region__c);
                   ClientType.put(AccountContact.Id, AccountContact.Account.Client_Type__c);
    
               }
           
           }
                        

            for(List<EmailTemplate> templateIds : [Select id, Name, DeveloperName from EmailTemplate]) {
               for(EmailTemplate templatevar : templateIds) {
                   Templates.put(templatevar.DeveloperName, templatevar.id);
               }
            }
    
                  
            // Use Organization Wide Address  
            id owaid;
            for(OrgWideEmailAddress owa : [select id, DisplayName, Address from OrgWideEmailAddress WHERE Address LIKE '%collin%']) {
            if(owa.DisplayName.contains('Collin'))  owaid = owa.id; OWASender = owa.DisplayName + '<' + owa.Address + '>'; }       
                  
            for(Id cID:clist) {
                
                
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
               
                mail.setTargetObjectId(cID);
                mail.setSaveAsActivity(true);
                mail.setReplyTo('collin@zadoon.com');
                mail.setOrgWideEmailAddressId(owaid);
                
                if(ClientType.get(cID) == 'Manufacturer Dealer' || ClientType.get(cID) == 'Dealer' || ClientType.get(cID) == 'Rental Company') {
                    mail.setTemplateID(Templates.get('Checkin_Email_Monthly_Man_Dealers')); 
                    ClientTemplate.put(cID, 'Checkin Email Monthly Manufacturer Dealers');
                }
                /* else if ( ClientType.get(cID).Contains('End User'))  */
                else if ((ClientRegion.get(cID) == 'U.S. / Canada' || ClientRegion.get(cID) == 'U.S.' || ClientRegion.get(cID) == 'Canada' || ClientRegion.get(cID) == null)  && ClientType.get(cID) == 'End User' && 
                          (month == 3 || month == 6 || month == 9 || month == 12))  {   
                    mail.setTemplateID(Templates.get('Checkin_Email_Monthly'));
                    ClientTemplate.put(cID, 'Checkin Email Monthly');
                }
                    
                else if ( !(ClientRegion.get(cID) == 'U.S. / Canada' || ClientRegion.get(cID) == 'U.S.'  || ClientRegion.get(cID) == 'Canada' || ClientRegion.get(cID) == null) && (ClientType.get(cID) == 'End User' || 
                            ClientType.get(cID) == 'Equipment Seller' || ClientType.get(cID) == 'Rental Company') ) {
                    mail.setTemplateID(Templates.get('Checkin_Email_Monthly_Intl_Buyers'));            
                    ClientTemplate.put(cID, 'Checkin Email Monthly International Buyer');
                }
                
                else if ( (ClientRegion.get(cID) == 'U.S. / Canada' || ClientRegion.get(cID) == 'U.S.' || ClientRegion.get(cID) == 'Canada'  || ClientRegion.get(cID) == null) && 
                    (ClientType.get(cID) == 'Equipment Seller') ) {
                    mail.setTemplateID(Templates.get('Checkin_Email_Monthly_Man_Dealers'));            
                    ClientTemplate.put(cID, 'Checkin Email Monthly Manufacturer Dealers');
                }


                
                
                if(!String.isBlank(mail.getTemplateID())) {
                    mail.setReferences('Account;' + AccountName.get(cID) + ';ContactName;' + ContactName.get(cID) + ';OWASender;' + OWASender + ';ClientType;' + ClientType.get(cID) + ';ClientRegion;' + ClientRegion.get(cID) + ';Email Template Name;' + ClientTemplate.get(cID) );

                    allmsg.add(mail);
                }    
                    
                System.debug('mail '+mail);
          
            }
                
            
            
            
            if(MonthlyCheckinEmail_Production == true)
                Messaging.sendEmail(allmsg,false); 
        }
            
        return allmsg;
        
    }
}