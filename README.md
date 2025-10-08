# My System Setup

This PowerShell Setups called My-System-Setup (MSS) simplifies the device configuration for Windows machines.

Features:

- Install a list of applications
  - Core tools
  - messengers
  - Programming tools
  - game launchers
- (Apply default settings)
- Create a consistent folder structure for the user
- Clone a list of mandatory git repositories.
- Check System Integrity
  - SystemHealth
  - storage health
  - cleanup data
- Provide an update command
  - update installed apps
  - update windows
  - (update graphics drivers)
  - update powershell modules
  - update pip and packages
- automatically removes default app shortcuts after install or update.

## Best Practices

```
Best Practices Demonstrated

CmdletBinding & parameters

Enables -Verbose, -Debug, -WhatIf automatically.

Use [Parameter()] attributes to make parameters mandatory or optional.

Clear Verb-Noun name

Install-App follows PowerShell conventions.

Inside your module, prefix with MSS if you want: Install-MSSApp.

Help comments (<# #>)

.SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE → essential for discoverability and Get-Help.

Error handling with try/catch/finally

Catches runtime errors and logs them cleanly.

finally ensures cleanup or logging happens regardless of success.

Verbose output

Write-Verbose allows users to see details when needed, without cluttering default output.

Dry-run / WhatIf support

Optional simulation mode prevents accidental changes.

Self-contained logic

Function can read configuration if needed, but avoids hardcoding paths beyond placeholders.

Return meaningful results

Could return success/failure object, path installed, or version info.
```
