<#
SYNOPSIS
    Sends output to a file.

DESCRIPTION

		this script creates a trigger on file(s) in a directory wich can be filtered by ...
		if a file is CHANGED, DELETED, CREATED, RENAMED, the trigger starts an action.
		(in this example only CHANGED is used, but for each trigger a single action can be defined)

		this action creates a backup of a file in watcher.PATh if a change is done in the file
		if so a zip-file is created and saved
		if the zip-files have the same size in kb the older, doublicate zip is removed
		if a zip file is older than XX days the old files will be removed aswell
    The Out-File cmdlet sends output to a file. You can use this cmdlet instead of the redirection operator (>) when you need to use its parameters.
Configure
		$localPath			= the path where the files to be monitored resist
		$watcher.Filter	= the filter for the files to be monitored
		$uurFile				= 
Author
		Mathias Koch / AdOptimize
Date
		May 2022
#>

$_PID						= [System.Diagnostics.Process]::GetCurrentProcess().Id
$localPath 			= Get-Location
$uurPath				= Split-Path -Path $localPath -Parent
$pidFile				= "uurMonitor.pid"

### kill last process and start all over
if (Test-Path $pidFile)
{
		$lastPid		= Get-Content -Path $pidFile
		taskkill /pid $lastPid
}

$_PID | Set-Content -Path $pidFile -ErrorAction SilentlyContinue 


### SET FOLDER TO WATCH + FILES TO WATCH + SUBFOLDERS YES/NO
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $uurPath 
    $watcher.Filter = "*.LOG"
    $watcher.IncludeSubdirectories = $false
    $watcher.EnableRaisingEvents = $true  

### DEFINE ACTIONS AFTER AN EVENT IS DETECTED
    $action = { 
								$localPath 			= Get-Location
								$uurPath				= Split-Path -Path $localPath -Parent
								#$actionLog			= "log.txt"
								#$actionFile			= Join-Path $localPath $actionLog
								#$actionLogLine	= "changed"
								$uurFile				= "uur.LOG"
								$uurZipFile			= "uur.LOG$(((get-date).ToUniversalTime()).ToString('yyyy-MM-dd_Hmmss')).zip"
								$uurFilePath		= Join-Path $uurPath $uurFile
								$uurZipPath			= join-Path $localPath $uurZipFile 
								$deleteDaysBack = (Get-Date).AddDays(-90) 

                #Add-content $actionFile" -value $actionLogLine -ErrorAction Continue
								# CREATE ZIP
								Compress-Archive -Path $uurFilePath -DestinationPath $uurZipPath -ErrorAction Continue
				
								# Delete old ZIP files
								Get-ChildItem -Path $localPath -Filter *.zip -file | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $deleteDaysBack } | Remove-Item -Force -ErrorAction Continue

								# equally sized files can be removed aswell . now what is equal :)
								$files				= Get-ChildItem $localPath -File -Recurse -Include *.zip -ErrorAction SilentlyContinue | sort CreationTime | 
																	Select-Object  FullName, @{Name='Size'; Expression={([string]([int]($_.Length / 1KB)))} } |
																	Group-Object Size |
																	Where-Object Count -GT 1
								If ($files.count -gt 1)
								{
									$files.Size
									$res	= $files | %{$_.Group[0].FullName}
									Remove-Item -Force $res -ErrorAction Continue
								}

								# due to sync it might be possible to have doublicate files in folders.. we delete them
								$duplicates 		= Get-ChildItem $localPath -File -Recurse -ErrorAction SilentlyContinue | 
																		Get-FileHash | 
																		Group-Object -Property Hash |
																		Where-Object Count -GT 1

								If ($duplicates.count -gt 1)
							  {
									$result = foreach ($d in $duplicates)
									{
										$d.Group | Select-Object -Property Path, Hash
									}
				          Remove-Item -Force $result.Path
								}


              }
### DECIDE WHICH EVENTS SHOULD BE WATCHED 
    #Register-ObjectEvent $watcher "Created" -Action $action
    Register-ObjectEvent $watcher "Changed" -Action $action
    #Register-ObjectEvent $watcher "Renamed" -Action $action
    #Register-ObjectEvent $watcher "Deleted" -Action $action
    while ($true) {
			sleep 30 
		}
