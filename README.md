# dotfiles
My personal dotfiles for Windows 10 using Debian in WSL 2.

# Installation
## Install WSL
1. Enable the Windows Subsystem for Linux:
```
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```
2. Enable Virtual Machine feature:
```
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```
3. Restart your computer.
4. Download and install the [WSL2 Linux kernel update package](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi).
5. Set WSL 2 as your default version:
```
wsl --set-default-version 2
```
6. Install Debian through Microsoft Store.
