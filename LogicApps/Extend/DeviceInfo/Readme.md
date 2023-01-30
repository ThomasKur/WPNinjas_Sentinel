# Extend Device Info

The following LogicApp creates a new custom table with valuabel information about devices withtin the environment. The deployment consits of two steps:

1. Creating Azure resources (Logic App and Connector)
2. Grant permission to Managed Identity of the Logic App.


## Creating Azure resources

You can create the Azure resources by using the following script or by using the Deploy to Azure button.


```console
az login
az group create --name rg-test1 --location westeurope
az group deployment create --resource-group rg-test1 --template-uri 'https://raw.githubusercontent.com/ThomasKur/WPNinjas_Sentinel/main/LogicApps/Extend/DeviceInfo/template.bicep'

```
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FThomasKur%2FWPNinjas_Sentinel%2Fmain%2FLogicApps%2FExtend%2FDeviceInfo%2Ftemplate.json)

## Grant permission to Managed Identity

```powershell
$GraphAppId         = "00000003-0000-0000-c000-000000000000"
$DisplayNameOfMSI   = Read-Host "Provide the name of the LogicApp you created in the previous step (Default name: la-ExtendedDeviceInfo)"

$PermissionName = @(
    "Directory.Read.All",
    "DeviceManagementManagedDevices.Read.All",
    "DeviceManagementConfiguration.Read.All"
    )


# Install the module
Install-Module AzureAD

Connect-AzureAD 

$MSI = (Get-AzureADServicePrincipal -Filter "displayName eq '$DisplayNameOfMSI'")

Start-Sleep -Seconds 10

$GraphServicePrincipal = Get-AzureADServicePrincipal -Filter "appId eq '$GraphAppId'"

# Request the required roles
$AppRoles = $GraphServicePrincipal.AppRoles | Where-Object { $_.Value -in $PermissionName -and $_.AllowedMemberTypes -contains "Application"}

# Add the roles to the MSI
foreach($AppRole in $AppRoles){
    New-AzureAdServiceAppRoleAssignment -ObjectId $MSI.ObjectId -PrincipalId $MSI.ObjectId -ResourceId $GraphServicePrincipal.ObjectId -Id $AppRole.Id
}
```
