<#
.SYNOPSIS
    It checks the location of the PC in Active Directory and outputs it (on the screen and in the file $ADOUFolder\ADOU.txt).
   
.DESCRIPTION
    It checks the location of the PC in Active Directory and outputs it (on the screen and in the file $ADOUFolder\ADOU.txt).
    The script works only if the user is connected to the corporate network (in the office or via VPN). The produced file - $ADOUFolder\ADOU.txt - is then read by K1000, shown to anyone accessing the PC details in inventory.

.NOTES
    Filename: ADOU.ps1
    Version: 0.1 (2023)
    Author: GSolone
    Blog: gioxx.org
    Twitter: @gioxx

    Changes:
        13/6/23- First version of the script.

.LINK
    -    
#> 

$corporateIP = "10.0.0.1"
$ADOUFolder = "C:\SWSetup"

$corporateNetwork = Test-Connection -ComputerName $corporateIP -Count 1 -Quiet
if ($corporateNetwork) {
    Write-Host "PC connected to the corporate network, I'm looking for it in AD."
    $computerName = $env:COMPUTERNAME
    $searcher = [adsisearcher]"(&(objectCategory=computer)(name=$computerName))"
    $result = $searcher.FindOne()

    if (!(Test-Path $ADOUFolder)) { New-Item -ItemType Directory -Path $ADOUFolder | Out-Null }
    if ($result) {
        $distinguishedName = $result.Properties["distinguishedName"]
        $ouPart = $distinguishedName -replace '^.*?((?:OU=[^,]+,?)+).+$', '$1'

        $ouString = ($ouPart -split 'OU=' | Where-Object { $_ -ne '' }) -join '/'
        $ouString = $ouString -replace ',', ''

        Write-Host "$computerName found in $ouString"
        Set-Content -Path "$ADOUFolder\ADOU.txt" -Value $ouString
    } else {
        Write-Host "$computerName not found"
        $ouString = "$computerName not found"
        Set-Content -Path "$ADOUFolder\ADOU.txt" -Value $ouString
    }
}
else {
    Write-Host "PC is not connected to the corporate network."
}
