# My System Setup

**My System Setup (MSS)** is a PowerShell-based toolkit to simplify the setup, configuration, and maintenance of new Windows systems.  
It automates winget apps installation, PowerShell modules imports, system diagnostics, Git utilities, as well as an easy to use function to update installed apps as well as Windows.

## 🚀 Features

### 💻 System & Application Setup

- **Install Applications:** Installs PowerShell modules and Winget apps from structured YAML categories:
  - Core tools
  - Messengers
  - Programming tools
  - Game launchers
- **Create User Folders:** Automatically sets up workspace directories with desktop shortcuts and Quick Access pinning.
- **Clone Git Repositories:** Fetches repositories defined in configuration.

### 🔧 Utilities & Tools

- **Git Utilities:** Creates an alias to amend the last commit and optionally push.
- **System Diagnostics:** Check system health, storage, and cleanup unused files.
- **System Update Manager:** Update winget apps, PowerShell modules, Python packages, and Windows updates from one command.
- **Dependency Provider:** Verify and install missing modules or apps.

## ⚡ Getting Started

> [!Note]
> Before running MSS, set your PowerShell execution policy:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

MSS is provided as a PowerShell module and can be installed with the help of the [PowerShell ModuleTools](https://github.com/JaxRaffnix/Powershell-ModuleTools) project.

### Installation Steps

1. Download [Powershell ModuleTools](https://github.com/JaxRaffnix/Powershell-ModuleTools).  
2. Run its installer:
    ```powershell
    .\self-installer.ps1.
    ```
3. Clone [My System Setup](https://github.com/JaxRaffnix/My-System-Setup)
4. From its directory, run:
    ```powershell
    Install-FromDev .
    ```

### Dependencies

The following dependencies are automatically installed with this module:

- [gsudo](https://github.com/gerardog/gsudo)  
- NuGet Package Provider
- PSGallery is set as a trusted PSRepository.

## 🛠 Feature Details

For a full function documentation, please refer to the relevant help text by running `help <function>`.

### Install-Applications

- Uses categories defined in `/config/applications.yaml`.  
- Highlights and their use case for some core category modules are:  
  - **PSScriptTools:** `Show-Tree -InColor -ShowItem`  
  - **Terminal-Icons:** `Get-ChildItem -Path . -Force`  
  - **PSReadLine:** auto-completion with `CTRL+SPACE`  
  - **PSWindowsUpdate:** `PSWritePDF`.

### New-User-Folders

- Creates folders for the user space defined in `/config/folders.yaml`:
  - `Workspace`
  - `Coding`
  - `Temp`  
- Supports desktop shortcuts and Quick Access pins.  

### Get-Repositories

- Clone repositories listed in `/config/repositories.yaml`:  
  - [Hilfestellung](https://github.com/JaxRaffnix/Hilfestellung.git)  
  - [Powershell-ModuleTools](https://github.com/JaxRaffnix/Powershell-ModuleTools.git)  

### Invoke-GitAmend

- Amend latest commit with optional message.  
- Alias `ga` or `Git-Amend`.
- Supports `git push --force-with-lease` if remote tracking exists.  

### Invoke-Diagnostics

- Checks:  
  - **System:** Defender status, reliability issues, startup apps, DISM & SFC, installed/pending updates  
  - **Storage:** Disk health, usage summary, large files  
  - **Cleanup:** Remove broken shortcuts, disk cleanup, empty recycle bin, clear temp/cache  
- Code to execute stored in `/scripts/diagnostics`.  
- Logs saved to `$env:USERPROFILE\Documents`.  

### Update-System

- Updates apps with Winget, PowerShell modules, Python packages, and Windows updates.  
- Runs winget updates as both admin and normal user.  

### Test-Dependency

- Ensures required apps/modules are installed, auto-installing if missing.  

## ✅ TO DO

- Ensure C compiler works with installed Strawberry  
- Battlenet requires a specific install location (e.g., `C:\Program Files (x86)`).  

### Known Issues

- Some App IDs are strings, not descriptive names (e.g., WhatsApp `9NKSQGP7F2NH`).  
- Python versions must be installed explicitly (e.g., `Python.Python.3.13`).  
