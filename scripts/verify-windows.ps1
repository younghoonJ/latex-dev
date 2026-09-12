$ErrorActionPreference = "Continue"

function Check-Command([string]$Name, [string]$VersionArgs = "--version") {
    $Command = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $Command) {
        Write-Host "[MISS] $Name" -ForegroundColor Red
        return
    }

    Write-Host "[ OK ] $Name -> $($Command.Source)" -ForegroundColor Green
    try {
        if ($Name -eq "perl") {
            & $Command.Source -v | Select-Object -First 2
        } elseif ($Name -eq "latexmk") {
            & $Command.Source -v | Select-Object -First 2
        } else {
            & $Command.Source $VersionArgs | Select-Object -First 2
        }
    } catch {}
}

Check-Command "nvim"
Check-Command "git"
Check-Command "pdflatex"
Check-Command "latexmk"
Check-Command "perl"
Check-Command "rg"

$SumatraCandidates = @(Get-Command SumatraPDF.exe -ErrorAction SilentlyContinue | ForEach-Object Source)
$SumatraCandidates += @(
    "$env:LOCALAPPDATA\SumatraPDF\SumatraPDF.exe",
    "$env:LOCALAPPDATA\Programs\SumatraPDF\SumatraPDF.exe",
    "$env:ProgramFiles\SumatraPDF\SumatraPDF.exe"
)
if (${env:ProgramFiles(x86)}) {
    $SumatraCandidates += "${env:ProgramFiles(x86)}\SumatraPDF\SumatraPDF.exe"
}
$Sumatra = $SumatraCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

if (-not $Sumatra) {
    $RegistryKeys = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\SumatraPDF.exe",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\SumatraPDF.exe",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\SumatraPDF.exe"
    )
    foreach ($Key in $RegistryKeys) {
        try {
            $Item = Get-Item $Key -ErrorAction Stop
            $Value = $Item.GetValue("")
            if ($Value -and (Test-Path $Value)) {
                $Sumatra = $Value
                break
            }
        } catch {}
    }
}

if ($Sumatra) {
    Write-Host "[ OK ] SumatraPDF -> $Sumatra" -ForegroundColor Green
} else {
    Write-Host "[MISS] SumatraPDF" -ForegroundColor Red
}

$Config = Join-Path $env:LOCALAPPDATA "nvim\init.lua"
if (Test-Path $Config) {
    Write-Host "[ OK ] Neovim config -> $Config" -ForegroundColor Green
} else {
    Write-Host "[MISS] Neovim config -> $Config" -ForegroundColor Red
}
