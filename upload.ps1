$VerbosePreference = 'Continue';

$settingsFile = Join-Path $PSScriptRoot 'settings.json'
$uploadFolder = Join-Path $PSScriptRoot 'upload'

Write-Verbose "Settings file: $settingsFile"
Write-Verbose "Upload folder: $uploadFolder"

if( -not (Test-Path $settingsFile -PathType Leaf)) {
    throw "The settings file $settingsFile does not exist."
}

#========= Upload Ordner löschen und neu anlgen
if( Test-Path $uploadFolder -PathType Container) {
    Write-Verbose "Lösche Upload Verzeichnis $uploadFolder"
    Remove-Item $uploadFolder -Recurse -Force
} 

Write-Verbose "Erstelle Upload Verzeichnis $uploadFolder"
mkdir $uploadFolder | Out-Null

#========= Einstellungen laden
$settings = Get-Content $settingsFile | ConvertFrom-Json

#========= Bild von Startbahn Webcam anfordern ================
$upcamFolder=[DateTime]::Now.ToString('yyyyMMdd')
$webcam1Src="http://mfvp.bplaced.net/$upcamFolder/images/upcam.jpg"

Write-Verbose "Flugfeld Bild von Webcam anfordern: $webcam1Src"
Invoke-WebRequest $webcam1Src -OutFile "$uploadFolder/Startbahn.jpg"

Write-Verbose "Wetter Bild von Webcam anfordern: $webcam1Src"
curl -u "$($settings.CameraUser):$($settings.CameraPassword)" http://wettercam.fritz.box/tmpfs/snap.jpg --output "$uploadFolder/WetterCam.jpg"

#========= Dateien hochladen ================
Get-ChildItem $uploadFolder -File | % {

    Write-Verbose "Lade Datei '$($_.FullName)' hoch"
    curl -v -k "$($settings.UploadServer)" --user "$($settings.UploadUser):$($settings.UploadPassword)" -T "$($_.FullName)"
}