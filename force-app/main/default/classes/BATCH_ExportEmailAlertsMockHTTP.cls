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
        
// Fabricate an HTTP response.
// NOTE: JSON user.recipient must be "g50471736@0.com" to match test data
// NOTE: JSON group.recipient must be "g50471736" to match test data.
// NOTE: JSON role.recipient must be "g50471736" to match test data.
HttpResponse res = new HttpResponse();
res.setHeader('Content-Type', 'application/json');
if (alertType == 'WorkflowAlert') {
  res.setBody('{"attributes":{"type":"WorkflowAlert","url":"/services/data/v56.0/tooling/sobjects/WorkflowAlert/01W3c000000gDrrEAE"},"Id":"01W3c000000gDrrEAE","TemplateId":"00X80000001ExRoEAK","CcEmails":"a@a.com,b@b.com","Description":"Test1","DeveloperName":"Test1","SenderType":"CurrentUser","ManageableState":"unmanaged","NamespacePrefix":null,"CreatedDate":"2023-02-19T20:30:03.000+0000","CreatedById":"00580000001hjv1AAA","LastModifiedDate":"2023-04-02T22:01:39.000+0000","LastModifiedById":"00580000001hjv1AAA","EntityDefinitionId":"Account","Metadata":{"ccEmails":["a@a.com,b@b.com"],"description":"Test1","protected":false,"recipients":[{"field":null,"recipient":"g50471736","type":"group"},{"field":null,"recipient":"g50471736","type":"role"},{"field":null,"recipient":"g50471736","type":"role"},{"field":null,"recipient":"g50471736","type":"roleSubordinates"},{"field":null,"recipient":"g50471736@0.com","type":"user"}],"senderAddress":null,"senderType":"CurrentUser","template":"unfiled$public/SalesNewCustomerEmail","urls":null},"FullName":"Account.Test1"}');
  res.setStatusCode(200); res.setStatus('ok');
}
else if (alertType == 'EmailAction') {
    res.setBody ('{"attributes":{"type":"Flow","url":"/services/data/v56.0/tooling/sobjects/Flow/3013c000000gQhfAAE"},"Id":"3013c000000gQhfAAE","DefinitionId":"300C0000000PGOuIAO","MasterLabel":"test1","ManageableState":"unmanaged","VersionNumber":3,"Status":"Obsolete","Description":null,"ProcessType":"Flow","CreatedDate":"2023-01-28T05:12:19.000+0000","CreatedById":"00580000001hjv1AAA","LastModifiedDate":"2023-02-26T02:05:21.000+0000","LastModifiedById":"00580000001hjv1AAA","Metadata":{"actionCalls":[{"actionName":"emailSimple","actionType":"emailSimple","connector":{"isGoTo":null,"processMetadataValues":[],"targetReference":"Done"},"dataTypeMappings":[],"description":null,"elementSubtype":null,"faultConnector":null,"flowTransactionModel":"CurrentTransaction","inputParameters":[{"name":"emailBody","processMetadataValues":[],"value":{"apexValue":null,"booleanValue":null,"dateTimeValue":null,"dateValue":null,"elementReference":null,"numberValue":null,"sobjectValue":null,"stringValue":"Hi Rodney"}},{"name":"emailAddresses","processMetadataValues":[],"value":{"apexValue":null,"booleanValue":null,"dateTimeValue":null,"dateValue":null,"elementReference":null,"numberValue":null,"sobjectValue":null,"stringValue":"a@a.com"}},{"name":"emailSubject","processMetadataValues":[],"value":{"apexValue":null,"booleanValue":null,"dateTimeValue":null,"dateValue":null,"elementReference":null,"numberValue":null,"sobjectValue":null,"stringValue":"A subject for you"}}],"label":"Email1","locationX":390,"locationY":25,"name":"Email1","outputParameters":[],"processMetadataValues":[],"storeOutputAutomatically":null}],"apexPluginCalls":[],"apiVersion":49,"assignments":[],"choices":[],"collectionProcessors":[],"constants":[{"dataType":"String","description":null,"name":"ConstantDone","processMetadataValues":[],"value":{"apexValue":null,"booleanValue":null,"dateTimeValue":null,"dateValue":null,"elementReference":null,"numberValue":null,"sobjectValue":null,"stringValue":"\'Done\'"}}],"decisions":[],"description":null,"dynamicChoiceSets":[],"environments":["Default"],"formulas":[],"interviewLabel":"test1 {!$Flow.CurrentDateTime}","isAdditionalPermissionRequiredToRun":null,"isOverridable":null,"isTemplate":null,"label":"test1","loops":[],"migratedFromWorkflowRuleName":null,"orchestratedStages":[],"overriddenFlow":null,"processMetadataValues":[{"name":"BuilderType","value":{"apexValue":null,"booleanValue":null,"dateTimeValue":null,"dateValue":null,"elementReference":null,"numberValue":null,"sobjectValue":null,"stringValue":"LightningFlowBuilder"}},{"name":"CanvasMode","value":{"apexValue":null,"booleanValue":null,"dateTimeValue":null,"dateValue":null,"elementReference":null,"numberValue":null,"sobjectValue":null,"stringValue":"FREE_FORM_CANVAS"}}],"processType":"Flow","recordCreates":[],"recordDeletes":[],"recordLookups":[],"recordRollbacks":[],"recordUpdates":[],"runInMode":null,"screens":[{"allowBack":false,"allowFinish":true,"allowPause":false,"backButtonLabel":null,"connector":null,"description":null,"elementSubtype":null,"fields":[{"choiceReferences":null,"dataType":null,"dataTypeMappings":[],"defaultSelectedChoiceReference":null,"defaultValue":null,"description":null,"extensionName":null,"fieldText":"Thank you!","fieldType":"DisplayText","fields":[],"helpText":null,"inputParameters":[],"inputsOnNextNavToAssocScrn":null,"isRequired":null,"isVisible":null,"name":"DoneMessage","objectFieldReference":null,"outputParameters":[],"processMetadataValues":[],"regionContainerType":null,"scale":null,"storeOutputAutomatically":null,"validationRule":null,"visibilityRule":null}],"helpText":null,"label":"Done","locationX":394,"locationY":212,"name":"Done","nextOrFinishButtonLabel":null,"pauseButtonLabel":null,"pausedText":null,"processMetadataValues":[],"rules":[],"showFooter":true,"showHeader":true}],"sourceTemplate":null,"start":{"connector":{"isGoTo":null,"processMetadataValues":[],"targetReference":"Email1"},"description":null,"doesRequireRecordChangedToMeetCriteria":null,"elementSubtype":null,"filterFormula":null,"filterLogic":null,"filters":[],"label":null,"locationX":50,"locationY":50,"name":null,"object":null,"objectContainer":null,"processMetadataValues":[],"recordTriggerType":null,"schedule":null,"scheduledPaths":[],"segment":null,"triggerType":null},"startElementReference":null,"status":"Obsolete","steps":[],"subflows":[],"textTemplates":[],"timeZoneSidKey":null,"transforms":[],"triggerOrder":null,"urls":null,"variables":[{"apexClass":null,"dataType":"SObject","description":null,"isCollection":false,"isInput":false,"isOutput":false,"name":"account","objectType":"Account","processMetadataValues":[],"scale":null,"value":null},{"apexClass":null,"dataType":"SObject","description":null,"isCollection":false,"isInput":false,"isOutput":false,"name":"NewAccount","objectType":"Account","processMetadataValues":[],"scale":null,"value":null}],"waits":[]},"FullName":"test1-3","IsTemplate":false,"IsOverridable":false,"SourceTemplate":null,"OverriddenFlow":null,"TriggerOrder":null,"RunInMode":null,"ApiVersion":49,"Environments":"Default","TimeZoneSidKey":null}');
    res.setStatusCode(200); res.setStatus('ok');
  }
else if (alertType == 'HTTPErr') {
  res.setBody ('{"attributes":{"type":"Flow","url":"/services/data/v56.0/tooling/sobjects/Flow/3013c000000gQhfAAE"},"Id":"3013c000000gQhfAAE"}');
  res.setStatusCode(900); res.setStatus('fail');
}
else if (alertType == 'NoAlerts') {
  //res.setBody ('{"attributes":{"type":"Flow","url":"/services/data/v56.0/tooling/sobjects/Flow/xxx3c000000gQhfAAE"},"Id":"xxx3c000000gQhfAAE"}');
  res.setBody ('{"size":0,"totalSize":0,"done":true,"queryLocator":null,"entityTypeName":null,"records":[]}');
  res.setStatusCode(200); res.setStatus('ok');
}

return res;
} // end method

} // end class