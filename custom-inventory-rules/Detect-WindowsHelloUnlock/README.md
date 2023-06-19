# Detect-WindowsHelloUnlock

🇬🇧 [Readme disponibile anche in inglese](README-EN.md).

## Scopo dello script

Rileva il metodo di sblocco del computer restituendo il risultato a video e memorizzandolo in un file di testo.

## Panoramica

Lo script è stato pensato per Kace ma può essere utilizzato anche senza un K1000 alle spalle. Nel caso in cui lo si voglia utilizzare con Kace ecco che può essere pianificato (per l'esecuzione) e messo in coppia con un Custom Inventory Field (via Custom Inventory Rules) che permetterebbe di includere un dato utile in più all'interno della scheda PC dentro K1000.

## Componenti

* Detect-WindowsHelloUnlock.ps1
* Custom inventory rule (for Quest Kace)

## Come funziona

1. Lo script PowerShell rileva il metodo di sblocco del PC basandosi su una chiave di registro dove Microsoft conserva un codice identificativo del metodo.
2. Lo script PowerShell viene pianificato e distribuito ai dispositivi di destinazione tramite K1000 [Online KScript](#the-kscript) ogni 6 ore.
3. Una [Custom Inventory Rule](#the-custom-inventory-rule) di K1000 legge il contenuto del file generato (default: `C:\SWSetup\HelloUnlock.txt`) e lo mostra come Custom Inventory Field nella scheda di ciascun PC coinvolto.

## Setup

### Lo script

1. Modifica [lo script](Detect-WindowsHelloUnlock.ps1) alla **linea 25** per specificare una diversa cartella di salvataggio del file `HelloUnlock.txt`.

```powershell
$HelloUnlockFolder = "C:\SWSetup"
```

2. Accedi all'area amministrativa del tuo K1000 e spostati in **Scripting**, crea un nuovo script (da Action / New).

3. Chiama lo script come vuoi (per esempio: **Detect-WindowsHelloUnlock**) e segui i passaggi di seguito.

#### Impostazioni dello script

* **Type**: `Online KScript`
* **Enabled**: `Yes`
* **Deploy**: one or some devices / **All devices** / Device Label
* **Windows Run As**: `Logged-in user`
* Carica `Detect-WindowsHelloUnlock.ps1` nelle **Dipendenze** (`New Dependency ...`)

#### Operazioni

* **Verify**: `Launch a program...`
    
    * **Directory**: `$(KACE_SYS_DIR)\WindowsPowerShell\v1.0`
    
    * **File**: `powershell.exe`
    
    * **Wait for completion**: `Yes`
    * **Visible**: `No`
    * **Parameters**: `-executionpolicy remotesigned -File $(KACE_DEPENDENCY_DIR)\Detect-WindowsHelloUnlock.ps1`

**Salva** il tuo nuovo script.

### La Custom Inventory Rule

1. Nella dashboard di K1000 vai in **Inventory** / **Software** e crea un nuovo software (Choose Action / New).

2. Dai un nome alla regola (per esempio: **Detect-WindowsHelloUnlock**) e segui i passaggi di seguito.

   * **Publisher**: `IT Department` (vale anche il tuo nome se sei solito gestire il K1000)

   * **Supported Operating Systems**: `Microsoft Windows (All)`

   * **Custom Inventory Rule**: `ShellCommandTextReturn(cmd /c type C:\SWSetup\HelloUnlock.txt)`


**Salva** la tua nuova Custom Inventory Rule.

------

Dovrai ora attendere che tutti i PC Windows eseguano l'aggiornamento dell'inventario (e che prima sia stato eseguito lo script PowerShell). Nel caso in cui lo script abbia trovato l'informazione desiderata, allora Detect-WindowsHelloUnlock la riporterà correttamente. Diversamente Detect-WindowsHelloUnlock riporterà `Not found.` (non è stato trovato il metodo di sblocco utilizzato).
