public class GoogleApi {
    public static string createFolder(string parentFolderId){
        string folderId;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('callout:Google_API/drive/v3/files');
        req.setHeader('content-type', 'application/json');
        //req.setHeader('Authorization','Bearer '+accessToken);
        //For creating folder 
        //String body = '{"name" : "folderName","mimeType" : "application/vnd.google-apps.folder"}';
        //For creating folder in parent folder
        String body = '{kind : "drive#file",mimeType : "application/vnd.google-apps.folder",name : "API created Sub Folder",parents : ["' +parentFolderId +'"]}';
        
        req.setBody(body);  
        //req.setTimeout(60*1000);
        system.debug('req::'+req);
        HttpResponse resp = http.send(req); 
        system.debug('resp::'+resp);
        system.debug('>>>>response body'+resp.getBody());
        return folderId;
        //
    }
    //Upload File With BAse 64 
    public static void uploadFileWithBase64( string fileName, string base64 , string folderId) {
        //system.debug('+newFileInfo.filename:::'+newFileInfo.filename);
        //system.debug('+newFileInfo.base64:::'+newFileInfo.base64);
       // ContentVersion cv = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = '06822000001hoz7AAA'];
        String body = '--foo_bar_baz\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n { "name": "' +fileName +'",'+ ' "mimeType" : "image/jpeg",' + '"parents": ["'+folderId  +'"]}\r\n\r\n--foo_bar_baz\r\nContent-Transfer-Encoding: base64\r\nContent-Type: image/jpeg\r\n\r\n' +base64 + '\r\n--foo_bar_baz--';
        System.debug(body);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Google_API/upload/drive/v3/files?uploadType=multipart');
        
        request.setHeader('Content-Type', 'multipart/related; boundary=foo_bar_baz');
        request.setHeader('Content-Length', Blob.valueOf(body).size() + '');
        request.setMethod('POST');
        request.setBody(body);
        system.debug('request.setEndpoint::'+request);
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        system.debug('>>>>response body'+response.getBody());
    }
   
    //Upload File from lwc
    @auraEnabled
    public static LightningResponse uploadFileLWC(string filesToInsert) {
        LightningResponse response1 = new LightningResponse();
        list<FileInfo> fileData = new list<FileInfo>();
                FileInfo fileData1 = (FileInfo)JSON.deserialize(filesToInsert, FileInfo.class);
                fileData.add(fileData1);
        		String body;
                for (FileInfo eachFileInfo : fileData) {
                    body = '--foo_bar_baz\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n { "title" : "' +eachFileInfo.filename +'",'+ ' "mimeType" : "image/jpeg",' + '"parents": ["1-ue8u8wcLdCyVS_5rTvUIQXsMbXoouNZ"]}\r\n\r\n--foo_bar_baz\r\nContent-Transfer-Encoding: base64\r\nContent-Type: image/jpeg\r\n\r\n' + EncodingUtil.base64Decode(eachFileInfo.base64) + '\r\n--foo_bar_baz--';
        System.debug(body);
                }
        
        //ContentVersion cv = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = '06822000001hoz7AAA'];
        //String body = '--foo_bar_baz\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n { "title" : "' +newFileInfo.filename +'",'+ ' "mimeType" : "image/jpeg",' + '"parents": ["1-ue8u8wcLdCyVS_5rTvUIQXsMbXoouNZ"]}\r\n\r\n--foo_bar_baz\r\nContent-Transfer-Encoding: base64\r\nContent-Type: image/jpeg\r\n\r\n' + EncodingUtil.base64Decode(newFileInfo.base64) + '\r\n--foo_bar_baz--';
        //System.debug(body);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Google_API/upload/drive/v3/files?uploadType=multipart');
        request.setHeader('Content-Type', 'multipart/related; boundary=foo_bar_baz');
        request.setHeader('Content-Length', Blob.valueOf(body).size() + '');
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        system.debug('>>>>response body'+response.getBody());
        response1.bIsSuccess = true;
         response1.put('setContentDocumentLink','setContentDocumentLink');
        return response1;
    }
    public class FileInfo {
        public String base64;
        public string filename;
        public string recordId;
    }
    //Upload File In Folder
    public static void uploadFile() {
        ContentVersion cv = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = '06822000001hoz7AAA'];
        String body = '--foo_bar_baz\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n { "title" : "filename",'+ ' "mimeType" : "image/jpeg",' + '"parents": ["1-ue8u8wcLdCyVS_5rTvUIQXsMbXoouNZ"]}\r\n\r\n--foo_bar_baz\r\nContent-Transfer-Encoding: base64\r\nContent-Type: image/jpeg\r\n\r\n' + EncodingUtil.base64Encode(cv.VersionData) + '\r\n--foo_bar_baz--';
        System.debug(body);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Google_API/upload/drive/v3/files?uploadType=multipart');
        request.setHeader('Content-Type', 'multipart/related; boundary=foo_bar_baz');
        request.setHeader('Content-Length', Blob.valueOf(body).size() + '');
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        system.debug('>>>>response body'+response.getBody());
    }
}
/*
{
    kind : "drive#file",
    mimeType : "application/vnd.google-apps.folder",
    name : "API created Sub Folder",
    parents : ["1vTgBzhlvH3prYoaI0iZOQHJ"] // Parent folder id into which folder needs to be created
  }
*/
/*How to create a new folder in google drive by using trigger on custom object creation?
public static void createFolder(String folderName, String accessToken) {
    HttpRequest req = new HttpRequest();
    req.setMethod('POST');     
    req.setEndpoint('https://www.googleapis.com/drive/v3/files');
    req.setHeader('Authorization', 'Bearer '+accessToken);
    req.setHeader('content-type', 'application/json');
    String body = '{"name" : "'+ folderName +'","mimeType" : "application/vnd.google-apps.folder"}';
    req.setTimeout(60*1000);
    req.setBody(body);
    Http http = new Http();
    HttpResponse res = http.send(req);
    System.debug('===== Response==='+ res.getBody());
}
*/
/*
public class IntegrationWithGoogleDrive {
    
    public static void uploadFile() {
        ContentVersion cv = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = '0682w00000R6rstAAB'];
        String body = '--foo_bar_baz\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n {\r\n"name": "My Image File"\r\n}\r\n\r\n--foo_bar_baz\r\nContent-Transfer-Encoding: base64\r\nContent-Type: image/jpeg\r\n\r\n' + EncodingUtil.base64Encode(cv.VersionData) + '\r\n--foo_bar_baz--';
        System.debug(body);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Google_Drive/upload/drive/v3/files?uploadType=multipart');
        request.setHeader('Content-Type', 'multipart/related; boundary=foo_bar_baz');
        request.setHeader('Content-Length', Blob.valueOf(body).size() + '');
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        system.debug('>>>>response body'+response.getBody());
    }
}*/

//I am able to create a file in Google drive from salesforce with the below code:
/*Http http = new Http();
HttpRequest req = new HttpRequest();
req.setMethod('POST');
req.setEndpoint('https://www.googleapis.com/upload/drive/v2/files?uploadType=media');
req.setHeader('content-type', 'text/plain');
req.setHeader('Authorization','Bearer '+accessToken);
String messageBody = 'Hi, This message is from Salesforce';
req.setBody(messageBody);  
req.setTimeout(60*1000);
HttpResponse resp = http.send(req); 
*/