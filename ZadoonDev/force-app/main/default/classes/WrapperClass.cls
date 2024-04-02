//wrapper class being used to show records with checkbox 

public class WrapperClass {
    public Boolean isSelected   {get;set;}
    public Iron_Demand_Unit__c ironDemand {get;set;}
    public Contact con {get; set;}
    public Product2 pro {get; set;}
    
    public WrapperClass(Iron_Demand_Unit__c ironDemand, Boolean isSelected) {
        this.ironDemand = ironDemand;
        this.isSelected = isSelected;
    }
    public WrapperClass(Contact con, Boolean isSelected) {
        this.con = con;
        this.isSelected = isSelected;
    }
    public WrapperClass(Product2 pro, Boolean isSelected) {
        this.pro = pro;
        this.isSelected = isSelected;
    }
}