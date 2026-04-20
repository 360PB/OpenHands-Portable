# OpenHands Process Killer
Write-Host "[OpenHands] Stopping services..."

# Kill by window title
Get-Process | Where-Object { $_.MainWindowTitle -match 'OpenHands (Backend|Frontend)' } | ForEach-Object {
    Write-Host "  Stopping window: $($_.MainWindowTitle)"
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

# Kill python.exe running uvicorn for openhands
Get-CimInstance Win32_Process | Where-Object {
    $_.Name -eq 'python.exe' -and $_.CommandLine -like '*uvicorn*openhands*'
} | ForEach-Object {
    Write-Host "  Stopping python process: $($_.ProcessId)"
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
}

# Kill node.exe running in frontend directory
Get-CimInstance Win32_Process | Where-Object {
    $_.Name -eq 'node.exe' -and $_.CommandLine -like '*frontend*'
} | ForEach-Object {
    Write-Host "  Stopping node process: $($_.ProcessId)"
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
}

# Kill any process listening on port 3000
Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue |
    Where-Object { $_.OwningProcess -gt 0 } |
    Select-Object -ExpandProperty OwningProcess -Unique |
    ForEach-Object {
        Write-Host "  Stopping port 3000 process: $_"
        Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue
    }

# Kill any process listening on port 3001
Get-NetTCPConnection -LocalPort 3001 -ErrorAction SilentlyContinue |
    Where-Object { $_.OwningProcess -gt 0 } |
    Select-Object -ExpandProperty OwningProcess -Unique |
    ForEach-Object {
        Write-Host "  Stopping port 3001 process: $_"
        Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue
    }

Write-Host "[OpenHands] Services stopped."