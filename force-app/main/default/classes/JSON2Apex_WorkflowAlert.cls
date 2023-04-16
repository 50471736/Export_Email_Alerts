//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//
// The supplied json has fields with names that are not valid in apex
// and so can only be parsed with explicitly generated code, this option
// was auto selected for you.

public class JSON2Apex_WorkflowAlert {

	public class Recipients {
		public Object field {get;set;} 
		public String recipient {get;set;} 
		public String type {get;set;} 

		public Recipients(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'field') {
							field = parser.readValueAs(Object.class);
						} else if (text == 'recipient') {
							recipient = parser.getText();
						} else if (text == 'type') {
							type = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Recipients consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Attributes {
		public String type {get;set;} 
		public String url {get;set;} 

		public Attributes(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'url') {
							url = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Attributes consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Metadata {
		public List<String> ccEmails {get;set;} 
		public String description {get;set;} 
		public Boolean protected_Z {get;set;} // in json: protected
		public List<Recipients> recipients {get;set;} 
		public Object senderAddress {get;set;} 
		public String senderType {get;set;} 
		public String template {get;set;} 
		public Object urls {get;set;} 

		public Metadata(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'ccEmails') {
							ccEmails = arrayOfString(parser);
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'protected') {
							protected_Z = parser.getBooleanValue();
						} else if (text == 'recipients') {
							recipients = arrayOfRecipients(parser);
						} else if (text == 'senderAddress') {
							senderAddress = parser.readValueAs(Object.class);
						} else if (text == 'senderType') {
							senderType = parser.getText();
						} else if (text == 'template') {
							template = parser.getText();
						} else if (text == 'urls') {
							urls = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Metadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public Attributes attributes {get;set;} 
	public String Id {get;set;} 
	public String TemplateId {get;set;} 
	public String CcEmails {get;set;} 
	public String Description {get;set;} 
	public String DeveloperName {get;set;} 
	public String SenderType {get;set;} 
	public String ManageableState {get;set;} 
	public Object NamespacePrefix {get;set;} 
	public String CreatedDate {get;set;} 
	public String CreatedById {get;set;} 
	public String LastModifiedDate {get;set;} 
	public String LastModifiedById {get;set;} 
	public String EntityDefinitionId {get;set;} 
	public Metadata Metadata {get;set;} 
	public String FullName {get;set;} 

	public JSON2Apex_WorkflowAlert(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'attributes') {
						attributes = new Attributes(parser);
					} else if (text == 'Id') {
						Id = parser.getText();
					} else if (text == 'TemplateId') {
						TemplateId = parser.getText();
					} else if (text == 'CcEmails') {
						CcEmails = parser.getText();
					} else if (text == 'Description') {
						Description = parser.getText();
					} else if (text == 'DeveloperName') {
						DeveloperName = parser.getText();
					} else if (text == 'SenderType') {
						SenderType = parser.getText();
					} else if (text == 'ManageableState') {
						ManageableState = parser.getText();
					} else if (text == 'NamespacePrefix') {
						NamespacePrefix = parser.readValueAs(Object.class);
					} else if (text == 'CreatedDate') {
						CreatedDate = parser.getText();
					} else if (text == 'CreatedById') {
						CreatedById = parser.getText();
					} else if (text == 'LastModifiedDate') {
						LastModifiedDate = parser.getText();
					} else if (text == 'LastModifiedById') {
						LastModifiedById = parser.getText();
					} else if (text == 'EntityDefinitionId') {
						EntityDefinitionId = parser.getText();
					} else if (text == 'Metadata') {
						Metadata = new Metadata(parser);
					} else if (text == 'FullName') {
						FullName = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex_WorkflowAlert consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static JSON2Apex_WorkflowAlert parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new JSON2Apex_WorkflowAlert(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	




    private static List<Recipients> arrayOfRecipients(System.JSONParser p) {
        List<Recipients> res = new List<Recipients>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Recipients(p));
        }
        return res;
    }




    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }



}