@isTest
public class UnitFilterController_Test {
    @isTest static void testGetProducts() {
        String stringifiedList = getOutputListWrapperForParent();
        String stringifiedListChild = getOutputListWrapperForChild();
        Account acc = new Account();
        acc.name = 'Test Account';
        acc.Not_A_Client_We_Want_To_Do_Business_With__c = false;
        insert acc;
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'jnjn@jnj.com';
        con.AccountId = acc.Id;
        con.Client_Email_Opt_Out__c = false;
        insert con;
        
        test.startTest();
        try{
            UnitFilterController.getProducts(stringifiedList, stringifiedListChild);
            UnitFilterController.getContactList();
            UnitFilterController.getFilteredContactList('','','test');
            
        }
        catch(exception e)
        {
        } 
        
             
            
        
        
        
        test.stopTest();        
    }
    @isTest static void testGetProducts1() {
        String stringifiedList = getOutputListWrapperForParent();
        String stringifiedListChild = getOutputListWrapperForChild();
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'jnjn@jnj.com';
        insert con;
        Model__c model = TestDataFactory.createModel(true);
        Equipment__c equip = TestDataFactory.createEquipment(true, model.Id); 
        Contact con1 = TestDataFactory.createContact(true);
        Product2 pro = TestDataFactory.createUnit(true, model.id, equip.id);
        Iron_Demand__c iron = TestDataFactory.createIronDemand(true, equip.id, con.id);
        Iron_Demand_Unit__c unit = TestDataFactory.createUnits(true, pro.id, iron.id);
        List<Product2> lstProd = new List<Product2>();
        List<Contact> lstCon = new List<Contact>();
        String conId = con1.Id;
        String prodId = pro.Id;
        List<String> lstStringCon = new List<String>();
		lstStringCon.add(conId);        
        List<String> lstStringProd = new List<String>();
        lstStringProd.add(prodId); 
        test.startTest();
        
            
            UnitFilterController.sendEmailToContact(lstStringCon,lstStringProd);
        UnitFilterController.sendEmailToIronDemandsContact(lstStringProd);
        
        
        
        test.stopTest();        
    }
    
    @isTest static void testGetFieldsList() {
        test.startTest();
        try
        {
            UnitFilterController.getFieldsList('test');
        }
        catch(exception e)
        {
        }     
        
        test.stopTest();        
    }
    
    @isTest static void testGetContactList(){
        
        Account acc = new Account();
        acc.name = 'Test Account';
        acc.Not_A_Client_We_Want_To_Do_Business_With__c = false;
        insert acc;
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'jnjn@jnj.com';
        con.AccountId = acc.Id;
        con.Client_Email_Opt_Out__c = false;
        insert con;
        
        test.startTest();
        UnitFilterController.getContactList();
        test.stopTest();
    }
    
    @isTest static void testGetContactList2(){
        test.startTest();
        try{
            List<Contact> lst = new List<Contact>();
            lst = UnitFilterController.getContactList();
            LightningResponse reponse = new LightningResponse();
            reponse.put('dd', lst);
            
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
        }
        test.stopTest();
    }
    @isTest static void testGetContactList3(){
        test.startTest();
        try{
            List<Contact> lst = new List<Contact>();
            LightningResponse reponse = new LightningResponse();
            reponse.put('dd', lst);
            
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
        }
        test.stopTest();
    }
    
    
    private static String getOutputListWrapperForParent(){
        UnitFilterController.OutputListWrapper olw = new UnitFilterController.OutputListWrapper();
        olw.filterList = new List<UnitFilterController.OutputFieldWrapper>();
        UnitFilterController.OutputFieldWrapper obj1 = new UnitFilterController.OutputFieldWrapper();
        obj1.name='Category__c';
        obj1.value='Excavator';
        olw.filterList.add(obj1);
        
        UnitFilterController.OutputFieldWrapper obj2 = new UnitFilterController.OutputFieldWrapper();
        obj2.name='Min_Year__c';
        obj2.value='2010';
        olw.filterList.add(obj2);
        
        UnitFilterController.OutputFieldWrapper obj3 = new UnitFilterController.OutputFieldWrapper();
        obj3.name='Max_Year__c';
        obj3.value='2022';
        olw.filterList.add(obj3);
        
        UnitFilterController.OutputFieldWrapper obj4 = new UnitFilterController.OutputFieldWrapper();
        obj4.name='Make__c';
        obj4.value='Caterpillar';
        olw.filterList.add(obj4);
        
        UnitFilterController.OutputFieldWrapper obj5 = new UnitFilterController.OutputFieldWrapper();
        obj5.name='Model__c';
        obj5.value='S650TX';
        olw.filterList.add(obj5);
        
        UnitFilterController.OutputFieldWrapper obj6 = new UnitFilterController.OutputFieldWrapper();
        obj6.name='Min_Hour__c';
        obj6.value='0';
        olw.filterList.add(obj6);
        
        UnitFilterController.OutputFieldWrapper obj7 = new UnitFilterController.OutputFieldWrapper();
        obj7.name='Max_Hour__c';
        obj7.value='50';
        olw.filterList.add(obj7);
        
        UnitFilterController.OutputFieldWrapper obj8 = new UnitFilterController.OutputFieldWrapper();
        obj8.name='Min_Price__c';
        obj8.value='0';
        olw.filterList.add(obj8);
        
        UnitFilterController.OutputFieldWrapper obj9 = new UnitFilterController.OutputFieldWrapper();
        obj9.name='Max_Price__c';
        obj9.value='1000000';
        olw.filterList.add(obj9);
        
        UnitFilterController.OutputFieldWrapper obj10 = new UnitFilterController.OutputFieldWrapper();
        obj10.name='Unit_Name__c';
        obj10.value='2500S';
        olw.filterList.add(obj10);
        
        String olwStrigified = JSON.serialize(olw);
        
        return olwStrigified;
        
    }
    
    private static String getOutputListWrapperForChild(){
        UnitFilterController.OutputListWrapper olw = new UnitFilterController.OutputListWrapper();
        olw.filterList = new List<UnitFilterController.OutputFieldWrapper>();
        UnitFilterController.OutputFieldWrapper obj1 = new UnitFilterController.OutputFieldWrapper();
        obj1.name='Drive__c';
        obj1.value='4WD';
        obj1.type = 'PICKLIST';
        olw.filterList.add(obj1);
        
        UnitFilterController.OutputFieldWrapper obj2 = new UnitFilterController.OutputFieldWrapper();
        obj2.name='Unit_operational__c';
        obj2.value='true';
        obj2.type = 'BOOLEAN-PICKLIST';
        olw.filterList.add(obj2);
        
        UnitFilterController.OutputFieldWrapper obj3 = new UnitFilterController.OutputFieldWrapper();
        obj3.name='Attachment_Type__c';
        obj3.listOfValue = new List<String>{'Bucket'};
            obj3.type = 'MULTIPICKLIST';
        olw.filterList.add(obj3);
        
        UnitFilterController.OutputFieldWrapper obj4 = new UnitFilterController.OutputFieldWrapper();
        obj4.name='Any_relevant_info__c';
        obj4.value = 'test';
        obj4.type = 'TEXTAREA';
        olw.filterList.add(obj4);
        
        String olwStrigified = JSON.serialize(olw);
        
        return olwStrigified;
    }
    
    
}