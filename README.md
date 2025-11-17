# Workstation File Transfer Script

A PowerShell tool that automates moving a user's data from an old workstation to a new one across UNC paths. It copies common profile folders, Outlook items, PST files, and Quick Access history. The script also creates transfer logs on both machines for easy review.

## What It Transfers

### Profile Folders
Copies these if they exist:
- `Desktop`
- `Documents`
- `Pictures`
- `Favorites`
- `Links`
- `Signatures`

### Outlook Items
- Signature folder from AppData\Roaming\Microsoft\Signatures
- PST files from:
  - `AppData\Local\Microsoft\Outlook`
  - `AppData\Roaming\Microsoft\Outlook`
  - `Documents\Outlook Files`
  - `C:\Users\<User>\Outlook`  
- PSTs are placed in a PSTs folder on the new device. The folder is removed if no PSTs exist.

### Quick Access
Copies `Recent\AutomaticDestinations` to restore Quick Access pins.

### Logging
Creates a folder on the technician desktop:  
`$env:USERPROFILE\Desktop\FileTransferLogs\<TargetUser>`

A copy of the log is also saved on the new workstation:  
`\\<NewComputerName>\C$\Users\<TargetUser>\AppData\Roaming\FileTransferLogs\<TargetUser>`


## How to Run
Run the script in an elevated PowerShell session with ExecutionPolicy set to Bypass, then provide the required parameters:
- OldComputerName (hostname of the source device)  
- NewComputerName (hostname of the destination device)  
- TargetUser (username whose data will be migrated)

Or run it directly:

```powershell
.\FileTransfer.ps1 -OldComputerName "OLDPC01" -NewComputerName "NEWPC01" -TargetUser "jsmith"
```
## Requirements:
PowerShell  
Administrative access to both machines  
Network access to \OldPC\C$ and \NewPC\C$  
The user profile must exist on the new machine  

The script checks paths and only transfers items that are present.

## Script Structure
### Functions:
userFolders  
outlookSignatures  
outlookPSTs  
quickAccessBackup  
copyLogs  

Each function handles one part of the migration for easier updates.

## Future Ideas
New Profile Pre-Creation
Browser bookmark transfer  
Printer and mapped drive migration  
CSV driven multi-user transfers  
Better error handling  
A small GUI for technicians (once more functions are added)
