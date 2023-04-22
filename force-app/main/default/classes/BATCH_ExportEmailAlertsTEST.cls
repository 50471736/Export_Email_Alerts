//---------------------------------------------------------------------------------
// This is the test class for BATCH_ExportEmailAlerts
//---------------------------------------------------------------------------------

@istest
//---------------------------------------------------------------------------------
private class BATCH_ExportEmailAlertsTEST {
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
static testmethod void test_CodeCvg_WorkflowAlert() {
//--------------------------------------------------------------------------------
Test.startTest();
Test.setMock(HttpCalloutMock.class, new BATCH_ExportEmailAlertsMockHTTP('WorkflowAlert'));
Database.executeBatch(new BATCH_ExportEmailAlerts(),10);
Test.stopTest();
} // end method

//--------------------------------------------------------------------------------
static testmethod void test_CodeCvg_EmailAction() {
//--------------------------------------------------------------------------------
Test.startTest();
Test.setMock(HttpCalloutMock.class, new BATCH_ExportEmailAlertsMockHTTP('EmailAction'));
Database.executeBatch(new BATCH_ExportEmailAlerts(),10);
Test.stopTest();
} // end method

//--------------------------------------------------------------------------------
static testmethod void test_CodeCvg_ApexAction() {
//--------------------------------------------------------------------------------
Test.startTest();
Test.setMock(HttpCalloutMock.class, new BATCH_ExportEmailAlertsMockHTTP('NoAlerts'));
BATCH_ExportEmailAlerts.ExportEmailAlerts();
Test.stopTest();
} // end method

//--------------------------------------------------------------------------------
static testmethod void test_Functionality_EmailAction() {
//--------------------------------------------------------------------------------
Test.startTest();
Test.setMock(HttpCalloutMock.class, new BATCH_ExportEmailAlertsMockHTTP('EmailAction'));
BATCH_ExportEmailAlerts b = new BATCH_ExportEmailAlerts();
Database.executeBatch(b,10);
Test.stopTest();

// Test: Make sure CSV has the right number of Flow email actions based on the HTTPMock data.
integer flowsFound = BATCH_ExportEmailAlerts.copyOfAlertCSV.countMatches('"Flow email action"'); // was "Flow"
if (2 == flowsFound) {
    system.debug('Test passed. CSV has two Flow alerts.');
}
else {
    system.debug('Test failed. Expected CSV to have two Flow alerts, found ' + flowsFound);
    Assert.fail();
}
} // end method

//--------------------------------------------------------------------------------
static testmethod void test_Functionality_WorkflowAlert() {
//--------------------------------------------------------------------------------
Test.startTest();
Test.setMock(HttpCalloutMock.class, new BATCH_ExportEmailAlertsMockHTTP('WorkflowAlert')); 
BATCH_ExportEmailAlerts b = new BATCH_ExportEmailAlerts();
Database.executeBatch(b,10);
Test.stopTest();

// Test: Make sure CSV has the right number of WorkflowAlerts based on the HTTPMock data.
integer wfaFound = BATCH_ExportEmailAlerts.copyOfAlertCSV.countMatches('"Email alert"'); // was "WorkflowAlert"
if (14 == wfaFound) {
    system.debug('Test passed. CSV has 14 WorkflowAlerts.');
}
else {
    system.debug('Test failed. Expected CSV to have 14 WorkflowAlerts, found ' + wfaFound);
    Assert.fail();
}
} // end method

//--------------------------------------------------------------------------------
static testmethod void test_Functionality_HTTPErr() {
//--------------------------------------------------------------------------------
Test.startTest();
Test.setMock(HttpCalloutMock.class, new BATCH_ExportEmailAlertsMockHTTP('HTTPErr'));
BATCH_ExportEmailAlerts b = new BATCH_ExportEmailAlerts();
Database.executeBatch(b,10);
Test.stopTest();
} // end method

//--------------------------------------------------------------------------------
static testmethod void test_Functionality_NoAlerts() {
//--------------------------------------------------------------------------------
Test.startTest();
Test.setMock(HttpCalloutMock.class, new BATCH_ExportEmailAlertsMockHTTP('NoAlerts'));
BATCH_ExportEmailAlerts b = new BATCH_ExportEmailAlerts();
Database.executeBatch(b,10);
Test.stopTest();
} // end method

//--------------------------------------------------------------------------------
@testsetup static void setup() {
//--------------------------------------------------------------------------------
setup_users(1);
} // end method

//--------------------------------------------------------------------------------
static list<user> setup_users(integer howMany) {
//--------------------------------------------------------------------------------
// Seed value for user fields requiring a unique value (e.g. Username)
final string uniqueString = 'g50471736'; 

// Create role. Must match role (or role/sub) name in mock HTTP's JSON payload. Value: "<uniqueString>"
UserRole role = new UserRole(DeveloperName = uniqueString, Name = uniqueString);
insert role;
// Create subrole.
UserRole subRole = new UserRole(DeveloperName = uniqueString + 'subrole', Name = uniqueString + 'subrole', ParentRoleId = role.id);
insert subRole;

// Create public group. Must match group name in mock HTTP's JSON payload. Value: "<uniqueString>"
group publicGroup = new group (Name = uniqueString, DeveloperName = uniqueString);
insert publicGroup;

// Create user. Username must match user name in mock HTTP's JSON payload. Value: "<uniqueString>@1.com" (first user)
// Select existing profile and assign to new users.
Profile profile= [SELECT Id FROM profile WHERE Name='Standard User' LIMIT 1]; 
list<user> users = new list<user>();
for (integer x=0; x < howMany; x++) { // Create as many users as requested
    users.add (new user (
        Lastname='Last' + x, 
        Firstname='First' + x, 
        Email=uniqueString + '@' + x + '.com', 
        Username=uniqueString + '@' + x + '.com', 
        ProfileId=profile.id, 
        UserRoleId=role.id,
        EmailEncodingKey = 'ISO-8859-1',  
        Alias = 'temp',  
        TimeZoneSidKey = 'America/Los_Angeles',  
        LocaleSidKey = 'en_US',  
        LanguageLocaleKey = 'en_US'
        ));
}
insert users;

// Assign users to a public group
list<GroupMember> gm = new list<GroupMember>();
for (integer x=0; x<users.size(); x++) {
    gm.add (new GroupMember(GroupId = publicGroup.id, UserOrGroupId = users[x].Id));
}
insert gm;
return users;
} // end method

} // end class