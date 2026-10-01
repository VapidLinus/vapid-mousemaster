# Renders keyboard.html to <mode>-<theme>.png for every mode, using headless Chrome or Edge.
# Run from anywhere: .\images\render.ps1   (needs internet for the Google Fonts)
$ErrorActionPreference = 'Stop'

$browser = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw 'Chrome or Edge not found.' }

$page = 'file:///' + ((Join-Path $PSScriptRoot 'keyboard.html') -replace '\\', '/')
# Separate profile so a running browser window isn't reused.
$userData = Join-Path $env:TEMP 'mousemaster-render'

foreach ($mode in 'normal', 'edge', 'grid', 'window', 'hint', 'fine', 'screen', 'ui', 'recursive', 'off') {
  foreach ($theme in 'light', 'dark') {
    $out = Join-Path $PSScriptRoot "$mode-$theme.png"
    Start-Process -FilePath $browser -Wait -WindowStyle Hidden -ArgumentList @(
      '--headless', '--disable-gpu', '--hide-scrollbars',
      "--user-data-dir=`"$userData`"",
      '--window-size=920,431', '--force-device-scale-factor=2',
      '--default-background-color=00000000',
      '--virtual-time-budget=5000',
      "--screenshot=`"$out`"",
      "$page#$mode-$theme"
    )
    Write-Host "$mode-$theme.png"
  }
}
