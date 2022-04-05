# Network Adapter (via WMIC)

**What the script does**:

🇬🇧: Runs a `wmic nicconfig get Description` on the PCs, to get a complete list of network adapters (even virtual ones). Useful when Kace does not detect (due to drivers or failure to properly communicate to the inventory) integrated miniports and LTE chips.

🇮🇹: Esegue un `wmic nicconfig get Description` sulle macchine, così da ottenere una lista completa degli adattatori di rete (anche virtuali). Utile quando Kace non rileva (causa driver o mancata corretta comunicazione all'inventory) miniport e chip LTE integrati.

**Supported Operating Systems**:
Windows 8 (All), Server 2008 R2 (All), Windows 10 (All), Windows 7 (All), Windows XP (All), Other (All)

**Custom Inventory Rule**:

```
ShellCommandTextReturn(wmic nicconfig get Description)
```

