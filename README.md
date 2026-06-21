⚡ W11 Deep Tweaker
> A one-click Windows 11 performance optimization tool built for gaming.
> Targets the **i5-13400F + RTX 3060 Ti** but works on any Windows 11 23H2 system.
---
🚀 Quick Launch
Open PowerShell as Administrator and run:
```powershell
irm https://gist.githubusercontent.com/YOURNAME/YOURGISTID/raw/W11_DeepTweaker.ps1 | iex
```
---
📋 What It Does
W11 Deep Tweaker is a native PowerShell GUI app — no installs, no dependencies, no bloat. It applies deep Windows 11 optimizations with a single click per tweak, with a full undo system for every change.
48 tweaks across 7 categories:
Category	Tweaks	Focus
🗂 Registry	10	Deep registry edits Windows UI can't reach
🧠 Advanced	5	TweakingGuy-level: MMCSS, Memory Integrity, IRQ pinning
⚙️ Services	7	Kill background services that eat CPU/RAM mid-game
🧠 CPU & Scheduler	4	Timer resolution, core parking, P-Core pinning
🌐 Network	3	Nagle off, TCP tuning, DNS flush
💾 Storage	3	NVMe power, page file, defrag scheduler
🧹 OS Cleanup	6	Defender exclusions, bloat removal, maintenance tasks
---
🖥️ Screenshots
> GUI launches with dark theme, category filter bar, and one-click Apply/Undo per tweak.
```
┌─────────────────────────────────────────────────────────────────┐
│ ⚡ W11 Deep Tweaker   i5-13400F · RTX 3060 Ti · 32GB · 23H2    │
├──────────┬──────────┬──────────┬──────────┬──────────┬──────────┤
│   All    │ Registry │ Advanced │ Services │   CPU    │ Network  │
├──────────┴──────────┴──────────┴──────────┴──────────┴──────────┤
│ ▶ Apply All Visible │ ⚡ Apply HIGH Impact │ ↩ Undo All │ 🛡 ... │
├────────┬──────┬────────┬──────────────────────────────┬─────────┤
│ Status │ Cat  │ Impact │ Tweak Name                   │         │
├────────┼──────┼────────┼──────────────────────────────┼─────────┤
│   –    │ CPU  │  HIGH  │ Win32PrioritySeparation = 26 │  Apply  │
│   ✔    │ Reg  │  HIGH  │ SvcHost split threshold      │  Undo   │
│   –    │ Adv  │  HIGH  │ Disable Memory Integrity     │  Apply  │
└────────┴──────┴────────┴──────────────────────────────┴─────────┘
```
---
⚙️ How to Use
Option 1 — Right-click launch
Download `W11_DeepTweaker.ps1`
Right-click → Run with PowerShell
Click Yes on the UAC prompt
Option 2 — If Windows blocks it
Run this once in PowerShell as Admin:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
```
Then right-click → Run with PowerShell.
Option 3 — One-liner (after hosting on GitHub)
```powershell
irm YOUR_RAW_GIST_URL | iex
```
Option 4 — .bat launcher (double-click to run)
```batch
@echo off
PowerShell -ExecutionPolicy Bypass -Command "irm YOUR_RAW_GIST_URL | iex"
pause
```
Save as `RunTweaker.bat` → right-click → Run as administrator.
---
🛡️ Safety First
> **Always create a restore point before applying any tweaks.**
The app has a built-in 🛡 Create Restore Point button — click it before anything else. Every tweak also has an individual Undo button that reverses the change.
To manually restore if something goes wrong:
```
Control Panel → System → System Protection → System Restore
```
---
🎯 Recommended Order
For the fastest FPS gains on i5-13400F + RTX 3060 Ti:
🛡 Create Restore Point — always first
⚡ Apply HIGH Impact — applies all high-impact tweaks automatically
Browse Advanced category — Memory Integrity off + MMCSS tuning
Browse Services — kill SysMain, WSearch, DiagTrack
Browse Cleanup — add game folders to Defender exclusions
Reboot
Run LatencyMon for 5 minutes to verify DPC latency is clean
---
📦 What Each Category Covers
🗂 Registry
SvcHost split threshold (groups services on 32GB RAM)
NTFS last access timestamps off
Kernel pinned in RAM (DisablePagingExecutive)
Win32PrioritySeparation = 26 (max foreground CPU boost)
GameDVR disabled at registry root
IRQ8 priority raised
USB selective suspend killed
Windows tips/content delivery off
🧠 Advanced (TweakingGuy-level)
Memory Integrity (Core Isolation) off — recovers 5–10% FPS from the hypervisor layer
MMCSS Games profile — tighter CPU time slices for game threads
MMCSS network throttling off — game packets never deprioritized
Spectre/Meltdown mitigations off — recovers 5–15% CPU IPC (gaming-only PCs)
GPU interrupt affinity — pins GPU IRQ to P-Core 0
⚙️ Services
SysMain (Superfetch) — off
Windows Search indexer — off
DiagTrack (telemetry) — off
Windows Error Reporting — off
Delivery Optimization — off
Print Spooler — off
Connected Devices Platform — off
🧠 CPU & Scheduler
Dynamic tick disabled (constant timer interrupt rate)
CPU min processor state = 100% (no frequency scaling)
Ultimate Performance power plan unlocked and activated
Core parking disabled (min cores = 100%)
🌐 Network
Nagle's algorithm disabled (TCPNoDelay + TcpAckFrequency)
DNS cache flushed
TCP autotuning set to normal + chimney disabled
💾 Storage
Page file set to fixed 4096–8192 MB (no resize spikes)
Scheduled defrag disabled on SSD/NVMe
Page file size locked
🧹 OS Cleanup
Xbox overlay apps removed
Windows maintenance tasks disabled
Hibernation disabled (frees ~32GB on NVMe)
Game folders added to Defender exclusions
NVIDIA telemetry services killed
Windows content delivery / tips registry keys off
---
⚠️ Risk Levels
Each tweak is labeled with a risk level:
Label	Meaning
✔ Safe	Fully reversible, no security impact
⚠ Verify first	Requires reboot or has a minor edge case to check
⛔ Advanced	Security trade-off — read the description before applying
Advanced tweaks (Memory Integrity off, Spectre/Meltdown off) will show a confirmation popup before applying. These are only recommended on dedicated gaming PCs not used for banking or general web browsing.
---
🖥️ System Requirements
Component	Requirement
OS	Windows 11 22H2 / 23H2 / 24H2
PowerShell	5.1 or later (built into Windows)
Privileges	Administrator (auto-elevates on launch)
.NET	4.x (built into Windows)
> Optimized for **i5-13400F (hybrid P/E-Core)** and **RTX 3060 Ti**, but all tweaks apply to any Windows 11 gaming PC.
---
🔧 How to Host Your Own One-Liner
Go to gist.github.com
Paste the full contents of `W11_DeepTweaker.ps1`
Click Create secret gist
Click the Raw button — copy that URL
Your one-liner becomes:
```powershell
irm https://gist.githubusercontent.com/YOURNAME/GISTID/raw/W11_DeepTweaker.ps1 | iex
```
---
📋 Activity Log
Every tweak applied or undone is logged with a timestamp in the Activity Log panel at the bottom of the app. Use 📋 Export Log to save it as a `.txt` file for reference.
---
❓ FAQ
Q: Do I need to reboot after applying tweaks?
A: Yes — most registry and service changes require a reboot to fully take effect. The app will remind you.
Q: Can I undo everything?
A: Yes — every tweak has an individual Undo button, and the ↩ Undo All Done button reverses all applied tweaks at once. For anything critical, the restore point covers everything.
Q: Will this work on Windows 11 24H2?
A: Most tweaks are compatible. MMCSS paths and some registry keys may differ slightly on newer builds.
Q: What's the difference between this and other windows debloater or tweaker?
A: This goes deeper — registry-level IRQ tuning, MMCSS scheduler tweaks, GPU interrupt affinity pinning, and Spectre mitigation control are not covered by those tools. Think of this as the layer you apply after running those.
Q: Is it safe to apply all tweaks at once?
A: Safe tweaks yes — use ⚡ Apply HIGH Impact for the fastest gains. Advanced tweaks (red badges) should be applied individually after reading the description.
---
📄 License
Free to use and modify for personal use. Not affiliated with Microsoft, NVIDIA, or Intel.
---
🙏 Credits
Inspired by the Windows optimization community — TweakingGuy, Chris Titus Tech, FR33THY, and the Calypto latency guides.
