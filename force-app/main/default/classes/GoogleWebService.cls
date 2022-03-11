public class GoogleWebService {
    /*description
	*@Author -> Sahil Manglani
	*last Modified -> 9th Aug 2021
	* check Auth Method is used for verifiying the user that is authenticated or not
	* @return if user is authenticated returns true else it returns false
	*/
    @AuraEnabled
    public static boolean checkAuth(){
        try{
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://www.googleapis.com/drive/v3/files');
            req.setMethod('GET');
            
            String accesstoken = Auth.AuthToken.getAccessToken('0SO5g0000004LQs', 'Open ID Connect');
            req.setHeader('Authorization', 'Bearer '+accesstoken);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            String response =  res.getBody();
            if(response.contains('error')){
                return false;
            }
            return true;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }     
    }
    /*description
	*@Author -> Sahil Manglani
	*last Modified -> 9th Aug 2021
	*@return returning map<string,object> of all the data
	*/
    @AuraEnabled
    public static Map<String,Object> getDataFromDrive(){
        try{
            Map<String,Object> result= new Map<String,Object>();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://www.googleapis.com/drive/v3/files?fields=*');
            req.setMethod('GET');
            
            String accesstoken = Auth.AuthToken.getAccessToken('0SO5g0000004LQs', 'Open ID Connect');
            req.setHeader('Authorization', 'Bearer '+accesstoken);
            
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            result= (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            System.debug(result);
            return result;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    /*description
	*@Author -> Sahil Manglani
	*last Modified -> 9th Aug 2021 
	* uploadFile -> this method upload a file to google drive
	* @param -> Document Id of file that needs to be uploaded
	* @return returning responseStatusCode
	*/
    @AuraEnabled
    public static String uploadFile(String docId) {
        try{
            List<ContentVersion> cvFile = [SELECT VersionData,FileType,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId= :docId];
            Blob myBlob = cvFile[0].VersionData;
            System.debug(cvFile[0]);
            System.debug(myBlob);
            String url = 'https://www.googleapis.com/upload/drive/v2/files?uploadType=media';
            String accessToken = Auth.AuthToken.getAccessToken('0SO5g0000004LQs', 'Open ID Connect');
            string authorizationHeader = 'Bearer ' + accessToken; 
            Integer contentSize = myBlob.size();
            HttpRequest req = new HttpRequest();
            req.setheader('Authorization',authorizationHeader);
            req.setheader('Content-Length',String.valueOf(contentSize));
            req.setheader('Content-Type','multipart/mixed;/'+cvFile[0].FileType);
            req.setMethod('POST'); 
            req.setEndpoint(url); 
            req.setBodyAsBlob(myBlob); 
            Http h = new Http(); 
            Httpresponse resp = h.send(req);
            //After file was successfully upload we delete the file
            //delete new ContentDocument(Id = cvFile[0].ContentDocumentId);
            if(resp.getStatusCode()==200){
                return String.valueOf(resp.getStatuscode());
            }
            return 'Other Response';
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*description
	*@Author -> Sahil Manglani
	*last Modified -> 9th Aug 2021 
	*method -> this method rename a file in google drive 
	*@param -> document Id of google Drive 
	*@param -> mimeType of Google Drive File 
	*@param -> new name of google drive file
	*@return -> returning response in string
	*/
    @AuraEnabled
    public static String renameFile(String docId,String mimeType,String name){
        try{
            HTTP h = new HTTP();
            String httpMethod = 'PATCH';
            String endpoint = 'https://www.googleapis.com/drive/v3/files/'+docId;
            httpRequest req = new httpRequest();
            String accessToken = Auth.AuthToken.getAccessToken('0SO5g0000004LQs', 'Open ID Connect');
            String authorizationHeader = 'Bearer '+accessToken;
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('name',name);
            gen.writeStringField('mimeType', mimeType);
            gen.writeEndObject();
            String body=gen.getAsString();
            
            req.setHeader('Authorization',authorizationHeader);
            req.setMethod(httpMethod);
            req.setEndpoint(endpoint);
            req.setHeader('Content-Type','application/json;charset=utf-8');
            req.setBody(body);
            
            httpResponse res = h.send(req);
            System.debug('response' + res.getBody());
            return String.valueOf(res.getStatusCode());
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}