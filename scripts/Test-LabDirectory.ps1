[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
$domain = Get-ADDomain
if ($domain.DNSRoot -ne 'seanslab.test') {
    throw "Expected seanslab.test; connected to '$($domain.DNSRoot)'."
}
$ou = Get-ADOrganizationalUnit -Identity 'OU=Lab,DC=seanslab,DC=test'
$user = Get-ADUser -Identity 'labuser01' -Properties Enabled
$group = Get-ADGroup -Identity 'Lab-Readers'
$member = Get-ADGroupMember -Identity $group | Where-Object { $_.DistinguishedName -eq $user.DistinguishedName }
if ($user.DistinguishedName -ne "CN=Lab User 01,$($ou.DistinguishedName)" -or $group.DistinguishedName -ne "CN=Lab-Readers,$($ou.DistinguishedName)") {
    throw 'The user or group is not in the expected lab OU.'
}
if (-not $user.Enabled -or -not $member) { throw 'The test user is disabled or is not a group member.' }
Write-Host "Domain: $($domain.DNSRoot)"
Write-Host "OU: $($ou.DistinguishedName)"
Write-Host "Enabled user: $($user.SamAccountName)"
Write-Host "Group membership verified: $($group.SamAccountName)"
Write-Host 'Directory checks passed. Test client logon and Group Policy separately.'
