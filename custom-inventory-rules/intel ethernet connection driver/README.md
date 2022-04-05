# Intel Ethernet Connection (driver version)

**What the script does**:

🇬🇧 Detects, via PowerShell, the driver version installed for those using an Intel network card.

🇮🇹 Rileva, tramite PowerShell, la versione del driver installata per chi usa una scheda di rete Intel.

**Supported Operating Systems**:  
Windows 11 (All), Windows 10 (All), Windows 7 (All)

**Custom Inventory Rule**:

```
ShellCommandTextReturn(powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Get-WmiObject Win32_PnPSignedDriver| where {$_.DeviceName -like 'intel(R) Ethernet Connection*'} | ft DriverVersion -hidetableheaders")
```
