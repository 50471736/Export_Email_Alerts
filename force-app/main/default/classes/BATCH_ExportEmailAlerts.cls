//---------------------------------------------------------
// Export Email Alerts
//---------------------------------------------------------

//---------------------------------------------------------
// Purpose: Exports all email alerts (and Flow email actions) to a CSV spreadsheet and emails it to current user
// Strategy: Uses REST/Tooling API to read the WorkflowAlert and Flow sObjects
// Strategy: Uses batch Apex to handle large alert volumes (>100)
// Updates made to Salesforce data: None
// Author: Sir Rodney MacKenzie mr.jcrm@gmail.com, February 2023
//
// How to run (admin privileges are recommended)
//  - Execute anonymous: Database.executeBatch(new BATCH_ExportEmailAlerts(),50); // Last parameter is batch size (min=1, max=100)
//  - Or, deploy these classes, then create a flow with a screen element whose button runs Apex Action "Export Email Alerts"
//
// Known issues
//   - After clicking an alert URL in the CSV, the detail page is shown in SFDC Classic, not Lightning.
//   - When viewed in LibreOffice Calc, the links in the CSV are sometimes truncated or non-responsive.
//---------------------------------------------------------

//---------------------------------------------------------
public class BATCH_ExportEmailAlerts implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts  {
//---------------------------------------------------------

static final string version = '1.02-beta';
  
//---------------------------------------------------------
@InvocableMethod(label='Export Email Alerts') public static void exportEmailAlerts() {
//---------------------------------------------------------
// This method makes the class available as an Apex Action in flow builder
Database.executeBatch(new BATCH_ExportEmailAlerts(),1); // Use batchsize=1 to be on the safe side.
} // end method
  
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
  public string errorString= ''; // List of errors encountered by this job.
  public integer appErrorCount = 0;
  integer totalErrors = 0;
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
    '"Alert type",' + // "Flow email action" or "Email alert"
    '"User name",' + // First Name + Last Name (applies only to SFDC users) ????
    '"Recipient type",' + // Group, Role, Role-Sub, User, CcEmail
    '"Recipient value",' + // GroupName, RoleName, UserFirstLast ????
    '"User status",' + // SFDC user active or inactive
    '"Alert URL",' + // SFDC_URL/01W... (WorkflowAlert), or SFDC_URL/301... (Flow)
    '\n'; 
  
  //--------------------------------------------------------------------
  // These static variables can be examined by a test class to verify the app works correctly.
  //--------------------------------------------------------------------
  @TestVisible static string copyOfAlertCSV; 
  
  //---------------------------------------------------------
  public BATCH_ExportEmailAlerts() { // Constructor
  //---------------------------------------------------------
  alertCSV = CSVHeading; // Initialize CSV
  } // end method
  
  //---------------------------------------------------------
  public Iterable<String> start(Database.BatchableContext BC) {
  //---------------------------------------------------------
  list<string> alertIds = new list<string>();
  
  // Set up common HTTP parameters for JSON web callouts
  HttpRequest req = new HttpRequest();
  Http h = new Http();
  HttpResponse res;
  req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
  req.setHeader('Content-Type', 'application/json');
  req.setMethod('GET'); 
  
  // Get WorkflowAlert ids
  req.setEndpoint(SFDC_URL + '/services/data/'+ APIVER + '/tooling/query?q=' + query_start_workflowalert);
  getAlertIds (h, req, res, alertIds, 'WorkflowAlert');
  
  // Get Flow ids
  req.setEndpoint(SFDC_URL + '/services/data/'+ APIVER + '/tooling/query?q=' + query_start_flow);
  getAlertIds (h, req, res, alertIds,'Flow');
   
   return alertIds; // Return list of alert Ids.
  } // end method
  
