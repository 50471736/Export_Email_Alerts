//---------------------------------------------------------
// Export Email Alerts
//---------------------------------------------------------

//---------------------------------------------------------
// Known issues
//   - When you click an alert URL in the spreadsheet, the result is always shown in SFDC Classic, not Lighting.
//   - If you open the spreadsheet in LibreOffice Calc, the links sometimes misbehave: are truncated; or CTRL-click doesn't work
//---------------------------------------------------------

//---------------------------------------------------------
// Author: Sir Rodney MacKenzie mr.jcrm@gmail.com
// Created: February 2023
// Purpose: Dumps all email alerts (and Flow email actions) to a spreadsheet and emails it to current user
// Strategy: Uses REST/Tooling API to read the WorkflowAlert and Flow sObjects
// Strategy: Uses batch Apex in order to handle orgs with large (> 100) numbers of email alerts
// Updates made to Salesforce data: None
//
// How to run
//  - Deploy these classes, then create a flow with a screen element whose button runs Apex Action "Export Email Alerts"
//  - Or, execute anonymous: Database.executeBatch(new BATCH_ExportEmailAlerts(),100); // Last parameter is batch size (min=1, max=100)
//
// Notes
//   - Implemented as batch Apex (not queueable Apex, because queueable has a governor limit of 100 HTTP callouts)
//
// Miscellaneous
//  - To monitor heap size: if (Limits.getHeapSize > 8000000){}
//  - URL = protocol + host or domain + path + querystring
//  - How to initialise a string list: for (string x : new list<string> {'a','b','c'})
//---------------------------------------------------------

//---------------------------------------------------------
public class BATCH_ExportEmailAlerts implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts  { // was global
//---------------------------------------------------------
static final string version = '1.1';

//---------------------------------------------------------
@InvocableMethod(label='Export Email Alerts') public static void exportEmailAlerts() {
//---------------------------------------------------------
// This method makes the class available as an Apex Action in flow builder
Database.executeBatch(new BATCH_ExportEmailAlerts(),1); // When run from a flow, use batchsize of 1 to be on the safe side
}

// Governor statistics
public integer max_cpu = 0;
public integer max_dmlrows = 0;
public integer max_dmlstmt = 0;
public integer max_heap = 0;
public integer max_queries = 0;
public integer max_queryrows = 0;
public integer max_emails = 0;
public integer max_batchsize = 0;
    
// Vars for any batch job
public string exceptions=''; // Summary of all exceptions caught when this job ran.
public datetime startTime = system.now();
static final string SFDC_URL = Url.getSalesforceBaseUrl().toExternalForm(); // E.g., Url.getOrgDomainUrl().toExternalForm() (Canonical URL) or Url.getSalesforceBaseUrl().toExternalForm() (Host-independent URL)
    
// Vars for this app
public string alertCSV = '';
static final string thisAppName = 'ExportEmailAlerts'; 
static final string APIVER = 'v56.0';
static final string query_start_workflowalert = 'Select+id+from+workflowalert';
static final string query_start_flow = 'Select+id+from+flow+where+status=\'active\'+and+processtype=\'flow\'';
public integer totalEmailAddresses = 0;
public final string CSVHeading = 
  '"Email",' +
  '"Alert name",' + // Email alert name, or Flow name + "/" + Email action name
  '"Alert type",' + // Flow email action, or Email alert
  '"User name",' + // First Name + Last Name (applies only to SFDC users) ????
  '"Recipient type",' + // Group, Role, Role-Sub, User, CcEmail
  '"Recipient value",' + // GroupName, RoleName, UserFirstLast ????
  '"User status",' + // SFDC user active or inactive
  '"Alert URL",' + // SFDC_URL/01W... (WorkflowAlert), or SFDC_URL/301... (Flow)
  '\n'; 

//---------------------------------------------------------
public BATCH_ExportEmailAlerts() { // Constructor (was global)
//---------------------------------------------------------
alertCSV = CSVHeading; 
} // end method

//---------------------------------------------------------
public Iterable<String> start(Database.BatchableContext BC) {
//---------------------------------------------------------
list<string> alertIds = new list<string>();

// Set up common HTTP parameters
HttpRequest req = new HttpRequest();
Http h = new Http();
HttpResponse res;
req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
req.setHeader('Content-Type', 'application/json');
req.setMethod('GET'); 

// Get WorkflowAlert ids
req.setEndpoint(SFDC_URL + '/services/data/'+ APIVER + '/tooling/query?q=' + query_start_workflowalert);
getAlertIds (h, req, res, alertIds);
// Get Flow ids
req.setEndpoint(SFDC_URL + '/services/data/'+ APIVER + '/tooling/query?q=' + query_start_flow);
getAlertIds (h, req, res, alertIds);

alertIds.clear();
for (integer x=0; x<500; x++) {
  alertIds.add ('01W3c000000gDu2EAE'); // add WorkflowAlerts
  alertIds.add ('3013c000000gQpfAAE'); // add Flows
} // end for

return alertIds; // Return list of alert Ids.
} // end method 

//---------------------------------------------------------
private void getAlertIds (Http h, HttpRequest req, HttpResponse res, list<string> alertIds) {
//---------------------------------------------------------
res = h.send(req);
if (res.getStatus() != 'ok') { 
  exceptions = exceptions + '\ngetAlertIds: HTTP GET error: ' + res.getStatus(); 
}
else {
  JSONParser parser = JSON.createParser(res.getBody());
  while (parser.nextToken() != null) {
    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Id')) {
      parser.nextToken(); // Get the Id.
      alertIds.add(parser.getText()); // Add the Id to a list.
    } // end if
  } // end while
} // end if
} // end method

