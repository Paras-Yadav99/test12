public class MLSCalloutHelper {
    public static Map<Id, List<MLSCalloutWrapper.Image>> MapofUnitAndListOfUrl;
    public static Map<Id, List<MLSCalloutWrapper.Image>> MapofUnitAndListOfVideoUrl;
    public static Map<Id, Integer> MapofUnitAndImagecount;
    public static Map<Id, Integer> MapofUnitAndVideoCount;
    public static final String MLS_KEY = 'MLS';
    public static final String Google_KEY = 'GoogleApi';
    public static String DEFAULT_CONDITION = 'used';
    public static String DEFAULT_CURRENCY = 'USD';
    List<Product2> units;

    public MLSCalloutHelper(List<Product2> units){
        this.units = units;
    }

    public MLSCalloutHelper(Set<Id> unitIds){
        units = [SELECT Id,  Category__c, Model__c, Inventory_Status__c, Manufacturer__c, Year__c, Old_SF_Unit_Details__c, IsActive, Starting_Advertised_Retail_Price__c, 
        Rental_Unit__c, Daily_Rental_Rate__c, Weekly_Rental_Rate__c, Monthly_Rental_Rate__c, Hour__c, Mileage__c, 
        VIN__c, ZID__c, Serial_Number__c, MT_Vague_Display_Location_Name__c, Displayed_Vague_Location__c, Storage_Country__c, MT_Location_Vague_Postal_Code__c, 
        Google_Drive_LInk__c, Google_Drive_Videos_Link__c, Storage_State__c, Storage_City__c, MLS_Number__c FROM Product2 WHERE Id IN :unitIds];
    }
    
    public void addInventoryItem(){
        Map<String, Call_Out_Setting__mdt> calloutMap = new Map<String, Call_Out_Setting__mdt>();

        for(Call_Out_Setting__mdt setting : Call_Out_Setting__mdt.getAll().values()){
            calloutMap.put(setting.DeveloperName , setting);
        }
        getImageUrls(calloutMap);
        String endpoint = calloutMap.get(MLS_KEY).endpoint__c;
        String authorization = calloutMap.get(MLS_KEY).Authorization__c;

        for(Product2 unit : units){
            MLSCalloutWrapper body = prepareBody(unit);
			system.debug('body>>>>'+body);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Authorization', authorization);
            request.setTimeout(120000);
			system.debug('JSON.serialize(body) : ' + JSON.serialize(body));
            request.setBody(JSON.serialize(body, true));
            HttpResponse response = http.send(request);
            // Parse the JSON response
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
                MLSCalloutWrapper responseBody = (MLSCalloutWrapper)
                JSON.deserialize(response.getBody(), MLSCalloutWrapper.class);
                unit.MLS_Number__c = responseBody.ListingID;
                unit.Is_Listed_On_MLS__c = true;
            }
        }
		system.debug('JSON.serialize(units) ' + JSON.serialize(units));
        if(units.size() > 0){
            update units;
        }
    } 
    public void getImageUrls(Map<String, Call_Out_Setting__mdt> calloutMap){
        String authorization = calloutMap.get(Google_KEY).Authorization__c;
        MapofUnitAndListOfUrl = new Map<Id, List<MLSCalloutWrapper.Image>>();
        MapofUnitAndListOfVideoUrl = new Map<Id, List<MLSCalloutWrapper.Image>>();
        List<MLSCalloutWrapper.Image> listOfUrl = new List<MLSCalloutWrapper.Image>();
        for(Product2 objUnit : units){
            List<MLSCalloutWrapper.Image> listofImageUrl = new List<MLSCalloutWrapper.Image>();
            List<MLSCalloutWrapper.Image> listofVideoUrl = new List<MLSCalloutWrapper.Image>();
            Integer Imagecount = 1;
            Integer Videocount = 1;
            if(objUnit.Google_Drive_LInk__c != null){
                String FolderKey = objUnit.Google_Drive_LInk__c.substringAfter('/folders/');
            	HttpResponse response = getGoogleResponse(calloutMap,authorization,FolderKey);
                if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            	} else {
                    System.debug(response.getBody());
                    FolderPictureWrapper responseBody = (FolderPictureWrapper)
                    JSON.deserialize(response.getBody(), FolderPictureWrapper.class);
                    
                    List<String> setOfgoogleTitle = new List<String>();
                    Map<string,String> MapofTitleAndLink = new Map<string,String>();
                    for(items objitem : responseBody.items){
                        //for(owners objowner : objitem.owners){
                        setOfgoogleTitle.add(objitem.title);
                        MapofTitleAndLink.put(objitem.title,objitem.webContentLink);
                     }
                    setOfgoogleTitle.sort();
                    for(Integer i = 0;i<setOfgoogleTitle.Size();i++){
                        if(MapofTitleAndLink.containsKey(setOfgoogleTitle.get(i))){
                            MLSCalloutWrapper.Image imageData = new MLSCalloutWrapper.Image();
        					imageData.Url = MapofTitleAndLink.get(setOfgoogleTitle.get(i));
        					imageData.OrderNo = Imagecount;
                            Imagecount++;
                            System.debug(imageData);
                            listofImageUrl.add(imageData);
                        }
                        	
                            
                    	//}
                    }
            	}
        	}
            if(objUnit.Google_Drive_Videos_Link__c != null){
                String FolderKey = objUnit.Google_Drive_Videos_Link__c.substringAfter('/folders/');
            	HttpResponse response = getGoogleResponse(calloutMap,authorization,FolderKey);
                if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            	} else {
                    System.debug(response.getBody());
                    FolderPictureWrapper responseBody = (FolderPictureWrapper)
                    JSON.deserialize(response.getBody(), FolderPictureWrapper.class);
                    Videocount = 1;
                    List<String> setOfgoogleTitle = new List<String>();
                    Map<string,String> MapofTitleAndLink = new Map<string,String>();
                    for(items objitem : responseBody.items){
                        //for(owners objowner : objitem.owners){
                        setOfgoogleTitle.add(objitem.title);
                        MapofTitleAndLink.put(objitem.title,objitem.webContentLink);
                     }
                    setOfgoogleTitle.sort();
                    for(Integer i = 0;i<setOfgoogleTitle.Size();i++){
                        if(MapofTitleAndLink.containsKey(setOfgoogleTitle.get(i))){
                            MLSCalloutWrapper.Image imageData = new MLSCalloutWrapper.Image();
        					imageData.Url = MapofTitleAndLink.get(setOfgoogleTitle.get(i));
        					imageData.OrderNo = Videocount;
                            Videocount++;
                            System.debug(imageData);
                            listofVideoUrl.add(imageData);
                        }
                        //}
                    }
            	}
        	}
            MapofUnitAndListOfUrl.put(objUnit.Id,listofImageUrl);
            MapofUnitAndListOfVideoUrl.put(objUnit.Id,listofVideoUrl);
            MapofUnitAndImagecount.put(objUnit.id, ImageCount);
            MapofUnitAndVideocount.put(objUnit.id, VideoCount);
        }
    }
    public HttpResponse getGoogleResponse(Map<String, Call_Out_Setting__mdt> calloutMap,String authorization,String folderKey){
        	String endpoint = calloutMap.get(Google_KEY).endpoint__c+'\''+folderKey+'\'+in+parents&key='+authorization ;
            System.debug(endpoint);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            HttpResponse response = http.send(request);
        	return response;
    }
    public void updateInventoryItem(){
        Map<String, Call_Out_Setting__mdt> calloutMap = new Map<String, Call_Out_Setting__mdt>();

        for(Call_Out_Setting__mdt setting : Call_Out_Setting__mdt.getAll().values()){
            calloutMap.put(setting.DeveloperName , setting);
        }
        getImageUrls(calloutMap);
        String endpoint = calloutMap.get(MLS_KEY).endpoint__c;
        String authorization = calloutMap.get(MLS_KEY).Authorization__c;
        
        for(Product2 unit : units){
            if(unit.MLS_Number__c != null){
                MLSCalloutWrapper body = prepareBody(unit);

                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint+'/'+String.valueOf(unit.MLS_Number__c));
                request.setMethod('PUT');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setHeader('Authorization', authorization);
                request.setTimeout(120000);

                request.setBody(JSON.serialize(body, true));
                HttpResponse response = http.send(request);
                // Parse the JSON response
                if(response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                } else {
                    System.debug(response.getBody());
                    MLSCalloutWrapper responseBody = (MLSCalloutWrapper)
                        JSON.deserialize(response.getBody(), MLSCalloutWrapper.class);
                    unit.MLS_Number__c = responseBody.ListingID;
                    unit.Is_Listed_On_MLS__c = true;
                    if(MapofUnitAndImagecount.containsKey(unit.Id)){
                    	unit.Number_of_Images_in_Google_Drive__c = MapofUnitAndImagecount.get(unit.Id);
                    }
                    if(MapofUnitAndVideocount.containsKey(unit.Id)){
                    	unit.Number_of_Videos_in_Google_Drive__c = MapofUnitAndVideocount.get(unit.Id);
                    }
                }
            }
        }

        if(units.size() > 0){
            update units;
        }
    }
    
    private MLSCalloutWrapper prepareBody(Product2 unit){
        MLSCalloutWrapper bodyWrapper = new MLSCalloutWrapper();
        bodyWrapper.Category = unit.Category__c;
        bodyWrapper.Manufacturer = unit.Manufacturer__c;
        bodyWrapper.Model = unit.Model__c;
        bodyWrapper.Year = String.isNotBlank(unit.Year__c) ? Integer.valueOf(unit.Year__c) : null;
        bodyWrapper.Condition = DEFAULT_CONDITION;
        bodyWrapper.Description = unit.Old_SF_Unit_Details__c;
        bodyWrapper.CurrencyCode = DEFAULT_CURRENCY;
        bodyWrapper.RetailFlag = unit.IsActive;
        bodyWrapper.ListPrice = unit.Starting_Advertised_Retail_Price__c;
        bodyWrapper.RentalFlag = unit.Rental_Unit__c;
        bodyWrapper.DailyRentalPrice = unit.Daily_Rental_Rate__c;
        bodyWrapper.WeeklyRentalPrice = unit.Weekly_Rental_Rate__c;
        bodyWrapper.MonthlyRentalPrice = unit.Monthly_Rental_Rate__c;
        bodyWrapper.AtAuction = false;
        bodyWrapper.WholesaleFlag = false;
        bodyWrapper.Hours = unit.Hour__c != null ? Integer.valueOf(unit.Hour__c) : null;
        bodyWrapper.Mileage = unit.Mileage__c != null ? Integer.valueOf(unit.Mileage__c) : null;
        bodyWrapper.MileageType = 'Miles';
        bodyWrapper.Quantity = 1;
        bodyWrapper.VIN = unit.VIN__c;
        bodyWrapper.StockNumber = unit.ZID__c;
        bodyWrapper.SerialNumber = unit.Serial_Number__c;
        bodyWrapper.FuelType = 'Diesel';
        if(unit.Old_SF_Unit_Details__c != null){
            bodyWrapper.EnclosedCab = 
                unit.Old_SF_Unit_Details__c?.containsIgnoreCase('CAB') || unit.Old_SF_Unit_Details__c?.containsIgnoreCase('EROPS');
            bodyWrapper.Ramp = unit.Old_SF_Unit_Details__c?.containsIgnoreCase('ripper');
            bodyWrapper.Thumb = unit.Old_SF_Unit_Details__c?.containsIgnoreCase('thumb');
        }
        MLSCalloutWrapper.Location location = new MLSCalloutWrapper.Location();
        location.City = unit.MT_Vague_Display_Location_Name__c;
        location.StateProvince = unit.Displayed_Vague_Location__c;
        location.Country = unit.Storage_Country__c;
        location.PostalCode = unit.MT_Location_Vague_Postal_Code__c;
        bodyWrapper.Location = location;
        //MLSCalloutWrapper.Image imageData = new MLSCalloutWrapper.Image();
        //imageData.Url = unit.Google_Drive_LInk__c;
        //imageData.OrderNo = 1;
        MLSCalloutWrapper.Images imageObj = new MLSCalloutWrapper.Images();
        imageObj.Images = new List<MLSCalloutWrapper.Image>();
        imageObj.Images.addAll(MapofUnitAndListOfUrl.get(unit.Id));
        bodyWrapper.Images = imageObj;
        system.debug('imageObj : ' + imageObj);
        //MLSCalloutWrapper.Image videoData = new MLSCalloutWrapper.Image();
        //videoData.Url = unit.Google_Drive_Videos_Link__c;
        //videoData.OrderNo = 1;
        MLSCalloutWrapper.Videos videoObj = new MLSCalloutWrapper.Videos();
        videoObj.Videos = new List<MLSCalloutWrapper.Image>();
        videoObj.Videos.addAll(MapofUnitAndListOfVideoUrl.get(unit.Id));
        bodyWrapper.Videos = videoObj;
        system.debug('videoObj : ' + videoObj);
		system.debug('JSON.serialize(bodyWrapper) : ' + JSON.serialize(bodyWrapper));
        return bodyWrapper;
    }

    public class Listings{
        public List<MLSCalloutWrapper> Listings;
    }
    public class FolderPictureWrapper{
        public List<items> items;
    }
    public class items {
		public list<owners> owners;
        public string alternateLink;
        public string webContentLink;
        public string title;
	}
	public class owners {
		public picture picture;
	}
	public class picture {
		public String url;	//https://lh3.googleusercontent.com/a-/AOh14GhHgJ8BPvJodYTlfZcRulD4CIGv5RmSC_ROSg1SCR4=s64
	}
}