taskkill /FI "WindowTitle eq uurBackupPowershell" /T /F
start "uurBackupPowershell" powershell.exe -NoExit -noprofile -executionpolicy bypass -command "& '%~dp0\uur.backup.logfile.ps1'"
