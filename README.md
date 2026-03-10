# Stock Monitor Feishu Skill

宝通科技股票监控技能 - 每分钟检测，飞书实时提醒

## 功能简介

这是一个专为潘孝军定制的股票监控技能，用于监控宝通科技(300031)股票价格。当股价涨跌幅达到±2%时，通过当前飞书会话发送实时提醒。

## 核心特性

- 🚀 **实时监控**：每分钟检测股价变化
- 📨 **飞书提醒**：直接在飞书会话中发送提醒
- 🧠 **智能控制**：避免重复提醒骚扰
- ⚡ **快速响应**：1分钟内发现并提醒
- 🔒 **稳定运行**：自动守护，崩溃重启

## 安装使用

### 快速安装

```bash
# 使用skillhub安装
skillhub install stock-monitor-feishu
```

### 手动安装

1. 克隆仓库：
```bash
git clone https://github.com/你的用户名/stock-monitor-feishu.git
cd stock-monitor-feishu
```

2. 设置权限：
```bash
chmod +x scripts/*.sh
```

3. 启动监控：
```bash
bash scripts/start_monitor.sh
```

## 配置说明

### 默认配置

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| 股票代码 | sz300031 | 宝通科技 |
| 股票名称 | 宝通科技 | 显示名称 |
| 上涨阈值 | +2.0% | 触发上涨提醒 |
| 下跌阈值 | -2.0% | 触发下跌提醒 |
| 每日上限 | 10次 | 每个方向最多提醒次数 |
| 时间间隔 | 30分钟 | 同一方向最小间隔 |

### 自定义配置

编辑 `scripts/smart_detector.sh` 修改配置：

```bash
# 股票配置
STOCK_CODE="sz300031"    # 修改为其他股票
STOCK_NAME="宝通科技"
UP_THRESHOLD=2.0
DOWN_THRESHOLD=-2.0

# 提醒控制
MAX_ALERTS_PER_DAY=10
MIN_ALERT_INTERVAL=1800  # 30分钟
```

## 使用示例

### 启动监控

```bash
# 启动完整监控系统
bash scripts/start_monitor.sh
```

### 查看状态

```bash
# 查看监控状态
bash scripts/check_status.sh

# 输出示例：
📊 宝通科技股票监控系统状态
================================
⏰ 当前时间：2026-03-10 10:35:56
📊 检测频率：每分钟一次
💰 当前股价：21.39元
📈 当前涨跌：+1.00%
🚀 上涨触发：≥ 21.59元 (+2%)
📉 下跌触发：≤ 20.74元 (-2%)
```

### 管理监控

```bash
# 停止监控
bash scripts/stop_monitor.sh

# 重启监控
bash scripts/start_monitor.sh

# 查看日志
tail -f /tmp/smart_stock_detect.log
tail -f /tmp/ai_monitor.log
```

## 系统架构

### 组件说明

1. **智能检测器** (`smart_detector.sh`)
   - 每分钟检测股价
   - 智能频率控制
   - 创建触发文件

2. **AI检查器** (`ai_checker.sh`)
   - 每分钟检查触发
   - 发送飞书提醒
   - 记录提醒历史

3. **守护进程** (`check_and_restart.sh`)
   - 确保系统运行
   - 崩溃自动重启
   - 状态监控

### 数据流

```
股价数据 → 智能检测 → 触发文件 → AI检查 → 飞书提醒
    ↓           ↓           ↓         ↓         ↓
腾讯财经API  频率控制   /tmp/stock_ai_alert_trigger.txt  当前会话
```

## 文件说明

### 脚本文件

- `scripts/smart_detector.sh` - 核心检测脚本
- `scripts/ai_checker.sh` - AI提醒脚本
- `scripts/start_monitor.sh` - 启动脚本
- `scripts/stop_monitor.sh` - 停止脚本
- `scripts/check_status.sh` - 状态检查
- `scripts/check_and_restart.sh` - 守护脚本

### 日志文件

- `/tmp/smart_stock_detect.log` - 股价检测日志
- `/tmp/ai_monitor.log` - AI监控日志
- `/tmp/ai_alert_sent.log` - 已发送提醒
- `/tmp/stock_alert_control/` - 提醒控制目录

### 配置文件

- `/tmp/stock_ai_alert_trigger.txt` - 触发文件（临时）
- `/tmp/ai_stock_monitor.pid` - 进程ID文件

## 定时任务

系统自动设置以下定时任务：

```bash
# 股价检测（每分钟，交易时间）
*/1 9-11,13-15 * * 1-5 /path/to/smart_detector.sh

# AI监控守护（每分钟）
* * * * * /path/to/check_and_restart.sh
```

## 故障排除

### 常见问题

**1. 收不到提醒**
```bash
# 检查AI监控是否运行
ps aux | grep ai_checker

# 检查触发文件
ls -la /tmp/stock_ai_alert_trigger.txt

# 查看日志
tail -f /tmp/ai_monitor.log
```

**2. 监控没有运行**
```bash
# 检查定时任务
crontab -l

# 检查进程
bash scripts/check_status.sh

# 重新启动
bash scripts/start_monitor.sh
```

**3. 提醒太频繁**
```bash
# 调整配置
编辑 scripts/smart_detector.sh：
- 增加 MIN_ALERT_INTERVAL
- 减少 MAX_ALERTS_PER_DAY
```

### 日志分析

查看关键日志信息：

```bash
# 实时查看检测日志
tail -f /tmp/smart_stock_detect.log

# 查看AI响应日志
tail -f /tmp/ai_monitor.log

# 查看已发送提醒
cat /tmp/ai_alert_sent.log
```

## 开发说明

### 扩展功能

1. **多股票监控**
   - 修改脚本支持多个股票代码
   - 为每个股票单独配置阈值

2. **多种提醒方式**
   - 添加微信、短信提醒
   - 支持语音提醒

3. **高级分析**
   - 添加技术指标分析
   - 趋势预测功能

### 代码结构

```
stock-monitor-feishu/
├── SKILL.md          # 技能文档
├── README.md         # 使用说明
├── scripts/          # 脚本目录
│   ├── core/         # 核心功能
│   ├── utils/        # 工具函数
│   └── config/       # 配置文件
└── tests/            # 测试文件
```

## 许可证

MIT License

## 作者

潘孝军

## 更新日志

### v1.0.0 (2026-03-10)
- 初始版本发布
- 宝通科技股票监控
- 飞书实时提醒
- 智能频率控制

---

**如有问题，请提交GitHub Issue或联系作者。**