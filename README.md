Autor:				Mathias Koch // AdOptimize
Date:					2022 May
OS:						Windows with powershell
Synopsis:			trigger local backup for files on
							CHANGED
							CREATED
							RENAMED
							# possible but sensless DELETED

Description:	If a file is CHANG(ed)|CREATE(d)|RENAME(d) the triggerworks as
              following
							- create a zip file of the monitored files
							- delete the zip files older than x days 
							- search remaining zip files for similar content by hash and
								delete doublicates
							- round file size in KB and delete files with equal file size

Take a look in uur.backup.logfile.ps1 to configure your environment

A bat-file will start the process. If the process is already running, the current running script will be stopped an a new service is started
							

