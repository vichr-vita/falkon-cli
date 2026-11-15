# Installs the falkon CLI on Windows from a GitHub release of vichr-vita/falkon-cli.
#
#   irm https://raw.githubusercontent.com/vichr-vita/falkon-cli/main/install.ps1 | iex
#
# Parameters (only when the script is saved and run as a file):
#   -Version vX.Y.Z   install this release instead of the latest
#
# Parameters cannot pass through `irm | iex`. To pick a release that way, set
# the environment variable first:
#
#   $env:FALKON_VERSION = 'vX.Y.Z'; irm https://raw.githubusercontent.com/vichr-vita/falkon-cli/main/install.ps1 | iex
#
# Environment:
#   FALKON_VERSION      same as -Version
#   FALKON_INSTALL_DIR  install directory (default: $env:LOCALAPPDATA\Programs\falkon)
#
# The script does not change PATH or any configuration; it tells you what to add.
param(
    [string]$Version = $env:FALKON_VERSION
)

# Runs the whole installation inside a function, so the error preference and
# the variables below do not leak into the session when run through `irm | iex`.
function Install-Falkon([string]$Version) {
    $ErrorActionPreference = 'Stop'

    $Repo = 'vichr-vita/falkon-cli'
    # Test hook, not documented for users: a mirror laid out as <base>/<version>/<file>.
    $ReleaseBaseUrl = if ($env:FALKON_RELEASE_BASE_URL) { $env:FALKON_RELEASE_BASE_URL } else { "https://github.com/$Repo/releases/download" }
    $InstallDir = if ($env:FALKON_INSTALL_DIR) { $env:FALKON_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'Programs\falkon' }

    # Throws a terminating error with the message.
    function Stop-Install([string]$Message) {
        throw "install.ps1: error: $Message"
    }

    # Returns the tag of the latest release.
    function Get-LatestVersion {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -Headers @{ 'User-Agent' = 'falkon-install' }
        if (-not $release.tag_name) { Stop-Install 'could not determine the latest release; pass -Version vX.Y.Z' }
        return $release.tag_name
    }

    # Only x86_64 binaries are published; Arm64 Windows runs them through x64 emulation.
    $architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    if ($architecture -ne 'X64' -and $architecture -ne 'Arm64') { Stop-Install "unsupported CPU architecture: $architecture" }

    if (-not $Version) { $Version = Get-LatestVersion }
    if (-not $Version.StartsWith('v')) { $Version = "v$Version" }

    $Target = 'x86_64-pc-windows-gnu'
    $Archive = "falkon-$Version-$Target.zip"
    Write-Host "Installing falkon $Version for $Target"

    $WorkDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $WorkDir | Out-Null
    try {
        Invoke-WebRequest -UseBasicParsing -Uri "$ReleaseBaseUrl/$Version/$Archive" -OutFile (Join-Path $WorkDir $Archive)
        Invoke-WebRequest -UseBasicParsing -Uri "$ReleaseBaseUrl/$Version/SHA256SUMS" -OutFile (Join-Path $WorkDir 'SHA256SUMS')

        $expectedLine = Get-Content (Join-Path $WorkDir 'SHA256SUMS') | Where-Object { ($_ -split '\s+')[1] -eq $Archive } | Select-Object -First 1
        if (-not $expectedLine) { Stop-Install "$Archive is not listed in SHA256SUMS" }
        $expected = ($expectedLine -split '\s+')[0].ToLowerInvariant()
        $actual = (Get-FileHash -Algorithm SHA256 -Path (Join-Path $WorkDir $Archive)).Hash.ToLowerInvariant()
        if ($expected -ne $actual) { Stop-Install "checksum mismatch for $Archive (expected $expected, got $actual)" }
        Write-Host 'Checksum verified'

        $ExtractDir = Join-Path $WorkDir 'extract'
        Expand-Archive -Path (Join-Path $WorkDir $Archive) -DestinationPath $ExtractDir
        if (-not (Test-Path (Join-Path $ExtractDir 'falkon.exe'))) { Stop-Install "$Archive does not contain falkon.exe" }

        New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
        Copy-Item -Force (Join-Path $ExtractDir 'falkon.exe') (Join-Path $InstallDir 'falkon.exe')
    }
    finally {
        Remove-Item -Recurse -Force $WorkDir -ErrorAction SilentlyContinue
    }

    $Installed = Join-Path $InstallDir 'falkon.exe'
    Write-Host "Installed: $Installed"
    & $Installed --version
    if ($LASTEXITCODE -ne 0) { Stop-Install "the installed binary does not run (exit code $LASTEXITCODE)" }

    $pathEntries = $env:PATH -split ';'
    if ($pathEntries -notcontains $InstallDir) {
        Write-Host "Warning: $InstallDir is not on your PATH. Add it in the environment variable settings to run falkon directly."
    }
}

Install-Falkon -Version $Version
