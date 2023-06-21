# Remove homenet.telecomitalia.it from Windows DNS Suffix

**What the script does**:

🇬🇧 If within the DNS client settings this script find a suffix that matches `homenet.telecomitalia.it` it proceed to **delete it without touching the others present**. The change is immediate and does not require restarting the connection (or worse the machine), it is totally transparent to the user.  
It can be performed by a local system user (which is then the one proposed by default by Kace) and/or even manually if you wish (you will need to be at least a local administrator of the machine, though).  
Check blog article (in italian): https://go.gioxx.org/c1jf7

🇮🇹 Se all’interno delle  impostazioni del client DNS lo script trova un suffisso che fa match con `homenet.telecomitalia.it` provvede a **eliminarlo senza toccare gli altri presenti**. La modifica è immediata e non richiede riavvio della connessione (o  peggio della macchina), è totalmente trasparente per l’utente.  
Può  essere eseguito da un utente locale di sistema (che poi è quello  proposto come predefinito da Kace) e/o anche manualmente se lo desideri  (servirà però essere almeno amministratori locali della macchina).  
Vedi articolo sul blog: https://go.gioxx.org/c1jf7

**Supported Operating Systems**:  
Tested: Windows 11 (All), Windows 10 (All), Windows 7 (All)  
Not tested: Windows 8 (All), Windows XP (All)

**Scheduled task**:  
Execute Every 2 hours (or as you wish).

#### Script settings

* **Type**: `Online KScript`
* **Enabled**: `Yes`
* **Deploy**: one or some devices / **All devices** / Device Label
* **Windows Run As**: `Local System`
* Upload `Homenet-TelecomItalia-Suffix.ps1` into **Dependencies ** (`New Dependency ...`)

#### Tasks

* **Verify**: `Launch a program...`
  * **Directory**: `$(KACE_SYS_DIR)\WindowsPowerShell\v1.0`
  * **File**: `powershell.exe`
  * **Wait for completion**: `Yes`
  * **Visible**: `No`
  * **Parameters**: `-executionpolicy remotesigned -File $(KACE_DEPENDENCY_DIR)\Homenet-TelecomItalia-Suffix.ps1`

**Save** .