  //---------------------------------------------------------
  private void getAlertIds (Http h, HttpRequest req, HttpResponse res, list<string> alertIds, string recType) {
  //---------------------------------------------------------
  res = h.send(req);
  if (res.getStatus() != 'ok') { 
    errorString = errorString + '\ngetAlertIds: HTTP GET error(' + recType + '): ' + res.getStatus(); 
    appErrorCount++;
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
  public void execute(Database.BatchableContext BC, list<String> scope) {
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
        system.debug('Bad HTTP status for rectype 01W: ' + res.getStatus() + ', id=' + scope[x]);
      } else {
        addToSpreadsheet_WorkflowAlert(res);
      }
    } 
    else if (scope[x].left(3) == '301') { // 301 rec prefix = flow)
      req.setEndpoint(SFDC_URL + '/services/data/'+ APIVER + '/tooling/sobjects/Flow/' + scope[x]);
      res = h.send(req);
      if (res.getStatus() != 'ok') {
        system.debug('Bad HTTP status for rectype 301: ' + res.getStatus() + ', id=' + scope[x]);
      } else {
        addToSpreadsheet_Flow(res);
      }
    } // end if 
  } // end for
  
  // Update governor stats for this batch
  updateBatchGovernorStats(scope.size());
  } // end method
  
  //----------------------------------------------------------
  public void finish(Database.BatchableContext BC) {
  //---------------------------------------------------------
  copyOfAlertCSV = alertCSV; // Enables copy of CSV to be passed to test class
  emailJobResult (BC);
  } // end method
  
  //---------------------------------------------------------
  public void addToSpreadsheet_WorkflowAlert(HttpResponse res) {
  //---------------------------------------------------------
  WorkflowAlert w = (WorkflowAlert)JSON.deserialize(res.getBody(), WorkflowAlert.class);
  
  list<user> userList;
  
  // CcEmails -----------------------------------------------
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
  
  // Recipients (Group, Role, RoleSubordinate, User) --------
  
  if (w.metadata.recipients.size() > 0) {
    for (integer x=0; x < w.metadata.recipients.size(); x++) {
     switch on w.Metadata.recipients[x].type {
  
      // Group  ----------------------------------------------
        when 'group' {
          userList = getUserList_Group(w.Metadata.recipients[x].recipient);
          writeRecipientCSV(w, x, userList);
        }
        
        // Role ---------------------------------------------
        when 'role' {
          userList = getUserList_Role(w.Metadata.recipients[x].recipient); // same as user.role.developername
          writeRecipientCSV(w, x, userList);
        }
  
        // Role & Subordinates ------------------------------      
        when 'roleSubordinates' {
          // Too bad we have to consume an SOQL query just to get the UserRole id.
          list<UserRole> roleList = new list<UserRole> ([SELECT Id FROM UserRole WHERE developerName = :w.Metadata.recipients[x].recipient]);
          writeRecipientCSV(w, x, getUsersUnderRole(roleList[0].Id));
        }
        
        // User ----------------------------------------------
        when 'user' {
          userList = getUserList_User(w.Metadata.recipients[x].recipient);
          writeRecipientCSV(w, x, userList);
        }
      } // end switch
  
    }
  }
  
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
      groupmemZ.add(groupMembers[x].UserOrGroupId);  // Is there a better way than "groupmemZ?"
    }
    userList = [SELECT Id, Email, FirstName, LastName, IsActive FROM User WHERE Id in :groupmemZ];
  }
  return userList;
  } // end method
  
  //---------------------------------------------------------
  private list<user> getUserList_Role (string roleName) {
  //---------------------------------------------------------
  return [SELECT Id, Email, FirstName, LastName, IsActive FROM User WHERE UserRole.developerName = :roleName];
  } // end method
  
  //---------------------------------------------------------
  private list<user> getUserList_User (string emailAddress) {
  //---------------------------------------------------------
  return [SELECT Id, Email, FirstName, LastName, IsActive FROM User WHERE email = :emailAddress];
  } // end method
  
  //---------------------------------------------------------
  private void writeRecipientCSV (workFlowAlert w, integer whichRecip, list<user> userList) {
  //---------------------------------------------------------
  for (integer y=0; y < userList.size(); y++) {
    totalEmailAddresses++;
    alertCSV = alertCSV + 
      '"' + userList[y].email + '",' +
      '"' + w.Description + '",' +
      '"' + w.attributes.type + '",' + 
      '"' + userList[y].firstName + ' ' + userList[y]. lastName + '",' +
      '"' + w.Metadata.recipients[whichRecip].type + '",' +
      '"' + w.Metadata.recipients[whichRecip].recipient + '",' +
      '"' + (userList[y].isActive == true ? 'Active' : 'Inactive') + '",' +
      '"' + SFDC_URL + '/' + w.id + '",' + 
      '\n';
  }
  } // end method
  
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
  string elapsedTime = convertMsToHHMMSS (system.now().getTime() - startTime.getTime());
  
  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
  AsyncApexJob asyncApexJob = 
    [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems 
    FROM AsyncApexJob 
    WHERE Id = :BC.getJobId()];
  
  string subjectLine;
  totalErrors = asyncApexJob.numberOfErrors + appErrorCount;
  if (totalErrors > 0) {
    subjectLine = thisAppName + ': There were ' + totalErrors + ' errors';
  }
  else if (totalEmailAddresses == 0) {
    subjectLine = 'Your org has no email alerts.';
  }
  else {
    subjectLine = 'Here\'s your list of email alerts.';
    Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
    blob csvBlob = Blob.valueOf(alertCSV);
    string csvname= 'Email alerts.csv'; csvAttc.setFileName(csvname);
    csvAttc.setBody(csvBlob);
    mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
  }
  
  String emailBody = 
  '\n' + subjectLine +
  '\n' + thisAppName + ' version ' + version +
  '\n' + 'Job status: ' + asyncApexJob.Status + 
  '\n' + 'There are ' + totalEmailAddresses.format() + ' email addresses used by alerts and Flow email actions.' +
  //'\n' + 'Batch size=' + string.valueOf(max_batchsize.format()) +
  '\n' + 'Elapsed time ' + elapsedTime + 
  '\n\n' + 'Governor statistics: ' + summarizeBatchGovernorStats() +
  '\n\n' + 'There were ' + totalErrors + ' errors.' + errorString;
  
  mail.setSubject(subjectLine);
  Mail.setCharset('UTF-8');
  mail.setReplyTo('noreply@salesforce.com');
  mail.setSenderDisplayName('Salesforce');
  mail.setPlainTextBody(emailBody);
  mail.setToAddresses(UserInfo.getUserEmail().split(','));
  system.debug ('emailJobResult: emailMessage=' + emailBody);
  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  } // end method
  
  //---------------------------------------------------------
  private string convertMsToHHMMSS (long ms) {
  //---------------------------------------------------------
  long elapsedSecs = ms/1000;
  string hrs = elapsedSecs / 3600 + 'h ';
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
  // Comment out the statistics you don't care about
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
  
  //--------------------------------------------------------------------
  // Methods for getting role and subordinate users, for a specific role.
  // Thanks to Adrian Larson.
  // https://salesforce.stackexchange.com/questions/102733/find-users-under-a-node-in-role-hierarchy
  //--------------------------------------------------------------------
  
  //----------------------------------------------------------------------
  public static Map<Id, List<UserRole>> hierarchy {
  //----------------------------------------------------------------------
  get { // Is a get/set really required?
    if (hierarchy == null) {
      hierarchy = new Map<Id, List<UserRole>>();
      for (UserRole role : [SELECT ParentRoleId FROM UserRole]) {
        if (!hierarchy.containsKey(role.ParentRoleId)) {
          hierarchy.put(role.ParentRoleId, new List<UserRole>());
        }
        hierarchy.get(role.ParentRoleId).add(role);
      }
    }
    return hierarchy;
  } // end get
  private set;
  } // end method
  
  //----------------------------------------------------------------------
  public static List<UserRole> getChildren(Id userRoleId) {
  //----------------------------------------------------------------------
  return hierarchy.containsKey(userRoleId) ? hierarchy.get(userRoleId) : new List<UserRole>();
  } // end method
  
  //----------------------------------------------------------------------
  public static Set<Id> getSubHierarchyInclusive(Id userRoleId) {
  //----------------------------------------------------------------------
  Set<Id> roleIds = new Set<Id> { userRoleId };
  for (UserRole childRole : getChildren(userRoleId)) {
    roleIds.addAll(getSubHierarchyInclusive(childRole.Id));
  }
  return roleIds;
  } // end method
  
  //----------------------------------------------------------------------
  public static List<User> getUsersUnderRole(Id roleId) {
  //----------------------------------------------------------------------
  return [
    SELECT Id, Email, FirstName, LastName, IsActive 
    FROM User
    WHERE UserRoleId IN :getSubHierarchyInclusive(roleId)];
  } // end method
  
  //---------------------------------------------------------------------------
  // END OF methods for getting role and subordinate users, for a specific role
  //---------------------------------------------------------------------------
  
  } // end class