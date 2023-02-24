# HybridAD Account Automation

PowerShell scripts for automating new user account tasks within a hybrid Active Directory environment. 

Supported tasks include setting initial password and a custom security attribute.

# Installation and use

To use the automation scripts: 

1. Clone the repository to a Windows machine with domain access to Active Directory and Azure Active Directory.
2. Update the scripts with information specific to your own AD and domain system.
3. To set passwords and custom secrutity attributes, run the controller script which looks for a CSV containing UPNs and passwords for each new account.
4. Each script can be run directly by providing the required information as command line arguments.

Each script is thoroughly documented including prerequisties, dependencies, and required information for the script to perform its tasks.
