[CmdletBinding()]
param(
    [switch]$InstallDependencies,
    [switch]$SkipPlugins,
    [switch]$SkipSumatraConfig
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Write-Step([string]$Message) {
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Warn([string]$Message) {
    Write-Warning $Message
}

function Test-Command([string]$Name) {
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Refresh-ProcessPath {
    $MachinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = @($MachinePath, $UserPath) -join ";"
}

function Find-SumatraPDF {
    $Command = Get-Command SumatraPDF.exe -ErrorAction SilentlyContinue
    if ($Command) { return $Command.Source }

    $Candidates = @(
        (Join-Path $env:LOCALAPPDATA "SumatraPDF\SumatraPDF.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\SumatraPDF\SumatraPDF.exe"),
        (Join-Path $env:ProgramFiles "SumatraPDF\SumatraPDF.exe")
    )
    if (${env:ProgramFiles(x86)}) {
        $Candidates += (Join-Path ${env:ProgramFiles(x86)} "SumatraPDF\SumatraPDF.exe")
    }

    foreach ($Candidate in $Candidates) {
        if ($Candidate -and (Test-Path $Candidate)) { return $Candidate }
    }

    $RegistryKeys = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\SumatraPDF.exe",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\SumatraPDF.exe",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\SumatraPDF.exe"
    )
    foreach ($Key in $RegistryKeys) {
        try {
            $Item = Get-Item $Key -ErrorAction Stop
            $Value = $Item.GetValue("")
            if ($Value -and (Test-Path $Value)) { return $Value }
        } catch {}
    }

    return $null
}

function Test-WingetPackageInstalled([string]$Id) {
    if (-not (Test-Command "winget")) { return $false }

    $Output = (& winget list --id $Id -e --accept-source-agreements 2>$null | Out-String)
    if ($LASTEXITCODE -ne 0) { return $false }
    return $Output -match [Regex]::Escape($Id)
}

function Install-WingetPackage([string]$Command, [string]$Id) {
    if (Test-Command $Command) {
        Write-Host "[ OK ] $Command already available"
        return
    }

    if (-not (Test-Command "winget")) {
        throw "'$Command' was not found and winget is unavailable. Install $Id manually and run this script again."
    }

    if (Test-WingetPackageInstalled $Id) {
        Write-Host "[ OK ] $Id already installed"
        Refresh-ProcessPath
        return
    }

    Write-Step "Installing $Id with winget"
    & winget install --id $Id -e --accept-package-agreements --accept-source-agreements
    $WingetExit = $LASTEXITCODE
    Refresh-ProcessPath

    if ($WingetExit -ne 0) {
        if ((Test-Command $Command) -or (Test-WingetPackageInstalled $Id)) {
            Write-Host "[ OK ] $Id is installed (winget exit code $WingetExit ignored)"
            return
        }
        throw "winget failed to install $Id (exit code $WingetExit)."
    }
}

if ($env:OS -ne "Windows_NT") {
    throw "This installer is for Windows. On Ubuntu, use scripts/install-nvim-latex.sh."
}

Refresh-ProcessPath

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$SourceConfig = Join-Path $RepoRoot "nvim"
$ConfigDir = Join-Path $env:LOCALAPPDATA "nvim"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

if (-not (Test-Path (Join-Path $SourceConfig "init.lua"))) {
    throw "Shared Neovim configuration was not found: $SourceConfig"
}

if ($InstallDependencies) {
    Install-WingetPackage "git" "Git.Git"
    Install-WingetPackage "nvim" "Neovim.Neovim"
    Install-WingetPackage "rg" "BurntSushi.ripgrep.MSVC"
    Install-WingetPackage "perl" "StrawberryPerl.StrawberryPerl"
    Install-WingetPackage "SumatraPDF" "SumatraPDF.SumatraPDF"
    Refresh-ProcessPath
}

$Required = @("git", "nvim", "pdflatex", "latexmk")
$Missing = @($Required | Where-Object { -not (Test-Command $_) })
if ($Missing.Count -gt 0) {
    throw "Missing required commands in PATH: $($Missing -join ', '). For MiKTeX, install the latexmk package in MiKTeX Console, then open a new terminal and retry."
}

if (-not (Test-Command "perl")) {
    Write-Warn "perl is not in PATH. If latexmk fails, install Strawberry Perl."
}
if (-not (Test-Command "rg")) {
    Write-Warn "ripgrep (rg) is not in PATH. Telescope live_grep will be unavailable."
}

$SumatraPath = Find-SumatraPDF
if (-not $SumatraPath) {
    Write-Warn "SumatraPDF was not found. VimTeX PDF viewing and SyncTeX need SumatraPDF on Windows."
}

$NvimCommand = Get-Command nvim.exe -ErrorAction Stop
$NvimPath = $NvimCommand.Source
$NvimVersionText = (& $NvimPath --version | Select-Object -First 1)
if ($NvimVersionText -match 'NVIM v(\d+)\.(\d+)\.(\d+)') {
    $Version = [Version]::new([int]$Matches[1], [int]$Matches[2], [int]$Matches[3])
    if ($Version -lt [Version]::new(0, 12, 4)) {
        throw "Detected $NvimVersionText. VimTeX v2.18 in this setup requires Neovim 0.12.4 or newer."
    }
}

if (Test-Path $ConfigDir) {
    $Backup = "$ConfigDir.backup.$Timestamp"
    Write-Step "Backing up existing Neovim config to $Backup"
    Move-Item -Path $ConfigDir -Destination $Backup
}

Write-Step "Installing shared Neovim config to $ConfigDir"
Copy-Item -Path $SourceConfig -Destination $ConfigDir -Recurse -Force

if ($SumatraPath) {
    $SumatraLua = ConvertTo-Json $SumatraPath -Compress
    $ViewerConfig = Join-Path $ConfigDir "lua\config\viewer.lua"
    Set-Content -Path $ViewerConfig -Value "vim.g.nvim_latex_sumatra_path = $SumatraLua" -Encoding utf8
}

$ToolsDir = Join-Path $ConfigDir "tools"
New-Item -ItemType Directory -Path $ToolsDir -Force | Out-Null
$InverseSource = Join-Path $ScriptDir "sumatra-inverse-search.ps1"
$InverseTarget = Join-Path $ToolsDir "sumatra-inverse-search.ps1"
Copy-Item -Path $InverseSource -Destination $InverseTarget -Force

if (-not $SkipPlugins) {
    Write-Step "Syncing lazy.nvim plugins"
    & $NvimPath --headless "+Lazy! sync" +qa
    if ($LASTEXITCODE -ne 0) {
        throw "Neovim plugin installation failed (exit code $LASTEXITCODE)."
    }

    Write-Step "Installing TexLab with Mason"
    & $NvimPath --headless "+MasonToolsInstallSync" +qa
    if ($LASTEXITCODE -ne 0) {
        throw "TexLab installation failed (exit code $LASTEXITCODE)."
    }
}

if (-not $SkipSumatraConfig -and $SumatraPath) {
    $InverseCmd = 'powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $InverseTarget + '" -NvimPath "' + $NvimPath + '" -Line %l -File "%f"'
    Write-Step "Configuring SumatraPDF inverse SyncTeX"
    Start-Process -FilePath $SumatraPath -ArgumentList @("-reuse-instance", "-inverse-search", $InverseCmd) | Out-Null
}

Write-Host ""
Write-Host "Installation completed." -ForegroundColor Green
Write-Host "  Neovim config : $ConfigDir"
Write-Host "  VimTeX compile : ,ll"
Write-Host "  PDF/forward    : ,lv"
Write-Host "  VimTeX info    : ,li"
Write-Host ""
Write-Host "For inverse search, double-click the PDF in SumatraPDF."
Write-Host "If anything fails, run: scripts\verify-windows.ps1"
