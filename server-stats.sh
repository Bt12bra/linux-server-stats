#!/bin/bash

echo "===== Server Stats ====="
echo ""

# 1. CPU Usage (works everywhere)
if [ -f /proc/stat ]; then
    cpu_usage=$(awk '/cpu / {usage=($2+$4)*100/($2+$4+$5)} END {printf "%.1f%%", usage}' /proc/stat)
else
    cpu_usage="[N/A]"
fi
echo "CPU Usage: $cpu_usage"

# 2. Memory (works without 'free' command)
if [ -f /proc/meminfo ]; then
    mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    mem_avail=$(awk '/MemAvailable/ {print $2}' /proc/meminfo 2>/dev/null || awk '/MemFree/ {print $2}' /proc/meminfo)
    mem_used=$((mem_total - mem_avail))
    echo "Memory: $((mem_used/1024))MB (Used) / $((mem_avail/1024))MB (Free) | $((mem_used*100/mem_total))% Used"
else
    echo "Memory: [N/A]"
fi

# 3. Disk (simplified)
if command -v df >/dev/null; then
    echo "Disk: $(df -h / | awk 'NR==2{print $3" (Used) / "$4" (Free) | "$5" Used"}')"
else
    echo "Disk: [N/A]"
fi

# 4. Processes (universal approach)
echo ""
echo "Top Processes:"
echo "---------------"

if [ -f /proc/loadavg ]; then
    echo "Load Average: $(awk '{print $1", "$2", "$3}' /proc/loadavg)"
else
    echo "Load: [N/A]"
fi

# 5. System Info
echo ""
echo "System Info:"
echo "------------"

# Uptime
if [ -f /proc/uptime ]; then
    uptime_sec=$(awk '{print int($1)}' /proc/uptime)
    echo "Uptime: $((uptime_sec/3600))h $((uptime_sec%3600/60))m"
else
    echo "Uptime: [N/A]"
fi

# OS Info
if [ -f /etc/os-release ]; then
    echo "OS: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
elif [ -f /etc/redhat-release ]; then
    echo "OS: $(cat /etc/redhat-release)"
else
    echo "OS: [N/A]"
fi
if command -v ps >/dev/null; then
    echo ""
    echo "Running Processes:"
    ps -eo pid,user,pcpu,pmem,comm --sort=-pcpu | head -n 6 2>/dev/null || echo "  [Process info unavailable]"
fi
