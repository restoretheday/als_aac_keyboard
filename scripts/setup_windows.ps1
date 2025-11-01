Param()
$ErrorActionPreference = 'Stop'

Write-Host "Checking Flutter..."
flutter --version | Out-Host

Write-Host "Fetching packages..."
flutter pub get | Out-Host

Write-Host "Done. You can now run ./scripts/run_tests.ps1"
