$daemonJson = "$env:USERPROFILE\.docker\daemon.json"

# Load existing config or create new hashtable
$config = @{
    builder = @{
        gc = @{
            defaultKeepStorage = "20GB"
            enabled = $true
        }
    }
    experimental = $false
}

if (Test-Path $daemonJson) {
    $raw = Get-Content $daemonJson -Raw
    if ($raw.Trim()) {
        $existing = $raw | ConvertFrom-Json
        # Copy all existing properties to hashtable
        $existing.PSObject.Properties | ForEach-Object {
            $config[$_.Name] = $_.Value
        }
    }
}

$mirrors = @(
    "https://docker.m.daocloud.io"
    "https://docker.1panel.live"
    "https://hub.rat.dev"
    "https://docker.mirrors.ustc.edu.cn"
)

# Get existing mirrors
$existing = @()
if ($config.ContainsKey('registry-mirrors')) {
    $existing = @($config['registry-mirrors'])
}

# Add missing mirrors
$added = 0
foreach ($m in $mirrors) {
    if ($existing -notcontains $m) {
        $existing += $m
        $added++
    }
}

$config['registry-mirrors'] = $existing

# Write back
$config | ConvertTo-Json -Depth 10 | Set-Content $daemonJson -Encoding UTF8

Write-Host "  Added $added mirror(s)"
Write-Host "  Current mirrors: $($existing -join ', ')"
