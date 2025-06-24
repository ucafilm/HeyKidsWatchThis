# HeyKidsWatchThis - Target Membership Fix Script (PowerShell)
# This script fixes the MockMovieService target membership warning

Write-Host "🎬 HeyKidsWatchThis - Fixing Target Membership Issue" -ForegroundColor Cyan
Write-Host "==================================================="
Write-Host ""

$ProjectDir = "T:\AI\Hey Kids Watch This\Real\HeyKidsWatchThis"
Set-Location $ProjectDir

Write-Host "📍 Current directory: $(Get-Location)"
Write-Host ""

# Check if MockMovieService.swift is in the correct location
if (Test-Path "HeyKidsWatchThisTests\MockMovieService.swift") {
    Write-Host "✅ MockMovieService.swift found in correct test directory" -ForegroundColor Green
} else {
    Write-Host "❌ MockMovieService.swift not found in test directory" -ForegroundColor Red
    exit 1
}

# Check if MockMovieService.swift accidentally exists in main directory
if (Test-Path "HeyKidsWatchThis\MockMovieService.swift") {
    Write-Host "❌ PROBLEM FOUND: MockMovieService.swift exists in main app directory" -ForegroundColor Red
    Write-Host "🔧 Removing MockMovieService.swift from main app directory..."
    Remove-Item "HeyKidsWatchThis\MockMovieService.swift" -Force
    Write-Host "✅ Removed MockMovieService.swift from main app directory" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "✅ MockMovieService.swift is NOT in main app directory (good)" -ForegroundColor Green
    Write-Host ""
}

# Clean build artifacts
Write-Host "🧹 Cleaning build artifacts..."

# Clean using xcodebuild (if available)
try {
    $cleanOutput = & xcodebuild -project "HeyKidsWatchThis.xcodeproj" -scheme "HeyKidsWatchThis" clean 2>&1
    Write-Host "✅ xcodebuild clean completed" -ForegroundColor Green
} catch {
    Write-Host "⚠️  xcodebuild not available, skipping command-line clean" -ForegroundColor Yellow
}

# Touch project file to force re-indexing
Write-Host "🔄 Forcing Xcode re-indexing..."
$projectFile = "HeyKidsWatchThis.xcodeproj\project.pbxproj"
if (Test-Path $projectFile) {
    (Get-Item $projectFile).LastWriteTime = Get-Date
    Write-Host "✅ Project file touched to trigger re-indexing" -ForegroundColor Green
}
Write-Host ""

Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Open Xcode" -ForegroundColor White
Write-Host "  2. Clean Build Folder (⌘+Shift+K)" -ForegroundColor White
Write-Host "  3. Build the project (⌘+B)" -ForegroundColor White
Write-Host "  4. The warning should disappear!" -ForegroundColor White
Write-Host ""

Write-Host "📝 If warning persists, manual fix in Xcode:" -ForegroundColor Yellow
Write-Host "  1. Select MockMovieService.swift in Project Navigator" -ForegroundColor White
Write-Host "  2. In File Inspector (right panel), find 'Target Membership'" -ForegroundColor White
Write-Host "  3. Ensure ONLY 'HeyKidsWatchThisTests' is checked ✅" -ForegroundColor White
Write-Host "  4. Ensure 'HeyKidsWatchThis' (main app) is UNCHECKED ❌" -ForegroundColor White
Write-Host ""

Write-Host "🎉 Fix Complete! The target membership issue should be resolved." -ForegroundColor Green
Write-Host "🎬 Ready for family movie night planning! 👨‍👩‍👧‍👦" -ForegroundColor Cyan
