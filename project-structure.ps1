param(
  [int]$Depth = 5,
  [string[]]$Exclude = @('.dart_tool', 'build', '.git', '.idea', '.vscode', '.opencode', 'windows', 'linux', 'macos', 'assets', 'src', 'docs')
)

$root = if ($args[0]) { $args[0] } else { (Get-Item -LiteralPath $PSScriptRoot).FullName }

function Show-Tree {
  param(
    [string]$Path,
    [string]$Prefix = '',
    [int]$Remaining,
    [System.Collections.Generic.HashSet[string]]$ExcludeSet
  )

  $items = Get-ChildItem -LiteralPath $Path | Where-Object {
    $_.Name -notin $ExcludeSet -and $_.Name -notlike '.*'
  } | Sort-Object { if ($_ -is [System.IO.DirectoryInfo]) { 0 } else { 1 } }, Name

  for ($i = 0; $i -lt $items.Count; $i++) {
    $item = $items[$i]
    $isLast = $i -eq $items.Count - 1
    $connector = if ($isLast) { '`-- ' } else { '|-- ' }

    "$Prefix$connector$($item.Name)"

    if ($item -is [System.IO.DirectoryInfo] -and $Remaining -gt 0 -and $item.Name -notin $ExcludeSet) {
      $subPrefix = if ($isLast) { '    ' } else { '|   ' }
      Show-Tree -Path $item.FullName -Prefix "$Prefix$subPrefix" -Remaining ($Remaining - 1) -ExcludeSet $ExcludeSet
    }
  }
}

$excludeSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($e in $Exclude) { [void]$excludeSet.Add($e) }

Write-Output "$([System.IO.Path]::GetFileName($root))/"
Show-Tree -Path $root -Remaining $Depth -ExcludeSet $excludeSet
