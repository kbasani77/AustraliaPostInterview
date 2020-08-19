/**
*   =====================================================================================
*   Class Name          : CaseCloseWorkforce_Test
*   Description         : Test class for CaseCloseWorkforceBatch. 
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
private class CaseCloseWorkforce_Test {
    
    @testsetup
    static void createTestData(){
        
        Case cs= new case();
        cs.Subject='Test123';
        cs.Status='New';
        insert cs;
        
    }
    
    /** Test method to test the positive response scinario */
    @isTest
    private static void testCaseSuccess(){
        
        case cs= [select id, status from Case where subject='Test123'];
        cs.Status='Closed';
        update cs;
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new CaseCloseWorkforceMock('{"success":true,"secretKey":"1231"}','success',200));
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new CaseCloseWorkforceSchedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();

        
        
    }
        /** Test method to test the negative response scinario */
    @isTest
    private static void testCaseFailure(){
        
        case cs= [select id, status from Case where subject='Test123'];
        cs.Status='Closed';
        update cs;
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new CaseCloseWorkforceMock('{"success":false,"error":"Id is invalid"}','success',500));
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new CaseCloseWorkforceSchedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        
    }
    
}