<#PSScriptInfo

.VERSION 1.0.3

.GUID a73568ed-d3da-4b81-9522-d29b69b97010

.AUTHOR Kexy Biscuit

.COMPANYNAME Biscuit Tin

.COPYRIGHT Copyright (c) 2020 Biscuit Tin

.TAGS wpbt

.LICENSEURI https://github.com/BiscuitTin/Disable-WpbtExecution/blob/master/LICENSE

.PROJECTURI https://github.com/BiscuitTin/Disable-WpbtExecution

.ICONURI https://avatars0.githubusercontent.com/u/48196342

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Add errors when the script isn't running on Windows or is running without elevated permissions.

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Modify an image to disable WPBT execution. 

#> 
Param(
  [Parameter(Mandatory=$true,Position=0,
  HelpMessage="Specify the .wim file to mount")]
  [string] $ImageFile
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (($null -eq $PSEdition) -or ($PSEdition -eq "Desktop") -or ($PSVersionTable.Platform -eq "Win32NT")))
{
  Write-Error "Microsoft Windows is required to run Disable-WpbtExecution."
  break
}

if (-not ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator"))
{
  Write-Error "Elevated permissions are required to run Disable-WpbtExecution."
  break
}

Dism.exe /Get-ImageInfo /ImageFile:"$ImageFile"
[int] $index = Read-Host "Specify the index of the image on which to perform the disable operation"

$mountDir = New-Item -Name "$(New-Guid)" -Path $([System.IO.Path]::GetTempPath()) -ItemType Directory
Dism.exe /Mount-Image /ImageFile:"$ImageFile" /Index:"$index" /MountDir:"$mountDir" /Optimize /CheckIntegrity

reg.exe LOAD "HKLM\IMAGE" "$mountDir\Windows\System32\config\SYSTEM"
reg.exe ADD "HKLM\IMAGE\ControlSet001\Control\Session Manager" /v "DisableWpbtExecution" /t REG_DWORD /d 1 /f
reg.exe UNLOAD "HKLM\IMAGE"

Dism.exe /Unmount-Image /MountDir:"$mountDir" /Commit /CheckIntegrity
Remove-Item $mountDir
