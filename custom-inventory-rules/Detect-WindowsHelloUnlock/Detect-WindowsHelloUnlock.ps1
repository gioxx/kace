<#
.SYNOPSIS
    Script will detect if the logged on user is using the PIN (or fingerprint/facial recognition/password) as user credential
   
.DESCRIPTION
    Script will detect if the logged on user is using the PIN credential provider indicating that the user is making use of Windows Hello for Business.
    If the logged on user is not making use of the PIN credential provider, the script will exit with error 1.

.NOTES
    Filename: Detect-WindowsHelloUnlock.ps1
    Version: 0.1
    Author: GSolone
    Blog: gioxx.org
    Twitter: @gioxx

    Changes:
        23/5/23- First version of the script.

.LINK
    https://learn.microsoft.com/en-us/answers/questions/1103769/detect-if-logged-into-windows-hello-for-business-i
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-itemproperty?view=powershell-7.3
    https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-switch?view=powershell-7.3    
#>

$HelloUnlockFolder = "C:\SWSetup"

$LogonUI = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI"
if ( $LogonUI ) {
    $LastLoggedOnProvider = Switch ( $LogonUI.LastLoggedOnProvider ) {
        "{D6886603-9D2F-4EB2-B667-1971041FA96B}" { "PIN" }
        "{BEC09223-B018-416D-A0AC-523971B639F5}" { "Fingerprint" }
        "{8AF662BF-65A0-4D0A-A540-A338A999D36F}" { "Facial Recognition" }
        default { "Password or other method" }
    }
    Write-Output "$($LogonUI.LastLoggedOnUser) authenticated through $LastLoggedOnProvider"
    Set-Content -Path "$HelloUnlockFolder\HelloUnlock.txt" -Value $LastLoggedOnProvider
    #exit 0
} else {
    Write-Output "Registry path not found."
    Set-Content -Path "$HelloUnlockFolder\HelloUnlock.txt" -Value "Not found."
    #exit 1
}