public class MLSCalloutWrapper {
    public Location Location;
    public Images Images;
    public Videos Videos;
    public String Category;
    public String Manufacturer;
    public String Model;
    public Integer Year;
    public Integer Hours;
    public Integer Quantity;
    public Integer Mileage;
    public Integer Gallons;
    public Integer LiftgateCapacityLbs;
    public Integer PneumaticSize;
    public Integer HorsePower;
    public Integer SleeperSize;
    public String Condition;
    public String Description;
    public String MileageType;
    public String VIN;
    public String StockNumber;
    public String SerialNumber;
    public String PartNumber;
    public String CastNumber;
    public String Color;
    public String DriveType;
    public String EngineManufacturer;
    public String EngineDisplacement;
    public String EngineSize;
    public String FuelType;
    public String RearAxle;
    public String RearAxleManufacturer;
    public String CompositionType;
    public String Weight;
    public String Length;
    public String Width;
    public String Height;
    public String GPMRating;
    public String GrossVehicleWeightRatingCategory;
    public String GrossVehicleWeightRatingClass;
    public String LiftCapacityTons;
    public String LiftCapacityLbs;
    public String LiftgateModel;
    public String PSIRating;
    public String ReeferHours;
    public String ReeferManufacturer;
    public String ReeferModel;
    public String ForwardSpeed;
    public String ReverseSpeed;
    public String SeparatorHours;
    public String SleeperType;
    public String SuspensionType;
    public String SuspensionManufacturer;
    public String TireSize;
    public String TrackLength;
    public String TrackPadWidth;
    public String TransmissionManufacturer;
    public String TransmissionType;
    public String CustomLabel1;
    public String CustomData1;
    public String CustomLabel2;
    public String CustomData2;
    public String CustomLabel3;
    public String CustomData3;
    public String CustomLabel4;
    public String CustomData4;
    public String CustomLabel5;
    public String CustomData5;
    public Boolean RetailFlag;
    public Boolean RentalFlag;
    public Boolean AtAuction;
    public Boolean WholesaleFlag;
    public Boolean EngineBrake;
    public Boolean OverDrive;
    public Boolean EnclosedCab;
    public Boolean Extendable;
    public Boolean Grapple;
    public Boolean GPS;
    public Boolean GroundRadar;
    public Boolean HalfRound;
    public Boolean Heating;
    public Boolean HydraulicTail;
    public Boolean Insulated;
    public Boolean LiftgateFlag;
    public Boolean Radio;
    public Boolean Ramp;
    public Boolean RearRipper;
    public Boolean RipperFlag;
    public Boolean Stinger;
    public Boolean Thumb;
    public Boolean Vacuum;
    public Boolean VaporRecovery;
    public Boolean Warranty;
    public Boolean WaterSystem;
    public Boolean WetKit;
    public Boolean Winch;
    public Decimal ListPrice;
    public Decimal HourlyRentalPrice;
    public Decimal DailyRentalPrice;
    public Decimal WeeklyRentalPrice;
    public Decimal MonthlyRentalPrice;
    public Decimal AnnualRentalPrice;
    public Decimal WheelBase;
    public String CurrencyCode;

    public Integer ListingID;
    public String DealerWebsiteUrl;
    public String WebsiteUrl;
    public String CreatedDate;
    public String ModifiedDate;
    public String ListingAuction;
    public String CatalogAuction;

    public Dealer Dealer;
    public Integer CategoryID;
    public Integer NumberOfRows;
    public Integer NumberOfBottoms;

    public class Dealer {
        public Integer DealerID;
        public String DealerName;
    }

    public class Image {
        public String Url;
        public Integer OrderNo;
    }

    public class Images {
        public List<Image> Images;
    }

    public class Location {
        public String Address1;
        public String City;
        public String StateProvince;
        public String Country;
        public String PostalCode;
    }

    public class Videos {
        public List<Image> Videos;
    }
}