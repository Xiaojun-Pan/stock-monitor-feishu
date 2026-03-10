---
name: stock-monitor-feishu
description: "宝通科技股票监控技能 - 每分钟检测，飞书实时提醒，智能频率控制"
author: "潘孝军"
version: "1.0.0"
---

# Stock Monitor Feishu Skill - 宝通科技股票监控技能

自动监控宝通科技(300031)股票价格，当涨跌幅达到±2%时，通过当前飞书会话发送实时提醒。

## 🎯 功能特点

- ✅ **实时监控**：每分钟检测宝通科技股价
- ✅ **飞书提醒**：通过当前飞书会话直接发送提醒
- ✅ **智能控制**：避免重复提醒骚扰
- ✅ **每日上限**：每个方向最多提醒10次/天
- ✅ **时间间隔**：同一方向至少间隔30分钟
- ✅ **完整日志**：所有操作都有详细记录
- ✅ **自动守护**：系统崩溃自动重启

## 📋 使用场景

- 📈 **短线交易者**：监控关键价位突破
- 💼 **上班族**：没空看盘，自动提醒
- 🎯 **止盈止损**：到达目标价自动通知
- 🔔 **价格异动**：大涨大跌不错过

## 🚀 快速开始

### 安装技能

```bash
# 使用skillhub安装
skillhub install stock-monitor-feishu

# 或手动安装
cd /root/.openclaw/workspace
git clone <你的GitHub仓库URL> skills/stock-monitor-feishu
```

### 启动监控

```bash
# 启动监控系统
cd /root/.openclaw/workspace/skills/stock-monitor-feishu
bash scripts/start_monitor.sh
```

### 查看状态

```bash
bash scripts/check_status.sh
```

## ⚙️ 配置说明

### 股票配置
默认监控宝通科技(300031)，阈值±2%

### 提醒控制
- **每日上限**：每个方向10次
- **时间间隔**：至少30分钟
- **监控时间**：交易日 9:00-11:30, 13:00-15:00

### 文件位置
```
/tmp/
├── stock_ai_alert_trigger.txt  # 触发文件
├── stock_alert_control/        # 提醒控制
├── ai_monitor.log              # AI监控日志
└── smart_stock_detect.log      # 股价检测日志
```

## 📊 监控规则

### 检测频率
- **股价检测**：每分钟一次
- **AI检查**：每分钟一次
- **守护进程**：每分钟检查

### 提醒条件
1. 股价涨跌幅达到 ±2%
2. 今日该方向提醒未超过10次
3. 距离上次同方向提醒至少30分钟

### 提醒消息格式
```
🚀 【宝通科技上涨提醒】
⏰ 触发时间：2026-03-10 10:30:00
⏰ 通知时间：2026-03-10 10:30:01
💰 当前价格：21.59元
📈 涨幅：+2.0%
🎯 触发阈值：+2.0%

📊 操作建议：
• 考虑是否获利了结
• 观察成交量变化
• 注意阻力位突破

💡 监控状态：正常运行中
🔄 下次检查：1分钟后
```

## 🛠️ 管理命令

### 常用命令
```bash
# 查看状态
bash scripts/check_status.sh

# 立即检测股价
bash scripts/smart_detector.sh

# 查看检测日志
tail -f /tmp/smart_stock_detect.log

# 查看AI监控日志
tail -f /tmp/ai_monitor.log

# 停止监控
bash scripts/stop_monitor.sh

# 重启监控
bash scripts/start_monitor.sh
```

### 定时任务
系统会自动设置以下定时任务：
```bash
# 股价检测（每分钟）
*/1 9-11,13-15 * * 1-5 /path/to/smart_detector.sh

# AI监控守护（每分钟）
* * * * * /path/to/check_and_restart.sh
```

## 📁 文件结构

```
stock-monitor-feishu/
├── SKILL.md                    # 技能说明文档
├── README.md                   # 使用说明
├── package.json               # 技能配置
├── clawhub.yaml               # 发布配置
├── scripts/                   # 脚本目录
│   ├── smart_detector.sh      # 智能股价检测
│   ├── ai_checker.sh          # AI提醒检查
│   ├── start_monitor.sh       # 启动脚本
│   ├── stop_monitor.sh        # 停止脚本
│   ├── check_status.sh        # 状态检查
│   └── check_and_restart.sh   # 守护脚本
└── examples/                  # 示例文件
    └── crontab.example        # 定时任务示例
```

## 🔧 自定义配置

### 修改监控股票
编辑 `scripts/smart_detector.sh`：
```bash
STOCK_CODE="sz300031"    # 改为其他股票代码
STOCK_NAME="宝通科技"     # 改为其他股票名称
UP_THRESHOLD=2.0         # 上涨阈值
DOWN_THRESHOLD=-2.0      # 下跌阈值
```

### 调整提醒频率
编辑 `scripts/smart_detector.sh`：
```bash
MAX_ALERTS_PER_DAY=10    # 每日提醒上限
MIN_ALERT_INTERVAL=1800  # 最小提醒间隔（秒）
```

## 🐛 故障排除

### 常见问题

**Q: 收不到提醒？**
A: 检查：
1. AI监控是否在运行：`ps aux | grep ai_checker`
2. 触发文件是否存在：`ls -la /tmp/stock_ai_alert_trigger.txt`
3. 查看日志：`tail -f /tmp/ai_monitor.log`

**Q: 提醒太频繁？**
A: 调整配置：
1. 增加 `MIN_ALERT_INTERVAL`
2. 减少 `MAX_ALERTS_PER_DAY`

**Q: 监控没有运行？**
A: 检查：
1. 定时任务：`crontab -l`
2. 进程状态：`bash scripts/check_status.sh`
3. 重新启动：`bash scripts/start_monitor.sh`

### 日志文件
- `/tmp/smart_stock_detect.log` - 股价检测日志
- `/tmp/ai_monitor.log` - AI监控日志
- `/tmp/ai_monitor_cron.log` - 守护进程日志
- `/tmp/ai_alert_sent.log` - 已发送提醒记录

## 📄 许可证

MIT License

## 👥 贡献者

- 潘孝军 - 创建者和维护者

## 🔗 相关链接

- GitHub仓库：https://github.com/你的用户名/stock-monitor-feishu
- 问题反馈：GitHub Issues
- 更新日志：CHANGELOG.md

---

**Made with ❤️ for 潘孝军的股票监控需求**