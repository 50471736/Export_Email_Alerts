# Export Email Alerts ![SFDCLogo transparent 5](https://user-images.githubusercontent.com/16543260/233790754-3b0b4cd8-e4fb-4b15-9f15-a4427f7feac7.png)

## Purpose
*This is a beta release. Use the GitHub [Issues tab](https://github.com/50471736/Export_Email_Alerts/issues) to report bugs or request enhancements.*
<br><br>Several people have expressed a need to list all Salesforce email alerts, including email addresses. This solution exports all email alerts and Flow email actions to a CSV spreadsheet and emails it to the current user.
## Architecture
- REST/Tooling API to read the WorkflowAlert and Flow sObjects
- Batch Apex to handle large alert volumes
## Author
Rod MacKenzie mr.jcrm@gmail.com, February 2023
## Installation. Deploy the classes
- BATCH_ExportEmailAlerts
- BATCH_ExportEmailAlertsMockHTTP
- BATCH_ExportEmailAlertsTEST
## How to run (admin privileges are recommended)
- Execute anonymous: ```Database.executeBatch(new BATCH_ExportEmailAlerts(),50);```
- Or, you can create a flow with a screen element whose button runs Apex Action "Export Email Alerts"
## Known issues
- After clicking an alert URL in the CSV, the detail page is shown in SFDC Classic, not Lightning.
- When viewed in LibreOffice Calc, the links in the CSV are sometimes truncated or non-responsive.
## Sample CSV
<img width="769" alt="Email alerts" src="https://user-images.githubusercontent.com/16543260/233796850-b12af254-c27e-4de3-ba76-dd4aa726b339.png">
