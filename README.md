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
