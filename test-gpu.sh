#!/bin/bash

set -u

GPU="RTX-2060-Mobile" # Put the GPU model here, don't put spaces!

LOG="$GPU-test-$(date +%Y%m%d-%H%M%S).log"

exec > >(tee -a "$LOG") 2>&1

echo "=============================================="
echo " $GPU PRE-PURCHASE DIAGNOSTIC"
echo " $(date)"
echo "=============================================="
echo

# ------------------------------------------------
# 1. Basic GPU detection
# ------------------------------------------------

echo "[1] GPU INFORMATION"
echo "----------------------------------------------"

if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "ERROR: nvidia-smi not found."
    echo "Install/use an NVIDIA-enabled NixOS environment first."
    exit 1
fi

nvidia-smi

echo
echo "Detailed GPU information:"
nvidia-smi -q | grep -E 'Product Name|Product Brand|Serial Number|VBIOS Version|GPU UUID|CUDA Version|Driver Version|Temperature|Power Draw|Power Limit|Memory|Utilization'

echo

# ------------------------------------------------
# 2. Verify memory size
# ------------------------------------------------

echo "[2] VRAM CHECK"
echo "----------------------------------------------"

VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | tr -d ' ')

echo "Detected VRAM: ${VRAM} MiB"

if [ "$VRAM" -ge 23000 ]; then
    echo "PASS: Approximately 24GB VRAM detected."
else
    echo "WARNING: Less than 23GB VRAM detected!"
fi

echo

# ------------------------------------------------
# 3. VBIOS / power information
# ------------------------------------------------

echo "[3] VBIOS / POWER"
echo "----------------------------------------------"

nvidia-smi --query-gpu=name,vbios_version,power.limit,power.max_limit --format=csv

echo

# ------------------------------------------------
# 4. PCIe information
# ------------------------------------------------

echo "[4] PCIe INFORMATION"
echo "----------------------------------------------"

lspci -nn | grep -i nvidia

echo

# ------------------------------------------------
# 5. Check kernel/NVIDIA Xid errors
# ------------------------------------------------

echo "[5] NVIDIA XID ERROR CHECK"
echo "----------------------------------------------"

XID=$(journalctl -k --no-pager 2>/dev/null | grep -iE 'NVRM: Xid|NVRM.*Xid' || true)

if [ -z "$XID" ]; then
    echo "PASS: No NVIDIA Xid errors found in kernel journal."
else
    echo "WARNING: NVIDIA Xid errors were found:"
    echo
    echo "$XID"
fi

echo

# ------------------------------------------------
# 6. Current GPU state
# ------------------------------------------------

echo "[6] CURRENT GPU STATE"
echo "----------------------------------------------"

nvidia-smi --query-gpu=temperature.gpu,power.draw,power.limit,utilization.gpu,utilization.memory,memory.used,memory.total,clocks.gr,clocks.mem --format=csv

echo

# ------------------------------------------------
# 7. CUDA availability
# ------------------------------------------------

echo "[7] CUDA CHECK"
echo "----------------------------------------------"

if command -v nvcc >/dev/null 2>&1; then
    echo "CUDA compiler:"
    nvcc --version
else
    echo "nvcc not installed."
fi

echo

# ------------------------------------------------
# 8. Vulkan GPU memory test
# ------------------------------------------------

echo "[8] VULKAN VRAM TEST (memtest_vulkan)"
echo "----------------------------------------------"

if command -v memtest_vulkan >/dev/null 2>&1; then
    echo "Starting memtest_vulkan..."
    echo
    memtest_vulkan
else
    echo "memtest_vulkan not installed."
fi

echo

# ------------------------------------------------
# 9. Continuous monitoring
# ------------------------------------------------

echo "[9] LIVE MONITORING"
echo "----------------------------------------------"

echo "The following values will be sampled every second."
echo "Press Ctrl-C when finished."
echo

echo "Time,GPU Temp,Power,Utilization,VRAM Used,VRAM Total,Core Clock,Memory Clock"

while true; do

    nvidia-smi --query-gpu=temperature.gpu,power.draw,utilization.gpu,memory.used,memory.total,clocks.gr,clocks.mem --format=csv,noheader,nounits | awk -v t="$(date '+%H:%M:%S')" '{print t "," $0}'

    sleep 1

done
