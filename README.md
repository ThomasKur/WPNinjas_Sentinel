# WPNinjas Sentinel

Content to be used with Microsoft Sentinel. All content is explained on [WPNinjas](https://wpninjas.eu).

## Logic Apps

### Extend

The Logic Apps in the extend section help to add additional or custom information into Sentinel or Microsoft 365 Defender.

| Name | Description | Deploy |
| --- | --- | --- |
| [Intune Device Information](https://github.com/ThomasKur/WPNinjas_Sentinel/blob/main/LogicApps/Extend/DeviceInfo/Readme.md) | The LogicApp creates a new custom table and is responsible to import Azure AD Device data enriched with Intune information.  | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FThomasKur%2FWPNinjas_Sentinel%2Fmain%2FLogicApps%2FExtend%2FDeviceInfo%2Ftemplate.json) |
| [Generic Graph Information](https://github.com/ThomasKur/WPNinjas_Sentinel/blob/main/LogicApps/Extend/GenericGraph/Readme.md) | The LogicApp creates a new custom table and can ingest data from any Microsft Graph Endpoint and handles Paging correctly. | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FThomasKur%2FWPNinjas_Sentinel%2Fmain%2FLogicApps%2FExtend%2FGenericGraph%2Ftemplate.json) |

### Incident Automation

### WatchList Automation

### TI Integration

## Analytic Rules

## Workbooks
