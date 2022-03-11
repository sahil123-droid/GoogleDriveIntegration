@isTest
private class GoogleWebServiceTest {
    static testmethod void testCheckAuth(){
        Test.setMock(HttpCalloutMock.class, new GoogleWebServiceMock());  
        boolean result = GoogleWebService.checkAuth(); 
        boolean anotherResult = GoogleWebService.checkAuth();
        System.assertEquals(true,result);
        System.assertEquals(false,anotherResult);
    }
    static testmethod void testgetDataFromDrive(){
        Test.setMock(HttpCalloutMock.class, new GoogleWebServiceMock());  
        Map<String,Object> result = GoogleWebService.getDataFromDrive();   
        System.assertEquals(true,result!=null);
    }
    @isTest(SeeAllData=true)
    static void testUploadFile(){
        Test.setMock(HttpCalloutMock.class, new GoogleWebServiceMock());  
        String result = GoogleWebService.uploadFile('0695g000001jzYqAAI');   
        System.assertEquals('200',result);
    }
    static testmethod void renameFile(){
        Test.setMock(HttpCalloutMock.class, new GoogleWebServiceMock());  
        String result = GoogleWebService.renameFile('1234','xyz','wyz');   
        System.assertEquals('200',result);
    }
}