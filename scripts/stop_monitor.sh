#!/bin/bash
# 停止股票监控

PID_FILE="/tmp/ai_stock_monitor.pid"

echo "🛑 停止宝通科技股票监控系统..."
echo ""

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" 2>/dev/null)
    if kill -0 "$PID" 2>/dev/null; then
        echo "停止AI监控进程 (PID: $PID)..."
        kill "$PID"
        sleep 2
        echo "✅ AI监控已停止"
    else
        echo "⚠️  AI监控进程不存在"
    fi
    rm -f "$PID_FILE"
else
    echo "⚠️  未找到PID文件"
fi

# 移除定时任务
echo ""
echo "移除定时任务..."
(crontab -l 2>/dev/null | grep -v "smart_detector" | grep -v "check_and_restart") | crontab -
echo "✅ 定时任务已移除"

echo ""
echo "📊 清理状态："
echo "- 进程文件：已清理"
echo "- 定时任务：已移除"
echo "- 日志文件：保留在 /tmp/ 目录"
echo ""
echo "✅ 监控系统已完全停止"
echo "如需重新启动，运行：bash scripts/start_monitor.sh"
