# -----------------------------------------------------------------------------------------------------------------------------
# PowerShell script to wipe all remaining Claude related artifacts from system after uninstall has run (successfully or failed)
#------------------------------------------------------------------------------------------------------------------------------

# ============================================
# Claude / Anthropic Deep Cleanup Script
# Windows 11 (incl. 25H2)
# ============================================

Write-Host "=== Claude / Anthropic deep cleanup starting ===" -ForegroundColor Cyan

# Helper: remove path if it exists
function Remove-IfExists {
    param(
        [Parameter(Mandatory = $true)][string]${Path},
        [ValidateSet("File","Registry")][string]${Type} = "File"
    )

    try {
        if (Test-Path ${Path}) {
            if (${Type} -eq "File") {
                Write-Host "Removing folder/file: ${Path}" -ForegroundColor Yellow
                Remove-Item -Path ${Path} -Recurse -Force -ErrorAction SilentlyContinue
            }
            elseif (${Type} -eq "Registry") {
                Write-Host "Removing registry key: ${Path}" -ForegroundColor Yellow
                Remove-Item -Path ${Path} -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    } catch {
        Write-Host "Failed to remove ${Path} (${Type}): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Helper: remove registry value if it exists
function Remove-RegistryValueIfExists {
    param(
        [Parameter(Mandatory = $true)][string]$KeyPath,
        [Parameter(Mandatory = $true)][string]$ValueName
    )

    try {
        if (Test-Path $KeyPath) {
            $item = Get-ItemProperty -Path $KeyPath -ErrorAction SilentlyContinue
            if ($item.PSObject.Properties.Name -contains $ValueName) {
                Write-Host "Removing registry value: $KeyPath -> $ValueName" -ForegroundColor Yellow
                Remove-ItemProperty -Path $KeyPath -Name $ValueName -Force -ErrorAction SilentlyContinue
            }
        }
    } catch {
        Write-Host "Failed to remove value $ValueName at ${KeyPath}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --------------------------------------------
# 1. Stop and remove Claude-related services
# --------------------------------------------
Write-Host "`n[1/7] Services" -ForegroundColor Cyan

$claudeServices = Get-Service -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -like "*claude*" -or $_.DisplayName -like "*claude*" -or $_.DisplayName -like "*Anthropic*"
}

foreach ($svc in $claudeServices) {
    try {
        Write-Host "Stopping service: ${svc.Name}" -ForegroundColor Yellow
        Stop-Service -Name ${svc.Name} -Force -ErrorAction SilentlyContinue
        Write-Host "Deleting service: ${svc.Name}" -ForegroundColor Yellow
        sc.exe delete ${svc.Name} | Out-Null
    } catch {
        Write-Host "Failed to stop/delete service ${svc.Name}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --------------------------------------------
# 2. Remove folders and files
# --------------------------------------------
Write-Host "`n[2/7] Folders & files" -ForegroundColor Cyan

$user = $env:USERNAME
$paths = @(
    # User-local Claude / Anthropic
    "C:\Users\$user\AppData\Local\Claude",
    "C:\Users\$user\AppData\Local\ClaudeAI",
    "C:\Users\$user\AppData\Local\Anthropic",
    "C:\Users\$user\AppData\Local\Programs\Claude",
    "C:\Users\$user\AppData\Local\Programs\ClaudeAI",
    "C:\Users\$user\AppData\Local\Programs\Anthropic",

    # Roaming
    "C:\Users\$user\AppData\Roaming\Claude",
    "C:\Users\$user\AppData\Roaming\ClaudeAI",
    "C:\Users\$user\AppData\Roaming\Anthropic",

    # UWP / AppX package style
    "C:\Users\$user\AppData\Local\Packages\Claude_pzs8sxrjxfjjc",

    # Browser native host cache (from your earlier keys)
    "C:\Users\$user\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\ChromeNativeHost",

    # Program Files (just in case)
    "C:\Program Files\Claude",
    "C:\Program Files\ClaudeAI",
    "C:\Program Files\Anthropic",
    "C:\Program Files (x86)\Claude",
    "C:\Program Files (x86)\ClaudeAI",
    "C:\Program Files (x86)\Anthropic"
)

foreach ($p in $paths) {
    Remove-IfExists -Path $p -Type "File"
}

# Temp folders with Claude/Anthropic
Write-Host "Cleaning temp folders for Claude/Anthropic..." -ForegroundColor Yellow
$temps = @(
    "$env:TEMP",
    "C:\Windows\Temp"
)

foreach ($t in $temps) {
    if (Test-Path $t) {
        Get-ChildItem -Path $t -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like "*claude*" -or $_.Name -like "*anthropic*" } |
            ForEach-Object {
                Remove-IfExists -Path $_.FullName -Type "File"
            }
    }
}

# --------------------------------------------
# 3. Registry cleanup
# --------------------------------------------
Write-Host "`n[3/7] Registry keys" -ForegroundColor Cyan

# Core Claude/Anthropic keys (user + machine)
$regKeys = @(
    "HKCU:\Software\Claude",
    "HKCU:\Software\ClaudeAI",
    "HKCU:\Software\Anthropic",
    "HKLM:\Software\Claude",
    "HKLM:\Software\ClaudeAI",
    "HKLM:\Software\Anthropic",

    # From your earlier findings
    "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PolicyCache\Claude_pzs8sxrjxfjjc",

    # Browser NativeMessagingHosts
    "HKCU:\Software\ArcBrowser\Arc\NativeMessagingHosts\com.anthropic.claude_browser_extension",
    "HKCU:\Software\BraveSoftware\Brave-Browser\NativeMessagingHosts\com.anthropic.claude_browser_extension",
    "HKCU:\Software\Chromium\NativeMessagingHosts\com.anthropic.claude_browser_extension"
)

foreach ($rk in $regKeys) {
    Remove-IfExists -Path $rk -Type "Registry"
}

# MuiCache values for Claude Setup (metadata only)
Write-Host "Cleaning MuiCache entries for Claude Setup..." -ForegroundColor Yellow
$muiPath = "HKCR:\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
$muiValues = @(
    "C:\Users\$user\Downloads\Claude Setup.exe.ApplicationCompany",
    "C:\Users\$user\Downloads\Claude Setup.exe.FriendlyAppName"
)

foreach ($val in $muiValues) {
    Remove-RegistryValueIfExists -KeyPath $muiPath -ValueName $val
}

# --------------------------------------------
# 4. Browser extension traces (file side)
# --------------------------------------------
Write-Host "`n[4/7] Browser extension traces" -ForegroundColor Cyan

# Common browser profile roots (user-level)
$browserRoots = @(
    "C:\Users\$user\AppData\Local\Google\Chrome\User Data",
    "C:\Users\$user\AppData\Local\BraveSoftware\Brave-Browser\User Data",
    "C:\Users\$user\AppData\Local\Arc\User Data",
    "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data",
    "C:\Users\$user\AppData\Local\Chromium\User Data"
)

foreach ($root in $browserRoots) {
    if (Test-Path $root) {
        Get-ChildItem -Path $root -Recurse -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Name -like "*claude*" -or $_.Name -like "*anthropic*"
            } |
            ForEach-Object {
                Remove-IfExists -Path $_.FullName -Type "File"
            }
    }
}

# --------------------------------------------
# 5. Node / npm global CLI cleanup
# --------------------------------------------
Write-Host "`n[5/7] Node / npm CLI" -ForegroundColor Cyan

# Try to uninstall global 'claude' package if present
try {
    $npmPath = Get-Command npm -ErrorAction SilentlyContinue
    if ($npmPath) {
        Write-Host "npm detected. Attempting to uninstall global 'claude'..." -ForegroundColor Yellow
        npm uninstall -g claude | Out-Null
    } else {
        Write-Host "npm not found. Skipping npm uninstall." -ForegroundColor DarkGray
    }
} catch {
    Write-Host "Failed to run npm uninstall: $($_.Exception.Message)" -ForegroundColor Red
}

# Remove common global npm locations for claude
$npmDirs = @(
    "C:\Users\$user\AppData\Roaming\npm\node_modules\claude",
    "C:\Users\$user\AppData\Roaming\npm\claude.cmd",
    "C:\Users\$user\AppData\Roaming\npm\claude.ps1"
)

foreach ($p in $npmDirs) {
    Remove-IfExists -Path $p -Type "File"
}

# --------------------------------------------
# 6. Windows Installer / Start menu / shortcuts
# --------------------------------------------
Write-Host "`n[6/7] Shortcuts & installer traces" -ForegroundColor Cyan

# Start Menu shortcuts
$shortcutPaths = @(
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Claude.lnk",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Claude AI.lnk",
    "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Claude.lnk",
    "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Claude AI.lnk"
)

foreach ($sp in $shortcutPaths) {
    Remove-IfExists -Path $sp -Type "File"
}

# Startup folders
$startupPaths = @(
    "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
)

foreach ($st in $startupPaths) {
    if (Test-Path $st) {
        Get-ChildItem -Path $st -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like "*claude*" -or $_.Name -like "*anthropic*" } |
            ForEach-Object {
                Remove-IfExists -Path $_.FullName -Type "File"
            }
    }
}

# Windows Installer cache (only entries with Claude/Anthropic in subject)
Write-Host "Scanning Windows Installer cache for Claude/Anthropic..." -ForegroundColor Yellow
$installerPath = "C:\Windows\Installer"
if (Test-Path $installerPath) {
    Get-ChildItem -Path $installerPath -ErrorAction SilentlyContinue |
        ForEach-Object {
            try {
                $file = $_
                $info = (Get-ItemProperty -Path $file.FullName -ErrorAction SilentlyContinue)
            } catch { $info = $null }

            if ($file.Name -like "*claude*" -or $file.Name -like "*anthropic*") {
                Remove-IfExists -Path $file.FullName -Type "File"
            }
        }
}

# --------------------------------------------
# 7. Final verification hints
# --------------------------------------------
Write-Host "`n[7/7] Suggested manual verification" -ForegroundColor Cyan

Write-Host "After this script, you can manually verify:" -ForegroundColor Green
Write-Host "  - No folders named 'Claude' or 'Anthropic' under AppData, Program Files, or Packages" -ForegroundColor Green
Write-Host "  - No services: Get-Service *claude* or *anthropic*" -ForegroundColor Green
Write-Host "  - No 'claude' command: `claude --version` should fail" -ForegroundColor Green
Write-Host "  - No Claude-related browser extension errors" -ForegroundColor Green

Write-Host "`n=== Claude / Anthropic deep cleanup complete. A reboot is recommended before reinstalling. ===" -ForegroundColor Cyan
