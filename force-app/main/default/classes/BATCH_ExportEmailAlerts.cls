//---------------------------------------------------------
// Export Email Alerts
//---------------------------------------------------------

//---------------------------------------------------------
// Author: Sir Rodney MacKenzie mr.jcrm@gmail.com
// Created: February 2023
// Purpose: Dumps all email alerts (and Flow email actions) to a spreadsheet and emails it to current user
// Strategy: Uses REST/Tooling API to read the WorkflowAlert and Flow sObjects
// Strategy: Uses batch Apex to handle orgs with large (> 100) numbers of email alerts
// Updates made to Salesforce data: None
//
// How to run
//  - Create a flow with a screen element whose button runs the Apex Action "Export Email Alerts"
//  - NOTE: This Apex class cannot be run via execute anonymous
//
// Notes
//   - Implemented as batch Apex, not queueable Apex, because with queueable the app would only handle orgs having 100 or fewer email alerts, due to governor limit on HTTP callouts.
//
// Miscellaneous
//  - To monitor heap size: if (Limits.getHeapSize > 8000000){}
//  - URL = protocol + host or domain + path + querystring
//---------------------------------------------------------

//---------------------------------------------------------
public class BATCH_ExportEmailAlerts implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts  { // was global
//---------------------------------------------------------

//---------------------------------------------------------
@InvocableMethod(label='Export Email Alerts') public static void exportEmailAlerts() {
// This method makes the class available as an Apex Action in flow builder
//---------------------------------------------------------
Database.executeBatch(new BATCH_ExportEmailAlerts(),100); // Specify batch size (min=1, max=100)
}

//---------------------------------------------------------

// Governor statistics
public integer batches=0;
public integer max_cpu = 0;
public integer max_dmlrows = 0;
public integer max_dmlstmt = 0;
public integer max_heap = 0;
public integer max_queries = 0;
public integer max_queryrows = 0;
public integer max_emails = 0;
public integer max_batchsize = 0;
    
// Vars for all batch jobs
public string exceptions=''; // Summary of all exceptions caught when this job ran.
public integer dbErrors=0;
public integer warnings=0;
public datetime startTime = system.now();
    
// Vars for this app
public string alertCSV;
static final string thisAppName = 'ExportEmailAlerts'; 
static final string APIVER = 'v56.0';
static final string query_start_workflowalert = 'Select+id+from+workflowalert';
static final string query_start_flow = 'Select+id+from+flow';
public integer TotalWorkflowAlerts = 0;

//---------------------------------------------------------
public class CSVRecord { // wrapper class for CSV
//---------------------------------------------------------
  public string Email;
  public string AlertName;
  public string UserFirstLast; 
  public string RecipientType; // Group, Role, Role-Sub, User, CcEmail
  public string RecipientName; // GroupName, RoleName, UserFirstLast
  public string UserStatus;
  public string AlertType; // Flow email action, Email alert
  public string AlertId; // 01W or 301
} // end class

//---------------------------------------------------------
public BATCH_ExportEmailAlerts() { // was global
//---------------------------------------------------------
// Constructor
//list<CSVRecord> CSVRecordList = new list<CSVRecord>();
} // end method
    
//---------------------------------------------------------
public Iterable<String> start(Database.BatchableContext BC) {
//---------------------------------------------------------
//for (string x : new list<string> {'a','b','c'}) {
list<string> workflowAlertIds = new list<string>();
HttpRequest req = new HttpRequest();
req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
req.setHeader('Content-Type', 'application/json');
req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/'+ APIVER + '/tooling/query?q=' + query_start_workflowalert);
req.setMethod('GET'); 
Http h = new Http();
HttpResponse res = h.send(req);
if (res.getStatus() != 'ok') { 
  exceptions = exceptions + '\nstart.HTTP GET error: Status=' + res.getStatus(); 
}
else {
  JSONParser parser = JSON.createParser(res.getBody());
  while (parser.nextToken() != null) {
    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Id')) {
      parser.nextToken(); // Get the Id.
      workflowAlertIds.add(parser.getText()); // Add the Id to a list.
    } // end if
  } // end while
  TotalWorkflowAlerts = workflowAlertIds.size(); // total number of alerts, for reporting purposes
} // end if

return workflowAlertIds; // Return list of alert Ids.
} // end method 
        
