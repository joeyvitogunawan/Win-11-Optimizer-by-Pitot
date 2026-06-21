#Requires -Version 5.1
<#
.SYNOPSIS
    W11 Deep Tweaker — i5-13400F + RTX 3060 Ti Edition
    Run as Administrator. Right-click → Run with PowerShell (as Admin)
#>

# ── Admin check ─────────────────────────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ── Color palette ────────────────────────────────────────────────────────────
$C = @{
    BG       = [System.Drawing.Color]::FromArgb(13,13,15)
    BG2      = [System.Drawing.Color]::FromArgb(20,20,22)
    BG3      = [System.Drawing.Color]::FromArgb(28,28,32)
    BG4      = [System.Drawing.Color]::FromArgb(36,36,42)
    Border   = [System.Drawing.Color]::FromArgb(42,42,50)
    Text     = [System.Drawing.Color]::FromArgb(232,232,240)
    Text2    = [System.Drawing.Color]::FromArgb(140,140,160)
    Text3    = [System.Drawing.Color]::FromArgb(80,80,100)
    Accent   = [System.Drawing.Color]::FromArgb(124,106,245)
    Green    = [System.Drawing.Color]::FromArgb(62,207,142)
    Amber    = [System.Drawing.Color]::FromArgb(245,166,35)
    Red      = [System.Drawing.Color]::FromArgb(245,101,101)
    Blue     = [System.Drawing.Color]::FromArgb(96,165,250)
    DoneRow  = [System.Drawing.Color]::FromArgb(22,42,30)
    FailRow  = [System.Drawing.Color]::FromArgb(42,18,18)
}

