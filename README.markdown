# Setting up a new computer

A human readable transcript of human instructions is much more efficient than
a scripted setup IMHO.

## A. Directories

1. Create the junction `C:\Home` that points to `%USERPROFILE%`.

2. Create the directory `C:\Home\Tools` and add this to `PATH`.

## B. Customisation

1. Accent colour and window borders.

2. Enable small taskbar icons.

3. Disable hidden file extensions.

4. Enable show hidden files.

5. Enable verbose status.

6. Set power button action to hibernate.

7. Set windows update to ask before install.

## C. Chocolatey

1. Install chocolatey

``` powershell
Set-ExecutionPolicy RemoteSigned -Scope Process
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
```

2. Install these:

```
choco install googlechrome firefox vlc adobereader paint.net gimp inkscape malwarebytes teamviewer virtualbox

choco install conemu putty vim-tux win32-openssh git 7zip

choco install mingw nodejs python2 python ruby lua perl racket activetcl miketex pandoc

choco install nirlauncher
```

3. Move all desktop shortcuts to the Tools directory.

4. Add the following to AppPath: VLC, Inkscape, TeamViewer.

```
H
```

5. Use shellexview and shellmenuview to disable unwanted context menu handlers, or put into extended mode.
