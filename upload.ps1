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

#========= Bild von Webcam anfordern ================
Write-Verbose "Bild von Webcam anfordern"
$webcam1Src = 'https://www.mfv-peissenberg.de/images/s2dlogo.gif'
Invoke-WebRequest $webcam1Src -OutFile "$uploadFolder/webcam1.gif"

#========= Dateien hochladen ================
Get-ChildItem $uploadFolder -File | % {

    Write-Verbose "Lade Datei '$($_.FullName)' hoch"
    curl -v -k "$($settings.Server)" --user "$($settings.User):$($settings.Password)" -T "$($_.FullName)"
}