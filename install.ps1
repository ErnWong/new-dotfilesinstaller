# Check for administrator and executionpolicy
# note: shiming tool must pass on arguments, pipes, etc...

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

$apppathsdir = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths'
$shellmenudir = 'HKCR:\Directory\Shell'
$explorerreg = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
$homedir = $Env:USERPROFILE
$toolsdir = "$homedir\Tools"
$desktopdir = [Environment]::GetFolderPath('Desktop')
$desktopcomdir = [Environment]::GetFolderPath('CommonDesktopDirectory')
$startmenudir = "%AppData%\Microsoft\Windows\Start Menu\Programs"
$startmenucomdir = "%ProgramData%\Microsoft\Windows\Start Menu\Programs"

function Get-LnkTarget {
    param([string]$path)
    $sh = New-Object -COM WScript.Shell
    return $sh.CreateShortcut($path).TargetPath
}

function Add-AppPath {
    param([string]$path)
    $filename = Split-Path -Path $path -Leaf
    $parentdir = Split-Path -Path $path -Parent
    if (-Not Test-Path $apppathsdir) {
        New-Item -Path $apppathsdir
    }
    New-Item -Path "$apppathsdir\$filename"
    Set-ItemProperty -Path "$apppathsdir\$filename" -Name '(Default)' -Value $path
    Set-ItemProperty -Path "$apppathsdir\$filename" -Name 'Path' -Value $parentdir
}

function Add-StartmenuLnkToAppPath {
    param([string]$filename)
    foreach ($file in Get-ChildItem -Path "$startmenudir\$filename") {
        Add-AppPath $file
    }
    foreach ($file in Get-ChildItem -Path "$startmenucomdir\$filename") {
        Add-AppPath $file
    }
}

function Add-DesktopLnkToAppPath {
    param([string]$filename)
    foreach ($file in Get-ChildItem -Path "$desktopcomdir\$filename") {
        Add-AppPath $file
    }
    foreach ($file in Get-ChildItem -Path "$desktopdir\$filename") {
        Add-AppPath $file
    }
}

function Move-DesktopShortcut {
    param([string]$filename)
    Get-ChildItem -Path "$desktopdir\$filename" |  Move-Item -Destination "$toolsdir\$filename"
    Get-ChildItem -Path "$desktopcomdir\$filename" |  Move-Item -Destination "$toolsdir\$filename"
}

function Disable-ShellMenu {
    param([string]$name)
    if (Test-Path "$shellmenudir\$name") {
        Set-ItemProperty -Path "$shellmenudir\$name" -Name 'Extended' -Value ''
    }
}

function Disable-ShellEx {
    param([string]$name)
}

New-Item $toolsdir
Set-ItemProperty -Path "$explorerreg\Advanced" -Name 'TaskbarSmallIcons' -Value 1 -Type DWORD
Set-ItemProperty -Path "$explorerreg\Advanced" -Name 'HideFileExt' -Value 0 -Type DWORD

Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing
    | Invoke-Expression

choco install googlechrome
Move-DesktopShortcut 'Google Chrome.lnk'
# Google Chrome:
# Installs to program files
# chrome added to program registry (so can 'Run' it)
# shortcut added desktop and startmenu programs
# PATH not affected
# so it needs to be moved to tools, no shim

choco install firefox -y
Move-DesktopShortcut 'Mozilla Firefox.lnk'
# Firefox:
# installed to program files
# added to app path registry
# added shortcut to desktop and startmenu programs
# PATH not affected
# need to move shortcut to tools, no shim needed

choco install vlc -y
Add-DesktopLnkToAppPath 'VLC*'
Move-DesktopShortcut 'VLC*'
Disable-ShellMenu AddToPlaylistVLC
Disable-ShellMenu PlayWithVLC
# VLC:
# shortcut on desktop added, but not startmenu
# installed to program files
# not added to app path
# path not affected
# need to move shortcut to tools, and shim needed (Or add to registry?)
#also:

choco install adobereader -y
Move-DesktopShortcut 'Acrobat Reader DC.lnk'
# Adobe Reader:
# installed to program files
# added to app path
# added desktop and startmenu shortcut
# path not affected
# need to move shortcut to tools, no shim needed

choco install paint.net
Add-StartmenuLnkToAppPath 'paint.net.lnk'
# Paint.net
# no path
# no desktop
# yes startmenu
# no apppath

choco install gimp -y
Add-StartmenuLnkToAppPath 'Gimp*'
# Gimp:
# installed to program files
# not added to desktop
# added to startmenu
# not added to app path
# path not affected
# need to shim?

choco install inkscape -y
Add-DesktopLnkToAppPath 'Inkscape*'
Move-DesktopShortcut 'Inkscape*'
# Inkscape:
# installed to program files
# added to desktop
# added to startmenu inside folder
# path not affected
# not added to app path
# need to shim and remove desktop shortcut

choco install malwarebytes -y
Move-DesktopShortcut 'Malwarebytes*'
Disable-ShellEx
# Malwarebytes:
# installed to program files
# added to desktop
# added to startmenu inside folder
# path not affected
# added to app path as mbam
# no need to shim, only remove desktop shortcut

choco install teamviewer -y
Add-DesktopLnkToAppPath 'TeamViewer*'
Move-DesktopShortcut 'TeamViewer*'
# TeamViewer:
# installed to program files
# added to startmenu
# added to desktop
# path not affected
# not added to app path
# shim needed

choco install flashplayerplugin
# flash:
# installed at system32
# path not affected

choco install jre8
# Java
# Adds to PATH!

choco install virtualbox
Move-DesktopShortcut '*VirtualBox*'
# VirtualBox
# Installed inside Program files
# Added to Desktop
# Added to Startmenu inside folder
# Adds to PATH!
# Installed to chocolatety\lib

choco install putty
# Installed to chocolatey\lib
# Shimmed to chocolatey\bin

choco install conemu
Move-DesktopShortcut 'ConEmu'
# Installed to program files
# Added to apppaths
# Path no change
# Added to startmenu
# Added to desktop

choco install vim-tux
Disable-ShellEx 'HKCR:\*\shellex\gvim'
# into programfiles
# added to startmenu
# added bats to c:\windows
# does not include the dlls
# path not changed

choco install win32-openssh #???
# added to path

choco install git
Disable-ShellMenu git_gui
Disable-ShellMenu git_shell
# added to path

# note to self: wincred to somewhere maybe called .gitrc or .git or .gitconfig

choco install 7zip
choco install posh-git #???
choco install sudo #???

choco install mingw #???? is this mingw-w64 ??
choco install nodejs
choco install python2
choco install python
choco install ruby
choco install lua
choco install perl
choco install racket
choco install activetcl
choco install miketex
choco install pandoc

# note to self: nirsoft shellexview shellmenuview, nirlauncher
choco install nirlauncher
# note to self: add open in new process/new window to nonextended 
