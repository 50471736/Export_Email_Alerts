# Export Email Alerts  ![SFDCLogo transparent 03pct](https://user-images.githubusercontent.com/16543260/233866155-fcd090d8-82cd-49fa-90d7-d2c2f2ee4b00.png)
## Purpose
Several administrators have expressed a need to list all Salesforce email alerts, including email addresses. This solution exports all email alerts and Flow email actions to a CSV spreadsheet and emails it to the current user.
<br><br>*Use the GitHub [Issues tab](https://github.com/50471736/Export_Email_Alerts/issues) to report bugs or request enhancements.*
## Architecture
- REST/Tooling API to read the WorkflowAlert and Flow sObjects
- Batch Apex to handle large numbers of alerts
## Author
Rod MacKenzie mr.jcrm@gmail.com
## Installation
Deploy these classes:
- BATCH_ExportEmailAlerts
- BATCH_ExportEmailAlertsMockHTTP
- BATCH_ExportEmailAlertsTEST
## How to run (admin privileges are recommended)
- Execute anonymous: ```Database.executeBatch(new BATCH_ExportEmailAlerts(),50);```
- Or, you can create a flow with a screen element whose button runs Apex Action "Export Email Alerts"
## Known issues
- After clicking an alert URL in the CSV, the detail page is shown in SFDC Classic, not Lightning.
## Sample CSV
<img width="769" alt="Email alerts" src="https://user-images.githubusercontent.com/16543260/233796850-b12af254-c27e-4de3-ba76-dd4aa726b339.png">
