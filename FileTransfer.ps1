# Rudimentary File Transfer Script 

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$OldComputerName,
    [Parameter(Mandatory=$true)][string]$NewComputerName,
    [Parameter(Mandatory=$true)][string]$TargetUser
)

# Creates Personal File Transfer Log Folder
New-Item -Path "$env:USERPROFILE\Desktop\FileTransferLogs\$TargetUser" -ItemType Directory -Force | Out-Null

# Folders located in User folder
function userFolders {

$userFolders = @("Desktop", "Pictures", "Favorites", "Links", "Documents", "Signatures")

    foreach ($item in $userFolders) {
        $src="\\$OldComputerName\C$\Users\$TargetUser\$item"
        $target="\\$NewComputerName\C$\Users\$TargetUser\$item"
            if (Test-Path $src)
            {
                robocopy $src $target /E /Z /W:1 /R:1 /V /NP /unilog+:"$env:USERPROFILE\Desktop\FileTransferLogs\$TargetUser\FileTransferLogs.txt" /TEE
            }
    }
}

# Outlook sigs
function outlookSignatures {

    $src="\\$OldComputerName\C$\Users\$TargetUser\AppData\Roaming\Microsoft\Signatures"
    $target="\\$NewComputerName\C$\Users\$TargetUser\AppData\Roaming\Microsoft\Signatures"
        if (Test-Path $src) {
            robocopy $src $target /E /Z /W:1 /R:1 /V /NP /unilog+:"$env:USERPROFILE\Desktop\FileTransferLogs\$TargetUser\FileTransferLogs.txt" /TEE
        }
}

# Outlook PSTs
function outlookPSTs {
    
    New-Item -Path \\$NewComputerName\C$\Users\$TargetUser\Desktop\PSTs -ItemType Directory -Force | Out-Null
    $PSTs = "\\$NewComputerName\C$\Users\$TargetUser\Desktop\PSTs"

    $src = @(
        "\\$OldComputerName\C$\Users\$TargetUser\AppData\Local\Microsoft\Outlook", 
        "\\$OldComputerName\C$\Users\$TargetUser\AppData\Roaming\Microsoft\Outlook",
        "\\$OldComputerName\C$\Users\$TargetUser\Documents\Outlook Files",
        "\\$OldComputerName\C$\Users\$TargetUser\Outlook" 
    )

    foreach ($item in $src) {
        $pstPath = Join-Path $item "*.pst"
            if (Test-Path $pstPath) {
                (Write-Host "`
                            `
                            `
                            !!!!! Found PST files:")
(Get-ChildItem -Path $item -Filter *.pst -Name)
Write-Host "Inside of" $item
            robocopy $item $PSTs *.pst /Z /W:1 /R:1 /V /NP /unilog+:"$env:USERPROFILE\Desktop\FileTransferLogs\$TargetUser\FileTransferLogs.txt" /TEE
            }
    }

    if ( !(Test-Path -Path (Join-Path $PSTs "*.pst"))) {
        Remove-Item -Path $PSTs -Recurse -Force
    }
}

# Quick Access Backup
function quickAccessBackup {

Start-Sleep -Seconds 2
Remove-Item -Path "\\$NewComputerName\C$\Users\$TargetUser\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations" -Force -Recurse
$src = "\\$OldComputerName\C$\Users\$TargetUser\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations"
$target = "\\$NewComputerName\C$\Users\$TargetUser\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations"
robocopy $src $target /E /unilog+:"$env:USERPROFILE\Desktop\FileTransferLogs\$TargetUser\FileTransferLogs.txt" /TEE

}

# Copy built local logs remotely to new computer
function copyLogs {

New-Item -Path "\\$NewComputerName\C$\Users\$TargetUser\AppData\Roaming\FileTransferLogs\$TargetUser" -ItemType Directory -Force | Out-Null
robocopy "$env:USERPROFILE\Desktop\FileTransferLogs\$TargetUser" "\\$NewComputerName\C$\Users\$TargetUser\AppData\Roaming\FileTransferLogs\$TargetUser" "FileTransferLogs.txt" /NFL /NDL /NJH /NJS /nc /ns /np
Write-Host "Local Log File Dropped in $env:USERPROFILE\Desktop\FileTransferLogs\$TargetUser"
Write-Host "Remote Log File Dropped in \\$NewComputerName\C$\Users\$TargetUser\AppData\Roaming\FileTransferLogs\$TargetUser"
}

userFolders
outlookSignatures
outlookPSTs
quickAccessBackup
copyLogs