//---------------------------------------------------------
public void execute(Database.BatchableContext BC, List<String> scope) { // was global
//---------------------------------------------------------
HttpRequest req = new HttpRequest();
Http h = new Http();
HttpResponse res;
req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
req.setHeader('Content-Type', 'application/json');
req.setMethod('GET'); 

for(Integer x = 0; x < scope.size(); x++) {
  if (scope[x].left(3) == '01W') { // 01W rec prefix = workflowalert
    req.setEndpoint(SFDC_URL + '/services/data/'+ APIVER + '/tooling/sobjects/WorkflowAlert/' + scope[x]);
    res = h.send(req);
    if (res.getStatus() != 'ok') {
      system.debug('glixl1 rectype 01W status=' + res.getStatus() + ', id=' + scope[x]);
    } else {
      addToSpreadsheet_WorkflowAlert(res);
    }
  } 
  else if (scope[x].left(3) == '301') { // 301 rec prefix = flow)
    req.setEndpoint(SFDC_URL + '/services/data/'+ APIVER + '/tooling/sobjects/Flow/' + scope[x]);
    res = h.send(req);
    if (res.getStatus() != 'ok') {
      system.debug('glixl2: rectype 301 status=' + res.getStatus() + ', id=' + scope[x]);
    } else {
      addToSpreadsheet_Flow(res);
    }
  } // end if    
} // end for

// Update governor stats for this batch
updateBatchGovernorStats(scope.size());
} // end method

//----------------------------------------------------------
public void finish(Database.BatchableContext BC) { // was global
//---------------------------------------------------------
emailJobResult (BC);
} // end method

