trigger AutoPopulatePricebookEntry on Product2 (after insert) {
    
    /*List<sObject> s = [select ID from Pricebook2 where IsStandard = TRUE];

for (Product2 newProduct: Trigger.new) {

PricebookEntry z = new PricebookEntry(Pricebook2Id=s[0].ID,Product2Id=newProduct.ID, UnitPrice=0.00, IsActive=TRUE, UseStandardPrice=FALSE);
insert z;

}*/
    
    
    
    List<Pricebook2> pbList = new List<Pricebook2>();
    pbList = [select Id from Pricebook2 where IsStandard = TRUE LIMIT 1];
    system.debug('pbList :  '+pbList);
    if(pbList.size() > 0) {
        List<PricebookEntry> pbEntry = new List <PricebookEntry>();
        for (Product2 newProduct: Trigger.new) {
            PricebookEntry z = new PricebookEntry(Pricebook2Id=pbList[0].Id,Product2Id=newProduct.Id, UnitPrice=0.00, IsActive=TRUE, UseStandardPrice=FALSE);
            pbEntry.add(z);
        }
        if(pbEntry.size() > 0 && !test.isRunningTest()) {
            insert pbEntry;
        }
    }
}