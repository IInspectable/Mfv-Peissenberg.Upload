$VerbosePreference = 'Continue';
$sw = [system.diagnostics.stopwatch]::StartNew()

. .\encryption.ps1

Write-Verbose "=== Upload Start $(Get-Date) ==="

Write-Verbose "Warte 15 Sekunden"
Start-Sleep -Milliseconds 15000


$settingsFile = Join-Path $PSScriptRoot 'settings.json'
$uploadFolder = Join-Path $PSScriptRoot 'upload'

Write-Verbose "Settings file: $settingsFile"
Write-Verbose "Upload folder: $uploadFolder"

if( -not (Test-Path $settingsFile -PathType Leaf)) {
    throw "The settings file $settingsFile does not exist."
}

#========= Upload Ordner leeren oder anlegen
if( Test-Path $uploadFolder -PathType Container) {
    Write-Verbose "Lösche alle Dateien im Upload-Verzeichnis $uploadFolder"
    Remove-Item "$uploadFolder/*" -Recurse
} else{
    Write-Verbose "Erstelle Upload-Verzeichnis $uploadFolder"
    mkdir $uploadFolder | Out-Null
} 

#============= Einstellungen laden  ======================
$settings = Get-Content $settingsFile | ConvertFrom-Json

#========= Upload Anweisung herunterladen ================
$rawConfigs = (Invoke-WebRequest $settings.ConfigurationUrl).Content
$uploadConfigurations = ConvertFrom-Json $rawConfigs

Write-Verbose ($uploadConfigurations | Out-String)

#============= Bilder anfordern ==========================
foreach ($uploadConfig in $uploadConfigurations) {

    $camSrc = $uploadConfig.downloadUrl
    $targetFile = $uploadConfig.targetFile

    $downloadUsr = $null
    if ($uploadConfig.downloadUsr) {
        $downloadUsr = DecryptAesString $settings.EncryptionKey $uploadConfig.downloadUsr
    }

    $downloadPwd = $null
    if ($uploadConfig.downloadPwd) {
        $downloadPwd = DecryptAesString $settings.EncryptionKey $uploadConfig.downloadPwd
    }

    $userParam=''
    if ($downloadUsr -and $downloadPwd) {
        $userParam="-u $($downloadUsr):$($downloadPwd)"
    }

    $targetPath = Join-Path $uploadFolder $targetFile

    Write-Verbose "Kamerabild von '$camSrc' nach '$targetPath' herunterladen."
    $cmd = "curl --retry 5 --retry-delay 1 $userParam '$camSrc' --output '$targetPath'"

    Invoke-Expression $cmd
}

#========= Dateien hochladen ================
Write-Verbose "Lade alle Dateien aus '$uploadFolder' hoch."
Write-Verbose "Upload Server: '$($settings.UploadServer)'."

Get-ChildItem $uploadFolder -File | ForEach-Object {

    Write-Verbose "Lade Datei '$($_.FullName)' hoch."
    curl -v -k --retry 5 --retry-delay 1 "$($settings.UploadServer)" --user "$($settings.UploadUser):$($settings.UploadPassword)" -T "$($_.FullName)" 
}

Write-Verbose "=== Upload Ende $(Get-Date) in $($sw.Elapsed)==="