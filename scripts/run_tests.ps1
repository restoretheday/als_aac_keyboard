Param()
$ErrorActionPreference = 'Stop'

Write-Host "Running flutter test..."
flutter test | Out-Host

if ($LASTEXITCODE -eq 0) {
  Write-Host "All tests passed."
} else {
  Write-Host "Tests failed with exit code $LASTEXITCODE"
  exit $LASTEXITCODE
}
