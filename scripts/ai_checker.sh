#!/bin/bash
# AI助手提醒检查脚本 - 每分钟检查一次触发文件

TRIGGER_FILE="/tmp/stock_ai_alert_trigger.txt"
CHECK_INTERVAL=60  # 60秒 = 1分钟
MAX_AGE=300        # 触发文件最大年龄5分钟（避免处理旧触发）

echo "🤖 AI助手提醒检查器启动"
echo "⏰ 检查频率：每分钟一次"
echo "📊 监控股票：宝通科技(300031)"
echo "🎯 触发阈值：涨跌 ±2%"
echo ""

# 创建标记文件，避免重复处理同一触发
PROCESSED_MARKER="/tmp/stock_alert_processed.mark"

# 检查触发文件
check_trigger() {
    if [ ! -f "$TRIGGER_FILE" ]; then
        return 1  # 无触发文件
    fi
    
    # 检查文件年龄
    local current_time=$(date +%s)
    local file_time=$(stat -c %Y "$TRIGGER_FILE" 2>/dev/null || echo "0")
    local age=$((current_time - file_time))
    
    if [ $age -gt $MAX_AGE ]; then
        echo "⚠️  触发文件已过期（${age}秒），删除旧文件"
        rm -f "$TRIGGER_FILE"
        return 1
    fi
    
    # 读取触发内容
    local trigger_content=$(cat "$TRIGGER_FILE" 2>/dev/null)
    if [ -z "$trigger_content" ]; then
        return 1
    fi
    
    # 解析触发内容
    local trigger_type=$(echo "$trigger_content" | cut -d':' -f2)
    local price=$(echo "$trigger_content" | cut -d':' -f3)
    local change=$(echo "$trigger_content" | cut -d':' -f4)
    local timestamp=$(echo "$trigger_content" | cut -d':' -f5)
    
    # 检查是否已处理过
    local processed_hash=$(echo "$trigger_content" | md5sum | cut -d' ' -f1)
    if [ -f "$PROCESSED_MARKER" ]; then
        local last_hash=$(cat "$PROCESSED_MARKER" 2>/dev/null)
        if [ "$last_hash" = "$processed_hash" ]; then
            echo "⏭️  已处理过此触发，跳过"
            return 1
        fi
    fi
    
    # 保存处理标记
    echo "$processed_hash" > "$PROCESSED_MARKER"
    
    echo "🚨 检测到股价触发！"
    echo "📈 类型：$trigger_type"
    echo "💰 价格：$price 元"
    echo "📊 涨跌幅：$change%"
    echo "⏰ 时间：$timestamp"
    echo ""
    
    # 返回触发信息
    echo "$trigger_type:$price:$change:$timestamp"
    return 0
}

# 生成提醒消息
generate_alert_message() {
    local trigger_type="$1"
    local price="$2"
    local change="$3"
    local timestamp="$4"
    
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ "$trigger_type" = "UP" ]; then
        echo "🚀 【宝通科技上涨提醒】"
        echo "⏰ 触发时间：$timestamp"
        echo "⏰ 通知时间：$current_time"
        echo "💰 当前价格：${price}元"
        echo "📈 涨幅：+${change}%"
        echo "🎯 触发阈值：+2.0%"
        echo ""
        echo "📊 操作建议："
        echo "• 考虑是否获利了结"
        echo "• 观察成交量变化"
        echo "• 注意阻力位突破"
    else
        echo "📉 【宝通科技下跌提醒】"
        echo "⏰ 触发时间：$timestamp"
        echo "⏰ 通知时间：$current_time"
        echo "💰 当前价格：${price}元"
        echo "📉 跌幅：${change}%"
        echo "🎯 触发阈值：-2.0%"
        echo ""
        echo "📊 操作建议："
        echo "• 考虑是否止损"
        echo "• 观察支撑位"
        echo "• 注意市场情绪"
    fi
    
    echo ""
    echo "💡 监控状态：正常运行中"
    echo "🔄 下次检查：1分钟后"
}

# 主循环
main_loop() {
    local loop_count=0
    
    while true; do
        loop_count=$((loop_count + 1))
        local current_time=$(date '+%Y-%m-%d %H:%M:%S')
        
        echo "--- 第 ${loop_count} 次检查 [$current_time] ---"
        
        # 检查触发
        local trigger_info=$(check_trigger)
        if [ $? -eq 0 ]; then
            echo "✅ 发现有效触发，准备发送提醒..."
            
            # 解析触发信息
            local trigger_type=$(echo "$trigger_info" | cut -d':' -f1)
            local price=$(echo "$trigger_info" | cut -d':' -f2)
            local change=$(echo "$trigger_info" | cut -d':' -f3)
            local timestamp=$(echo "$trigger_info" | cut -d':' -f4)
            
            # 生成消息
            local alert_message=$(generate_alert_message "$trigger_type" "$price" "$change" "$timestamp")
            
            echo ""
            echo "📨 提醒消息内容："
            echo "----------------------------------------"
            echo "$alert_message"
            echo "----------------------------------------"
            echo ""
            
            # 记录到日志
            echo "$current_time - 触发$trigger_type提醒 - $price元 - $change%" >> /tmp/ai_alert_sent.log
            
            # 删除触发文件，避免重复处理
            rm -f "$TRIGGER_FILE"
            
            echo "✅ 提醒已准备，将在飞书会话中发送"
            echo "✅ 触发文件已清理"
            
            # 在实际部署中，这里应该调用消息发送API
            # 由于我们在飞书会话中，我可以直接回复
            echo ""
            echo "🚨 测试提醒已触发！"
            echo "这是宝通科技股票监控系统的测试提醒。"
            echo "当实际股价触发±2%阈值时，我会这样提醒你。"
        else
            echo "✅ 无新触发，一切正常"
        fi
        
        echo ""
        
        # 等待下一次检查
        sleep $CHECK_INTERVAL
    done
}

# 启动主循环
echo "🔄 开始每分钟检查..."
echo "📝 日志文件：/tmp/ai_alert_sent.log"
echo "📁 触发文件：$TRIGGER_FILE"
echo "⏰ 每次检查间隔：${CHECK_INTERVAL}秒"
echo ""
echo "按 Ctrl+C 停止检查"
echo ""

main_loop