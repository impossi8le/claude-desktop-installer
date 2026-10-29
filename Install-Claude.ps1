$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
    Write-Error 'This installer is for Windows.'
    exit 1
}

$architecture = $env:PROCESSOR_ARCHITEW6432
if (-not $architecture) { $architecture = $env:PROCESSOR_ARCHITECTURE }
switch -Regex ($architecture) {
    '^(ARM64)$' { $claudeArchitecture = 'arm64'; break }
    '^(AMD64)$' { $claudeArchitecture = 'x64'; break }
    default {
        Write-Error "Unsupported Windows architecture: $architecture. Claude Desktop is available here for x64 and ARM64."
        exit 1
    }
}

$downloadUrl = "https://claude.ai/api/desktop/win32/$claudeArchitecture/setup/latest/redirect"
$installerPath = Join-Path $env:TEMP ("ClaudeSetup-{0}.exe" -f [guid]::NewGuid().ToString('N'))

try {
    Write-Host 'Downloading the official Claude Desktop installer from Anthropic...' -ForegroundColor Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing

    $signature = Get-AuthenticodeSignature -FilePath $installerPath
    if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'Anthropic, PBC') {
        throw 'The downloaded file does not have a valid Anthropic signature. The installer was not started.'
    }

    Write-Host 'Starting the Anthropic installer. Follow its prompts to finish setup.' -ForegroundColor Cyan
    $process = Start-Process -FilePath $installerPath -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "Claude Setup exited with code $($process.ExitCode)."
    }
} catch {
    Write-Error "Claude Desktop setup failed: $($_.Exception.Message)"
    exit 1
} finally {
    Remove-Item -LiteralPath $installerPath -Force -ErrorAction SilentlyContinue
}

Write-Host 'Claude Setup finished. Open Claude from the Start menu and sign in to your account.' -ForegroundColor Green
