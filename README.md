# NVIDIA GPU Pre-Purchase Diagnostic Script

A lightweight Linux diagnostic script for evaluating a used NVIDIA GPU, with particular emphasis on the VRAM, sustained workloads, temperatures, power consumption, VBIOS information, VRAM errors, and NVIDIA Xid errors.

This is intended to help evaluate a used GPU before purchasing it, especially cards that have been used for different kinds of workload like 3D gaming, local LLM inference, crypto mining, etc..

Important: This script is a diagnostic/monitoring tool, not a definitive hardware certification. A successful test cannot prove that a GPU has never been repaired or that every component will remain healthy indefinitely.

## Features

The script checks and monitors:

🎮 GPU model and identification
💾 Total VRAM
🔧 VBIOS version
⚡ Power limit and current power consumption
🌡️ GPU temperature
📊 GPU utilization
🧠 VRAM utilization
🕐 GPU and memory clocks
🔌 PCIe device information
🚨 NVIDIA Xid errors in the kernel journal
🧮 CUDA compiler availability
🧠 VRAM errors
📈 Continuous GPU monitoring
📝 Automatic test log

## Requirements

The script requires:

- Linux
- NVIDIA proprietary driver
- nvidia-smi
- lspci
- journalctl
- nvcc
- memtest_vulkan

On Linux, nvidia-smi should normally be available if the NVIDIA driver is correctly configured.

You can check:

```shell
$ nvidia-smi
```

You should see your GPU listed.

For example:

NVIDIA GeForce RTX 2060 Mobile
6144 MiB

# CUDA compiler

The script can also detect whether nvcc is installed, but nvcc is not required for the basic diagnostic functionality.

Check:

```shell
$ nvcc --version
```

On Linux, install it with the distro's particular package manager (It may vary per distro)

```shell
$ apt-get install nvcc
```

# Installation

Save the script as:

```shell
test-gpu.sh
```

Make it executable:

```shell
chmod +x test-gpu.sh
```

Run it:

```shell
./test-gpu.sh
```

The script automatically creates a log file similar to following:

[GPU-Model]-test-YYYYMMDD-HHMMSS.log

For example:

```
$ cat RTX-2060-Mobile-test-20260816-185430.log
```
