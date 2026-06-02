# Patch Flutter SDK to use absolute pub-cache paths for Windows plugin CMake files
# Required because B: drive doesn't support directory symlink traversal on this machine

$flutterPluginsFile = "C:\src\flutter\packages\flutter_tools\lib\src\flutter_plugins.dart"
$buildWindowsFile = "C:\src\flutter\packages\flutter_tools\lib\src\windows\build_windows.dart"

$content = [System.IO.File]::ReadAllText($flutterPluginsFile)
$original = $content

# Step 1: Add _windowsPluginCmakefileTemplate after _pluginCmakefileTemplate
$templateMarker = "endforeach(ffi_plugin)"
$templateEndMarker = "''';"
$newTemplate = @"

'''

const _windowsPluginCmakefileTemplate = r'''
#
# Generated file, do not edit.
#

set(PLUGIN_BUNDLED_LIBRARIES)

{{#methodChannelPlugins}}
add_subdirectory({{path}}/{{os}} plugins/{{name}})
target_link_libraries(${BINARY_NAME} PRIVATE {{name}}_plugin)
list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:{{name}}_plugin>)
list(APPEND PLUGIN_BUNDLED_LIBRARIES ${{{name}}_bundled_libraries})
{{/methodChannelPlugins}}

{{#ffiPlugins}}
add_subdirectory({{path}}/{{os}} plugins/{{name}})
list(APPEND PLUGIN_BUNDLED_LIBRARIES ${{{name}}_bundled_libraries})
{{/ffiPlugins}}'''

"@

# Find the endforeach(ffi_plugin) line and the ''';
$searchPattern = "$templateMarker`r`n$templateEndMarker"
if ($content.Contains($searchPattern)) {
  $content = $content.Replace($searchPattern, "$templateMarker$newTemplate")
  Write-Host "Step 1: Added _windowsPluginCmakefileTemplate" -ForegroundColor Green
} else {
  # Try with just \n
  $searchPattern = "$templateMarker`n$templateEndMarker"
  if ($content.Contains($searchPattern)) {
    $content = $content.Replace($searchPattern, "$templateMarker$newTemplate")
    Write-Host "Step 1: Added _windowsPluginCmakefileTemplate (LF)" -ForegroundColor Green
  } else {
    Write-Host "Step 1 FAILED: Could not find template end marker" -ForegroundColor Red
    exit 1
  }
}

# Step 2: Add path injection in writeWindowsPluginFiles
$injectMarker = "final List<Map<String, Object?>> windowsFfiPlugins = _extractPlatformMaps(
    ffiPlugins,
    WindowsPlugin.kConfigKey,
  );
  final context = <String, Object>{"

$pathInjection = @"
  final Map<String, String> pluginPaths = {
    for (final Plugin p in plugins)
      p.name: p.path.replaceAll('\\', '/'),
  };
  for (final Map<String, Object?> plugin in windowsMethodChannelPlugins) {
    final String? name = plugin['name'] as String?;
    if (name != null && pluginPaths.containsKey(name)) {
      plugin['path'] = pluginPaths[name];
    }
  }
  for (final Map<String, Object?> plugin in windowsFfiPlugins) {
    final String? name = plugin['name'] as String?;
    if (name != null && pluginPaths.containsKey(name)) {
      plugin['path'] = pluginPaths[name];
    }
  }
  final context = <String, Object>{
"@

if ($content.Contains($injectMarker)) {
  $content = $content.Replace($injectMarker, $pathInjection)
  Write-Host "Step 2: Added path injection" -ForegroundColor Green
} else {
  Write-Host "Step 2 FAILED: Could not find inject marker" -ForegroundColor Red
  exit 1
}

# Step 3: Change to use _windowsPluginCmakefileTemplate
$originalCall = @"
  await _writePluginCmakefile(project.windows.generatedPluginCmakeFile, context, templateRenderer);
"@
$newCall = @"
  await _renderTemplateToFile(
    _windowsPluginCmakefileTemplate,
    context,
    project.windows.generatedPluginCmakeFile,
    templateRenderer,
  );
"@

if ($content.Contains($originalCall)) {
  $content = $content.Replace($originalCall, $newCall)
  Write-Host "Step 3: Updated to use _windowsPluginCmakefileTemplate" -ForegroundColor Green
} else {
  Write-Host "Step 3 FAILED: Could not find original call" -ForegroundColor Red
  exit 1
}

# Write the patched file
if ($content -ne $original) {
  [System.IO.File]::WriteAllText($flutterPluginsFile, $content)
  Write-Host "File patched successfully!" -ForegroundColor Green
} else {
  Write-Host "No changes were made - content is identical" -ForegroundColor Yellow
}

# Step 4: Patch build_windows.dart to skip createPluginSymlinks
$buildContent = [System.IO.File]::ReadAllText($buildWindowsFile)
$buildOriginal = $buildContent

$symlinkCall = "createPluginSymlinks(windowsProject.parent);"
$symlinkComment = "// createPluginSymlinks(windowsProject.parent); // B: drive symlink workaround"

if ($buildContent.Contains($symlinkCall)) {
  $buildContent = $buildContent.Replace($symlinkCall, $symlinkComment)
  [System.IO.File]::WriteAllText($buildWindowsFile, $buildContent)
  Write-Host "Step 4: Commented out createPluginSymlinks in build_windows.dart" -ForegroundColor Green
} else {
  Write-Host "Step 4 FAILED: Could not find createPluginSymlinks call" -ForegroundColor Red
  exit 1
}

Write-Host "`nAll patches applied. Run 'flutter --version' to rebuild the tool snapshot." -ForegroundColor Cyan
