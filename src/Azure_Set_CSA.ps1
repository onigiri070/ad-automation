# Author: Rob Pelger
# Company, Department, Team
# Created: 2022.08.25
# Updated: 2023.02.23
# Recent changes:
#   Sanitize code for public access

# Copies User ID number from Employee ID property to UserIDNumber Custom Security Attribute.
#
# Script must be run in Windows Powershell, not in Powershell Core
# Dependencies:
# - Uninstall AzureAD module if installed
# - Install AzureADPreview module: Install-Module -Name AzureADPreview 

# LIBRARIES
# None

# FUNCTIONS
# Get-UserProperties($username)
# Retrieve UserID, UPN, and Employee ID
# Takes one parameter: $username - command line argument received from command line
function Get-UserProperties {
    param (
        [Parameter(Mandatory = $true)] [string] $username
    )
    $ADProperties = "UserPrincipalName","EmployeeID"
    $userProperties = Get-ADUser -identity $username -properties $ADProperties
    Write-Output $userProperties
    return "$userProperties"
}
# Set-UserIDNumber
# Set CSA UserIDNumber to $userID object
function Set-UserIDNumber {
    param (
        [Parameter(Mandatory = $true)] [string] $userID
    )
    $CSAUserID = @{
        AttributeSet = @{
            "@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
            UserIDNumber = "$($userID)"
        }
    }
    # DEBUG
    #Write-Output $CSAUserID
    # Set CSA UserIDNumber to user
    # Try to write changes to Azure and catch any exceptions & write them to the console
    try {
        Set-AzureADMSUser -Id $userAzureID -CustomSecurityAttributes $CSAUserID
        Write-Output "$username : Successfully set Custom Security Attribute UserIDNumber"
    } catch {
        Write-Output "Set-AzureADMSUser exception:"
        Write-Output $_
    }
}

# MAIN
$username = $args[0]
# DEBUG
#Write-Output $username
# Get user properties
$userAccountProperties = Get-UserProperties($username)
# Parse properties into separate variables and cast system.object[] type to String, trimming trailing whitespace
$userUPN = (($userAccountProperties | Select-Object UserPrincipalName).UserPrincipalName | Out-String).Trim()
$userStudentID = (($userAccountProperties | Select-Object StudentID).StudentID | Out-String).Trim()
# DEBUG
#Write-Output "UPN: $userUPN" "UserID: $userStudentID"
# Get Azure Object ID for user's UPN
$userAzureID = (Get-AzureADMSUser -Id "$userUPN" -select Id).Id
Set-UserIDNumber($userStudentID)

# TODO
