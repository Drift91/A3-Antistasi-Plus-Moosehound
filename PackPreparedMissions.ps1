$root = $PSScriptRoot;

$folderForPreparedMissions = New-Item -Path $root -Name "PreparedMissions" -ItemType "directory" -Force;

$missionFolders = Get-ChildItem -Directory -Path ".\PreparedMissions";
$packedMissionFiles = Get-ChildItem -Filter *.pbo -Path ".\PreparedMissions";

ForEach ($mission in $packedMissionFiles) {
    Write-Host "Removing $($mission).";
    $missionPath = $(Join-Path $folderForPreparedMissions.FullName $mission);
    Remove-Item $missionPath;
}

ForEach ($missionFolder in $missionFolders) {
    Write-Host "Packing $($missionFolder).";
    $destinationPath = $(Join-Path $folderForPreparedMissions.FullName $missionFolder);
    FileBank $destinationPath;
}

