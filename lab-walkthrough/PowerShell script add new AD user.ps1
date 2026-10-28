#PowerShell script to add a new user to Active Directory 
# Run in elevated PowerShell

Import-Module ActiveDirectory

# Array of user info
$users = @(
    @{Name="Alice Johnson"; Given="Alice"; Surname="Johnson"; Sam="ajohnson"; UPN="ajohnson@domain.com"},
    @{Name="Bob Smith"; Given="Bob"; Surname="Smith"; Sam="bsmith"; UPN="bsmith@domain.com"},
    @{Name="Charlie Brown"; Given="Charlie"; Surname="Brown"; Sam="cbrown"; UPN="cbrown@domain.com"},
    @{Name="Diana Prince"; Given="Diana"; Surname="Prince"; Sam="dprince"; UPN="dprince@domain.com"},
    @{Name="Ethan Hunt"; Given="Ethan"; Surname="Hunt"; Sam="ehunt"; UPN="ehunt@domain.com"},
    @{Name="Fiona Davis"; Given="Fiona"; Surname="Davis"; Sam="fdavis"; UPN="fdavis@domain.com"},
    @{Name="George Miller"; Given="George"; Surname="Miller"; Sam="gmiller"; UPN="gmiller@domain.com"},
    @{Name="Hannah Lee"; Given="Hannah"; Surname="Lee"; Sam="hlee"; UPN="hlee@domain.com"},
    @{Name="Isaac Wright"; Given="Isaac"; Surname="Wright"; Sam="iwright"; UPN="iwright@domain.com"},
    @{Name="Julia Clark"; Given="Julia"; Surname="Clark"; Sam="jclark"; UPN="jclark@domain.com"}
)

# Common OU Path (adjust for your AD domain if you don't want it to go to the default Users container)
$ouPath = "CN=Users,DC=domain,DC=com"

# Default password for all users (change to policy-compliant)
$password = ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force

# Create users
foreach ($u in $users) {
    New-ADUser `
        -Name $u.Name `
        -GivenName $u.Given `
        -Surname $u.Surname `
        -SamAccountName $u.Sam `
        -UserPrincipalName $u.UPN `
        -Path $ouPath `
        -AccountPassword $password `
        -Enabled $true `
        -ChangePasswordAtLogon $true
    Write-Output "Created user: $($u.Name)"
}
