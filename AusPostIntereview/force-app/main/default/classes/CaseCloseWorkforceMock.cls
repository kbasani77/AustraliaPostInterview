/**
*   =====================================================================================
*   Class Name          : CaseCloseWorkforceMock
*   Description         : Test mock class for CaseCloseWorkforceBatch. 
*   Author              : Kishore Reddy
*   Created On          : 19 Aug 2020
*   Modification Log    : 
*   =====================================================================================
*   Developer       Date            Modification ID         Description
*   =====================================================================================
*   Kishore Reddy  19 Aug 2020                             Initial version
*   =====================================================================================
*/

@isTest
global class CaseCloseWorkforceMock implements HttpCalloutMock {
    
    public String resBody;
    Public Integer statusCode;
    Public String status;
    public CaseCloseWorkforceMock(String resBody,String status,Integer statusCode){
        this.resBody=resBody;
        this.status=status;
        this.statusCode=statusCode;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res= new HTTPResponse();
        res.setStatus(status);
        res.setStatusCode(statusCode);
        
        res.setBody(resBody);
        return res;
        
    }
    
}