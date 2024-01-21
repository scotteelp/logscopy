# LOGSCOPY
## Framework System Logs Backup Script (logscopy.ps1)

**Author:** Scott Richards
**Date:** December 2023

This PowerShell script, `logscopy.ps1`, is designed to automate the backup of system logs using a JSON configuration file. It copies log files from a source directory to a target directory, calculates MD5 hashes for both source and target files, and logs the backup process.

## Prerequisites

Before running the script, ensure that you have the following prerequisites in place:

- **PowerShell Environment:** The script requires a PowerShell environment to run.
- **JSON Configuration File:** You must provide a JSON configuration file named `logscopy_env.json`. Make sure it's in the same directory as the script.

## Configuration

Configure the `logscopy_env.json` file with the following parameters:

- `LogDir`: This is the directory where log files will be stored during the backup process.
- `pathSourceDir`: Specify the source directory where your log files are located.
- `pathTargetDir`: Set the target directory where the script will copy log files.
- `myTime`: Identify a property within the log files that specifies the date and time of each log entry.
- `ExcludedExtensions`: Define an array of file extensions to exclude from the backup.

## Running the Script

To run the script, follow these steps:

1. Open a PowerShell console.
2. Navigate to the directory containing the script (`logscopy.ps1`).
3. Execute the script using the following command:

```powershell
.\logscopy.ps1
```

## Logging
The script creates a log file with a timestamp in the specified LogDir directory. You can refer to this log file for detailed information about the backup process.

## File Backup Process
The script follows these steps to back up log files:

It calculates the local timezone offset and appends it to the log file name.
The script iterates through log files in the source directory, excluding those with extensions listed in ExcludedExtensions.
For each file, it calculates the MD5 hash of the source file.
Log files are organized in the target directory based on the year, month, and day of each log entry.
If the target directory does not exist, the script creates it.
Files are copied from the source directory to the target directory.
The script calculates the MD5 hash of the copied files.
If the MD5 hashes of the source and target files match, the source file is deleted.

## Notifications
The script provides a notification feature that triggers a Windows toast notification when the backup process is completed successfully.

## Example Usage
Here is an example of how to run the script:

```powershell
.\logscopy.ps1
```

License
This script is open source and is provided under the MIT License. For details, please see the LICENSE file included in this repository.

