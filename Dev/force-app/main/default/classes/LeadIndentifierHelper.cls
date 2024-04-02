public class LeadIndentifierHelper {
    
    public static Map<String, String> validateEmail(Lead newLead) {
        Map<String, String> result = new Map<String, String>();
        Map<String, Set<String>> keyWordToValue = new Map<String, Set<String>>();
        Map<String, Key_Words_Details_For_Lead__mdt> keywordAndValueToRecord = new Map<String, Key_Words_Details_For_Lead__mdt>();
        
        for(Key_Words_Details_For_Lead__mdt record : [SELECT Id, Allow__c, Username__c, KeyWord__c, Key_Word_Value__c 
                                                      FROM Key_Words_Details_For_Lead__mdt]) {
            if(keyWordToValue.containsKey(record.KeyWord__c)) {
                keyWordToValue.get(record.KeyWord__c).add(record.Key_Word_Value__c);
                keywordAndValueToRecord.put(record.KeyWord__c + record.Key_Word_Value__c, record);
            }else {
                keyWordToValue.put(record.KeyWord__c, new Set<String>{record.Key_Word_Value__c});
                keywordAndValueToRecord.put(record.KeyWord__c + record.Key_Word_Value__c, record);
            }
        }
        if(!keyWordToValue.isEmpty()) {
            // Check Email
            if(String.isNotBlank(newLead.Email) && keyWordToValue.containsKey('Email')) {
                for(String keyword : keyWordToValue.get('Email')) {
                    if(keywordAndValueToRecord.containsKey('Email' + keyword) && 
                       keywordAndValueToRecord.get('Email' + keyword).Allow__c == false && 
                       newLead.Email.containsIgnoreCase(keyword)) {
                        result.put('needToCreate', 'FALSE');
                        return result;
                    }
                    if(keywordAndValueToRecord.containsKey('Email' + keyword) && 
                       keywordAndValueToRecord.get('Email' + keyword).Allow__c == true && 
                       newLead.Email.containsIgnoreCase(keyword)) {
                        result.put('needToCreate', 'TRUE');
                        result.put('username',  keywordAndValueToRecord.get('Email' + keyword).Username__c);
                        return result;
                    }
                }
            }
            // check company
            if(String.isNotBlank(newLead.Company) && keyWordToValue.containsKey('Company')) {
                for(String keyword : keyWordToValue.get('Company')) {
                    if(keywordAndValueToRecord.containsKey('Company' + keyword) && 
                       keywordAndValueToRecord.get('Company' + keyword).Allow__c == false && 
                       newLead.Company.containsIgnoreCase(keyword)) {
                        result.put('needToCreate', 'FALSE');
                        return result;
                    }
                    if(keywordAndValueToRecord.containsKey('Company' + keyword) && 
                       keywordAndValueToRecord.get('Company' + keyword).Allow__c == true && 
                       newLead.Company.containsIgnoreCase(keyword)) {
                        result.put('needToCreate', 'TRUE');
                        result.put('username',  keywordAndValueToRecord.get('Company' + keyword).Username__c);
                        return result;
                    }
                }
            }
            /*
            // check lead source
             if(String.isNotBlank(newLead.LeadSource) && keyWordToValue.containsKey('Lead Source')) {
                for(String keyword : keyWordToValue.get('Lead Source')) {
                    if(keywordAndValueToRecord.containsKey('Lead Source' + keyword) && 
                       keywordAndValueToRecord.get('Lead Source' + keyword).Allow__c == false && 
                       newLead.LeadSource.containsIgnoreCase(keyword)) {
                        result.put('needToCreate', 'FALSE');
                        return result;
                    }
                    if(keywordAndValueToRecord.containsKey('Lead Source' + keyword) && 
                       keywordAndValueToRecord.get('Lead Source' + keyword).Allow__c == true && 
                       newLead.LeadSource.containsIgnoreCase(keyword)) {
                        result.put('needToCreate', 'TRUE');
                        result.put('username',  keywordAndValueToRecord.get('Lead Source' + keyword).Username__c);
                        return result;
                    }
                }
            }
            */
            // check subject
            if(String.isNotBlank(newLead.Subject__c) && keyWordToValue.containsKey('Subject')) {
                for(String keyword : keyWordToValue.get('Subject')) {
                    if(keywordAndValueToRecord.containsKey('Subject' + keyword) && 
                       keywordAndValueToRecord.get('Subject' + keyword).Allow__c == false && 
                       newLead.Subject__c.containsIgnoreCase(keyword)) {
                        result.put('needToCreate', 'FALSE');
                        return result;
                    }
                    if(keywordAndValueToRecord.containsKey('Subject' + keyword) && 
                       keywordAndValueToRecord.get('Subject' + keyword).Allow__c == true && 
                       newLead.Subject__c.containsIgnoreCase(keyword)) {
                        result.put('needToCreate', 'TRUE');
                        result.put('username',  keywordAndValueToRecord.get('Subject' + keyword).Username__c);
                        return result;
                    }
                }
            }
            /**
            // check email body
            if(String.isNotBlank(newLead.Description__c) && keyWordToValue.containsKey('Email Body')) {
                for(String keyword : keyWordToValue.get('Email Body')) {
                    if(keywordAndValueToRecord.containsKey('Email Body' + keyword) && 
                       keywordAndValueToRecord.get('Email Body' + keyword).Allow__c == false && 
                       newLead.Description__c.containsIgnoreCase(keyword)) {
                        result.put('needToCreate', 'FALSE');
                        return result;
                    }
                    if(keywordAndValueToRecord.containsKey('Email Body' + keyword) && 
                       keywordAndValueToRecord.get('Email Body' + keyword).Allow__c == true && 
                       newLead.Description__c.containsIgnoreCase(keyword)) {
                        result.put('needToCreate', 'TRUE');
                        result.put('username',  keywordAndValueToRecord.get('Email Body' + keyword).Username__c);
                        return result;
                    }
                }
            }
            if(String.isNotBlank(newLead.Email_HTML_Body__c) && keyWordToValue.containsKey('Email Body')) {
                for(String keyword : keyWordToValue.get('Email Body')) {
                    if(keywordAndValueToRecord.containsKey('Email Body' + keyword) && 
                       keywordAndValueToRecord.get('Email Body' + keyword).Allow__c == false && 
                       newLead.Email_HTML_Body__c.containsIgnoreCase(keyword)) {
                        result.put('needToCreate', 'FALSE');
                        return result;
                    }
                    if(keywordAndValueToRecord.containsKey('Email Body' + keyword) && 
                       keywordAndValueToRecord.get('Email Body' + keyword).Allow__c == true && 
                       newLead.Email_HTML_Body__c.containsIgnoreCase(keyword)) {
                        result.put('needToCreate', 'TRUE');
                        result.put('username',  keywordAndValueToRecord.get('Email Body' + keyword).Username__c);
                        return result;
                    }
                }
            }*/
        }
        result.put('needToCreate', 'NONE');
        return result;
    }  
}