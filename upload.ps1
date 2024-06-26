$VerbosePreference = 'Continue';
$sw = [system.diagnostics.stopwatch]::StartNew()

Write-Verbose "=== Upload Start $(Get-Date) ==="

$settingsFile = Join-Path $PSScriptRoot 'settings.json'
$uploadFolder = Join-Path $PSScriptRoot 'upload'

Write-Verbose "Settings file: $settingsFile"
Write-Verbose "Upload folder: $uploadFolder"

if( -not (Test-Path $settingsFile -PathType Leaf)) {
    throw "The settings file $settingsFile does not exist."
}

#========= Upload Ordner leeren oder anlegen
if( Test-Path $uploadFolder -PathType Container) {
    Write-Verbose "Lösche Upload Verzeichnis $uploadFolder"
    Remove-Item "$uploadFolder/*" -Recurse
} else{
    Write-Verbose "Erstelle Upload Verzeichnis $uploadFolder"
    mkdir $uploadFolder | Out-Null
} 

#========= Einstellungen laden
$settings = Get-Content $settingsFile | ConvertFrom-Json

#========= Bild von Startbahn-Webcam anfordern ================
$upcamFolder=[DateTime]::Now.ToString('yyyyMMdd')
$webcam1Src="http://mfvp.bplaced.net/$upcamFolder/images/upcam.jpg"

Write-Verbose "Flugfeld Bild von Startbahn-Webcam anfordern: $webcam1Src"
Invoke-WebRequest $webcam1Src -OutFile "$uploadFolder/Startbahn.jpg"

#========= Bild von Wetter-Webcam anfordern ================
$wetterCamSrc = "http://wettercam.fritz.box/tmpfs/snap.jpg"
Write-Verbose "Wetter Bild von Wetter-Webcam anfordern: $wetterCamSrc"
curl -u "$($settings.CameraUser):$($settings.CameraPassword)" "$wetterCamSrc" --output "$uploadFolder/WetterWebcam.jpg"

#========= Dateien hochladen ================
Write-Verbose "Lade alle Dateien aus '$uploadFolder' hoch."
Write-Verbose "Upload Server: '$($settings.UploadServer)'."

Get-ChildItem $uploadFolder -File | ForEach-Object {

    Write-Verbose "Lade Datei '$($_.FullName)' hoch."
    curl -v -k "$($settings.UploadServer)" --user "$($settings.UploadUser):$($settings.UploadPassword)" -T "$($_.FullName)"
}

Write-Verbose "=== Upload Ende $(Get-Date) in $($sw.Elapsed)==="