//---------------------------------------------------------
public void addToSpreadsheet_WorkflowAlert(HttpResponse res) {
//---------------------------------------------------------
WorkflowAlert w = (WorkflowAlert)JSON.deserialize(res.getBody(), WorkflowAlert.class);

if (w.CcEmails != null) { 
  list<string> ccEmailList = new list<string>(w.CcEmails.split(','));
  for (integer x=0; x < ccEmailList.size(); x++) {
    totalEmailAddresses++;
    alertCSV = alertCSV + 
      '"' + ccEmailList[x] + '",' +
      '"' + w.Description + '",' +
      '"' + w.attributes.type + '",' + 
      '" ",' + 
      '" ",' +
      '"' + 'Cc email' + '",' + 
      '" ",' +
      '"' + SFDC_URL + '/' + w.id + '",' +      
      '\n';
  }
}

if (w.metadata.recipients.size() > 0) {
  system.debug('ok 1, description=' + w.description + ', recips=' + w.metadata.recipients.size());
  for (integer x=0; x < w.metadata.recipients.size(); x++) {
    system.debug('ok 2' + ', recip.type=' + w.Metadata.recipients[x].type); 
    switch on w.Metadata.recipients[x].type {
      when 'group' {
        system.debug('ok 1: group, desc=' + w.description);
        list<user> userList = getUserList_Group(w.Metadata.recipients[x].recipient);
        if (userList.size() > 0) {
          system.debug('ok 1.1');
          for (integer y=0; y < userList.size(); y++) {
            system.debug('ok 1.2');
            totalEmailAddresses++;
            alertCSV = alertCSV + 
              '"' + userList[y].email + '",' +
              '"' + w.Description + '",' +
              '"' + w.attributes.type + '",' + 
              '"' + userList[y].firstName + ' ' + userList[y]. lastName + '",' +
              '"' + w.Metadata.recipients[y].type + '",' +
              '"' + w.Metadata.recipients[y].recipient + '",' +
              '"' + (userList[y].isActive == true ? 'Active' : 'Inactive') + '",' +
              '"' + SFDC_URL + '/' + w.id + '",' + 
              '\n';
          }
        }
      }
      when 'role' {
        system.debug('ok 2: role, desc=' + w.Description);
      }
      when 'roleSubordinates' {
        system.debug('ok 3: role+sub, desc=' + w.Description);
      }
      when 'user' {
        system.debug('ok 4: user, desc=' + w.Description);
      }
    } // end switch

  }
}

/* To-do 
Recip structure:
  - list<string> RecipientName_list = new list<string>(); // Group("groupName"), Role("roleName"), User("xx@xx.com,yy@yy.com")
  - list<string> RecipientType_List = new list<string>(); // "Public groups", "Role", "roleSubordinates", "User"
SOQL for single SFDC user: 
  - string userIsActive, userNameFirstLast: if recipType='user:' SELECT isactive,lastname,firstname FROM user WHERE email = recipients[x].name
SOQL to Find SFDC users who belong to the following:
  - Role:
      SELECT Id FROM UserRole WHERE Name = JSON.RoleName
      SELECT isactive,lastname,firstname,email FROM User WHERE UserRoleId = userRole.id
  - Role+Sub:
      SELECT xxx
  - Group
      SELECT Id FROM Group WHERE Name = JSON.GroupName 
      SELECT UserOrGroupId FROM GroupMember WHERE GroupId = Group.Id
      Loop: SELECT isactive,lastname,firstname,email FROM User WHERE Id = GroupMember.UserOrGroupId
*/
} // end method

//---------------------------------------------------------
private list<user> getUserList_Group (string groupName) {
//---------------------------------------------------------
list<user> userList = new list <user>();
list<group> groupId = new list<group> ([SELECT Id FROM Group WHERE Name = :groupName LIMIT 1]);
if (groupId.size() > 0) {
  id groupid0 = groupId[0].id;
  list<GroupMember> groupMembers = new list<groupmember> ([SELECT UserOrGroupId FROM groupmember WHERE GroupId = :groupid0]);
  list<id> groupmemZ = new list<id>();
  for (integer x=0; x < groupMembers.size(); x++) {
    groupmemZ.add(groupMembers[x].UserOrGroupId);
  }
  userList = [SELECT Id, Email, FirstName, LastName, IsActive FROM User WHERE Id in :groupmemZ];
}
  return userList;
} // end method

  //SELECT Id FROM Group WHERE Name = JSON.GroupName 
  //SELECT UserOrGroupId FROM GroupMember WHERE GroupId = Group.Id
  //Loop: SELECT isactive,lastname,firstname,email FROM User WHERE Id = GroupMember.UserOrGroupId  

//---------------------------------------------------------
public void addToSpreadsheet_Flow(HttpResponse res) {
//---------------------------------------------------------
Flow f = (Flow)JSON.deserialize(res.getBody(), Flow.class);
// To be in the spreadsheet, the flow must have an "emailSimple" action.
for (integer a=0; a < f.metadata.actionCalls.size(); a++) {
  if (f.metadata.actionCalls[a].actionType == 'emailSimple') {
    for (integer b=0; b < f.metadata.actionCalls[a].inputParameters.size(); b++) {
      if (f.metadata.actionCalls[a].inputParameters[b].name == 'emailAddresses') { 
        list<string> emailList = new list<string>(f.metadata.actionCalls[a].inputParameters[b].value.stringValue.split(','));
        for (integer x=0; x < emailList.size(); x++) {
          totalEmailAddresses++;
          alertCSV = alertCSV + 
          '"' + emailList[x] + '",' +
          '"' + f.MasterLabel + '/' + f.Metadata.actionCalls[a].label + '",' +
          '"' + f.attributes.type + '",' + 
          '" ",' +
          '" ",' +
          '" ",' +
          '" ",' +
          '"' + SFDC_URL + '/' + f.id + '",' +
          '\n';
        }
      }
    }
  } // end if
} // end for

} // end method
      
