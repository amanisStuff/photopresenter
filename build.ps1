param([ValidateSet("Debug","Profile","Release")][string]$Config = "Debug")

$ErrorActionPreference = "Stop"
$ProjectRoot = "B:\photopresenter"
$env:PUB_CACHE = "B:\pub-cache"
Set-Location $ProjectRoot

# Phase 1: pub get
Write-Host "=== pub get ===" -ForegroundColor Cyan
flutter pub get
if (-not $?) { throw "pub get failed" }

# Phase 2: flutter build (will fail at CMake, which is expected)
Write-Host "=== flutter build (CMake failure expected) ===" -ForegroundColor Cyan
$oldPref = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$null = flutter build windows --$($Config.ToLower()) 2>&1
$ErrorActionPreference = $oldPref
Write-Host "  (continuing after CMake failure...)" -ForegroundColor Yellow

# Phase 3: Patch generated_plugins.cmake
Write-Host "=== Patching generated_plugins.cmake ===" -ForegroundColor Cyan
$json = Get-Content ".flutter-plugins-dependencies" -Raw | ConvertFrom-Json
$pluginPaths = @{}
foreach ($p in $json.plugins.windows) {
  $pluginPaths[$p.name] = ($p.path -replace '\\', '/').TrimEnd('/')
}

$usedPlugins = @("audioplayers_windows","desktop_drop","pasteboard","screen_retriever_windows","window_manager")
$lines = @(
  "set(PLUGIN_BUNDLED_LIBRARIES)",
  ""
)

foreach ($name in $usedPlugins) {
  $path = $pluginPaths[$name]
  if (-not $path) { Write-Warning "Skipping $name - no path found"; continue }
  
  $target = "add_subdirectory($path/windows plugins/$name)"
  $link = 'target_link_libraries(${BINARY_NAME} PRIVATE ' + $name + '_plugin)'
  $file1 = 'list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:' + $name + '_plugin>)'
  $file2 = 'list(APPEND PLUGIN_BUNDLED_LIBRARIES ${' + $name + '_bundled_libraries})'
  
  $lines += $target
  $lines += $link
  $lines += $file1
  $lines += $file2
  $lines += ""
}

Set-Content -LiteralPath "windows/flutter/generated_plugins.cmake" -Value ($lines -join "`r`n")
Write-Host "  Patched generated_plugins.cmake" -ForegroundColor Green

# Phase 4: Find cmake
$cmakePath = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
if (-not (Test-Path $cmakePath)) { throw "CMake not found at $cmakePath" }

# Phase 5: CMake generation
Write-Host "=== CMake generation ===" -ForegroundColor Cyan
$sourceDir = "$ProjectRoot/windows"
$buildDir = "$ProjectRoot/build/windows/x64"
& $cmakePath -S $sourceDir -B $buildDir -G "Visual Studio 17 2022" -A x64 "-DFLUTTER_TARGET_PLATFORM=windows-x64"
if (-not $?) { throw "CMake generation failed" }

# Phase 6: CMake build
Write-Host "=== CMake build ===" -ForegroundColor Cyan
& $cmakePath --build $buildDir --config $Config --target INSTALL
if (-not $?) { throw "CMake build failed" }

Write-Host "=== Build succeeded! ===" -ForegroundColor Green
