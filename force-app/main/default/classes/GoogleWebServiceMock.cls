@isTest
global class GoogleWebServiceMock implements HttpCalloutMock{
    static Integer count=0;
    global HTTPResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if(request.getMethod()=='GET'){
            if(request.getEndpoint().contains('files?fields=*')){
                response.setBody('{"files": {"id":1, "name":"file1.txt"}}');
            }
            else if(request.getEndpoint().contains('files')){
                if(GoogleWebServiceMock.count==0){
                    response.setBody('{"files": {"id":1, "name":"file1.txt"}}');
                }
                else{
                    response.setBody('{"error":"invalid error"}');
                }
                GoogleWebServiceMock.count++;
            }
            
        }
        else if(request.getMethod()=='POST'){
            response.setBody('{"success":{"id":"0695g000001jzYqAAI","name":"Untitled"}');
        }
        else if(request.getMethod()=='PATCH'){
            response.setBody('{"success":{"id":"1234","name":"renamed"}');
        }
        response.setStatusCode(200);
        return response; 
    }
}