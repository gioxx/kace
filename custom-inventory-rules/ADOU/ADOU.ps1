<#
    New-ADOU (PS1)
        Verifica la posizione del PC in Active Directory e la manda in output (a video e nel file $ADOUFolder\ADOU.txt)
        Checks the location of the PC in Active Directory and outputs it (on the screen and in the file $ADOUFolder\ADOU.txt)
    GSolone, 2023
    Credits:
        OpenAI / ChatGPT! :-)
    Modifiche:
        13/6/23: Prima versione dello script (First version of the script).
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
