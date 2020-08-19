/**
*   =====================================================================================
*   Class Name          : CaseCloseWorkforceBatch
*   Description         : This Batch class queries all the cases which are closed, make a callout to Workforce API for integration.
*   Author              : Kishore Reddy
*   Created On          : 19 Aug 2020
*   Modification Log    : 
*   =====================================================================================
*   Developer       Date            Modification ID         Description
*   =====================================================================================
*   Kishore Reddy  19 Aug 2020                             Initial version
*   =====================================================================================
*/
global class CaseCloseWorkforceBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{ 
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String caseCloseQuery = 'SELECT Id, SecretKey__c,Agent_id__c, Status From Case where SecretKey__c = null AND Agent_id__c!=null AND Status = \'Closed\'';
        return Database.getQueryLocator(caseCloseQuery);
    }
    
     /**
     *  Method name  :  execute
     *  Description  :  Make a callout to Workforce API with case id and Agent Id. if the status code is 200, respective case is updated with the SecretKey__c,
     * 					else a record is created in the Workforce_API_Log_Hstory__c object with the error details for analysis and process the records later.	
     *  Author       :  Kishore Reddy
     *  Return Type  :  NA
     *  Parameter    :  List<Case> passed from the start mathod             
     */
     
    global void execute(Database.BatchableContext bc, List<Case> scope){
        
        List< Workforce_API_Log_Hstory__c> insertWFLog= new List< Workforce_API_Log_Hstory__c >();
        
        List< case> caseToBeUpdate = new List< case >();
        system.debug('scope'+scope.size());
        for (Case cs : scope){
            Workforce_API_Log_Hstory__c tempWFObj= new Workforce_API_Log_Hstory__c();
             Map<String,String> reqbodyMap= new Map<String,String>();
                try{
                    String param='id='+cs.id+'&agentid='+cs.Agent_id__c;          
                    HttpRequest request = new HttpRequest();
                    HttpResponse response = new HttpResponse();
                    Http http = new Http();    
                    request.setHeader('Content-Type', 'x-www-form-urlencoded');
                    //request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    //request.setHeader('Content-Type', 'application/json');
                    //request.setEndpoint('https://nfapihub.herokuapp.com?'+param);
                    request.setEndpoint('Callout:WorkforcePlanningAPI?'+param);
                    
                    system.debug('endpoint '+request.getEndpoint());
                    request.setMethod('POST');
                    //request.setTimeout(120000);
                 
                    /* if content type is not application/x-www-form-urlencoded
                    reqbodyMap.put('id',cs.id);
                    reqbodyMap.put('agentid',cs.agent_id__c);
                    request.setBody(JSON.serialize(reqbodyMap));
                    */
                    
                    response = http.send(request);
                    
                    Map<String,String>jsonResMap = (Map<String,String>)JSON.deserializeStrict(response.getBody(), Map<String,String>.class);
                
                    if (response.getStatusCode() == 200) {
                        
                        cs.SecretKey__c = jsonResMap.get('secretKey ');
						caseToBeUpdate.add(cs);
                    }else{
                            
                        tempWFObj.case_id__C = cs.id;
                   		tempWFObj.message__C = jsonResMap.get('error');
                        insertWFLog.add(tempWFObj);
                    }
                }
                catch(Exception e){
                    System.debug('Error-' + e.getMessage()); 
                        
                    tempWFObj.case_id__C = cs.id;
                    tempWFObj.message__C = e.getMessage()+ 'at '+e.getLineNumber();
                    insertWFLog.add(tempWFObj);
                }
            
        }
        
       if(caseToBeUpdate.size()>0){
            update caseToBeUpdate;
        }
        if(insertWFLog.size()>0){
            insert insertWFLog;
        }
    }
     
    global void finish(Database.BatchableContext bc){
         
    }

}