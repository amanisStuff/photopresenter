@echo off
setlocal enabledelayedexpansion

set "PUB_CACHE=B:\pub-cache"
set "PROJECT_ROOT=B:\photopresenter"
set "CONFIG=Debug"

cd /d "%PROJECT_ROOT%"

:: Phase 1: pub get
echo === pub get ===
call flutter pub get
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Phase 2: Try flutter build (will fail at CMake)
echo === flutter build windows -- will fail at CMake ===
call flutter build windows --debug
echo === CMake failure expected - continuing ===

:: Phase 3: Patch generated_plugins.cmake
echo === Patching generated_plugins.cmake ===

:: Read plugin paths from JSON using PowerShell
for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -Command "$json = Get-Content '.flutter-plugins-dependencies' -Raw | ConvertFrom-Json; $w = $json.plugins.windows; foreach ($p in $w) { Write-Output (\"$($p.name)=$($p.path -replace '\\\\', '/' -replace '/$', '')\") }"`) do (
  for /f "tokens=1,* delims==" %%x in ("%%a") do (
    set "P_%%x=%%y"
  )
)

:: Build the patched cmake file
set "CMAKE_FILE=windows\flutter\generated_plugins.cmake"
(
  echo set^(PLUGIN_BUNDLED_LIBRARIES^)
  echo.
  
  if defined P_audioplayers_windows (
    echo add_subdirectory^(%P_audioplayers_windows%/windows plugins/audioplayers_windows^)
    echo target_link_libraries^(%{BINARY_NAME}% PRIVATE audioplayers_windows_plugin^)
    echo list^(APPEND PLUGIN_BUNDLED_LIBRARIES $^<TARGET_FILE:audioplayers_windows_plugin^>^)
    echo list^(APPEND PLUGIN_BUNDLED_LIBRARIES ${audioplayers_windows_bundled_libraries}^)
    echo.
  )

  if defined P_desktop_drop (
    echo add_subdirectory^(%P_desktop_drop%/windows plugins/desktop_drop^)
    echo target_link_libraries^(%{BINARY_NAME}% PRIVATE desktop_drop_plugin^)
    echo list^(APPEND PLUGIN_BUNDLED_LIBRARIES $^<TARGET_FILE:desktop_drop_plugin^>^)
    echo list^(APPEND PLUGIN_BUNDLED_LIBRARIES ${desktop_drop_bundled_libraries}^)
    echo.
  )

  if defined P_pasteboard (
    echo add_subdirectory^(%P_pasteboard%/windows plugins/pasteboard^)
    echo target_link_libraries^(%{BINARY_NAME}% PRIVATE pasteboard_plugin^)
    echo list^(APPEND PLUGIN_BUNDLED_LIBRARIES $^<TARGET_FILE:pasteboard_plugin^>^)
    echo list^(APPEND PLUGIN_BUNDLED_LIBRARIES ${pasteboard_bundled_libraries}^)
    echo.
  )

  if defined P_screen_retriever_windows (
    echo add_subdirectory^(%P_screen_retriever_windows%/windows plugins/screen_retriever_windows^)
    echo target_link_libraries^(%{BINARY_NAME}% PRIVATE screen_retriever_windows_plugin^)
    echo list^(APPEND PLUGIN_BUNDLED_LIBRARIES $^<TARGET_FILE:screen_retriever_windows_plugin^>^)
    echo list^(APPEND PLUGIN_BUNDLED_LIBRARIES ${screen_retriever_windows_bundled_libraries}^)
    echo.
  )

  if defined P_window_manager (
    echo add_subdirectory^(%P_window_manager%/windows plugins/window_manager^)
    echo target_link_libraries^(%{BINARY_NAME}% PRIVATE window_manager_plugin^)
    echo list^(APPEND PLUGIN_BUNDLED_LIBRARIES $^<TARGET_FILE:window_manager_plugin^>^)
    echo list^(APPEND PLUGIN_BUNDLED_LIBRARIES ${window_manager_bundled_libraries}^)
    echo.
  )
) > "%CMAKE_FILE%"

echo Patched %CMAKE_FILE%

:: Phase 4: Find cmake
set "CMAKE_PATH="
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" (
  set "CMAKE_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
)

:: Phase 5: CMake generation
echo === CMake generation ===
"%CMAKE_PATH%" -S "%PROJECT_ROOT%\windows" -B "%PROJECT_ROOT%\build\windows\x64" -G "Visual Studio 17 2022" -A x64 -DFLUTTER_TARGET_PLATFORM=windows-x64
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Phase 6: CMake build
echo === CMake build ===
"%CMAKE_PATH%" --build "%PROJECT_ROOT%\build\windows\x64" --config %CONFIG% --target INSTALL
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo === Build succeeded! ===
