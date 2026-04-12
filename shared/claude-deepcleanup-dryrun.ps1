# ============================================
# Claude / Anthropic Deep Cleanup Script (DRY RUN)
# Windows 11 (incl. 25H2)
# ============================================

Write-Host "=== DRY RUN: Claude / Anthropic deep cleanup starting ===" -ForegroundColor Cyan

# Helper: simulate removal
function Simulate-Remove {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [ValidateSet("File","Registry")][string]$Type = "File"
    )

    if (Test-Path $Path) {
        Write-Host "[DRY RUN] Would remove $Type: $Path" -ForegroundColor Yellow
    }
}

# Helper: simulate registry value removal
function Simulate-RemoveValue {
    param(
        [Parameter(Mandatory = $true)][string]$KeyPath,
        [Parameter(Mandatory = $true)][string]$ValueName
    )

    if (Test-Path $KeyPath) {
        $item = Get-ItemProperty -Path $KeyPath -ErrorAction SilentlyContinue
        if ($item.PSObject.Properties.Name -contains $ValueName) {
            Write-Host "[DRY RUN] Would remove registry value: $KeyPath -> $ValueName" -ForegroundColor Yellow
        }
    }
}

# --------------------------------------------
# 1. Services
# --------------------------------------------
Write-Host "`n[1/7] Services" -ForegroundColor Cyan

$claudeServices = Get-Service | Where-Object {
    $_.Name -like "*claude*" -or $_.DisplayName -like "*claude*" -or $_.DisplayName -like "*Anthropic*"
}

foreach ($svc in $claudeServices) {
    Write-Host "[DRY RUN] Would stop service: $($svc.Name)" -ForegroundColor Yellow
    Write-Host "[DRY RUN] Would delete service: $($svc.Name)" -ForegroundColor Yellow
}

# --------------------------------------------
# 2. Folders & files
# --------------------------------------------
Write-Host "`n[2/7] Folders & files" -ForegroundColor Cyan

$user = $env:USERNAME
$paths = @(
    "C:\Users\$user\AppData\Local\Claude",
    "C:\Users\$user\AppData\Local\ClaudeAI",
    "C:\Users\$user\AppData\Local\Anthropic",
    "C:\Users\$user\AppData\Local\Programs\Claude",
    "C:\Users\$user\AppData\Local\Programs\ClaudeAI",
    "C:\Users\$user\AppData\Local\Programs\Anthropic",
    "C:\Users\$user\AppData\Roaming\Claude",
    "C:\Users\$user\AppData\Roaming\ClaudeAI",
    "C:\Users\$user\AppData\Roaming\Anthropic",
    "C:\Users\$user\AppData\Local\Packages\Claude_pzs8sxrjxfjjc",
    "C:\Users\$user\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\ChromeNativeHost",
    "C:\Program Files\Claude",
    "C:\Program Files\ClaudeAI",
    "C:\Program Files\Anthropic",
    "C:\Program Files (x86)\Claude",
    "C:\Program Files (x86)\ClaudeAI",
    "C:\Program Files (x86)\Anthropic"
)

foreach ($p in $paths) {
    Simulate-Remove -Path $p -Type "File"
}

# Temp folders
Write-Host "Scanning temp folders..." -ForegroundColor Yellow
$temps = @("$env:TEMP", "C:\Windows\Temp")

foreach ($t in $temps) {
    if (Test-Path $t) {
        Get-ChildItem -Path $t -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like "*claude*" -or $_.Name -like "*anthropic*" } |
            ForEach-Object {
                Simulate-Remove -Path $_.FullName -Type "File"
            }
    }
}

# --------------------------------------------
# 3. Registry keys
# --------------------------------------------
Write-Host "`n[3/7] Registry keys" -ForegroundColor Cyan