//---------------------------------------------------------
public void execute(Database.BatchableContext BC, List<String> scope) { // was global
//---------------------------------------------------------
batches++;
// ------------- Create spreadsheet rows for WorkflowAlert (rec prefix=01W)
// if (scope[0].left(3) == '01W') { // 01W rec prefix = workflowalert

HttpRequest req = new HttpRequest();
Http h = new Http();
HttpResponse res;
req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
req.setHeader('Content-Type', 'application/json');
req.setMethod('GET'); 

for(Integer x = 0; x < scope.size(); x++) {
  if (scope[0].left(3) == '01W') { // 01W rec prefix = workflowalert
    req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/'+ APIVER + '/tooling/sobjects/WorkflowAlert/' + scope[x]);
    res = h.send(req);
    addToSpreadsheet_WorkflowAlert(res);
  } 
  else if (scope[0].left(3) == '301') { // 301 rec prefix = flow)
    req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/'+ APIVER + '/tooling/sobjects/WorkflowAlert/' + scope[x]);
    res = h.send(req);
    addToSpreadsheet_Flow(res);
  } // end if    
} // end for

// Update governor stats for this batch
updateBatchGovernorStats(scope.size());
} // end method

//----------------------------------------------------------
public void finish(Database.BatchableContext BC) { // was global
//---------------------------------------------------------
alertCSV = 
'"Title 1",' + '"Title 2",' + '"Title 3",' + '"Title 4",' + '"Title 5",' + '"Title 6",' + '"Title 7",' + '"Title 8"' + '\n' + 
'"aaa",' + '"bbb",' + '"ccc",' + '"ddd",' + '"eee",' + '"fff",' + '"ggg",' + '"hhh"' + '\n' + 
'"aaa1",' + '"bbb2",' + '"ccc3",' + '"ddd4",' + '"eee5",' + '"fff6",' + '"ggg7",' + '"hhh8"';
emailCSV(alertCSV);
emailJobResult (BC);
} // end method

//---------------------------------------------------------
public void addToSpreadsheet_WorkflowAlert(HttpResponse res) {
//---------------------------------------------------------

WorkflowAlert w = (WorkflowAlert)JSON.deserialize(res.getBody(), WorkflowAlert.class);

// JSON fields 
list<string> RecipientName_list = new list<string>(); // Group("groupName"), Role("roleName"), User("userFirstName userLastName")
list<string> RecipientType_List = new list<string>(); // "Public groups", "Role", "Role and Subordinates", "User"
string CcEmails; // list of emails delimited by commas
string alertType; // "Email alert" or "Flow email action"
string alertName; // aka workflowAlert.Description
string userStatus; // SELECT status FROM user WHERE firstname = %firstname AND lastname = %lastname

integer Type_Count=0; Integer CcEmails_Count=0;
JSONParser parser = JSON.createParser(res.getBody());
while (parser.nextToken() != null) {
    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Description')) {
        parser.nextToken();
        alertName = parser.getText();
    } // end if
    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Recipient')) {
        parser.nextToken();
        recipientName_list.add(parser.getText());
    } // end if
    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Type')) { // There's two different Type keys.
        Type_Count++;
        parser.nextToken();
        if (Type_Count == 1) { // First Type is alert.type
            alertType = parser.getText();
        }
        else { // Second & subsequent Types are recipient.types
            recipientType_list.add(parser.getText());
          } // end if
    } // end if
    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'CcEmails')) {
        CcEmails_Count++;
        if (CcEmails_Count == 1) { // There are duplicate CcEmail keys after first one, ignore them.
            parser.nextToken();
            CcEmails = parser.getText();
        } // end if
    } // end if
} // end while
system.debug('glixl add workflowalert to ss: ' +
'RecipientName_list=' + RecipientName_list + 
'RecipientType_List=' + RecipientType_List + 
'CcEmails=' + CcEmails + 
'alertType=' + alertType +  
'alertName=' + alertName);

} // end method

