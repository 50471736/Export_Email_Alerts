@isTest
//---------------------------------------------------------
global class BATCH_ExportEmailAlertsMockHTTP implements HttpCalloutMock {
//---------------------------------------------------------
public string alertType;

//---------------------------------------------------------
public BATCH_ExportEmailAlertsMOCKHTTP (string alertType) {
//---------------------------------------------------------
this.alertType = alertType;
}

//---------------------------------------------------------
global HTTPResponse respond(HTTPRequest req) {
//---------------------------------------------------------
// Optionally, only send a mock response for a specific endpoint and method:
// - System.assertEquals('https://example.com/example/test', req.getEndpoint());
// - System.assertEquals('GET', req.getMethod());
        
// Fabricate an HTTP response
HttpResponse res = new HttpResponse();
res.setHeader('Content-Type', 'application/json');
res.setBody('{"attributes" : { "type" : "WorkflowAlert", "url" : "/services/data/v56.0/tooling/sobjects/WorkflowAlert/01Wxxxxxxxxxxxxxxx" }, "Id" : "01Wxxxxxxxxxxxxxxx", "TemplateId" : "00Xxxxxxxxxxxxxxxx", "CcEmails" : "aaa@aaa.com,bbb@bbb.org", "Description" : "testAlertName", "DeveloperName" : "testAlertName", "SenderType" : "CurrentUser",  "ManageableState" : "unmanaged",  "NamespacePrefix" : null, "CreatedDate" : "2023-02-23T21:03:21.000+0000", "CreatedById" : "005xxxxxxxxxxxxxxx", "LastModifiedDate" : "2023-02-23T23:38:43.000+0000", "LastModifiedById" : "005xxxxxxxxxxxxxxx", "EntityDefinitionId" : "sobject", "Metadata" : { "ccEmails" : [ "a@a.com,b@b.org" ], "description" : "aTest9", "protected" : false, "recipients" : [ { "field" : null, "recipient" : "CEO","type" : "roleSubordinates"  }, { "field" : null, "recipient" : "xxx@xxx.com", "type" : "user" } ],  "senderAddress" : null, "senderType" : "CurrentUser", "template" : "xxx",  "urls" : null  }, "FullName" : "sObject.testAlertName" }');
res.setStatusCode(200); res.setStatus('ok');
system.debug('Mock: alertType=' + alertType);
return res;
}
}