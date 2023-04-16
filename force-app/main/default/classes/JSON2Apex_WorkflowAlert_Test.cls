//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

@IsTest
public class JSON2Apex_WorkflowAlert_Test {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'  \"attributes\" : {'+
		'    \"type\" : \"WorkflowAlert\",'+
		'    \"url\" : \"/services/data/v56.0/tooling/sobjects/WorkflowAlert/01W3c000000gDrrEAE\"'+
		'  },'+
		'  \"Id\" : \"01W3c000000gDrrEAE\",'+
		'  \"TemplateId\" : \"00X80000001ExRoEAK\",'+
		'  \"CcEmails\" : \"shit@shit.com,piss@piss.com\",'+
		'  \"Description\" : \"Test1\",'+
		'  \"DeveloperName\" : \"Test1\",'+
		'  \"SenderType\" : \"CurrentUser\",'+
		'  \"ManageableState\" : \"unmanaged\",'+
		'  \"NamespacePrefix\" : null,'+
		'  \"CreatedDate\" : \"2023-02-19T20:30:03.000+0000\",'+
		'  \"CreatedById\" : \"00580000001hjv1AAA\",'+
		'  \"LastModifiedDate\" : \"2023-02-26T22:22:52.000+0000\",'+
		'  \"LastModifiedById\" : \"00580000001hjv1AAA\",'+
		'  \"EntityDefinitionId\" : \"Account\",'+
		'  \"Metadata\" : {'+
		'    \"ccEmails\" : [ \"shit@shit.com,piss@piss.com\" ],'+
		'    \"description\" : \"Test1\",'+
		'    \"protected\" : false,'+
		'    \"recipients\" : [ {'+
		'      \"field\" : null,'+
		'      \"recipient\" : \"CEO\",'+
		'      \"type\" : \"roleSubordinates\"'+
		'    }, {'+
		'      \"field\" : null,'+
		'      \"recipient\" : \"retsamteppup@yahoo.com\",'+
		'      \"type\" : \"user\"'+
		'    } ],'+
		'    \"senderAddress\" : null,'+
		'    \"senderType\" : \"CurrentUser\",'+
		'    \"template\" : \"unfiled$public/SalesNewCustomerEmail\",'+
		'    \"urls\" : null'+
		'  },'+
		'  \"FullName\" : \"Account.Test1\"'+
		'}';
		JSON2Apex_WorkflowAlert r = JSON2Apex_WorkflowAlert.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_WorkflowAlert.Recipients objRecipients = new JSON2Apex_WorkflowAlert.Recipients(System.JSON.createParser(json));
		System.assert(objRecipients != null);
		System.assert(objRecipients.field == null);
		System.assert(objRecipients.recipient == null);
		System.assert(objRecipients.type == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_WorkflowAlert.Attributes objAttributes = new JSON2Apex_WorkflowAlert.Attributes(System.JSON.createParser(json));
		System.assert(objAttributes != null);
		System.assert(objAttributes.type == null);
		System.assert(objAttributes.url == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_WorkflowAlert.Metadata objMetadata = new JSON2Apex_WorkflowAlert.Metadata(System.JSON.createParser(json));
		System.assert(objMetadata != null);
		System.assert(objMetadata.ccEmails == null);
		System.assert(objMetadata.description == null);
		System.assert(objMetadata.protected_Z == null);
		System.assert(objMetadata.recipients == null);
		System.assert(objMetadata.senderAddress == null);
		System.assert(objMetadata.senderType == null);
		System.assert(objMetadata.template == null);
		System.assert(objMetadata.urls == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_WorkflowAlert objJSON2Apex_WorkflowAlert = new JSON2Apex_WorkflowAlert(System.JSON.createParser(json));
		System.assert(objJSON2Apex_WorkflowAlert != null);
		System.assert(objJSON2Apex_WorkflowAlert.attributes == null);
		System.assert(objJSON2Apex_WorkflowAlert.Id == null);
		System.assert(objJSON2Apex_WorkflowAlert.TemplateId == null);
		System.assert(objJSON2Apex_WorkflowAlert.CcEmails == null);
		System.assert(objJSON2Apex_WorkflowAlert.Description == null);
		System.assert(objJSON2Apex_WorkflowAlert.DeveloperName == null);
		System.assert(objJSON2Apex_WorkflowAlert.SenderType == null);
		System.assert(objJSON2Apex_WorkflowAlert.ManageableState == null);
		System.assert(objJSON2Apex_WorkflowAlert.NamespacePrefix == null);
		System.assert(objJSON2Apex_WorkflowAlert.CreatedDate == null);
		System.assert(objJSON2Apex_WorkflowAlert.CreatedById == null);
		System.assert(objJSON2Apex_WorkflowAlert.LastModifiedDate == null);
		System.assert(objJSON2Apex_WorkflowAlert.LastModifiedById == null);
		System.assert(objJSON2Apex_WorkflowAlert.EntityDefinitionId == null);
		System.assert(objJSON2Apex_WorkflowAlert.Metadata == null);
		System.assert(objJSON2Apex_WorkflowAlert.FullName == null);
	}
}