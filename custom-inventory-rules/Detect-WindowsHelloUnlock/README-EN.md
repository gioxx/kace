# Detect-WindowsHelloUnlock

🇮🇹 [Readme also available in italian](README.md).

## Purpose of the script

It detects the method of unlocking the computer by returning the result on the screen and storing it in a text file.

## Overview

The script is intended for Kace but can also be used without a K1000 behind it. In case you want to use it with Kace here it can be scheduled (for execution) and paired with a Custom Inventory Field (via Custom Inventory Rules) that would allow you to include an extra useful data item within the PC board inside K1000.

## Components

* Detect-WindowsHelloUnlock.ps1
* Custom inventory rule (for Quest Kace)

## How it works

1. The PowerShell script detects the method of unlocking the PC based on a registry key where Microsoft keeps a code that identifies the method.
2. The PowerShell script is scheduled and deployed to the target device(s) via K1000 [Online KScript](#the-kscript) every 6 hours.
3. A K1000 [Custom Inventory Rule](#the-custom-inventory-rule) reads the contents of the generated file (default: `C:\SWSetup\HelloUnlock.txt`) and displays it as Custom Inventory Field in the tab of each PC involved.

## Setup

### The Script

1. Edit [the script](Detect-WindowsHelloUnlock.ps1) **line 25** to specify a different save folder for the `HelloUnlock.txt` file.

```powershell
$HelloUnlockFolder = "C:\SWSetup"
```
   
2. Log in to the administrative area of your K1000 and move to **Scripting**, create a new script (from Action / New).
   
3. Call the script whatever you want (for example: **Detect-WindowsHelloUnlock**) and follow the steps below.

#### Script settings

* **Type**: `Online KScript`
* **Enabled**: `Yes`
* **Deploy**: one or some devices / **All devices** / Device Label
* **Windows Run As**: `Logged-in user`
* Upload `Detect-WindowsHelloUnlock.ps1` into **Dependencies ** (`New Dependency ...`)

#### Tasks

* **Verify**: `Launch a program...`

  * **Directory**: `$(KACE_SYS_DIR)\WindowsPowerShell\v1.0`

  * **File**: `powershell.exe`

  * **Wait for completion**: `Yes`
  * **Visible**: `No`
  * **Parameters**: `-executionpolicy remotesigned -File $(KACE_DEPENDENCY_DIR)\Detect-WindowsHelloUnlock.ps1`

**Save** your brand new script.

### The Custom Inventory Rule

1. In the K100 Dashboard go to **Inventory** / **Software** section and create a new Software entry (Choose Action / New)
   
2. Give the rule a name (for example: **Detect-WindowsHelloUnlock**) and follow the steps below.
   
   * **Publisher**: `IT Department` (vale anche il tuo nome se sei solito gestire il K1000 / your name also is valid if you used to run the K1000)
   
   * **Supported Operating Systems**: `Microsoft Windows (All)`
   
   * **Custom Inventory Rule**: `ShellCommandTextReturn(cmd /c type C:\SWSetup\HelloUnlock.txt)`

**Save** your new Custom Inventory Rule.

------

You will now have to wait for all Windows PCs to run the inventory update (and for the PowerShell script to run first). In case the script has found the desired information, then Detect-WindowsHelloUnlock will report it correctly. Otherwise Detect-WindowsHelloUnlock will report `Not found.` (the unlocking method used could not be found).