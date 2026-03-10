#!/bin/bash
# 智能股票检测脚本 - 每分钟检测，智能提醒

STOCK_CODE="sz300031"
STOCK_NAME="宝通科技"
UP_THRESHOLD=2.0
DOWN_THRESHOLD=-2.0

# 提醒控制文件
ALERT_CONTROL_DIR="/tmp/stock_alert_control"
mkdir -p "$ALERT_CONTROL_DIR"

# 每日提醒记录
TODAY=$(date '+%Y%m%d')
DAILY_ALERT_FILE="$ALERT_CONTROL_DIR/${STOCK_CODE}_${TODAY}.alert"
MAX_ALERTS_PER_DAY=10  # 每天最多提醒10次（每个方向）

# 获取股价
get_stock_data() {
    RESPONSE=$(curl -s "https://qt.gtimg.cn/q=$STOCK_CODE" 2>/dev/null)
    
    if command -v iconv &> /dev/null; then
        RESPONSE=$(echo "$RESPONSE" | iconv -f gbk -t utf-8 2>/dev/null || echo "$RESPONSE")
    fi
    
    if [ -z "$RESPONSE" ]; then
        return 1
    fi
    
    DATA=$(echo "$RESPONSE" | cut -d'"' -f2)
    if [ -z "$DATA" ]; then
        return 1
    fi
    
    echo "$DATA"
    return 0
}

# 解析数据
parse_stock_data() {
    DATA="$1"
    
    NAME=$(echo "$DATA" | cut -d'~' -f2)
    PRICE=$(echo "$DATA" | cut -d'~' -f4)
    YESTERDAY=$(echo "$DATA" | cut -d'~' -f5)
    OPEN=$(echo "$DATA" | cut -d'~' -f6)
    HIGH=$(echo "$DATA" | cut -d'~' -f33)
    LOW=$(echo "$DATA" | cut -d'~' -f34)
    CHANGE_PERCENT=$(echo "$DATA" | cut -d'~' -f39 | tr -d '%')
    
    # 计算涨跌幅
    if [ -n "$YESTERDAY" ] && [ "$YESTERDAY" != "0.000" ]; then
        CHANGE=$(echo "scale=2; (($PRICE - $YESTERDAY) / $YESTERDAY) * 100" | bc 2>/dev/null)
        if [ -z "$CHANGE" ]; then
            CHANGE="$CHANGE_PERCENT"
        fi
    else
        CHANGE="$CHANGE_PERCENT"
    fi
    
    echo "$NAME|$PRICE|$CHANGE|$YESTERDAY|$OPEN|$HIGH|$LOW"
}

# 检查是否需要提醒（智能控制）
check_smart_alert() {
    local alert_type="$1"
    local change="$2"
    local price="$3"
    
    # 读取今日提醒记录
    local today_alerts=0
    local last_alert_time=""
    local last_alert_type=""
    
    if [ -f "$DAILY_ALERT_FILE" ]; then
        # 统计今日该类型的提醒次数
        today_alerts=$(grep -c "^$alert_type:" "$DAILY_ALERT_FILE" 2>/dev/null || echo "0")
        
        # 获取最后一次该类型提醒的时间
        last_alert_line=$(grep "^$alert_type:" "$DAILY_ALERT_FILE" | tail -1)
        if [ -n "$last_alert_line" ]; then
            last_alert_time=$(echo "$last_alert_line" | cut -d':' -f2)
            last_alert_type="$alert_type"
        fi
    fi
    
    # 检查是否超过每日限制
    if [ "$today_alerts" -ge "$MAX_ALERTS_PER_DAY" ]; then
        echo "INFO: 今日${alert_type}提醒已达${MAX_ALERTS_PER_DAY}次上限，跳过"
        return 1
    fi
    
    # 检查距离上次提醒的时间（至少间隔30分钟）
    if [ -n "$last_alert_time" ]; then
        local current_time=$(date +%s)
        local last_time=$(date -d "$last_alert_time" +%s 2>/dev/null || echo "0")
        local time_diff=$((current_time - last_time))
        local min_interval=1800  # 30分钟
        
        if [ "$time_diff" -lt "$min_interval" ]; then
            local remaining=$((min_interval - time_diff))
            local remaining_min=$((remaining / 60))
            echo "INFO: 距离上次${alert_type}提醒仅${remaining_min}分钟，需等待${remaining}秒"
            return 1
        fi
    fi
    
    # 可以提醒
    return 0
}

# 记录提醒
record_alert() {
    local alert_type="$1"
    local price="$2"
    local change="$3"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$alert_type:$timestamp:$price:$change" >> "$DAILY_ALERT_FILE"
    
    # 限制文件大小，只保留最近100条记录
    tail -n 100 "$DAILY_ALERT_FILE" > "${DAILY_ALERT_FILE}.tmp" && mv "${DAILY_ALERT_FILE}.tmp" "$DAILY_ALERT_FILE"
}

# 主函数
main() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "⏰ $timestamp - 检测 $STOCK_NAME 股价..."
    
    # 获取数据
    DATA=$(get_stock_data)
    if [ $? -ne 0 ]; then
        echo "❌ 获取股价数据失败"
        return 1
    fi
    
    # 解析数据
    PARSED_DATA=$(parse_stock_data "$DATA")
    NAME=$(echo "$PARSED_DATA" | cut -d'|' -f1)
    PRICE=$(echo "$PARSED_DATA" | cut -d'|' -f2)
    CHANGE=$(echo "$PARSED_DATA" | cut -d'|' -f3)
    YESTERDAY=$(echo "$PARSED_DATA" | cut -d'|' -f4)
    OPEN=$(echo "$PARSED_DATA" | cut -d'|' -f5)
    HIGH=$(echo "$PARSED_DATA" | cut -d'|' -f6)
    LOW=$(echo "$PARSED_DATA" | cut -d'|' -f7)
    
    echo "📊 $NAME 股价：${PRICE}元，涨跌幅：${CHANGE}%"
    
    # 检查阈值
    local alert_type="NORMAL"
    if (( $(echo "$CHANGE >= $UP_THRESHOLD" | bc -l 2>/dev/null) )); then
        alert_type="UP"
    elif (( $(echo "$CHANGE <= $DOWN_THRESHOLD" | bc -l 2>/dev/null) )); then
        alert_type="DOWN"
    fi
    
    if [ "$alert_type" != "NORMAL" ]; then
        echo "⚠️  检测到${alert_type}触发：价格${PRICE}元，涨跌幅${CHANGE}%"
        
        # 智能检查是否需要提醒
        if check_smart_alert "$alert_type" "$CHANGE" "$PRICE"; then
            echo "✅ 符合提醒条件，创建触发文件..."
            
            # 创建触发文件
            TRIGGER_FILE="/tmp/stock_ai_alert_trigger.txt"
            echo "TRIGGER:$alert_type:$PRICE:$CHANGE:$timestamp" > "$TRIGGER_FILE"
            
            # 记录提醒
            record_alert "$alert_type" "$PRICE" "$CHANGE"
            
            echo "📝 今日${alert_type}提醒次数：$(grep -c "^$alert_type:" "$DAILY_ALERT_FILE" 2>/dev/null || echo "0")/${MAX_ALERTS_PER_DAY}"
        else
            echo "⏭️  跳过提醒（频率控制）"
        fi
    else
        echo "✅ 价格正常"
    fi
    
    # 记录检测日志
    echo "$timestamp - $NAME - $PRICE - $CHANGE%" >> "/tmp/smart_stock_detect.log"
    
    return 0
}

# 执行
main "$@"