# Export Email Alerts
## Purpose
Exports all email alerts and Flow email actions to a CSV spreadsheet and emails it to current user
## Strategies
- Uses REST/Tooling API to read the WorkflowAlert and Flow sObjects
- Uses batch Apex to handle large alert volumes
## Author
Sir Rodney MacKenzie mr.jcrm@gmail.com, February 2023
## How to run
- Admin privileges are recommended
- Execute anonymous: <tt>Database.executeBatch(new BATCH_ExportEmailAlerts(),50);</tt>
- Or, deploy the classes then create a flow with a screen element whose button runs Apex Action "Export Email Alerts"
## Known issues
- After clicking an alert URL in the CSV, the detail page is shown in SFDC Classic, not Lightning.
- When viewed in LibreOffice Calc, the links in the CSV are sometimes truncated or non-responsive.Exports all email alerts and Flow email actions to a CSV spreadsheet and emails it to current user
# Here's what the CSV looks like
