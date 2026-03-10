#!/bin/bash
# 启动AI助手每分钟监控

echo "🤖 启动宝通科技AI助手监控系统"
echo "=========================================="
echo ""

# 设置脚本权限
chmod +x /root/.openclaw/workspace/ai_alert_checker.sh

# 检查是否已在运行
PID_FILE="/tmp/ai_stock_monitor.pid"
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE" 2>/dev/null)
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "⚠️  监控系统已在运行（PID: $OLD_PID）"
        echo "   停止旧进程..."
        kill "$OLD_PID"
        sleep 2
    fi
fi

# 启动新的监控进程
echo "🚀 启动AI助手监控..."
nohup /root/.openclaw/workspace/ai_alert_checker.sh > /tmp/ai_monitor.log 2>&1 &
NEW_PID=$!

echo $NEW_PID > "$PID_FILE"
echo "✅ 监控系统已启动（PID: $NEW_PID）"
echo ""

# 设置定时任务，确保监控持续运行
echo "🔄 设置守护进程定时任务..."
(crontab -l 2>/dev/null | grep -v "start_ai_monitor") | crontab -

# 每分钟检查一次监控是否在运行
CRON_JOB="* * * * * /root/.openclaw/workspace/check_and_restart_monitor.sh >> /tmp/ai_monitor_cron.log 2>&1"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "✅ 守护定时任务已设置（每分钟检查）"
echo ""

# 创建检查重启脚本
cat > /root/.openclaw/workspace/check_and_restart_monitor.sh << 'EOF'
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
EOF

chmod +x /root/.openclaw/workspace/check_and_restart_monitor.sh

echo "📊 系统状态："
echo "------------------------------------------"
echo "📈 监控股票：宝通科技(300031)"
echo "🎯 触发阈值：涨跌 ±2%"
echo "⏰ 股价检查：每5分钟（定时任务）"
echo "🤖 AI检查：每分钟（守护进程）"
echo "📨 提醒方式：当前飞书会话直接回复"
echo ""
echo "📁 重要文件："
echo "- AI监控PID：$PID_FILE"
echo "- AI监控日志：/tmp/ai_monitor.log"
echo "- 状态检查日志：/tmp/ai_monitor_status.log"
echo "- 触发文件：/tmp/stock_ai_alert_trigger.txt"
echo "- 已发送提醒：/tmp/ai_alert_sent.log"
echo "- 股价检测日志：/tmp/stock_auto_detect.log"
echo "------------------------------------------"
echo ""
echo "🛠️ 管理命令："
echo "- 查看AI监控日志：tail -f /tmp/ai_monitor.log"
echo "- 查看股价检测：tail -f /tmp/stock_auto_detect.log"
echo "- 检查监控状态：ps aux | grep ai_alert_checker"
echo "- 停止监控：kill \$(cat $PID_FILE)"
echo "- 重启监控：bash $0"
echo ""
echo "🧪 测试触发机制："
echo "1. 模拟触发：echo 'TRIGGER:UP:21.59:2.0:2026-03-10 10:30:00' > /tmp/stock_ai_alert_trigger.txt"
echo "2. 查看AI响应：tail -f /tmp/ai_monitor.log"
echo ""
echo "🚀 系统已启动！"
echo "当宝通科技股价触发±2%阈值时，我会在这个飞书会话中直接回复你。"
echo ""
echo "当前时间：$(date '+%Y-%m-%d %H:%M:%S')"
echo "监控状态：✅ 运行中"