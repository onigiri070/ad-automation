# Author: Rob Pelger
# Company, Department, Team
# Created: 2022.08.30
# Updated: 2023.02.23
# Recent changes:
#   Sanitize code for public access

# Sets a temporary password received as an argument for the user passed to the script as an argument
#
# Script must be run in Windows Powershell, not in Powershell Core
# Dependencies:
# - Uninstall AzureAD module if installed
# - Install AzureADPreview module: Install-Module -Name AzureADPreview 

# LIBRARIES
# None

# FUNCTIONS
# Set-TempPassword $upn $pass
function Set-TempPassword {
    param (
        [Parameter(Mandatory = $true)] [string] $upn,
        [Parameter(Mandatory = $true)] [string] $pass
    )
    # Set temporary password for user
    # Try to write changes to Azure and catch any exceptions & write them to the console
    try {
        $ConvertedPassword = ConvertTo-SecureString $pass -AsPlainText -Force
        Set-AzureADUserPassword -ObjectId $upn -Password $ConvertedPassword 
        Write-Output "$upn : Successfully set temporary password"
    } catch {
        Write-Output "Set-AzureADUserPassword exception:"
        Write-Output $_
    }
}

# MAIN
$username = $args[0]
$password = $args[1]
$userprincipalname = "$username@domain.suffix"
# DEBUG
#Write-Output $username $password
#Write-Output $password.GetType()
#Write-Output $objectId.GetType()
Set-TempPassword $userprincipalname $password

# TODO
