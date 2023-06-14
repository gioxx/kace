# ADOU

🇬🇧 [Readme disponibile anche in inglese](README-EN.md).

## Scopo dello script

Rileva la posizione del computer (connesso a un dominio aziendale) all'interno di Active Directory, restituendo la OU (o le OU) all'interno del quale il PC si trova.

## Panoramica

Lo script è stato pensato per Kace ma può essere utilizzato anche senza un K1000 alle spalle. Nel caso in cui lo si voglia utilizzare con Kace ecco che può essere pianificato (per l'esecuzione) e messo in coppia con un Custom Inventory Field (via Custom Inventory Rules) che permetterebbe di includere un dato utile in più all'interno della scheda PC dentro K1000.

## Componenti

* ADOU.ps1
* Custom inventory rule (for Quest Kace)

## Come funziona

1. Lo script PowerShell rileva se il PC è connesso alla rete aziendale (effettuerà un ping verso l'IP del DNS primario), quindi - in caso di risposta affermativa - interrogherà l'Active Directory ottenendo l'intero DN relativo alla posizione del computer. L'output verrà successivamente ripulito fino a ottenere le OU che verranno (se più di una) concatenate intevallando uno slash come separatore.
2. Lo script PowerShell viene pianificato e distribuito ai dispositivi di destinazione tramite K1000 [Online KScript](#the-kscript) ogni 6 ore.
3. Una [Custom Inventory Rule](#the-custom-inventory-rule) di K1000 legge il contenuto del file generato (default: `C:\SWSetup\ADOU.txt`) e lo mostra come Custom Inventory Field nella scheda di ciascun PC coinvolto.

## Setup

### Lo script

1. Modifica [lo script](ADOU.ps1) alla **linea 10** inserendo l'indirizzo IP verso il quale far effettuare il ping (per verificare che il PC sia connesso alla rete aziendale in maniera diretta o via VPN). Solo se questo risponderà positivamente allora proseguirà con il resto delle operazioni.

```powershell
$corporateIP = "10.0.0.1"
```

2. Modifica [lo script](ADOU.ps1) alla **linea 11** per specificare una diversa cartella di salvataggio del file `ADOU.txt`.

```powershell
$ADOUFolder = "C:\SWSetup"
```

3. Accedi all'area amministrativa del tuo K1000 e spostati in **Scripting**, crea un nuovo script (da Action / New).

4. Chiama lo script come vuoi (per esempio: **Detect ADOU**) e segui i passaggi di seguito.

#### Impostazioni dello script

* **Type**: `Online KScript`
* **Enabled**: `Yes`
* **Deploy**: one or some devices / **All devices** / Device Label
* **Windows Run As**: `Logged-in user`
* Carica `ADOU.ps1` nelle **Dipendenze** (`New Dependency ...`)

#### Operazioni

* **Verify**: `Launch a program...`
    
    * **Directory**: `$(KACE_SYS_DIR)\WindowsPowerShell\v1.0`
    
    * **File**: `powershell.exe`
    
    * **Wait for completion**: `Yes`
    * **Visible**: `No`
    * **Parameters**: `-executionpolicy remotesigned -File $(KACE_DEPENDENCY_DIR)\ADOU.ps1`

**Salva** il tuo nuovo script.

### La Custom Inventory Rule

1. Nella dashboard di K1000 vai in **Inventory** / **Software** e crea un nuovo software (Choose Action / New).

2. Dai un nome alla regola (per esempio: **ADOU**) e segui i passaggi di seguito.

   * **Publisher**: `IT Department` (vale anche il tuo nome se sei solito gestire il K1000)

   * **Supported Operating Systems**: `Microsoft Windows (All)`

   * **Custom Inventory Rule**: `ShellCommandTextReturn(cmd /c type C:\SWSetup\ADOU.txt)`


**Salva** la tua nuova Custom Inventory Rule.

------

Dovrai ora attendere che tutti i PC Windows eseguano l'aggiornamento dell'inventario (e che prima sia stato eseguito lo script PowerShell). Nel caso in cui lo script abbia trovato l'informazione desiderata, allora ADOU la riporterà correttamente. Diversamente ADOU riporterà `$computerName not found` (PC non connesso al dominio, presumibilmente).
