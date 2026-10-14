# TeamsLight-Auto.ps1
# Windows powerShell 5.1+, no third-party modules.
# requires an approved Microsoft Entra public-client app with delegated presence.Read.
# edit below values
$TenantId = '******************'
$ClientId = '************************'
$ComPort = 'COM3'
$PollSeconds = 15

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Ports
$Scope = 'https://graph.microsoft.com/Presence.Read offline_access'
$AuthBase = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0"
$CacheFolder = Join-Path $env:LOCALAPPDATA 'TeamsLight'
$CacheFile = Join-Path $CacheFolder 'auth.dat'
New-Item -ItemType Directory -Path $CacheFolder -Force | Out-Null

if ($TenantId -like 'PASTE-*' -or $ClientId -like 'PASTE-*') {
    throw 'Set TenantId and ClientId at the top of this script before running.'
}

function Save-Token($Token) {
    # DPAPI via SecureString protects refresh token for the current user
    if ($Token.refresh_token) {
        $secure = ConvertTo-SecureString -String $Token.refresh_token -AsPlainText -Force
        ConvertFrom-SecureString -SecureString $secure | Set-Content -Path $CacheFile
    }
}

function Get-SavedRefreshToken {
    if (-not (Test-Path $CacheFile)) { return $null }
    try {
        $secure = Get-Content -Raw $CacheFile | ConvertTo-SecureString
        $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) }
        finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
    } catch { return $null }
}

function Request-Token {
    $refresh = Get-SavedRefreshToken
    if ($refresh) {
        try {
            $token = Invoke-RestMethod -Method Post -Uri "$AuthBase/token" -Body @{
                client_id = $ClientId
                grant_type = 'refresh_token'
                refresh_token = $refresh
                scope = $Scope
            } -ContentType 'application/x-www-form-urlencoded'
            Save-Token $token
            return $token
        } catch {
            Write-Warning 'Saved sign-in expired or was revoked. Sign in again.'
        }
    }

    $device = Invoke-RestMethod -Method Post -Uri "$AuthBase/devicecode" -Body @{
        client_id = $ClientId
        scope = $Scope
    } -ContentType 'application/x-www-form-urlencoded'
    Write-Host $device.message
    $interval = [Math]::Max(5, [int]$device.interval)
    $deadline = (Get-Date).AddSeconds([int]$device.expires_in)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds $interval
        try {
            $token = Invoke-RestMethod -Method Post -Uri "$AuthBase/token" -Body @{
                grant_type = 'urn:ietf:params:oauth:grant-type:device_code'
                client_id = $ClientId
                device_code = $device.device_code
            } -ContentType 'application/x-www-form-urlencoded'
            Save-Token $token
            return $token
        } catch {
            $errorBody = ''
            if ($_.ErrorDetails -and $_.ErrorDetails.Message) { $errorBody = $_.ErrorDetails.Message }
            if ($errorBody -match 'authorization_pending') { continue }
            if ($errorBody -match 'slow_down') { $interval += 5; continue }
            throw "Microsoft sign-in failed: $errorBody $($_.Exception.Message)"
        }
    }
    throw 'Device sign-in timed out.'
}

function Get-StatusCommand($Presence) {
    # availability strings not teams UI labels.
    switch ($Presence) {
        'Available' { return 'A' }
        'AvailableIdle' { return 'W' }
        'Busy' { return 'B' }
        'BusyIdle' { return 'B' }
        'DoNotDisturb' { return 'D' }
        'BeRightBack' { return 'W' }
        'Away' { return 'W' }
        'Offline' { return 'O' }
        'PresenceUnknown' { return $null }
        default { return $null }
    }
}

$serial = $null
$token = $null
$tokenExpiry = Get-Date
$lastCommand = $null
Write-Host "TeamsLight starting. Port: $ComPort. Poll interval: $PollSeconds seconds. Ctrl+C to stop."
try {
    while ($true) {
        try {
            if (-not $token -or (Get-Date) -ge $tokenExpiry) {
                $token = Request-Token
                $tokenExpiry = (Get-Date).AddSeconds([Math]::Max(60, [int]$token.expires_in - 120))
            }

            $presence = Invoke-RestMethod -Method Get -Uri 'https://graph.microsoft.com/v1.0/me/presence' -Headers @{
                Authorization = "Bearer $($token.access_token)"
            }
            $command = Get-StatusCommand $presence.availability
            if ($null -eq $command) {
                Write-Warning "Unknown presence '$($presence.availability)'; leaving light unchanged."
            } else {
                if ($null -eq $serial -or -not $serial.IsOpen) {
                    if ($serial) { $serial.Dispose() }
                    $serial = New-Object System.IO.Ports.SerialPort($ComPort, 9600, 'None', 8, 'One')
                    $serial.Open()
                    # Nano resets when its serial port is opened.
                    Start-Sleep -Milliseconds 2500
                    $lastCommand = $null
                }
                if ($command -ne $lastCommand) {
                    $serial.Write($command)
                    $lastCommand = $command
                    Write-Host "$(Get-Date -Format 'HH:mm:ss') $($presence.availability) -> $command"
                }
            }
        } catch {
            Write-Warning $_.Exception.Message
            # a serial disconnect, reopen and resend the current presence 
            if ($serial) {
                try { if ($serial.IsOpen) { $serial.Close() } } catch {}
                $serial.Dispose()
                $serial = $null
                $lastCommand = $null
            }
            # if Graph rejects an access token, retry auth next cycle
            if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 401) {
                $token = $null
            }
        }
        Start-Sleep -Seconds $PollSeconds
    }
} finally {
    if ($serial) { if ($serial.IsOpen) { $serial.Close() }; $serial.Dispose() }
}
