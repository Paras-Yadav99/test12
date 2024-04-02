// Aura-Response 
    global class AuraResponse{
        @AuraEnabled 
        public Boolean isSuccess;
        @AuraEnabled 
        public string message;
        @AuraEnabled 
        public string response;
        
        AuraResponse(Boolean isSuccess,
                     String message,
                     String response) {
                         
                         this.isSuccess = isSuccess;
                         this.message = message;
                         this.response = response;
                     }
    }