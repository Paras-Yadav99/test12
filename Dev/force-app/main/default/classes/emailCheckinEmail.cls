global class emailCheckinEmail Implements Schedulable {

    global void execute(SchedulableContext sc) {
        Date startdt = date.newinstance(2017, 7, 1);
        Date enddt = date.newinstance(2017, 7, 13);
        
        EmailCheckinMethod(startdt, enddt, 0);
    }


    Webservice static void EmailCheckinMethod(Date startdt, Date enddt, Integer isTest ) {
     /* 
    if(startdt == null)
        startdt = date.newinstance(System.Today().Year(),System.Today().Month(),1);
    if(enddt == null)
        enddt = date.newinstance(System.Today().Year(),System.Today().Month(), System.Today().Day());
     
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
    else  {
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
      
      } */
      
      if(isTest == 1) {
          
           /* find accounts with units older than 30 days */
          /*  List<Contact> AccountContacts = [
                SELECT 
                    Id, Name, Account.Name
                FROM 
                    Contact 
                WHERE Account_First_Letter__c IN :firstLetters AND 
                    Client_Email_Opt_Out__c = FALSE];
                    
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            EmailTemplate templateId = [Select id from EmailTemplate where name = 'Checkin Email (Monthly)'];
            
            for(Contact con:AccountContacts) {
            
            
    
    
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateID(templateId.Id); 
                mail.setTargetObjectId(con.Id);
                mail.setSaveAsActivity(true);
                allmsg.add(mail);
                    
                System.debug('mail '+mail);
          
            }
            
            Messaging.sendEmail(allmsg,false); */
        }
      }
  
   
   
    
}