//---------------------------------------------------------
public void emailJobResult(Database.BatchableContext BC) {
//---------------------------------------------------------
//string elapsedTime = ((system.now().getTime() - startTime.getTime()) / 1000.0 / 60.0 / 60.0).format();
string elapsedTime = convertMsToHHMMSS (system.now().getTime() - startTime.getTime());

Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
AsyncApexJob asyncApexJob = 
  [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems 
  FROM AsyncApexJob 
  WHERE Id = :BC.getJobId()];

string subjectLine;
if (asyncApexJob.numberOfErrors > 0) {
  subjectLine = thisAppName + ' ' + asyncApexJob.Status + '. ' + asyncApexJob.numberOfErrors + ' batches had errors';
}
else if (totalEmailAddresses == 0) {
  subjectLine = 'Your org has no email alerts.';
}
else {
  subjectLine = 'Here\'s your list of email alerts';
  Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
  blob csvBlob = Blob.valueOf(alertCSV);
  string csvname= 'Email alerts.csv'; csvAttc.setFileName(csvname);
  csvAttc.setBody(csvBlob);
  mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
}

String emailBody = '\n' +
'\n' + thisAppName + ' version ' + version +
'\n' + 'Job status: ' + asyncApexJob.Status + 
'\n' + 'There are ' + totalEmailAddresses.format() + ' email addresses used by alerts and Flow email actions.' +
'\n' + 'Batch size=' + string.valueOf(max_batchsize.format()) +
'\n' + 'Elapsed time ' + elapsedTime + 
'\n\n' + 'Governor statistics: ' + summarizeBatchGovernorStats() +
'\n\n' + 'Exceptions: ' + exceptions;

mail.setSubject(subjectLine);
Mail.setCharset('UTF-8');
mail.setReplyTo('noreply@salesforce.com');
mail.setSenderDisplayName('Salesforce');
mail.setPlainTextBody(emailBody);
mail.setToAddresses(UserInfo.getUserEmail().split(','));
system.debug ('glixl emailJobResult: emailMessage=' + emailBody);
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
} // end method

//---------------------------------------------------------
private string convertMsToHHMMSS (long ms) {
//---------------------------------------------------------
long elapsedSecs = ms/1000;
string hrs = elapsedSecs / 3600 + 'h '; // test was 7510 secs elapsed time
string mins = math.Mod(elapsedSecs, 3600) / 60 + 'm ';
string secs = math.Mod( math.Mod(elapsedSecs, 3600), 60) + 's';
return hrs + mins + secs;
}

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
//
string summary = '';
summary += '\n' + 'Batch with most cpu=' + String.valueOf(max_cpu.format()) + 'ms. Limit=' + String.valueOf(Limits.getLimitCpuTime().format()) + 'ms';
summary += '\n' + 'Batch with biggest heapsize=' + String.valueOf(max_heap.format()) + ' bytes. Limit=' + String.valueOf(Limits.getLimitHeapSize().format()) + ' bytes';
//summary += '\n' + 'Batch with most DML statements=' + String.valueOf(max_dmlstmt.format()) + '. Limit=' + String.valueOf(Limits.getLimitDmlStatements().format());
//summary += '\n' + 'Batch with most DML rows=' + String.valueOf(max_dmlrows.format()) + '. Limit=' + String.valueOf(Limits.getLimitDmlRows().format());
summary += '\n' + 'Batch with most SOQL queries=' + String.valueOf(max_queries.format()) + '. Limit=' + String.valueOf(Limits.getLimitQueries().format());
summary += '\n' + 'Batch with most SOQL rows=' + String.valueOf(max_queryrows.format()) + '. Limit=' + String.valueOf(Limits.getLimitQueryRows().format());
//summary += '\n' + 'Batch with most email invocations=' + String.valueOf(max_emails.format()) + '. Limit=' + String.valueOf(Limits.getLimitEmailInvocations().format());
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
  public string MasterLabel;
}

public class fl_attributes {
  public string type;
}

public class fl_Metadata {
  public list<fl_actionCalls> actionCalls;
}

public class fl_actionCalls {
  public string actionType; // "emailSimple"
  public list<fl_inputParameters> inputParameters;
  public string label;
}

public class fl_inputParameters {
  public string name; // "emailAddresses"
  public fl_value value; // was "public fl_value value;"
}

public class fl_value {
  public string stringValue; // "x@x.com,y@y.com"
}

} // end class