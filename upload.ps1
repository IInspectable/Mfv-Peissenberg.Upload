
$settingsFile = Join-Path $PSScriptRoot 'settings.json'
$uploadFolder = Join-Path $PSScriptRoot 'upload'

if( -not (Test-Path $settingsFile -PathType Leaf)) {
    throw "The settings file $settingsFile does not exist."
}

#-----------------------
if( Test-Path $uploadFolder -PathType Container) {
    Remove-Item $uploadFolder -Recurse -Force
} 

echo "erstelle $uploadFolder"
mkdir $uploadFolder | Out-Null

$settings = Get-Content $settingsFile | ConvertFrom-Json

echo $settingsFile
echo $uploadFolder

#echo $settings

# ---------------------------
$webcam1Src='https://www.mfv-peissenberg.de/images/s2dlogo.gif'
Invoke-WebRequest $webcam1Src -OutFile "$uploadFolder/webcam1.gif"

Get-ChildItem $uploadFolder -File | % {

   # 

    echo $_.FullName

    curl -v -k "$($settings.Server)" --user "$($settings.User):$($settings.Password)" -T "$($_.FullName)"
}