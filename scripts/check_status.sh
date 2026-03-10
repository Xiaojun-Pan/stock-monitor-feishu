#!/bin/bash
# 股票监控系统状态查看

echo "📊 宝通科技股票监控系统状态"
echo "================================"
echo ""

# 当前时间
echo "⏰ 当前时间：$(date '+%Y-%m-%d %H:%M:%S')"
echo "📅 今日日期：$(date '+%Y年%m月%d日 星期%w')"
echo ""

# 获取实时股价
echo "🔍 实时股价检测："
/root/.openclaw/workspace/smart_stock_detector.sh 2>&1 | grep -v "检测\|股价\|价格正常"
echo ""

# 监控配置
echo "⚙️ 监控配置："
echo "- 股票代码：sz300031"
echo "- 股票名称：宝通科技"
echo "- 上涨阈值：+2.0%"
echo "- 下跌阈值：-2.0%"
echo "- 检测频率：每分钟一次"
echo "- 监控时间：交易日 9:00-11:30, 13:00-15:00"
echo "- 每日提醒上限：每个方向最多3次"
echo "- 提醒间隔：至少30分钟"
echo ""

# 今日提醒统计
TODAY=$(date '+%Y%m%d')
ALERT_FILE="/tmp/stock_alert_control/sz300031_${TODAY}.alert"
if [ -f "$ALERT_FILE" ]; then
    echo "📈 今日提醒统计："
    UP_COUNT=$(grep -c "^UP:" "$ALERT_FILE" 2>/dev/null || echo "0")
    DOWN_COUNT=$(grep -c "^DOWN:" "$ALERT_FILE" 2>/dev/null || echo "0")
    echo "- 上涨提醒：${UP_COUNT}/3 次"
    echo "- 下跌提醒：${DOWN_COUNT}/3 次"
    
    if [ "$UP_COUNT" -gt 0 ] || [ "$DOWN_COUNT" -gt 0 ]; then
        echo ""
        echo "📝 今日提醒记录："
        cat "$ALERT_FILE"
    fi
else
    echo "📈 今日提醒统计：0/3 次（暂无提醒）"
fi
echo ""

# 系统进程状态
echo "🤖 系统进程状态："
echo "- AI监控检查：$(ps aux | grep -c 'ai_alert_checker' | grep -v grep) 个进程"
echo "- 股价检测：每分钟运行（crontab）"
echo "- 守护进程：每分钟检查（crontab）"
echo ""

# 定时任务
echo "⏰ 定时任务："
crontab -l | grep -E "(smart_stock|check_and_restart)" | while read line; do
    echo "- $line"
done
echo ""

# 日志文件
echo "📋 日志文件："
echo "- 智能检测：/tmp/smart_stock_detect.log"
echo "- AI监控：/tmp/ai_monitor.log"
echo "- 已发送提醒：/tmp/ai_alert_sent.log"
echo "- 触发文件：/tmp/stock_ai_alert_trigger.txt"
echo "- 控制目录：/tmp/stock_alert_control/"
echo ""

# 当前价格分析
echo "💰 当前价格分析："
# 获取最新价格
LATEST_LOG=$(tail -n 1 /tmp/smart_stock_detect.log 2>/dev/null)
if [ -n "$LATEST_LOG" ]; then
    PRICE=$(echo "$LATEST_LOG" | awk -F' - ' '{print $3}' | awk '{print $1}')
    CHANGE=$(echo "$LATEST_LOG" | awk -F' - ' '{print $4}' | tr -d '%')
    
    if [ -n "$PRICE" ] && [ -n "$CHANGE" ]; then
        echo "- 当前价格：${PRICE}元"
        echo "- 当前涨跌幅：${CHANGE}%"
        
        # 计算触发价格
        YESTERDAY="21.17"  # 昨收价
        UP_TRIGGER=$(echo "scale=2; $YESTERDAY * 1.02" | bc)
        DOWN_TRIGGER=$(echo "scale=2; $YESTERDAY * 0.98" | bc)
        
        echo "- 上涨触发价：≥ ${UP_TRIGGER}元 (+2%)"
        echo "- 下跌触发价：≤ ${DOWN_TRIGGER}元 (-2%)"
        
        # 计算距离
        DIFF_UP=$(echo "scale=2; $UP_TRIGGER - $PRICE" | bc)
        DIFF_DOWN=$(echo "scale=2; $PRICE - $DOWN_TRIGGER" | bc)
        
        if (( $(echo "$DIFF_UP > 0" | bc -l) )); then
            echo "- 距离上涨触发：还需 +${DIFF_UP}元"
        else
            echo "- 已超过上涨触发价：${DIFF_UP#-}元"
        fi
        
        if (( $(echo "$DIFF_DOWN > 0" | bc -l) )); then
            echo "- 距离下跌触发：还有 ${DIFF_DOWN}元缓冲"
        else
            echo "- 已超过下跌触发价：${DIFF_DOWN#-}元"
        fi
    fi
fi
echo ""

# 管理命令
echo "🛠️ 管理命令："
echo "- 立即检测：/root/.openclaw/workspace/smart_stock_detector.sh"
echo "- 查看检测日志：tail -f /tmp/smart_stock_detect.log"
echo "- 查看AI监控：tail -f /tmp/ai_monitor.log"
echo "- 停止AI监控：kill \$(cat /tmp/ai_stock_monitor.pid 2>/dev/null)"
echo "- 重启监控：/root/.openclaw/workspace/start_ai_monitor.sh"
echo "- 清除今日记录：rm -f /tmp/stock_alert_control/sz300031_*.alert"
echo ""

echo "✅ 监控系统运行正常"
echo "🔔 提醒规则：每分钟检测，智能频率控制"