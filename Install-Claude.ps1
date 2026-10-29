$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
    Write-Error 'This installer is for Windows.'
    exit 1
}

$winget = Get-Command winget.exe -ErrorAction SilentlyContinue
if (-not $winget) {
    Write-Error 'WinGet was not found. Install or update App Installer, then try again: https://aka.ms/getwinget'
    exit 1
}

Write-Host 'Installing Claude Desktop from the WinGet catalog...' -ForegroundColor Cyan
$arguments = @(
    'install',
    '--id', 'Anthropic.Claude',
    '--exact',
    '--source', 'winget',
    '--silent',
    '--accept-source-agreements',
    '--accept-package-agreements'
)

$process = Start-Process -FilePath $winget.Source -ArgumentList $arguments -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) {
    Write-Error "WinGet exited with code $($process.ExitCode). Check your internet connection and App Installer, then try again."
    exit $process.ExitCode
}

Write-Host 'Claude Desktop is installed. Open it from the Start menu and sign in to your account.' -ForegroundColor Green