//---------------------------------------------------------
public void addToSpreadsheet_Flow(HttpResponse res) {
//---------------------------------------------------------
Flow f = (Flow)JSON.deserialize(res.getBody(), Flow.class);
} // end method
      
//---------------------------------------------------------
private void EmailCSV(string emailAlerts) {
//---------------------------------------------------------
Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
blob csvBlob = Blob.valueOf(emailAlerts);
string csvname= 'Email alerts.csv'; csvAttc.setFileName(csvname);
csvAttc.setBody(csvBlob);
Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
String[] toAddresses = new list<string> {'test@test.com'};
String subject ='Here\'s your list of email alerts'; email.setSubject(subject);
email.setSenderDisplayName('Salesforce');
email.setToAddresses(UserInfo.getUserEmail().split(','));
email.setPlainTextBody('List of email alerts');
email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
}

//---------------------------------------------------------
public void emailJobResult(Database.BatchableContext BC) {
//---------------------------------------------------------
string elapsedTime = ((system.now().getTime() - startTime.getTime()) / 1000.0 / 60.0 / 60.0).format();
AsyncApexJob asyncApexJob = 
  [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems 
  FROM AsyncApexJob 
  WHERE Id = :BC.getJobId()];

integer numberOfErrors = dbErrors + asyncApexJob.numberOfErrors;

String emailMessage = '\n' +
'\n' + 'There are ' + TotalWorkflowAlerts.format() + ' Workflow Alerts in this org.' +
'\n' + 'Job status: ' + asyncApexJob.Status + 
'\n' + 'There were ' + String.valueOf(dbErrors.format()) + ' dbErrors.' +
'\n' + 'There were ' + String.valueOf(warnings.format()) + ' warnings.' +
'\n' + 'Biggest batch size=' + string.valueOf(max_batchsize.format()) +
'\n' + asyncApexJob.numberOfErrors + ' batches had errors.' +
'\n' + asyncApexJob.jobItemsProcessed + ' batches processed.' +
'\n' + 'Elapsed time ' + elapsedTime + ' hrs.' + 
'\n\n' + 'Governor statistics: ' + summarizeBatchGovernorStats() +
'\n\n' + 'Exceptions: ' + exceptions;

Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setSubject(thisAppName + ' ' + asyncApexJob.Status + '. ' + NumberOfErrors + ' errors');
Mail.setCharset('UTF-8');
mail.setReplyTo('noreply@salesforce.com');
mail.setSenderDisplayName(thisAppName);
mail.setPlainTextBody(emailMessage);
mail.setToAddresses(UserInfo.getUserEmail().split(','));
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
system.debug ('glixl emailJobResult: emailMessage=' + emailMessage);
} // end method

//---------------------------------------------------------
private void updateBatchGovernorStats(integer scopeSize) {
//----------------------------------------------------------
if (scopeSize > max_batchsize) max_batchsize = scopeSize;
if (Limits.getCpuTime() > max_cpu) max_cpu = Limits.getCpuTime();
if (Limits.getHeapSize() > max_heap) max_heap = Limits.getHeapSize();
if (Limits.getDMLStatements() > max_dmlstmt) max_dmlstmt = Limits.getDmlStatements();
if (Limits.getDMLRows() > max_dmlrows) max_dmlrows = Limits.getDmlRows();
if (Limits.getQueries() > max_queries) max_queries = Limits.getQueries();
if (Limits.getQueryRows() > max_queryrows) max_queryrows = Limits.getQueryRows();
if (Limits.getEmailInvocations() > max_emails) max_emails = Limits.getEmailInvocations();
} // end method 

