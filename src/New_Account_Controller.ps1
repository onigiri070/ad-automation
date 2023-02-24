# Author: Rob Pelger
# Company, Department, Team
# Created: 2022.08.30
# Updated: 2023.02.23
# Recent changes:
#   Sanitize code for public access

# Controller which reads username, password data from CSV and calls appropriate scripts to process new account tasks. 
# If needed, each referenced script can be called directly from the comamnd line by providing the required data objects as arguments.
#
# Script must be run in Windows Powershell, not in Powershell Core
# Dependencies:
# - Meets dependencies of referenced PS1 files

# LIBRARIES
# None

# MAIN
Connect-AzureAD

# Import csv containing only usernames and passwords, create header properties, and store object in $csvData
# Generate semaphore file for mailing system to send new user welcome emails
$csvData = Import-Csv -Path "\\location\of\accounts.csv" -Header 'username', 'password'
$semaphore = "\\location\of\semaphore.txt"

# Iterate through $csvData, setting the CSA and password for each row
# Skip any accounts with username "no AD account"
$csvData | ForEach-Object {
    if ($_.username -eq "no AD account") {
        & Write-Output "No AD account listed for this user. Skipping...`n"
    } else {
        # DEBUG
        #Write-Output "Username: "$_.username, "Password: "$_.password
        & "$PSScriptRoot\Azure_Set_CSA.ps1" $_.username
        & "$PSScriptRoot\Azure_Reset_Password.ps1" $_.username $_.password
    }
}

# Once done processing accounts generate semaphore to trigger welcome emails
Write-Output "`nGenerating semaphore..."
New-Item -Path $semaphore -Force

# Disconnect from services
Disconnect-AzureAD
Write-Output "`nDisconnected AzureAD session. You can now close this window."

# TODO
# (1) Check for existing connection to AzureAD. If one exists, do not try to connect.
