$RepoRawUrl             = "https://raw.githubusercontent.com/ThomasKur/WPNinjas_Sentinel/main/"
$MainReadmeTemplate     = Get-Content -Path .\Helper\Templates\Main-Readme.md

#region LogicApp / Extend
$MainReadmeTableLaExt   = "| Name | Description | Deploy |" + [System.Environment]::NewLine
$MainReadmeTableLaExt  += "| --- | --- | --- |" + [System.Environment]::NewLine

$bicepLaExtFiles        = Get-ChildItem -Path .\LogicApps\Extend -Recurse -Filter "*.bicep"

foreach($bicepLaExtFile in $bicepLaExtFiles){
    $Content            = Get-Content -Path $bicepLaExtFile.PSPath
    $Title              = ($Content | Where-Object { $_.StartsWith('// Title: ')}).Replace("// Title: ","")
    $TitleLink          = "[$Title](" + $bicepLaExtFile.PSParentPath.Replace((Get-Location).Path,"").Replace("\","/")+ "/Readme.md)"
    $Description        = ($Content | Where-Object { $_.StartsWith('// Description: ')}).Replace("// Description: ","")
    $GraphScopes        = ($Content | Where-Object { $_.StartsWith('// GraphScopes: ')}).Replace("// GraphScopes: ","")
    $RawUrlBicep        = $RepoRawUrl + $bicepLaExtFile.FullName.Replace((Get-Location).Path,"").Replace("\","/").Replace("//","/")
    $RawUrlArm          = $RawUrlBicep.Replace("bicep","json")
    $AzDeployLink       = "https://portal.azure.com/#create/Microsoft.Template/uri/" + [uri]::EscapeDataString($RawUrlArm)
    $AzDeployButton     = "[![Deploy to Azure](https://aka.ms/deploytoazurebutton)]($AzDeployLink)"
    
    # Generate Logic App Readme
    $template           = Get-Content -Path .\Helper\Templates\LogicApp-Extend-Readme.md
    $template           = $template.Replace("%Title%",$Title)
    $template           = $template.Replace("%Description%",$Description)
    $template           = $template.Replace("%GraphScopes%",$GraphScopes)
    $template           = $template.Replace("%RawUrlBicep%",$RawUrlBicep)
    $template           = $template.Replace("%AzDeployButton%",$AzDeployButton)

    $template | Out-File -FilePath "$($bicepLaExtFile.PSParentPath)\Readme.md" -Force

    $MainReadmeTableLaExt  += "| $Title | $Description | $AzDeployButton |" + [System.Environment]::NewLine

}

$MainReadmeTemplate = $MainReadmeTemplate.Replace("%MainReadmeTableLaExt%",$MainReadmeTableLaExt)

#endregion

#region Finalizing

$MainReadmeTemplate | Out-File -FilePath "Readme.md" -Force

#endregion
