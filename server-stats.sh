#!/bin/bash

# Check if commands exist, use alternatives where needed
echo "===== Server Stats ====="

# 1. CPU Usage (works on most systems)
if command -v mpstat &> /dev/null; then
    cpu_usage=$(mpstat 1 1 | awk '$12 ~ /[0-9.]+/ {print 100 - $12"%"}')
elif [ -f /proc/stat ]; then
    cpu_usage=$(awk '/cpu / {usage=100-($5*100)/($2+$3+$4+$5+$6+$7+$8+$9+$10)} END {print usage"%"}' /proc/stat)
else
    cpu_usage="[Not Available]"
fi
echo "CPU Usage: $cpu_usage"

# 2. Memory (works without `free`)
if [ -f /proc/meminfo ]; then
    mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    mem_free=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    mem_used=$((mem_total - mem_free))
    echo "Memory: $((mem_used/1024))MB (Used) / $((mem_free/1024))MB (Free) | $((mem_used*100/mem_total))% Used"
else
    echo "Memory: [Not Available]"
fi

# 3. Disk (uses `df` fallback)
if command -v df &> /dev/null; then
    echo "Disk: $(df -h / | awk 'NR==2{print $3 " (Used) / " $4 " (Free)"}')"
else
    echo "Disk: [Not Available]"
fi

# 4. Top Processes (uses `ps` without --sort)
echo -e "\nTop 5 CPU Processes:"
ps -eo pid,user,%cpu,comm --no-headers | sort -k3 -nr | head -n 5 2>/dev/null || echo "[ps/sort not available]"

echo -e "\nTop 5 Memory Processes:"
ps -eo pid,user,%mem,comm --no-headers | sort -k3 -nr | head -n 5 2>/dev/null || echo "[ps/sort not available]"

# 5. Stretch Goals (with fallbacks)
echo -e "\nAdditional Info:"
# Uptime
if [ -f /proc/uptime ]; then
    uptime_sec=$(awk '{print int($1)}' /proc/uptime)
    echo "Uptime: $((uptime_sec/3600))h $((uptime_sec%3600/60))m"
else
    echo "Uptime: [Not Available]"
fi

# OS Version
if [ -f /etc/os-release ]; then
    echo "OS: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
elif [ -f /etc/redhat-release ]; then
    echo "OS: $(cat /etc/redhat-release)"
else
    echo "OS: [Not Available]"
fi

# Load Average
if [ -f /proc/loadavg ]; then
    echo "Load Avg: $(cat /proc/loadavg | awk '{print $1,$2,$3}')"
else
    echo "Load Avg: [Not Available]"
fi