# ── Tweak definitions ────────────────────────────────────────────────────────
# Each tweak: Name, Category, Impact, Risk, Description, ScriptBlock
$Tweaks = @(

# ════════════ REGISTRY ════════════
    [PSCustomObject]@{
        Name="SvcHost split threshold (32GB)"
        Cat="Registry"; Impact="HIGH"; Risk="MOD"
        Desc="Groups svchost services to reduce context switching on 32GB RAM."
        Action={
            reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d 33554432 /f | Out-Null
        }
        Undo={
            reg delete "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /f 2>$null | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="Disable NTFS last access timestamps"
        Cat="Registry"; Impact="MED"; Risk="SAFE"
        Desc="Stops metadata writes on every file read. Reduces disk I/O during game loading."
        Action={ fsutil behavior set disablelastaccess 1 | Out-Null }
        Undo={ fsutil behavior set disablelastaccess 0 | Out-Null }
    }
    [PSCustomObject]@{
        Name="Keep kernel in RAM (DisablePagingExecutive)"
        Cat="Registry"; Impact="MED"; Risk="SAFE"
        Desc="Forces Windows kernel and drivers to stay in physical RAM. Prevents latency spikes."
        Action={
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f | Out-Null
        }
        Undo={
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 0 /f | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="Disable large system cache"
        Cat="Registry"; Impact="MED"; Risk="SAFE"
        Desc="Gives RAM priority to games/programs rather than disk file cache."
        Action={
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f | Out-Null
        }
        Undo={
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 1 /f | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="Win32PrioritySeparation = 26 (max foreground boost)"
        Cat="Registry"; Impact="HIGH"; Risk="SAFE"
        Desc="Short, variable quantum with max foreground priority. Game gets maximum CPU slice."
        Action={
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 26 /f | Out-Null
        }
        Undo={
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 2 /f | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="Disable GameDVR / Xbox background recording"
        Cat="Registry"; Impact="MED"; Risk="SAFE"
        Desc="Kills Xbox Game DVR buffer flush that can drop frames mid-game."
        Action={
            reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f | Out-Null
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f | Out-Null
        }
        Undo={
            reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 1 /f | Out-Null
            reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /f 2>$null | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="Raise IRQ8 priority"
        Cat="Registry"; Impact="MED"; Risk="MOD"
        Desc="Elevates system clock interrupt priority for more consistent frame scheduling."
        Action={
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "IRQ8Priority" /t REG_DWORD /d 1 /f | Out-Null
        }
        Undo={
            reg delete "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "IRQ8Priority" /f 2>$null | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="Disable USB selective suspend (registry)"
        Cat="Registry"; Impact="MED"; Risk="SAFE"
        Desc="Prevents USB devices (mouse/keyboard) from powering down mid-session."
        Action={
            reg add "HKLM\SYSTEM\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWORD /d 1 /f | Out-Null
        }
        Undo={
            reg add "HKLM\SYSTEM\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWORD /d 0 /f | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="Disable Windows tips & content delivery"
        Cat="Registry"; Impact="LOW"; Risk="SAFE"
        Desc="Kills background tasks that push Windows suggestions and Start menu ads."
        Action={
            $p = "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            reg add $p /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f | Out-Null
            reg add $p /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f | Out-Null
            reg add $p /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f | Out-Null
            reg add $p /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f | Out-Null
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f | Out-Null
        }
        Undo={
            $p = "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            reg add $p /v "SoftLandingEnabled" /t REG_DWORD /d 1 /f | Out-Null
            reg add $p /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 1 /f | Out-Null
            reg add $p /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 1 /f | Out-Null
            reg add $p /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 1 /f | Out-Null
        }
    }

# ════════════ ADVANCED / TWEAKINGGUY LEVEL ════════════
    [PSCustomObject]@{
        Name="Disable Memory Integrity (Core Isolation)"
        Cat="Advanced"; Impact="HIGH"; Risk="ADV"
        Desc="Removes the hypervisor layer intercepting every kernel call. Recovers 5-10% FPS. Only safe if you don't run untrusted software."
        Action={
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f | Out-Null
        }
        Undo={
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 1 /f | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="MMCSS Games profile tweak"
        Cat="Advanced"; Impact="HIGH"; Risk="MOD"
        Desc="Tunes Multimedia Class Scheduler Service to give game threads tighter, higher-priority CPU time slices."
        Action={
            $p = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
            reg add $p /v "Affinity"              /t REG_DWORD /d 0          /f | Out-Null
            reg add $p /v "Background Only"       /t REG_SZ    /d "False"    /f | Out-Null
            reg add $p /v "Clock Rate"            /t REG_DWORD /d 2710       /f | Out-Null
            reg add $p /v "GPU Priority"          /t REG_DWORD /d 8          /f | Out-Null
            reg add $p /v "Priority"              /t REG_DWORD /d 6          /f | Out-Null
            reg add $p /v "Scheduling Category"   /t REG_SZ    /d "High"     /f | Out-Null
            reg add $p /v "SFIO Priority"         /t REG_SZ    /d "High"     /f | Out-Null
        }
        Undo={
            $p = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
            reg add $p /v "GPU Priority"        /t REG_DWORD /d 8        /f | Out-Null
            reg add $p /v "Priority"            /t REG_DWORD /d 2        /f | Out-Null
            reg add $p /v "Scheduling Category" /t REG_SZ    /d "Medium" /f | Out-Null
            reg add $p /v "SFIO Priority"       /t REG_SZ    /d "Normal" /f | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="MMCSS SystemProfile network throttling off"
        Cat="Advanced"; Impact="MED"; Risk="SAFE"
        Desc="Disables network throttling in MMCSS so game network packets are never deprioritized."
        Action={
            reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f | Out-Null
            reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f | Out-Null
        }
        Undo={
            reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 10 /f | Out-Null
            reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="Disable Spectre/Meltdown mitigations"
        Cat="Advanced"; Impact="HIGH"; Risk="ADV"
        Desc="Recovers 5-15% CPU IPC lost to Intel security mitigations. GAMING-ONLY PCs only."
        Action={
            $p = "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
            reg add $p /v "FeatureSettingsOverride"     /t REG_DWORD /d 3 /f | Out-Null
            reg add $p /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f | Out-Null
        }
        Undo={
            $p = "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
            reg delete $p /v "FeatureSettingsOverride"     /f 2>$null | Out-Null
            reg delete $p /v "FeatureSettingsOverrideMask" /f 2>$null | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="GPU interrupt affinity → P-Core 0 (IRQ pinning)"
        Cat="Advanced"; Impact="MED"; Risk="MOD"
        Desc="Pins GPU interrupt handling to P-Core 0 so it never competes with game threads on E-Cores."
        Action={
            # Find GPU device path and set affinity policy
            $gpuPath = (Get-PnpDevice -Class Display | Where-Object {$_.FriendlyName -match "NVIDIA"} | Select-Object -First 1).InstanceId
            if ($gpuPath) {
                $regPath = "HKLM\SYSTEM\CurrentControlSet\Enum\$gpuPath\Device Parameters\Interrupt Management\Affinity Policy"
                reg add $regPath /v "DevicePolicy"           /t REG_DWORD /d 4 /f | Out-Null
                reg add $regPath /v "AssignmentSetOverride"  /t REG_DWORD /d 1 /f | Out-Null
            } else { throw "NVIDIA GPU not found in PnP devices." }
        }
        Undo={
            $gpuPath = (Get-PnpDevice -Class Display | Where-Object {$_.FriendlyName -match "NVIDIA"} | Select-Object -First 1).InstanceId
            if ($gpuPath) {
                $regPath = "HKLM\SYSTEM\CurrentControlSet\Enum\$gpuPath\Device Parameters\Interrupt Management\Affinity Policy"
                reg delete $regPath /v "DevicePolicy" /f 2>$null | Out-Null
                reg delete $regPath /v "AssignmentSetOverride" /f 2>$null | Out-Null
            }
        }
    }

# ════════════ SERVICES ════════════
    [PSCustomObject]@{
        Name="Disable SysMain (Superfetch)"
        Cat="Services"; Impact="MED"; Risk="SAFE"
        Desc="Stops background RAM preloading. Frees RAM for games on a 32GB system."
        Action={ Stop-Service SysMain -Force -ErrorAction SilentlyContinue; Set-Service SysMain -StartupType Disabled }
        Undo={ Set-Service SysMain -StartupType Automatic; Start-Service SysMain -ErrorAction SilentlyContinue }
    }
    [PSCustomObject]@{
        Name="Disable Windows Search indexer"
        Cat="Services"; Impact="MED"; Risk="SAFE"
        Desc="Stops file indexing from competing with game asset streaming."
        Action={ Stop-Service WSearch -Force -ErrorAction SilentlyContinue; Set-Service WSearch -StartupType Disabled }
        Undo={ Set-Service WSearch -StartupType Automatic; Start-Service WSearch -ErrorAction SilentlyContinue }
    }
    [PSCustomObject]@{
        Name="Disable DiagTrack (telemetry)"
        Cat="Services"; Impact="LOW"; Risk="SAFE"
        Desc="Kills Microsoft telemetry upload background service."
        Action={
            Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
            Set-Service DiagTrack -StartupType Disabled
            Stop-Service dmwappushservice -Force -ErrorAction SilentlyContinue
            Set-Service dmwappushservice -StartupType Disabled -ErrorAction SilentlyContinue
        }
        Undo={
            Set-Service DiagTrack -StartupType Automatic
            Start-Service DiagTrack -ErrorAction SilentlyContinue
        }
    }
    [PSCustomObject]@{
        Name="Disable Windows Error Reporting"
        Cat="Services"; Impact="LOW"; Risk="SAFE"
        Desc="Prevents crash dump writes and uploads that can stall the system."
        Action={
            Stop-Service WerSvc -Force -ErrorAction SilentlyContinue
            Set-Service WerSvc -StartupType Disabled
            reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f | Out-Null
        }
        Undo={
            Set-Service WerSvc -StartupType Manual
            reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 0 /f | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="Disable Windows Update delivery optimization"
        Cat="Services"; Impact="MED"; Risk="SAFE"
        Desc="Stops Windows using your bandwidth as a P2P update seeder during gaming."
        Action={ Stop-Service DoSvc -Force -ErrorAction SilentlyContinue; Set-Service DoSvc -StartupType Disabled }
        Undo={ Set-Service DoSvc -StartupType Automatic; Start-Service DoSvc -ErrorAction SilentlyContinue }
    }
    [PSCustomObject]@{
        Name="Disable Print Spooler"
        Cat="Services"; Impact="LOW"; Risk="SAFE"
        Desc="Removes unnecessary service. Re-enable when you need to print."
        Action={ Stop-Service Spooler -Force -ErrorAction SilentlyContinue; Set-Service Spooler -StartupType Disabled }
        Undo={ Set-Service Spooler -StartupType Automatic; Start-Service Spooler -ErrorAction SilentlyContinue }
    }
    [PSCustomObject]@{
        Name="Disable Connected Devices Platform (CDPSvc)"
        Cat="Services"; Impact="LOW"; Risk="SAFE"
        Desc="Stops background device discovery probing irrelevant to gaming."
        Action={
            Stop-Service CDPSvc -Force -ErrorAction SilentlyContinue
            Set-Service CDPSvc -StartupType Disabled -ErrorAction SilentlyContinue
        }
        Undo={ Set-Service CDPSvc -StartupType Automatic -ErrorAction SilentlyContinue }
    }

# ════════════ CPU & SCHEDULER ════════════
    [PSCustomObject]@{
        Name="Dynamic tick off (disable HPET dynamic)"
        Cat="CPU"; Impact="MED"; Risk="SAFE"
        Desc="Forces constant timer interrupt rate. Reduces scheduling jitter for frame consistency."
        Action={
            bcdedit /set disabledynamictick yes | Out-Null
            bcdedit /deletevalue useplatformtick 2>$null | Out-Null
        }
        Undo={ bcdedit /set disabledynamictick no | Out-Null }
    }
    [PSCustomObject]@{
        Name="CPU min processor state = 100% (no throttle)"
        Cat="CPU"; Impact="MED"; Risk="SAFE"
        Desc="Forces all P-Cores to stay at max frequency. Zero clock-scaling latency."
        Action={
            powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 | Out-Null
            powercfg /setactive SCHEME_CURRENT | Out-Null
        }
        Undo={
            powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5 | Out-Null
            powercfg /setactive SCHEME_CURRENT | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="Enable Ultimate Performance power plan"
        Cat="CPU"; Impact="HIGH"; Risk="SAFE"
        Desc="Unlocks hidden power plan: zero core parking, no frequency scaling, max performance."
        Action={
            powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null | Out-Null
            $guid = (powercfg /list | Select-String "Ultimate Performance" | ForEach-Object { ($_ -split '\s+')[3] }) | Select-Object -Last 1
            if ($guid) { powercfg /setactive $guid | Out-Null }
        }
        Undo={ powercfg /setactive SCHEME_BALANCED | Out-Null }
    }
    [PSCustomObject]@{
        Name="Disable core parking (min cores = 100%)"
        Cat="CPU"; Impact="MED"; Risk="SAFE"
        Desc="Prevents CPU cores from parking. All P-Cores always ready for game thread bursts."
        Action={
            powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR 0cc5b647-c1df-4637-891a-dec35c318583 100 | Out-Null
            powercfg /setactive SCHEME_CURRENT | Out-Null
        }
        Undo={
            powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR 0cc5b647-c1df-4637-891a-dec35c318583 0 | Out-Null
            powercfg /setactive SCHEME_CURRENT | Out-Null
        }
    }

# ════════════ NETWORK ════════════
    [PSCustomObject]@{
        Name="Disable Nagle's algorithm (TCPNoDelay)"
        Cat="Network"; Impact="HIGH"; Risk="SAFE"
        Desc="Sends game packets immediately instead of batching. Kills ping spikes."
        Action={
            $ifaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
            foreach ($iface in $ifaces) {
                $ip = (Get-ItemProperty $iface.PSPath -ErrorAction SilentlyContinue).DhcpIPAddress
                if ($ip -and $ip -ne "0.0.0.0") {
                    Set-ItemProperty $iface.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
                    Set-ItemProperty $iface.PSPath -Name "TCPNoDelay"      -Value 1 -Type DWord -Force
                }
            }
        }
        Undo={
            $ifaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
            foreach ($iface in $ifaces) {
                Remove-ItemProperty $iface.PSPath -Name "TcpAckFrequency" -ErrorAction SilentlyContinue
                Remove-ItemProperty $iface.PSPath -Name "TCPNoDelay"      -ErrorAction SilentlyContinue
            }
        }
    }
    [PSCustomObject]@{
        Name="Flush DNS cache"
        Cat="Network"; Impact="LOW"; Risk="SAFE"
        Desc="Clears stale DNS entries. Reduces matchmaking connection time."
        Action={ ipconfig /flushdns | Out-Null; ipconfig /registerdns | Out-Null }
        Undo={ Write-Host "DNS flush is one-way — nothing to undo." }
    }
    [PSCustomObject]@{
        Name="TCP autotuning = normal"
        Cat="Network"; Impact="LOW"; Risk="SAFE"
        Desc="Ensures TCP receive window is not restricted. Better throughput for game patches."
        Action={
            netsh int tcp set global autotuninglevel=normal | Out-Null
            netsh int tcp set global chimney=disabled        | Out-Null
            netsh int tcp set global dca=enabled             | Out-Null
        }
        Undo={ netsh int tcp set global autotuninglevel=normal | Out-Null }
    }

# ════════════ STORAGE ════════════
    [PSCustomObject]@{
        Name="Fixed page file 4096–8192 MB"
        Cat="Storage"; Impact="MED"; Risk="SAFE"
        Desc="Eliminates mid-game page file resize I/O spikes. Fixed size = no dynamic resize."
        Action={
            $cs = Get-WmiObject Win32_ComputerSystem
            $cs.AutomaticManagedPagefile = $false
            $cs.Put() | Out-Null
            $pf = Get-WmiObject -Query "SELECT * FROM Win32_PageFileSetting WHERE Name='C:\\pagefile.sys'"
            if (-not $pf) { $pf = ([WmiClass]"Win32_PageFileSetting").CreateInstance() }
            $pf.Name = "C:\pagefile.sys"
            $pf.InitialSize = 4096
            $pf.MaximumSize = 8192
            $pf.Put() | Out-Null
        }
        Undo={
            $cs = Get-WmiObject Win32_ComputerSystem
            $cs.AutomaticManagedPagefile = $true
            $cs.Put() | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="Disable scheduled disk defrag on SSD/NVMe"
        Cat="Storage"; Impact="LOW"; Risk="SAFE"
        Desc="Prevents pointless defrag scheduler runs on NVMe drives."
        Action={
            $task = Get-ScheduledTask -TaskName "ScheduledDefrag" -TaskPath "\Microsoft\Windows\Defrag\" -ErrorAction SilentlyContinue
            if ($task) { Disable-ScheduledTask -TaskName "ScheduledDefrag" -TaskPath "\Microsoft\Windows\Defrag\" | Out-Null }
        }
        Undo={
            Enable-ScheduledTask -TaskName "ScheduledDefrag" -TaskPath "\Microsoft\Windows\Defrag\" -ErrorAction SilentlyContinue | Out-Null
        }
    }

# ════════════ OS CLEANUP ════════════
    [PSCustomObject]@{
        Name="Remove Xbox / gaming overlay appx packages"
        Cat="Cleanup"; Impact="MED"; Risk="SAFE"
        Desc="Removes Xbox Game Overlay, Speech to Text overlay, and TCUI background apps."
        Action={
            @("Microsoft.XboxGameOverlay","Microsoft.XboxSpeechToTextOverlay","Microsoft.Xbox.TCUI") | ForEach-Object {
                Get-AppxPackage -Name $_ -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            }
        }
        Undo={ Write-Host "Re-install Xbox apps via Microsoft Store if needed." }
    }
    [PSCustomObject]@{
        Name="Disable Windows maintenance tasks"
        Cat="Cleanup"; Impact="MED"; Risk="SAFE"
        Desc="Stops automatic maintenance (WER, idle tasks) from firing mid-game."
        Action={
            reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d 1 /f | Out-Null
        }
        Undo={
            reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d 0 /f | Out-Null
        }
    }
    [PSCustomObject]@{
        Name="Disable hibernation (free hiberfil.sys disk space)"
        Cat="Cleanup"; Impact="LOW"; Risk="SAFE"
        Desc="Deletes hibernation file (saves ~32GB on NVMe). Also disables Fast Startup."
        Action={ powercfg /hibernate off | Out-Null }
        Undo={ powercfg /hibernate on | Out-Null }
    }
    [PSCustomObject]@{
        Name="Add game folders to Defender exclusions"
        Cat="Cleanup"; Impact="HIGH"; Risk="MOD"
        Desc="Stops Defender scanning game files in real time. Massive loading speed improvement."
        Action={
            $paths = @("C:\Games","C:\Program Files (x86)\Steam","C:\Program Files\Epic Games",
                       "$env:LOCALAPPDATA\NVIDIA")
            foreach ($p in $paths) {
                if (Test-Path $p) {
                    Add-MpPreference -ExclusionPath $p -ErrorAction SilentlyContinue
                }
            }
        }
        Undo={
            $paths = @("C:\Games","C:\Program Files (x86)\Steam","C:\Program Files\Epic Games",
                       "$env:LOCALAPPDATA\NVIDIA")
            foreach ($p in $paths) {
                Remove-MpPreference -ExclusionPath $p -ErrorAction SilentlyContinue
            }
        }
    }
    [PSCustomObject]@{
        Name="Disable NVIDIA telemetry services"
        Cat="Cleanup"; Impact="LOW"; Risk="SAFE"
        Desc="Stops NVIDIA background telemetry upload services."
        Action={
            @("NvTelemetryContainer","NvNetworkService") | ForEach-Object {
                Stop-Service $_ -Force -ErrorAction SilentlyContinue
                Set-Service $_ -StartupType Disabled -ErrorAction SilentlyContinue
            }
        }
        Undo={
            @("NvTelemetryContainer","NvNetworkService") | ForEach-Object {
                Set-Service $_ -StartupType Automatic -ErrorAction SilentlyContinue
            }
        }
    }
)

# ── State tracking ───────────────────────────────────────────────────────────
$TweakState = @{}   # key=index, value='done'|'failed'|'undone'
$LogLines   = [System.Collections.Generic.List[string]]::new()

function Write-Log {
    param([string]$Msg, [string]$Level="INFO")
    $ts  = Get-Date -Format "HH:mm:ss"
    $line = "[$ts][$Level] $Msg"
    $LogLines.Add($line)
    $script:LogBox.AppendText($line + "`r`n")
    $script:LogBox.ScrollToCaret()
}

# ── Category colors ──────────────────────────────────────────────────────────
$CatColor = @{
    Registry = $C.Accent
    Advanced = $C.Red
    Services = $C.Amber
    CPU      = $C.Blue
    Network  = $C.Green
    Storage  = $C.Text2
    Cleanup  = [System.Drawing.Color]::FromArgb(180,120,255)
}
$ImpColor = @{ HIGH=$C.Red; MED=$C.Amber; LOW=$C.Green }
$RiskLabel= @{ SAFE="✔ Safe"; MOD="⚠ Verify"; ADV="⛔ Advanced" }
$RiskColor= @{ SAFE=$C.Green; MOD=$C.Amber; ADV=$C.Red }

# ═══════════════════════════════════════════════════════════════════
# GUI LAYOUT
# ═══════════════════════════════════════════════════════════════════
$Form = New-Object System.Windows.Forms.Form
$Form.Text            = "W11 Deep Tweaker   —   i5-13400F · RTX 3060 Ti · 32GB"
$Form.Size            = New-Object System.Drawing.Size(1200,780)
$Form.MinimumSize     = New-Object System.Drawing.Size(1000,680)
$Form.BackColor       = $C.BG
$Form.ForeColor       = $C.Text
$Form.Font            = New-Object System.Drawing.Font("Segoe UI",9)
$Form.StartPosition   = "CenterScreen"
$Form.Icon            = [System.Drawing.SystemIcons]::Shield

# ── Header panel ────────────────────────────────────────────────────────────
$Header = New-Object System.Windows.Forms.Panel
$Header.Dock      = "Top"
$Header.Height    = 56
$Header.BackColor = $C.BG2
$Form.Controls.Add($Header)

$LblTitle = New-Object System.Windows.Forms.Label
$LblTitle.Text      = "  ⚡ W11 Deep Tweaker"
$LblTitle.Font      = New-Object System.Drawing.Font("Segoe UI",14,[System.Drawing.FontStyle]::Bold)
$LblTitle.ForeColor = $C.Accent
$LblTitle.Location  = New-Object System.Drawing.Point(0,8)
$LblTitle.Size      = New-Object System.Drawing.Size(320,36)
$Header.Controls.Add($LblTitle)

$LblSub = New-Object System.Windows.Forms.Label
$LblSub.Text      = "i5-13400F · RTX 3060 Ti · 32GB RAM · Windows 11 23H2"
$LblSub.Font      = New-Object System.Drawing.Font("Segoe UI",8.5)
$LblSub.ForeColor = $C.Text2
$LblSub.Location  = New-Object System.Drawing.Point(318,18)
$LblSub.Size      = New-Object System.Drawing.Size(420,24)
$Header.Controls.Add($LblSub)

$LblProgress = New-Object System.Windows.Forms.Label
$LblProgress.Text      = "0 / $($Tweaks.Count) done"
$LblProgress.Font      = New-Object System.Drawing.Font("Segoe UI",9)
$LblProgress.ForeColor = $C.Text2
$LblProgress.TextAlign = "MiddleRight"
$LblProgress.Anchor    = "Top,Right"
$LblProgress.Size      = New-Object System.Drawing.Size(160,56)
$LblProgress.Location  = New-Object System.Drawing.Point(($Form.Width - 180),0)
$Header.Controls.Add($LblProgress)

# ── Category filter strip ────────────────────────────────────────────────────
$FilterPanel = New-Object System.Windows.Forms.Panel
$FilterPanel.Dock      = "Top"
$FilterPanel.Height    = 38
$FilterPanel.BackColor = $C.BG3
$Form.Controls.Add($FilterPanel)

$Cats = @("All") + ($Tweaks | Select-Object -ExpandProperty Cat -Unique)
$FilterBtns = @{}
$fx = 8
foreach ($cat in $Cats) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text      = $cat
    $btn.Tag       = $cat
    $btn.Size      = New-Object System.Drawing.Size(90,24)
    $btn.Location  = New-Object System.Drawing.Point($fx,7)
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 1
    if ($cat -eq "All") {
        $btn.BackColor = $C.Accent
        $btn.ForeColor = $C.Text
        $btn.FlatAppearance.BorderColor = $C.Accent
    } else {
        $col = if ($CatColor.ContainsKey($cat)) { $CatColor[$cat] } else { $C.Text2 }
        $btn.BackColor = $C.BG4
        $btn.ForeColor = $col
        $btn.FlatAppearance.BorderColor = $C.Border
    }
    $btn.Font   = New-Object System.Drawing.Font("Segoe UI",8.5)
    $btn.Cursor = "Hand"
    $btn.Add_Click({
        param($s,$e)
        $tag = $s.Tag
        foreach ($fb in $FilterBtns.Values) {
            $fb.BackColor = $C.BG4
            $fb.ForeColor = if ($CatColor.ContainsKey($fb.Tag)) { $CatColor[$fb.Tag] } else { $C.Text2 }
            $fb.FlatAppearance.BorderColor = $C.Border
        }
        $s.BackColor = $C.Accent
        $s.ForeColor = $C.Text
        $s.FlatAppearance.BorderColor = $C.Accent
        FilterTweaks $tag
    })
    $FilterBtns[$cat] = $btn
    $FilterPanel.Controls.Add($btn)
    $fx += 96
}

# ── Main split ───────────────────────────────────────────────────────────────
$Split = New-Object System.Windows.Forms.SplitContainer
$Split.Dock           = "Fill"
$Split.Orientation    = "Horizontal"
$Split.SplitterDistance = 490
$Split.BackColor      = $C.Border
$Split.Panel1.BackColor = $C.BG
$Split.Panel2.BackColor = $C.BG
$Form.Controls.Add($Split)

# ── Toolbar (Apply All / Undo All / Export Log) ──────────────────────────────
$Toolbar = New-Object System.Windows.Forms.Panel
$Toolbar.Dock      = "Top"
$Toolbar.Height    = 42
$Toolbar.BackColor = $C.BG2
$Split.Panel1.Controls.Add($Toolbar)

function MakeBtn($txt,$clr,$x) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text      = $txt
    $b.Size      = New-Object System.Drawing.Size(148,28)
    $b.Location  = New-Object System.Drawing.Point($x,7)
    $b.FlatStyle = "Flat"
    $b.BackColor = $clr
    $b.ForeColor = $C.Text
    $b.FlatAppearance.BorderSize  = 0
    $b.Font      = New-Object System.Drawing.Font("Segoe UI",8.5,[System.Drawing.FontStyle]::Bold)
    $b.Cursor    = "Hand"
    $Toolbar.Controls.Add($b)
    return $b
}

$BtnApplyAll    = MakeBtn "▶  Apply All Visible"    $C.Accent   8
$BtnApplyHigh   = MakeBtn "⚡  Apply HIGH Impact"   ([System.Drawing.Color]::FromArgb(100,60,60)) 164
$BtnUndoAll     = MakeBtn "↩  Undo All Done"        $C.BG4      320
$BtnRestorePoint= MakeBtn "🛡  Create Restore Point" $C.BG4      476
$BtnExportLog   = MakeBtn "📋  Export Log"           $C.BG4      632

# ── Tweak list (DataGridView) ─────────────────────────────────────────────────
$Grid = New-Object System.Windows.Forms.DataGridView
$Grid.Dock                    = "Fill"
$Grid.BackgroundColor         = $C.BG
$Grid.GridColor               = $C.Border
$Grid.BorderStyle             = "None"
$Grid.RowHeadersVisible       = $false
$Grid.AllowUserToAddRows      = $false
$Grid.AllowUserToDeleteRows   = $false
$Grid.AllowUserToResizeRows   = $false
$Grid.MultiSelect             = $true
$Grid.SelectionMode           = "FullRowSelect"
$Grid.ReadOnly                = $true
$Grid.DefaultCellStyle.BackColor   = $C.BG2
$Grid.DefaultCellStyle.ForeColor   = $C.Text
$Grid.DefaultCellStyle.SelectionBackColor = $C.BG4
$Grid.DefaultCellStyle.SelectionForeColor = $C.Text
$Grid.DefaultCellStyle.Font        = New-Object System.Drawing.Font("Segoe UI",9)
$Grid.DefaultCellStyle.Padding     = New-Object System.Windows.Forms.Padding(4,0,4,0)
$Grid.ColumnHeadersDefaultCellStyle.BackColor   = $C.BG3
$Grid.ColumnHeadersDefaultCellStyle.ForeColor   = $C.Text2
$Grid.ColumnHeadersDefaultCellStyle.Font        = New-Object System.Drawing.Font("Segoe UI",8.5,[System.Drawing.FontStyle]::Bold)
$Grid.ColumnHeadersHeight           = 30
$Grid.ColumnHeadersHeightSizeMode   = "DisableResizing"
$Grid.RowTemplate.Height            = 46
$Grid.EnableHeadersVisualStyles     = $false
$Grid.AutoSizeRowsMode              = "None"
$Grid.ScrollBars                    = "Vertical"

# Columns
$ColStatus = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$ColStatus.HeaderText="Status"; $ColStatus.Width=80; $ColStatus.Name="Status"; $ColStatus.SortMode="NotSortable"
$ColCat = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$ColCat.HeaderText="Category"; $ColCat.Width=90; $ColCat.Name="Cat"; $ColCat.SortMode="NotSortable"
$ColImpact = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$ColImpact.HeaderText="Impact"; $ColImpact.Width=66; $ColImpact.Name="Impact"; $ColImpact.SortMode="NotSortable"
$ColRisk = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$ColRisk.HeaderText="Risk"; $ColRisk.Width=90; $ColRisk.Name="Risk"; $ColRisk.SortMode="NotSortable"
$ColName = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$ColName.HeaderText="Tweak"; $ColName.AutoSizeMode="Fill"; $ColName.Name="Name"; $ColName.SortMode="NotSortable"
$ColDesc = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$ColDesc.HeaderText="Description"; $ColDesc.Width=340; $ColDesc.Name="Desc"; $ColDesc.SortMode="NotSortable"
$ColApply = New-Object System.Windows.Forms.DataGridViewButtonColumn
$ColApply.HeaderText=""; $ColApply.Width=80; $ColApply.Name="Apply"; $ColApply.Text="Apply"; $ColApply.UseColumnTextForButtonValue=$true; $ColApply.SortMode="NotSortable"
$ColUndo = New-Object System.Windows.Forms.DataGridViewButtonColumn
$ColUndo.HeaderText=""; $ColUndo.Width=70; $ColUndo.Name="Undo"; $ColUndo.Text="Undo"; $ColUndo.UseColumnTextForButtonValue=$true; $ColUndo.SortMode="NotSortable"

$Grid.Columns.AddRange($ColStatus,$ColCat,$ColImpact,$ColRisk,$ColName,$ColDesc,$ColApply,$ColUndo)

# Style button columns
$applyStyle = New-Object System.Windows.Forms.DataGridViewCellStyle
$applyStyle.BackColor = $C.Accent
$applyStyle.ForeColor = $C.Text
$applyStyle.Font = New-Object System.Drawing.Font("Segoe UI",8.5,[System.Drawing.FontStyle]::Bold)
$applyStyle.Alignment = "MiddleCenter"
$ColApply.DefaultCellStyle = $applyStyle

$undoStyle = New-Object System.Windows.Forms.DataGridViewCellStyle
$undoStyle.BackColor = $C.BG4
$undoStyle.ForeColor = $C.Text2
$undoStyle.Font = New-Object System.Drawing.Font("Segoe UI",8.5)
$undoStyle.Alignment = "MiddleCenter"
$ColUndo.DefaultCellStyle = $undoStyle

$Split.Panel1.Controls.Add($Grid)
$Grid.BringToFront()

# ── Log panel ────────────────────────────────────────────────────────────────
$LogLabel = New-Object System.Windows.Forms.Label
$LogLabel.Text      = "  Activity Log"
$LogLabel.Dock      = "Top"
$LogLabel.Height    = 24
$LogLabel.BackColor = $C.BG3
$LogLabel.ForeColor = $C.Text2
$LogLabel.Font      = New-Object System.Drawing.Font("Segoe UI",8.5,[System.Drawing.FontStyle]::Bold)
$LogLabel.TextAlign = "MiddleLeft"
$Split.Panel2.Controls.Add($LogLabel)

$LogBox = New-Object System.Windows.Forms.RichTextBox
$LogBox.Dock        = "Fill"
$LogBox.BackColor   = $C.BG
$LogBox.ForeColor   = $C.Green
$LogBox.Font        = New-Object System.Drawing.Font("Consolas",8.5)
$LogBox.BorderStyle = "None"
$LogBox.ReadOnly    = $true
$LogBox.ScrollBars  = "Vertical"
$Split.Panel2.Controls.Add($LogBox)
$script:LogBox = $LogBox

# ── Visible row index map ─────────────────────────────────────────────────────
$VisibleIndices = [System.Collections.Generic.List[int]]::new()

function PopulateGrid {
    param([string]$CatFilter="All")
    $Grid.Rows.Clear()
    $VisibleIndices.Clear()
    for ($i = 0; $i -lt $Tweaks.Count; $i++) {
        $tw = $Tweaks[$i]
        if ($CatFilter -ne "All" -and $tw.Cat -ne $CatFilter) { continue }
        $status = if ($TweakState.ContainsKey($i)) { $TweakState[$i] } else { "–" }
        $ri = $Grid.Rows.Add($status, $tw.Cat, $tw.Impact, $RiskLabel[$tw.Risk], $tw.Name, $tw.Desc)
        $row = $Grid.Rows[$ri]
        $VisibleIndices.Add($i)

        # Status color
        switch ($TweakState[$i]) {
            "done"   { $row.DefaultCellStyle.BackColor=$C.DoneRow; $row.DefaultCellStyle.ForeColor=$C.Green }
            "failed" { $row.DefaultCellStyle.BackColor=$C.FailRow; $row.DefaultCellStyle.ForeColor=$C.Red }
            default  { $row.DefaultCellStyle.BackColor=$C.BG2; $row.DefaultCellStyle.ForeColor=$C.Text }
        }
        # Category color
        $catCol = if ($CatColor.ContainsKey($tw.Cat)) { $CatColor[$tw.Cat] } else { $C.Text2 }
        $row.Cells["Cat"].Style.ForeColor = $catCol
        # Impact color
        $row.Cells["Impact"].Style.ForeColor = if ($ImpColor.ContainsKey($tw.Impact)) { $ImpColor[$tw.Impact] } else { $C.Text2 }
        # Risk color
        $row.Cells["Risk"].Style.ForeColor = if ($RiskColor.ContainsKey($tw.Risk)) { $RiskColor[$tw.Risk] } else { $C.Text2 }
    }
    UpdateProgress
}

function FilterTweaks([string]$cat) { PopulateGrid $cat }

function UpdateProgress {
    $done = ($TweakState.Values | Where-Object {$_ -eq "done"}).Count
    $LblProgress.Text = "$done / $($Tweaks.Count) done"
    $LblProgress.ForeColor = if ($done -gt 0) { $C.Green } else { $C.Text2 }
}

function ApplyTweak([int]$idx) {
    $tw = $Tweaks[$idx]
    Write-Log "Applying: $($tw.Name)" "INFO"
    try {
        & $tw.Action
        $TweakState[$idx] = "done"
        Write-Log "✔ Done: $($tw.Name)" "OK"
    } catch {
        $TweakState[$idx] = "failed"
        Write-Log "✘ FAILED: $($tw.Name) — $_" "ERROR"
    }
}

function UndoTweak([int]$idx) {
    $tw = $Tweaks[$idx]
    Write-Log "Undoing: $($tw.Name)" "INFO"
    try {
        & $tw.Undo
        $TweakState[$idx] = "undone"
        Write-Log "↩ Undone: $($tw.Name)" "OK"
    } catch {
        Write-Log "✘ Undo FAILED: $($tw.Name) — $_" "ERROR"
    }
}

# ── Grid cell click ───────────────────────────────────────────────────────────
$Grid.Add_CellContentClick({
    param($s,$e)
    if ($e.RowIndex -lt 0) { return }
    $tweakIdx = $VisibleIndices[$e.RowIndex]
    if ($e.ColumnIndex -eq $Grid.Columns["Apply"].Index) {
        $tw = $Tweaks[$tweakIdx]
        if ($tw.Risk -eq "ADV") {
            $confirm = [System.Windows.Forms.MessageBox]::Show(
                "⛔ ADVANCED RISK TWEAK`n`n'$($tw.Name)'`n`n$($tw.Desc)`n`nThis has security or stability implications. Proceed?",
                "Confirm Advanced Tweak","YesNo","Warning"
            )
            if ($confirm -ne "Yes") { return }
        }
        ApplyTweak $tweakIdx
        PopulateGrid ($FilterBtns.Values | Where-Object {$_.BackColor -eq $C.Accent} | Select-Object -First 1 -ExpandProperty Tag)
    } elseif ($e.ColumnIndex -eq $Grid.Columns["Undo"].Index) {
        UndoTweak $tweakIdx
        PopulateGrid ($FilterBtns.Values | Where-Object {$_.BackColor -eq $C.Accent} | Select-Object -First 1 -ExpandProperty Tag)
    }
})

# ── Apply All Visible ─────────────────────────────────────────────────────────
$BtnApplyAll.Add_Click({
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Apply all $($VisibleIndices.Count) visible tweaks?`n`nAdvanced/risky tweaks will prompt individually.",
        "Apply All","YesNo","Question"
    )
    if ($confirm -ne "Yes") { return }
    $currentCat = ($FilterBtns.Values | Where-Object {$_.BackColor -eq $C.Accent} | Select-Object -First 1 -ExpandProperty Tag)
    foreach ($idx in $VisibleIndices) {
        $tw = $Tweaks[$idx]
        if ($tw.Risk -eq "ADV") {
            $c2 = [System.Windows.Forms.MessageBox]::Show(
                "⛔ Advanced: '$($tw.Name)'`n$($tw.Desc)`n`nApply this one?","Advanced Tweak","YesNo","Warning"
            )
            if ($c2 -ne "Yes") { Write-Log "Skipped (user): $($tw.Name)" "SKIP"; continue }
        }
        ApplyTweak $idx
    }
    PopulateGrid $currentCat
    [System.Windows.Forms.MessageBox]::Show("Done! Reboot recommended for all changes to take effect.","Apply All Complete","OK","Information")
})

# ── Apply HIGH Impact only ────────────────────────────────────────────────────
$BtnApplyHigh.Add_Click({
    $highIdx = for ($i=0;$i -lt $Tweaks.Count;$i++) { if ($Tweaks[$i].Impact -eq "HIGH") { $i } }
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Apply all $($highIdx.Count) HIGH IMPACT tweaks?`nThis is the fastest way to maximum FPS.`n`nAdvanced ones will prompt individually.",
        "Apply HIGH Impact","YesNo","Question"
    )
    if ($confirm -ne "Yes") { return }
    foreach ($idx in $highIdx) {
        $tw = $Tweaks[$idx]
        if ($tw.Risk -eq "ADV") {
            $c2 = [System.Windows.Forms.MessageBox]::Show(
                "⛔ Advanced: '$($tw.Name)'`n$($tw.Desc)`n`nApply?","Advanced","YesNo","Warning"
            )
            if ($c2 -ne "Yes") { Write-Log "Skipped: $($tw.Name)" "SKIP"; continue }
        }
        ApplyTweak $idx
    }
    $currentCat = ($FilterBtns.Values | Where-Object {$_.BackColor -eq $C.Accent} | Select-Object -First 1 -ExpandProperty Tag)
    PopulateGrid $currentCat
    [System.Windows.Forms.MessageBox]::Show("HIGH impact tweaks applied! Reboot to activate.","Done","OK","Information")
})

# ── Undo All ─────────────────────────────────────────────────────────────────
$BtnUndoAll.Add_Click({
    $doneIdx = $TweakState.Keys | Where-Object { $TweakState[$_] -eq "done" }
    if (-not $doneIdx) { [System.Windows.Forms.MessageBox]::Show("Nothing to undo yet.","Undo","OK","Information"); return }
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Undo all $($doneIdx.Count) applied tweaks?","Undo All","YesNo","Warning"
    )
    if ($confirm -ne "Yes") { return }
    foreach ($idx in $doneIdx) { UndoTweak $idx }
    $currentCat = ($FilterBtns.Values | Where-Object {$_.BackColor -eq $C.Accent} | Select-Object -First 1 -ExpandProperty Tag)
    PopulateGrid $currentCat
})

# ── Create Restore Point ──────────────────────────────────────────────────────
$BtnRestorePoint.Add_Click({
    Write-Log "Creating system restore point..." "INFO"
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "W11 DeepTweaker — Before Tweaks" -RestorePointType "MODIFY_SETTINGS"
        Write-Log "✔ Restore point created." "OK"
        [System.Windows.Forms.MessageBox]::Show("Restore point created successfully!`nYou can revert via System Properties → System Restore.","Restore Point","OK","Information")
    } catch {
        Write-Log "✘ Restore point failed: $_" "ERROR"
    }
})

# ── Export Log ────────────────────────────────────────────────────────────────
$BtnExportLog.Add_Click({
    $dlg = New-Object System.Windows.Forms.SaveFileDialog
    $dlg.Filter   = "Text Files|*.txt"
    $dlg.FileName = "W11_TweakLog_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
    if ($dlg.ShowDialog() -eq "OK") {
        $LogLines | Out-File $dlg.FileName -Encoding UTF8
        Write-Log "Log exported to $($dlg.FileName)" "INFO"
    }
})

# ── Resize handler ────────────────────────────────────────────────────────────
$Form.Add_Resize({
    $LblProgress.Location = New-Object System.Drawing.Point(($Form.Width - 180),0)
})

# ── Init ──────────────────────────────────────────────────────────────────────
Write-Log "W11 Deep Tweaker loaded. $($Tweaks.Count) tweaks available." "INFO"
Write-Log "⚠ Always create a restore point before applying tweaks." "WARN"
Write-Log "Tip: Use 'Apply HIGH Impact' for the fastest FPS gains." "INFO"
PopulateGrid "All"

[System.Windows.Forms.Application]::Run($Form)
