<#
  Remove homenet.telecomitalia.it from Windows DNS Suffix
  GSolone 22/3/22
  Credits:
  https://superuser.com/a/1507551
  https://docs.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientglobalsetting?view=windowsserver2022-ps&viewFallbackFrom=win10-ps
  https://www.mssqltips.com/sqlservertip/5459/how-to-modify-the-global-dns-configuration-on-servers-using-powershell/
  https://adamtheautomator.com/powershell-replace/
#>
try {
  $dnsCGSetting = Get-DnsClientGlobalSetting
  if($dnsCGSetting.SuffixSearchList.Contains('homenet.telecomitalia.it')) {
    $dnsCGClean = $dnsCGSetting.SuffixSearchList.replace('homenet.telecomitalia.it','')
    Set-DnsClientGlobalSetting -SuffixSearchList $dnsCGClean
    Write-Host "Telecom suffix removed."
  } else {
    Write-Host "No Telecom suffix found."
  }
} catch {
  Write-Host "An error occurred:"
  Write-Host $_.ScriptStackTrace
}
