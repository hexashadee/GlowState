windows setup

GlowState uses a powershell script to check your teams presence and send the status to the Arduino over USB

requirements
windows 10 or 11
powershell 5.1 +
arduino nano with GlowState firmware installed
MS Entra app registration approved for delegated Presence.Read access
USB connection to the Arduino

## configuration

open `windows/TeamsLight-Auto.ps1` and update these values:

```powershell
$TenantId = 'PASTE-TENANT-ID-HERE'
$ClientId = 'PASTE-CLIENT-ID-HERE'
$ComPort = 'COM3'
```

the tenant and client IDs come from MS Entra application 

to find the Arduino COM port, open Device Manager and look under Ports (COM & LPT)

## running GlowState

open powershell, go to the folder containing the script, run:

```powershell
.\TeamsLight-Auto.ps1
```

on the first run, follow the MS sign in instructions displayed in powershell

the script checks Teams presence every 15 seconds and sends the corresponding command to the Arduino when your status changes

## notes
no third party PowerShell modules required
Microsoft Graph permissions may require amin approval
the script must remain running for automatic syncing
automatic synchronization has not yet been verified end to end
