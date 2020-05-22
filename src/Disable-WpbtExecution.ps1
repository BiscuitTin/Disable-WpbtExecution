Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$imageFile = Read-Host "Specify the .wim file to mount"
$mountDir = New-Item -Name "$(New-Guid)" -Path $([System.IO.Path]::GetTempPath()) -ItemType Directory
Dism.exe /Get-ImageInfo /ImageFile:"$imageFile"
$index = Read-Host "Specify the index of the image on which to perform the disable operation"
Dism.exe /Mount-Image /ImageFile:"$imageFile" /Index:"$index" /MountDir:"$mountDir" /Optimize /CheckIntegrity
reg.exe LOAD "HKLM\IMAGE" "$mountDir\Windows\System32\config\SYSTEM"
reg.exe ADD "HKLM\IMAGE\ControlSet001\Control\Session Manager" /v "DisableWpbtExecution" /t REG_DWORD /d 1 /f
reg.exe UNLOAD "HKLM\IMAGE"
Dism.exe /Unmount-Image /MountDir:"$mountDir" /Commit /CheckIntegrity
Remove-Item $mountDir
