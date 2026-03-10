# 🚀 Stock Monitor Feishu Skill

![GitHub](https://img.shields.io/github/license/Xiaojun-Pan/stock-monitor-feishu)
![GitHub last commit](https://img.shields.io/github/last-commit/Xiaojun-Pan/stock-monitor-feishu)
![GitHub repo size](https://img.shields.io/github/repo-size/Xiaojun-Pan/stock-monitor-feishu)
![OpenClaw Skill](https://img.shields.io/badge/OpenClaw-Skill-blue)

宝通科技股票监控技能 - 每分钟检测，飞书实时提醒，智能频率控制

## ✨ 功能特性

- ⚡ **实时监控**：每分钟检测宝通科技(300031)股价
- 📨 **飞书提醒**：通过当前飞书会话直接发送提醒
- 🧠 **智能控制**：避免重复提醒骚扰
- ⏰ **频率控制**：每日上限10次，间隔30分钟
- 🔒 **稳定运行**：自动守护，崩溃重启
- 📊 **完整日志**：所有操作详细记录

## 🚀 快速开始

### 安装使用

```bash
# 使用skillhub安装
skillhub install stock-monitor-feishu

# 或从GitHub安装
git clone https://github.com/Xiaojun-Pan/stock-monitor-feishu.git
cd stock-monitor-feishu
bash scripts/start_monitor.sh
```

### 查看状态

```bash
bash scripts/check_status.sh
```

## 📊 监控配置

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| 股票代码 | sz300031 | 宝通科技 |
| 上涨阈值 | +2.0% | 触发上涨提醒 |
| 下跌阈值 | -2.0% | 触发下跌提醒 |
| 检测频率 | 每分钟 | 股价检测频率 |
| 每日上限 | 10次 | 每个方向最多提醒 |
| 时间间隔 | 30分钟 | 同一方向最小间隔 |

## 🏗️ 系统架构

```
股价数据 → 智能检测 → 触发文件 → AI检查 → 飞书提醒
    ↓           ↓           ↓         ↓         ↓
腾讯财经API  频率控制   /tmp/stock_ai_alert_trigger.txt  当前会话
```

## 📁 文件结构

```
stock-monitor-feishu/
├── SKILL.md          # 技能文档
├── README.md         # 使用说明
├── package.json      # 配置
├── clawhub.yaml      # 发布配置
├── scripts/          # 脚本目录
│   ├── smart_detector.sh      # 智能检测
│   ├── ai_checker.sh          # AI检查
│   ├── start_monitor.sh       # 启动
│   ├── stop_monitor.sh        # 停止
│   ├── check_status.sh        # 状态
│   └── check_and_restart.sh   # 守护
└── examples/         # 示例文件
```

## 🔧 管理命令

```bash
# 启动监控
bash scripts/start_monitor.sh

# 停止监控
bash scripts/stop_monitor.sh

# 查看状态
bash scripts/check_status.sh

# 查看日志
tail -f /tmp/smart_stock_detect.log
tail -f /tmp/ai_monitor.log
```

## 📈 当前状态

监控系统已在以下服务器运行：
- **服务器**: VM-0-3-ubuntu
- **状态**: ✅ 运行中
- **股票**: 宝通科技(300031)
- **阈值**: ±2%
- **频率**: 每分钟检测

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📄 许可证

MIT License © 潘孝军

## 🔗 链接

- [GitHub仓库](https://github.com/Xiaojun-Pan/stock-monitor-feishu)
- [OpenClaw文档](https://docs.openclaw.ai)
- [问题反馈](https://github.com/Xiaojun-Pan/stock-monitor-feishu/issues)

---

**Made with ❤️ for 潘孝军的股票监控需求**
