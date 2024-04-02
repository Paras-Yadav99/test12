@isTest public class UpdateProOppFromUnitTest {
    @isTest public static void testUpdateProOppFromUnit(){
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
        for (Product2 eachProduct2 : lstProduct){
            eachProduct2.Confidential_Information_Notes__c = 'sfjauygfaf';
        }
        insert lstProduct;
        Pricebook2 standardPricebook = new Pricebook2(
                                                        Id = Test.getStandardPricebookId(),
                                                        IsActive = true
                                                    );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
    
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1, lstAccount[0].id, lstProduct[0].id);
        string ProcuretmentRecordType = label.Opp_Rec_type_Dev_Name_procurement_opp ;
        list<recordType> lstRecordType ;
        if(string.isNotBlank(ProcuretmentRecordType)){
             lstRecordType = [SELECT Id,DeveloperName From RecordType Where DeveloperName =: ProcuretmentRecordType];
        }
        for(Opportunity eachOpportunity : lstOpportunity ){
			eachOpportunity.recordTypeId =   lstRecordType[0].id;          
        }
        insert lstOpportunity;
       system.debug('lstRecordType'+lstRecordType);
        
        test.startTest();
        UpdateProOppFromUnit newinstance = new UpdateProOppFromUnit();
		database.executeBatch(newinstance);

        test.stopTest();
        
    }
}