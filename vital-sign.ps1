$VerbosePreference = 'Continue';
$sw = [system.diagnostics.stopwatch]::StartNew()

Write-Verbose "=== Vital Sign Start $(Get-Date) ==="

$settingsFile = Join-Path $PSScriptRoot 'settings.json'

Write-Verbose "Settings file: $settingsFile"

if ( -not (Test-Path $settingsFile -PathType Leaf)) {
    throw "The settings file $settingsFile does not exist."
}

#============= Einstellungen laden  ======================
$settings = Get-Content $settingsFile | ConvertFrom-Json

$temperature=(cat /sys/class/thermal/thermal_zone0/temp)/1000
$uptime = [DateTime](uptime -s)

$data = ConvertTo-JSON @{
    Key         = $settings.VitalSignKey;
    Temperature = $temperature;
    LastSign    = [DateTime]::Now;
    UpTime      = $uptime
}

Write-Verbose $data

curl -d "$data" -H 'Content-Type: application/json' $settings.VitalSignUrl

Write-Verbose "=== Vital Sign Ende $(Get-Date) in $($sw.Elapsed)==="