$regKeys = @(
    "HKCU:\Software\Claude",
    "HKCU:\Software\ClaudeAI",
    "HKCU:\Software\Anthropic",
    "HKLM:\Software\Claude",
    "HKLM:\Software\ClaudeAI",
    "HKLM:\Software\Anthropic",
    "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PolicyCache\Claude_pzs8sxrjxfjjc",
    "HKCU:\Software\ArcBrowser\Arc\NativeMessagingHosts\com.anthropic.claude_browser_extension",
    "HKCU:\Software\BraveSoftware\Brave-Browser\NativeMessagingHosts\com.anthropic.claude_browser_extension",
    "HKCU:\Software\Chromium\NativeMessagingHosts\com.anthropic.claude_browser_extension"
)

foreach ($rk in $regKeys) {
    Simulate-Remove -Path $rk -Type "Registry"
}

# MuiCache values
Write-Host "Checking MuiCache entries..." -ForegroundColor Yellow
$muiPath = "HKCR:\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
$muiValues = @(
    "C:\Users\$user\Downloads\Claude Setup.exe.ApplicationCompany",
    "C:\Users\$user\Downloads\Claude Setup.exe.FriendlyAppName"
)

foreach ($val in $muiValues) {
    Simulate-RemoveValue -KeyPath $muiPath -ValueName $val
}

# --------------------------------------------
# 4. Browser extension traces
# --------------------------------------------
Write-Host "`n[4/7] Browser extension traces" -ForegroundColor Cyan

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
            Where-Object { $_.Name -like "*claude*" -or $_.Name -like "*anthropic*" } |
            ForEach-Object {
                Simulate-Remove -Path $_.FullName -Type "File"
            }
    }
}

# --------------------------------------------
# 5. Node / npm CLI
# --------------------------------------------
Write-Host "`n[5/7] Node / npm CLI" -ForegroundColor Cyan

$npmPath = Get-Command npm -ErrorAction SilentlyContinue
if ($npmPath) {
    Write-Host "[DRY RUN] Would run: npm uninstall -g claude" -ForegroundColor Yellow
} else {
    Write-Host "npm not found. Skipping npm uninstall." -ForegroundColor DarkGray
}

$npmDirs = @(
    "C:\Users\$user\AppData\Roaming\npm\node_modules\claude",
    "C:\Users\$user\AppData\Roaming\npm\claude.cmd",
    "C:\Users\$user\AppData\Roaming\npm\claude.ps1"
)

foreach ($p in $npmDirs) {
    Simulate-Remove -Path $p -Type "File"
}

# --------------------------------------------
# 6. Shortcuts & installer traces
# --------------------------------------------
Write-Host "`n[6/7] Shortcuts & installer traces" -ForegroundColor Cyan

$shortcutPaths = @(
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Claude.lnk",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Claude AI.lnk",
    "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Claude.lnk",
    "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Claude AI.lnk"
)

foreach ($sp in $shortcutPaths) {
    Simulate-Remove -Path $sp -Type "File"
}

$startupPaths = @(
    "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
)

foreach ($st in $startupPaths) {
    if (Test-Path $st) {
        Get-ChildItem -Path $st -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like "*claude*" -or $_.Name -like "*anthropic*" } |
            ForEach-Object {
                Simulate-Remove -Path $_.FullName -Type "File"
            }
    }
}

# Windows Installer cache
Write-Host "Scanning Windows Installer cache..." -ForegroundColor Yellow
$installerPath = "C:\Windows\Installer"
if (Test-Path $installerPath) {
    Get-ChildItem -Path $installerPath -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "*claude*" -or $_.Name -like "*anthropic*" } |
        ForEach-Object {
            Simulate-Remove -Path $_.FullName -Type "File"
        }
}

# --------------------------------------------
# 7. Final notes
# --------------------------------------------
Write-Host "`n=== DRY RUN COMPLETE ===" -ForegroundColor Cyan
Write-Host "No changes were made. Review the output above to confirm what will be removed." -ForegroundColor Green
