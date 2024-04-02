@isTest public class UpdateNoOfCasesOnUnitTest {
    /*@isTest public static void TestUpdateNo(){
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
        insert lstProduct;
       
        list<Case> lstCase = 	testDataFactory.noOfCasesToInsert(1, lstProduct[0].id );
        insert lstCase;
        
        UpdateNoOfCasesOnUnit batchObj_cl = new UpdateNoOfCasesOnUnit();
        
        
        test.startTest();
        database.executebatch(batchObj_cl);
        test.stopTest();
    }*/
    @isTest public static void TestUpdateNoOfLeadsOnUnit(){
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
        insert lstProduct;
       
        list<Lead> lstLead = testDataFactory.noOfLeadToInsert(1, '2356236');
        for(Lead eachLead : lstLead){
            eachLead.status ='Qualified';
            eachLead.Unit__c = lstProduct[0].id;
        }
        insert lstLead;
        
        UpdateNoOfLeadsOnUnit batchObj_cl = new UpdateNoOfLeadsOnUnit();
        
        
        test.startTest();
        database.executebatch(batchObj_cl);
        test.stopTest();
    }/*
    @isTest public static void TestUpdateNoOfSalesOppOnUnit(){
        list<Account> lstAccount = testDataFactory.noOfAccountToInsert(1,'TestKizzy');
        insert lstAccount;
        list<Equipment__c> lstEquipment=  testDataFactory.noOfEquipment(1);
        insert lstEquipment;
        list<Product2> lstProduct = testDataFactory.noOfUnitsToCreate2(1, lstEquipment[0].id, lstAccount[0].id);
        insert lstProduct;
       	string ProcuretmentRecordType = label.Opp_Rec_type_Dev_Name_procurement_opp ;
        list<recordType> lstRecordType ;
        if(string.isNotBlank(ProcuretmentRecordType)){
             lstRecordType = [SELECT Id,DeveloperName From RecordType Where DeveloperName =: ProcuretmentRecordType];
        }
        list<Opportunity> lstOpportunity = testDataFactory.createOpportunity(1,lstAccount[0].id,lstProduct[0].id );
        for(Opportunity eachOpportunity : lstOpportunity){
            
            eachOpportunity.RecordTypeId = lstRecordType[0].id;
        }
        insert lstOpportunity;
        
        UpdateNoOfSalesOppOnUnit batchObj_cl = new UpdateNoOfSalesOppOnUnit();
        
        
        test.startTest();
        database.executebatch(batchObj_cl);
        test.stopTest();
    }*/
}