# Author: Rob Pelger 
# Company - Department
# Created: 2023.03.15
# Takes txt file as input iterates through and disables accounts matching SAM account name and moves them to the proper OU. Then renames and moves original TXT file to archive directory.
#
# Script must be run in Windows Powershell, not in Powershell Core
# Dependencies:
# - Install ActiveDirectory module 

# LIBRARIES
# None

# FUNCTIONS
# Get TXT file containing users to be withdrawn.
function Get-TXT {
    param (
        [Parameter(Mandatory = $true)] [string] $txt_file
    )
    $account_data = Get-Content -Path $txt_file 
    return $account_data
}

# Get SAM account name from UPN
function Get-SamAccountName {
    param (
        [Parameter(Mandatory = $true)] [string] $account
    )
    try {
        $sam_account_name = (Get-ADUser -filter "UserPrincipalName -eq '$account'").SamAccountName
        return $sam_account_name
    }
    catch {
        Show-Err "get SAM account name" $_
    }
}

# Display error function
function Show-Err {
    param (
        [Parameter(Mandatory = $true)] [string] $operation_exception,
        [Parameter(Mandatory = $true)] [string] $error_value
    )
    Write-Output "$operation_exception\:"
    Write-Output $error_value
}

# Disable AD account
function Disable-Account {
    param (
        [Parameter(Mandatory = $true)] [string] $sam_account_name
    )
    try {
        Disable-ADAccount -Identity $sam_account_name
    }
    catch {
        Show-Err "Failed disable AD account:" $_
    }
}

# Move AD account to specified OU
function Move-OU {
    param (
        [Parameter(Mandatory = $true)] [string] $sam_account_name,
        [Parameter(Mandatory = $true)] [string] $dest_ou
    )
    try {
        $user_dn = (Get-ADUSer -identity $sam_account_name).DistinguishedName
        Move-ADObject -identity $user_dn -TargetPath $dest_ou
    }
    catch {
        Show-Err "Failed to move OU:" $_
    }
}

# Rename file and move to Archive directory
function Move-DataFile {
    param (
        [Parameter(Mandatory = $true)] [string] $origin_file,
        [Parameter(Mandatory = $true)] [string] $new_file
    )
    try {
        Move-Item -Path $origin_file -Destination $new_file
    }
    catch {
        Show-Err "Failed to move data file: " $_ 
    }
}

# MAIN
Import-Module ActiveDirectory
$target_ou = "OU=Disabled,OU=Accounts,DC=domain,DC=com"
$current_file = "\\network\storage\WithdrawnAccounts\withdrawn.txt"

if (Test-Path -Path $current_file -PathType Leaf) {
    $account_list = Get-TXT $current_file
    
    foreach ($account in $account_list) {
        $sam_account = Get-SamAccountName $account
        Disable-Account $sam_account
        Move-OU $sam_account $target_ou
    }
    $archive_name = "Archive\" + (Get-Date -Format "yyyyMMdd") + ".txt"
    $archive_file = $current_file.Replace("withdrawn.txt", "$archive_name")
    Move-DataFile $current_file $archive_file
} else {
    Show-Err "Failed accessing TXT data file:" $_
}
