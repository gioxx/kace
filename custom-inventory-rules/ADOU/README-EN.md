# ADOU

🇮🇹 [Readme also available in italian](README.md).

## Purpose of the script

Detects the location of the computer (connected to a corporate domain) in the Active Directory, returning the OU(s) that the PC is located in.

## Overview

The script is intended for Kace but can also be used without a K1000 behind it. In case you want to use it with Kace here it can be scheduled (for execution) and paired with a Custom Inventory Field (via Custom Inventory Rules) that would allow you to include an extra useful data item within the PC board inside K1000.

## Components

* ADOU.ps1
* Custom inventory rule (for Quest Kace)

## How it works

1. The PowerShell script will detect if the PC is connected to the corporate network (it will ping the IP of the primary DNS), then - if so - it will query the Active Directory obtaining the entire DN related to the computer's location. The output will then be cleaned up to obtain the OUs, which will be (if more than one) concatenated by intevalling a slash as a separator.
2. The PowerShell script is scheduled and deployed to the target device(s) via K1000 [Online KScript](#the-kscript) every 6 hours.
3. A K1000 [Custom Inventory Rule](#the-custom-inventory-rule) reads the contents of the generated file (default: `C:\SWSetup\ADOU.txt`) and displays it as Custom Inventory Field in the tab of each PC involved.

## Setup

### The Script

1. Edit [the script](ADOU.ps1) **line 10** entering the IP address to which to ping (to verify that the PC is connected to the corporate network either directly or via VPN). Only if this responds positively then continue with the remaining operations.

```powershell
$corporateIP = "10.0.0.1"
```

2. Edit [the script](ADOU.ps1) **line 11** to specify a different save folder for the `ADOU.txt` file.

```powershell
$ADOUFolder = "C:\SWSetup"
```
   
3. Log in to the administrative area of your K1000 and move to **Scripting**, create a new script (from Action / New).
   
4. Call the script whatever you want (for example: **Detect ADOU**) and follow the steps below.

#### Script settings

* **Type**: `Online KScript`
* **Enabled**: `Yes`
* **Deploy**: one or some devices / **All devices** / Device Label
* **Windows Run As**: `Logged-in user`
* Upload `ADOU.ps1` into **Dependencies ** (`New Dependency ...`)

#### Tasks

* **Verify**: `Launch a program...`

  * **Directory**: `$(KACE_SYS_DIR)\WindowsPowerShell\v1.0`

  * **File**: `powershell.exe`

  * **Wait for completion**: `Yes`
  * **Visible**: `No`
  * **Parameters**: `-executionpolicy remotesigned -File $(KACE_DEPENDENCY_DIR)\ADOU.ps1`

**Save** your brand new script.

### La Custom Inventory Rule (The Custom Inventory Rule)

1. In the K100 Dashboard go to **Inventory** / **Software** section and create a new Software entry (Choose Action / New)
   
2. Give the rule a name (for example: **ADOU**) and follow the steps below.
   
   * **Publisher**: `IT Department` (vale anche il tuo nome se sei solito gestire il K1000 / your name also is valid if you used to run the K1000)
   
   * **Supported Operating Systems**: `Microsoft Windows (All)`
   
   * **Custom Inventory Rule**: `ShellCommandTextReturn(cmd /c type C:\SWSetup\ADOU.txt)`

**Save** your new Custom Inventory Rule.

------

You will now have to wait for all Windows PCs to run the inventory update (and for the PowerShell script to run first). In case the script has found the desired information, then ADOU will report it correctly. Otherwise ADOU will report `$computerName not found` (PC not connected to the domain, allegedly).