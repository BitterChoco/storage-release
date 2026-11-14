[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string] $DataDirectory
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($DataDirectory)) {
    $DataDirectory = Join-Path $PSScriptRoot 'data'
} elseif (-not [System.IO.Path]::IsPathRooted($DataDirectory)) {
    $DataDirectory = Join-Path (Get-Location).Path $DataDirectory
}

if (-not (Test-Path -LiteralPath $DataDirectory -PathType Container)) {
    throw "Data directory does not exist: $DataDirectory"
}

$DataDirectory = (Resolve-Path -LiteralPath $DataDirectory).Path
$manifestPath = Join-Path $DataDirectory 'manifest.json'
$schemaVersion = 1
$version = '1.0.0'

if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
    $existingManifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    if ($null -ne $existingManifest.schemaVersion) {
        $schemaVersion = $existingManifest.schemaVersion
    }
    if (-not [string]::IsNullOrWhiteSpace([string] $existingManifest.version)) {
        $version = [string] $existingManifest.version
    }
}

$files = Get-ChildItem -LiteralPath $DataDirectory -File -Recurse -Force |
    Where-Object { $_.FullName -ne $manifestPath } |
    ForEach-Object {
        $relativePath = $_.FullName.Substring($DataDirectory.Length).TrimStart('\', '/') -replace '\\', '/'
        $hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()

        [pscustomobject][ordered]@{
            path   = $relativePath
            size   = [long] $_.Length
            sha256 = $hash
        }
    }

$files = @($files | Sort-Object -Property path)
$manifest = [ordered]@{
    schemaVersion = $schemaVersion
    version       = $version
    files         = $files
}
$json = ConvertTo-Json -InputObject $manifest -Depth 5
$json += [Environment]::NewLine

if ($PSCmdlet.ShouldProcess($manifestPath, 'Update file hashes and sizes')) {
    $temporaryPath = Join-Path $DataDirectory ([System.IO.Path]::GetRandomFileName())
    try {
        $encoding = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($temporaryPath, $json, $encoding)
        Move-Item -LiteralPath $temporaryPath -Destination $manifestPath -Force
    } finally {
        if (Test-Path -LiteralPath $temporaryPath) {
            Remove-Item -LiteralPath $temporaryPath -Force
        }
    }

    Write-Output "Updated $manifestPath with $($files.Count) file entries."
}
