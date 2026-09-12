param(
    [Parameter(Mandatory = $true)]
    [int]$Line,

    [Parameter(Mandatory = $true)]
    [string]$File,

    [Parameter(Mandatory = $true)]
    [string]$NvimPath
)

$ErrorActionPreference = "Stop"
$Server = "//./pipe/nvim-latex"
$Log = Join-Path $env:TEMP "nvim-sumatra-inverse.log"

try {
    if (-not (Test-Path $NvimPath)) {
        throw "nvim.exe not found: $NvimPath"
    }

    & $NvimPath --server $Server --remote $File 2>> $Log | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Could not connect to Neovim server $Server (exit $LASTEXITCODE)."
    }

    $Keys = "<C-\><C-N>:call cursor($Line, 1)<CR>zz"
    & $NvimPath --server $Server --remote-send $Keys 2>> $Log | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "remote-send failed (exit $LASTEXITCODE)."
    }
} catch {
    Add-Content -Path $Log -Value ((Get-Date -Format s) + " " + $_.Exception.Message)
    exit 1
}
