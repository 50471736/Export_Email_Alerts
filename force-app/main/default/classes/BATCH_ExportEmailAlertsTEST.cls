@istest
//---------------------------------------------------------------------------------
public with sharing class BATCH_ExportEmailAlertsTEST {
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
static testmethod void test_CodeCvg_WorkflowAlert() {
//--------------------------------------------------------------------------------
Test.startTest();
Test.setMock(HttpCalloutMock.class, new BATCH_ExportEmailAlertsMockHTTP('WorkflowAlert'));
Database.executeBatch(new BATCH_ExportEmailAlerts(),1);
Test.stopTest();
} // end method

//--------------------------------------------------------------------------------
static testmethod void test_CodeCvg_EmailAction() {
//--------------------------------------------------------------------------------
Test.startTest();
Test.setMock(HttpCalloutMock.class, new BATCH_ExportEmailAlertsMockHTTP('EmailAction'));
Database.executeBatch(new BATCH_ExportEmailAlerts(),1);
Test.stopTest();
} // end method

//--------------------------------------------------------------------------------
static testmethod void test_Functionality() {
//--------------------------------------------------------------------------------
Test.startTest();
Test.setMock(HttpCalloutMock.class, new BATCH_ExportEmailAlertsMOCKHTTP('WorkflowAlert'));
BATCH_ExportEmailAlerts b = new BATCH_ExportEmailAlerts();
HttpResponse res = new HttpResponse();
b.addToSpreadsheet_WorkflowAlert(res);
//assert xxx
Test.stopTest();
} // end method

} // end class