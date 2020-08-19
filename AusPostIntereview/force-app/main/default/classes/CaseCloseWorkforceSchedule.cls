/**
*   =====================================================================================
*   Class Name          : CaseCloseWorkforceSchedule
*   Description         : This Scheduler class allows to schdule the batch class CaseCloseWorkforceBatch. Batch size and schduling 
						  times can be adjusted as per the business requireent.
*   Author              : Kishore Reddy
*   Created On          : 19 Aug 2020
*   Modification Log    : 
*   =====================================================================================
*   Developer       Date            Modification ID         Description
*   =====================================================================================
*   Kishore Reddy  19 Aug 2020                             Initial version
*   =====================================================================================
*/
global class CaseCloseWorkforceSchedule implements Schedulable { 
    
    global void execute (SchedulableContext ctx) { 
        CaseCloseWorkforceBatch batch = new CaseCloseWorkforceBatch();  
        Database.executeBatch(batch, 99);
    } 
    
}