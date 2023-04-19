# Export Email Alerts
## Purpose
I noticed that over the years people have wished a for way to list all Salesforce email alerts, including email addresses. It was challenging to design a solution but I did it. This solution exports all email alerts and Flow email actions to a CSV spreadsheet and emails it to the current user.
## Strategies
- Uses REST/Tooling API to read the WorkflowAlert and Flow sObjects
- Uses batch Apex to handle large alert volumes
## Author
Rod MacKenzie mr.jcrm@gmail.com, February 2023
## How to run
Admin privileges are recommended.
<br>Deploy the classes. Then,
- Execute anonymous: <tt>Database.executeBatch(new BATCH_ExportEmailAlerts(),50);</tt>
- Or, create a flow with a screen element whose button runs Apex Action "Export Email Alerts"
## Known issues
- After clicking an alert URL in the CSV, the detail page is shown in SFDC Classic, not Lightning.
- When viewed in LibreOffice Calc, the links in the CSV are sometimes truncated or non-responsive.Exports all email alerts and Flow email actions to a CSV spreadsheet and emails it to current user
## Sample CSV
<img width="613" alt="image" src="https://user-images.githubusercontent.com/16543260/232662125-a596d2c1-5694-4b07-ac98-b1cc2c0d9753.png">
