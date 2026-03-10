#!/bin/bash
# 检查并重启AI监控

PID_FILE="/tmp/ai_stock_monitor.pid"
LOG_FILE="/tmp/ai_monitor_status.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') - 检查AI监控状态..." >> "$LOG_FILE"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" 2>/dev/null)
    if kill -0 "$PID" 2>/dev/null; then
        echo "✅ AI监控运行正常（PID: $PID）" >> "$LOG_FILE"
        exit 0
    else
        echo "⚠️  AI监控进程不存在，重新启动..." >> "$LOG_FILE"
    fi
else
    echo "⚠️  未找到PID文件，重新启动..." >> "$LOG_FILE"
fi

# 重新启动
nohup /root/.openclaw/workspace/ai_alert_checker.sh > /tmp/ai_monitor.log 2>&1 &
NEW_PID=$!
echo $NEW_PID > "$PID_FILE"
echo "✅ 已重新启动AI监控（新PID: $NEW_PID）" >> "$LOG_FILE"
