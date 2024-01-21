########################################
# Written by Scott Richards            #
# December 2023                        #
# Framework System Logs Backup Script  #
########################################

# JSON env config file

$configFilePath = Join-Path $PWD.Path "logscopy_env.json"


# Read JSON env file

$configJson = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json


# Access JSON values

$LogDir = $configJson.LogDir

$sourceDir = $configJson.pathSourceDir

$baseTargetDir = $configJson.pathTargetDir

$myTime = $configJson.myTime

$excludeExts = $configJson.ExcludedExtensions


# Get hostname

$hostName = $env:COMPUTERNAME


# Get timezone offset in format '+hhmm' or -'hhmm'

$timeZoneOffset = [System.TimeZoneInfo]::Local.GetUtcOffset((Get-Date))

$offsetString = "{0:00}{1:00}" -f $timeZoneOffset.Hours, $timeZoneOffset.Minutes

if ($timeZoneOffset.TotalMinutes -ge 0) {

    $offsetString = "+" + $offsetString

}

# Define log file

$logDate = (Get-Date -Format "yyyyMMdd_HHmmss-ff")

$logfile = "$LogDir\logscopy_$hostname" + "_" + $logDate + "_UTC$offsetString" +".txt"


# Start transcript

Start-Transcript -Path $logFile -Append


# Function for Logging

function Log-Message

{

    [CmdletBinding()]

    Param

    (

        [Parameter(Mandatory=$true, Position=0)]

        [string]$LogMessage

    )


    Write-Output ("{0} - {1}" -f (Get-Date -Format "MM/dd/yyyy HHmmss-ff"), $LogMessage)

}


echo " "

echo "Framework Systems Logs Backup Script"

echo  "===================================="

$StartDate = (Get-Date)

Log-Message "Starting Backups"

Log-Message "Logs Directory: $PWD\$LogDir"

Log-Message "Source Directory: $sourceDir."

Log-Message "Target Directory: $baseTargetDir."

Log-Message "Files will be parsed based on $myTime."

Log-Message "Excluding the following extensions: $excludeExts."

 
# Function to calc the MD5 hash for file

function Get-MD5Hash {

    param (

        [string]$filePath

    )

 

    $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider

    try {

        $fileStream = [System.IO.File]::OpenRead($filePath)

        $hash = [System.BitConverter]::ToString($md5.ComputeHash($fileStream)).Replace("-", "")

        $fileStream.Close()

        return $hash

    }

    catch {

        Log-Message "Error calculating MD5: $_"

    }

}


# Get list of files from source dir - extensions (i.e. $excludedExts) defined in JSON env config

$files = Get-ChildItem -Path $sourceDir -Recurse -File | Where-Object {

    $exclude = $false

    foreach ($ext in $excludeExts) {

        if ($_.Extension -eq $ext) {

            $exclude = $true

            break

        }

    }

    -not $exclude

}

 
foreach ($file in $files) {

    # Calc MD5 Hash for source files

    $sourceHash = Get-MD5Hash -filePath $file.FullName

 
    # Extract year, month and day from the file's myTime - myTime which is set in JSON env config file

    $year = $file.$myTime.ToString("yyyy")

    $monthName = $file.$myTime.ToString("MMMM")

    $dayNumber = $file.$myTime.ToString("dd")

 
    # Calc the relative path from the source dir

    $relativePath = $file.FullName.Substring($sourceDir.Length).TrimStart('\')

 
    # Define target dir for file

    $targetDir = Join-Path $baseTargetDir -ChildPath "$hostname\$year\$monthName\$dayNumber\$relativePath"

 
    # Create target dir if doesn't exist

    if (-not (Test-Path -Path $targetDir)) {

        New-Item -Path $targetDir -ItemType Directory -Force

    }

 
    # Copy file to target dir

    $targetFilePath = Join-Path $targetDir -ChildPath $file.Name

    Copy-Item -Path $file.FullName -Destination $targetFilePath

    Log-Message "Copied $($file.FullName) to $targetFilePath"

 
    # Calc MD5 Hash for copied target files

    $targetHash = Get-MD5Hash -filePath $targetFilePath

 

    if ($sourceHash -eq $targetHash) {

        Remove-Item -Path $file.FullName -Force

        Log-Message "Source MD5 Hash matches Target. Deleted file: $($file.FullName)"

    }

    else {

        Log-Message "Hash mismatch for file: $($file.FullName)"

    }

}

 
$EndDate = (Get-Date)

echo " "

echo "=========================================="

Log-Message "Backups Completed!!"

 
# Calculate script time to run

New-Timespan -Start $StartDate -End $EndDate

 
# Stop transcript

Stop-Transcript

 
# Windows Notification using toast to generate notif

function Trigger-Notif {

    $ErrorActionPreference = "Stop"

    $notificationTitle = "Notification: LOGSCOPY Script has been completed successfully"

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null

    $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText01)

    $toastXml = [xml] $template.GetXml()

    $toastXml.GetElementsByTagName("text").AppendChild($toastXml.CreateTextNode($notificationTitle)) > $null

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument

    $xml.LoadXml($toastXml.OuterXml)

    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)

    $toast.Tag = "PS1"

    $toast.Group = "DE NA"

    $toast.ExpirationTime = [DateTimeOffset]::Now.AddSeconds(5)

    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Script Completed!")

    $notifier.Show($toast);

}

 
# Call Windows notif

Trigger-Notif
