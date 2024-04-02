global class processRentalUnitTask implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name,Rental_Start_Date__c,Last_Term__c,Rental_Term__c,Last_Invoice_Date__c,Rental_End_Date__c,Rental_Type__c,Rate_Approved_By__c,Rate_Approved_Date__c FROM Rental_Unit__c where Unit__c != null and Rental_Term__c != null and Rental_Start_Date__c != null and Rate_Approved_By__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Rental_Unit__c> rentalUnitList) {
        List<Task> lstTasktoCreate = new List<Task>();
        List<Rental_Unit__c> lstRentalUnitToUpdate = new List<Rental_Unit__c>();
        Date todayDate = System.Today();
        String userNameTask = System.label.RentalTaskOwnerUserName;
        User taskToassign =[Select Id,UserName from User where UserName =:userNameTask Limit 1];
        System.debug('user'+taskToassign);
        Id taskOwner = taskToassign.Id;
        for(Rental_Unit__c rentalUnitObj : rentalUnitList){
            System.debug('user'+rentalUnitObj.Name);
            if(rentalUnitObj.Rental_Type__c == 'Weekly' &&
               ( String.isBlank(String.Valueof(rentalUnitObj.Last_Term__c)) || 
                (rentalUnitObj.Last_Term__c != null && 
                 rentalUnitObj.Last_Term__c != rentalUnitObj.Rental_Term__c &&
                 rentalUnitObj.Rental_Term__c >  rentalUnitObj.Last_Term__c))){
                     Date endDate = rentalUnitObj.Last_Invoice_Date__c != null ? rentalUnitObj.Last_Invoice_Date__c +7 : rentalUnitObj.Rental_Start_Date__c +7;
                     Decimal term = rentalUnitObj.Last_Term__c != null ? rentalUnitObj.Last_Term__c += 1 : 1;
                     System.debug('user1'+todayDate);
                      System.debug('user2'+endDate);
                     
                     if( endDate == todayDate ){
                         Task newTaskToSendInvoice = new Task();
                         newTaskToSendInvoice.Subject ='Send rental invoice';
                         newTaskToSendInvoice.Description ='Task to send rental invoice';
                         newTaskToSendInvoice.whatId = rentalUnitObj.Id;
                         newTaskToSendInvoice.ownerId = taskOwner;
                         newTaskToSendInvoice.ActivityDate = System.today();
                         
                         lstTasktoCreate.add(newTaskToSendInvoice);
                         
                         Task newTaskToCreateGPSData = new Task();
                         newTaskToCreateGPSData.Subject ='Review GPS data and update unit page';
                         newTaskToCreateGPSData.Description ='Review GPS data and update unit page';
                         newTaskToCreateGPSData.whatId = rentalUnitObj.Id;
                         newTaskToCreateGPSData.ownerId = taskOwner;
                         newTaskToCreateGPSData.ActivityDate = System.today();
                         lstTasktoCreate.add(newTaskToCreateGPSData);
                         lstRentalUnitToUpdate.add(new Rental_Unit__c(Id =rentalUnitObj.Id,Last_Term__c= term,Last_Invoice_Date__c =endDate));
                         
                     }
                     
                     
                     
                 }
            else if(rentalUnitObj.Rental_Type__c == 'Monthly' && 
                   ( String.isBlank(String.Valueof(rentalUnitObj.Last_Term__c)) || 
                     (rentalUnitObj.Last_Term__c != null && 
                      rentalUnitObj.Last_Term__c != rentalUnitObj.Rental_Term__c &&
                      rentalUnitObj.Rental_Term__c >  rentalUnitObj.Last_Term__c))){
                          
                          Date endDate = rentalUnitObj.Last_Invoice_Date__c != null ? rentalUnitObj.Last_Invoice_Date__c +30 : rentalUnitObj.Rental_Start_Date__c +30;
                          Decimal term = rentalUnitObj.Last_Term__c != null ? rentalUnitObj.Last_Term__c += 1 : 1;
                          
                          
                          if( endDate == todayDate ){
                              Task newTaskToSendInvoice = new Task();
                              newTaskToSendInvoice.Subject ='Send rental invoice';
                              newTaskToSendInvoice.Description ='Task to send rental invoice';
                              newTaskToSendInvoice.whatId = rentalUnitObj.Id;
                              newTaskToSendInvoice.ownerId = taskOwner;
                              newTaskToSendInvoice.ActivityDate = System.today();
                              lstTasktoCreate.add(newTaskToSendInvoice);
                              
                              Task newTaskToCreateGPSData = new Task();
                              newTaskToCreateGPSData.Subject ='Review GPS data and update unit page';
                              newTaskToCreateGPSData.Description ='Review GPS data and update unit page';
                              newTaskToCreateGPSData.whatId = rentalUnitObj.Id;
                              newTaskToCreateGPSData.ownerId = taskOwner;
                              newTaskToCreateGPSData.ActivityDate = System.today();
                              lstTasktoCreate.add(newTaskToCreateGPSData);
                              lstRentalUnitToUpdate.add(new Rental_Unit__c(Id =rentalUnitObj.Id,Last_Term__c= term,Last_Invoice_Date__c =endDate));
                          }
                          
                          
                      }
        }
         System.debug('user'+lstTasktoCreate);
        System.debug('user'+lstRentalUnitToUpdate);
        if(!lstTasktoCreate.isEmpty()){
            insert lstTasktoCreate;
        }
        if(!lstRentalUnitToUpdate.isEmpty()){
            update lstRentalUnitToUpdate;
        }
        
        
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}