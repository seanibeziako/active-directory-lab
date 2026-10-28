[CmdletBinding()]
param(
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$expectedDomain = 'seanslab.test'
$rootDn = 'DC=seanslab,DC=test'
$labDn = "OU=Lab,$rootDn"
$userName = 'labuser01'
$groupName = 'Lab-Readers'

if (-not $Apply) {
    Write-Host 'Preview only: no directory changes will be made.'
    Write-Host "Target domain: $expectedDomain"
    Write-Host "Create or reuse: $labDn, group $groupName, user $userName."
    Write-Host 'The user will be added to the group if not already a member.'
    Write-Host 'Review the script and run with -Apply on the lab domain controller.'
    return
}

Import-Module ActiveDirectory
$domain = Get-ADDomain
if ($domain.DNSRoot -ne $expectedDomain) {
    throw "Refusing to make changes: connected to '$($domain.DNSRoot)', expected '$expectedDomain'."
}

$ou = Get-ADOrganizationalUnit -Filter "Name -eq 'Lab'" -SearchBase $rootDn -SearchScope OneLevel
if (-not $ou) {
    New-ADOrganizationalUnit -Name 'Lab' -Path $rootDn
    Write-Host "Created $labDn"
} else {
    Write-Host "Using existing $labDn"
}

$group = Get-ADGroup -Filter "SamAccountName -eq '$groupName'"
if (-not $group) {
    New-ADGroup -Name $groupName -SamAccountName $groupName -GroupScope Global -GroupCategory Security -Path $labDn
    $group = Get-ADGroup -Identity $groupName
    Write-Host "Created group $groupName"
} elseif ($group.DistinguishedName -ne "CN=$groupName,$labDn") {
    throw "Group $groupName already exists outside the lab OU; inspect it manually."
}

$user = Get-ADUser -Filter "SamAccountName -eq '$userName'"
if (-not $user) {
    $password = Read-Host 'Enter a unique initial password for the lab user' -AsSecureString
    New-ADUser -Name 'Lab User 01' -SamAccountName $userName -UserPrincipalName "$userName@$expectedDomain" -Path $labDn -AccountPassword $password -Enabled $true -ChangePasswordAtLogon $true
    $user = Get-ADUser -Identity $userName
    Write-Host "Created user $userName"
} elseif ($user.DistinguishedName -ne "CN=Lab User 01,$labDn") {
    throw "User $userName already exists outside the expected lab location; inspect it manually."
}

$membership = Get-ADGroupMember -Identity $group -ErrorAction Stop | Where-Object { $_.DistinguishedName -eq $user.DistinguishedName }
if (-not $membership) {
    Add-ADGroupMember -Identity $group -Members $user
    Write-Host "Added $userName to $groupName"
} else {
    Write-Host "$userName is already a member of $groupName"
}
Write-Host 'Provisioning finished. Run Test-LabDirectory.ps1 and verify client sign-in separately.'
