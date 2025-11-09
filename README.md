# My System Setup

**My System Setup (MSS)** is a PowerShell-based toolkit to simplify the initial configuration of a new Windows machine. It includes app installation, system checks, Git utilities, and an easy-to-use update function.  

## 🌟 Features

- **Install Applications:** Core tools, messengers, programming tools, and game launchers from configuration file.  
- **Create User Folders:** Automatically creates the folders `Workspace`, `Coding` and `Temp`. Supports Explorer Shortcuts and Quick Access pinning.  
- **Clone Git Repositories:** Fetch repositories from GitHub defined in config file. Defaults:  
  - [Hilfestellung](https://github.com/JaxRaffnix/Hilfestellung.git)  
  - [Powershell-ModuleTools](https://github.com/JaxRaffnix/Powershell-ModuleTools.git)  
- **Git Utilities:** Create Shorthand to amend last commit with optional push.  
- **System Diagnostics:** Check Windows health, disk usage, pending updates, and remove clutter.  
- **Update System:** Update apps, PowerShell modules, Python packages, and Windows updates automatically.  
- **Dependency Management:** Verify and install missing apps or modules automatically.  

## ⚡ Getting Started

> [!Note]
> You may need to run: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

MSS is provided as a PowerShell module. To install and import it to the `PSModulePath` for your user, we utilize a helper function from another project:  

1. Download [Powershell ModuleTools](https://github.com/JaxRaffnix/Powershell-ModuleTools).
2. Use the `.\self-installer.ps1` script from the `ModuleTools`.
3. Download [My System Setup](https://github.com/JaxRaffnix/My-System-Setup)
4. Now run `Install-FromDev .` from your My-System-Setup location.

The following dependencies are automatically installed with this module:

- [gsudo](https://github.com/gerardog/gsudo)  
- NuGet Package Provider
- PSRepository PSGallery is set as a Trusted.

## 🛠 Feature Details

For a full function documentation, please refer to the relevant help text by running `help <function>`.

### Install-Applications

- Uses categories defined in `/config/applications.yaml`.  
- Core modules include:  
  - **PSScriptTools:** `Show-Tree -InColor -ShowItem`  
  - **Terminal-Icons:** `Get-ChildItem -Path . -Force`  
  - **PSReadLine:** auto-completion with `CTRL+SPACE`  
  - **PSWindowsUpdate:** `PSWritePDF`.

### New-User-Folders

- Defined in `/config/folders.yaml`.  
- Folders created: `workspace`, `coding`, `temp`.  
- Supports desktop shortcuts and Quick Access pins.  

### Get-Repositories

- Clone repositories listed in `/config/repositories.yaml`.  
- Example repos: Hilfestellung, Powershell-ModuleTools.  

### Invoke-GitAmend

- `Invoke-Gitamend` (alias `ga` or `Git-Amend`) with optional message.  
- Supports `git push --force-with-lease` if remote tracking exists.  

### Invoke-Diagnostics

- Executed code stored in `/config/diagnostics`.  
- Logs saved to `$env:USERPROFILE\Documents`.  
- Checks:  
  - **System:** Defender status, reliability issues, startup apps, DISM & SFC, installed/pending updates  
  - **Storage:** Disk health, usage summary, large files  
  - **Cleanup:** Remove broken shortcuts, disk cleanup, empty recycle bin, clear temp/cache  

### Update-System

- Updates apps with Winget, PowerShell modules, Python packages, and Windows updates.  
- Runs updates as both admin and normal user.  

### Test-Dependency

- Ensures required apps/modules are installed, auto-installing if missing.  

## ✅ TO DO

- Pin Taskbar apps: `C:\Users\<User>\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar`  
- Ensure C compiler works with installed Strawberry Perl  

### Unsure

- Simplify Diagnostic checks: only one script file per category?
- Ebook reader `aquile` ID: `9P08T4JLTQNK`.

### Known Issues

- Some App IDs are strings, not descriptive names (e.g., WhatsApp `9NKSQGP7F2NH`).  
- Python versions must be installed explicitly (e.g., `Python.Python.3.13`).  
- Battlenet requires a specific install location (e.g., `C:\Program Files (x86)`).  