//---------------------------------------------------------
private string summarizeBatchGovernorStats() {
//---------------------------------------------------------
string summary = '';

summary += '\n' + 'Batch with most cpu=' + String.valueOf(max_cpu.format()) + 'ms. Limit=' + String.valueOf(Limits.getLimitCpuTime().format()) + 'ms';
summary += '\n' + 'Batch with biggest heapsize=' + String.valueOf(max_heap.format()) + '. Limit=' + String.valueOf(Limits.getLimitHeapSize().format());
summary += '\n' + 'Batch with most DML statements=' + String.valueOf(max_dmlstmt.format()) + '. Limit=' + String.valueOf(Limits.getLimitDmlStatements().format());
summary += '\n' + 'Batch with most DML rows=' + String.valueOf(max_dmlrows.format()) + '. Limit=' + String.valueOf(Limits.getLimitDmlRows().format());
summary += '\n' + 'Batch with most SOQL queries=' + String.valueOf(max_queries.format()) + '. Limit=' + String.valueOf(Limits.getLimitQueries().format());
summary += '\n' + 'Batch with most SOQL rows=' + String.valueOf(max_queryrows.format()) + '. Limit=' + String.valueOf(Limits.getLimitQueryRows().format());
summary += '\n' + 'Batch with most email invocations=' + String.valueOf(max_emails.format()) + '. Limit=' + String.valueOf(Limits.getLimitEmailInvocations().format());

return summary;
} // end method

//---------------------------------------------------------
// Wrapper class for workFlowAlert sObject
//---------------------------------------------------------
public class WorkflowAlert {
  public wf_attributes attributes;
  public string Id;
  public wf_Metadata Metadata;
  public string CcEmails;
  public string Description;  
}

public class wf_attributes {
  public string type;
}

public class wf_Metadata {
  public list<wf_recipients> recipients;
}

public class wf_recipients {
  public string recipient;
  public string type;
}

//---------------------------------------------------------
// Wrapper class for Flow sObject
//---------------------------------------------------------
public class Flow {
  public fl_attributes attributes;
  public string Id;
  public fl_Metadata Metadata;
  public string CcEmails;
  public string Description;  
}

public class fl_attributes {
  public string type;
}

public class fl_Metadata {
  public list<fl_recipients> recipients;
}

public class fl_recipients {
  public string recipient;
  public string type;
}

//---------------------------------------------------------
// How to use wrapper class
//---------------------------------------------------------
private void shit() {
String jsonInput = '{  "attributes" : {    "type" : "WorkflowAlert",    "url" : "servicesdatav56.0toolingsobjectsWorkflowAlert01W3c000000gDu2EAE"  },  "Id" : "01W3c000000gDu2EAE",  "TemplateId" : "00X80000001ExRoEAK",  "CcEmails" : "a@a.com,b@b.com",  "Description" : "aTest9",  "DeveloperName" : "aTest9",  "SenderType" : "CurrentUser",  "ManageableState" : "unmanaged",  "NamespacePrefix" : null,  "CreatedDate" : "2023-02-23T21:03:21.000+0000",  "CreatedById" : "00580000001hjv1AAA",  "LastModifiedDate" : "2023-03-09T16:56:17.000+0000",  "LastModifiedById" : "00580000001hjv1AAA",  "EntityDefinitionId" : "Account",  "Metadata" : {    "ccEmails" : [ "a@a.com,b@b.com" ],    "description" : "aTest9",    "protected" : false,    "recipients" : [ {      "field" : null,      "recipient" : "junkyard@yahoo.com",      "type" : "user"    }, {      "field" : null,      "recipient" : "mr.jcrm@gmail.com",      "type" : "user"    } ],    "senderAddress" : null,    "senderType" : "CurrentUser",    "template" : "unfiledp$?/ublicSalesNewCustomerEmail",    "urls" : null  },  "FullName" : "Account.aTest9"}';
WorkflowAlert w = (WorkflowAlert)JSON.deserialize(jsonInput, WorkflowAlert.class);
system.debug('---------------------------------------------------------------------------------');
system.debug('id=' + w.id + ' ccemails=' + w.ccemails + ' desc=' + w.Description + ' type=' + w.attributes.type);
system.debug('recip0=' + w.metadata.recipients[0].recipient + ' type=' + w.metadata.recipients[0].type);
} // end method

} // end class