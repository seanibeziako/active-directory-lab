# Active Directory support lab

A small, isolated Windows lab for practicing directory administration and help-desk troubleshooting. The lab has been deployed and tested. This repository contains setup instructions, a PowerShell provisioning script, and a verification checklist.

## What you will practice

- Deploying a domain controller and configuring DNS for a lab domain.
- Joining a Windows workstation to the domain.
- Creating an organizational unit (OU), a security group, and a test user.
- Checking group membership, testing sign-in, and documenting an account-support issue.

## Lab layout

| Machine | Purpose | Example address |
| --- | --- | --- |
| DC01 | Windows Server domain controller and DNS | 192.168.77.10/24 |
| CLIENT01 | Windows 10/11 Pro or Enterprise workstation | 192.168.77.20/24 |

Use `seanslab.test` as the isolated lab domain. These are examples: choose an unused private subnet and confirm your virtualization network configuration. Use a private, isolated virtual switch or host-only network. Do not connect the lab domain controller to an organization’s production network. A separate temporary internet connection may be needed for installations and updates; remove it before practicing isolation.

## Prerequisites

- A computer and hypervisor capable of running compatible Windows Server and Windows client virtual machines. Check guest architecture support, particularly on Apple silicon.
- Licensed installation media or appropriate evaluation editions for Windows Server and Windows 10/11 Pro or Enterprise. Windows Home cannot join an on-premises domain.
- Enough storage and memory for both machines, and access to administrator accounts in the lab VMs.
- A snapshot or backup before major configuration changes. Never use real user accounts or production passwords.

## 1. Prepare the virtual machines

1. Create two VMs on the same isolated network. Install Windows Server on DC01 and a supported Windows client edition on CLIENT01.
2. Set DC01 to a static IP on the isolated subnet, for example `192.168.77.10` with a `255.255.255.0` mask. Give CLIENT01 an unused address in the same subnet, or configure appropriate DHCP.
3. Configure CLIENT01's DNS server to the domain controller's lab IP. Verify the addresses are unique and that the two VMs can reach each other. The IP examples are not automatically applied by this repository.

## 2. Deploy the lab domain

On **DC01 only**, sign in as a local administrator and open an elevated Windows PowerShell session. Install the AD DS role and then create the lab forest:

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName 'seanslab.test'
```

The forest command prompts for a Directory Services Restore Mode password and confirmation and normally restarts the server. Use a unique lab-only password. After reboot, sign in with the domain administrator account and confirm that DNS and Active Directory management tools are available. Microsoft documents the process in [Install Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services--level-100-).

## 3. Add a workstation

On CLIENT01, confirm its DNS points to DC01. Join `seanslab.test` using Windows settings or an elevated PowerShell session and an authorized lab domain account:

```powershell
Add-Computer -DomainName 'seanslab.test' -Credential (Get-Credential)
Restart-Computer
```

Sign in after the restart and verify the computer's domain membership. See [Microsoft's domain join guide](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/join-computer-to-domain).

## 4. Provision practice objects

On DC01, copy the `scripts` folder to the lab VM and open Windows PowerShell as a domain administrator. The script checks that it is connected to the `seanslab.test` domain; it previews its intent by default. Review it before running:

```powershell
.\scripts\Initialize-LabDirectory.ps1
.\scripts\Initialize-LabDirectory.ps1 -Apply
.\scripts\Test-LabDirectory.ps1
```

The apply step asks for a test-user password. It creates the lab OU, the `Lab-Readers` global security group, and `labuser01`, and adds that user to the group if needed. Existing objects are not reset. The validation script reports what it finds; it does not prove client sign-in or Group Policy operation.

## 5. Run support exercises

Use [the exercise record](docs/exercise-record.md) for each task. Record the actual symptoms, commands, screenshots, and outcomes from your own lab.

1. Sign in as `SEANSLAB\labuser01` on CLIENT01. Confirm the user's group membership on DC01.
2. In Active Directory Users and Computers, reset the test user's password, then attempt a sign-in with the new password. Record what happened.
3. Create an OU for a test workstation, move only CLIENT01's computer object to it, and link a test Group Policy Object with a harmless setting. On CLIENT01, run `gpupdate /force` and `gpresult /r`; verify the setting and record the result. See [Group Policy overview](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-overview).
4. Temporarily set CLIENT01's DNS to an incorrect lab address, attempt name resolution, then restore DC01's address. Use `ipconfig /all` and `nslookup seanslab.test` to document what changed.

## Troubleshooting and cleanup

- **Domain lookup fails:** Verify client DNS points to DC01, both machines share the lab network, and the domain controller is running. Check `ipconfig /all` and `nslookup seanslab.test`.
- **Domain join fails:** Confirm the client edition supports joining, credentials have permission, name resolution works, and the VMs can communicate.
- **Script refuses to run:** Confirm you are running it on the correct domain with the ActiveDirectory module installed and appropriate rights. Review execution policy and the script before allowing execution.
- **GPO does not apply:** Check the object is in the linked OU, the link is enabled, and `gpresult /r` shows the expected policy. Allow time for refresh or run `gpupdate /force`.
- Remove lab VMs using your hypervisor when finished. Preserve only sanitized notes and screenshots; do not publish passwords, keys, real names, IPs from real networks, or sensitive logs.

## Status and licensing

This repository documents an Active Directory support lab. See [LICENSE](LICENSE). Links point to third-party Microsoft documentation, which is not included or relicensed here.
