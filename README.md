<div align="center">

<img src="assets/promo-ink-timeline.png" alt="宋金对峙主题水墨宣传图" width="100%" />

# 《这真的是对的时间线吗？》

### *Is This Really the Right Timeline?*

**只要有问题，就有回答**

[![License](https://img.shields.io/badge/license-MIT-1f2937?style=for-the-badge)](LICENSE)
[![Zhihu Hackathon](https://img.shields.io/badge/zhihu--hackathon-2026-b33a32?style=for-the-badge)](https://www.zhihu.com/)
[![Status](https://img.shields.io/badge/status-active-2f855a?style=for-the-badge)](https://github.com/)
[![Stars](https://img.shields.io/github/stars/MOHE007/is-this-the-right-timeline?style=for-the-badge&logo=github)](https://github.com/MOHE007/is-this-the-right-timeline)

</div>

一个大四学生穿越进没读完的知乎文章世界，在 AI 向导刘看山的陪伴下，沿着三章历史切片追问：知道结局之后，我们真的能改变什么吗？

## 🎬 Demo 预览

<div align="center">
<img src="assets/demo1-preview.svg" alt="第一章 Demo 预览" width="92%" />
</div>

**15 分钟 · 文字线索 · 多结局**

👉 [在线体验 Demo1（GitHub Pages）](https://mohe007.github.io/is-this-the-right-timeline/)

## ✨ Features

- **问题驱动叙事**：每一次提问都会改变你理解历史的方式。
- **线索交叉验证**：家书、军令、路线图与普通人证言共同组成消息链。
- **三章三种玩法**：文字调查、横版动作、3D 探索逐章升级。
- **AI 向导三档帮助**：提醒、回答、救助；回答遵循「事实 → 背景 → 反问」。
- **离线可通关**：本地问答库保证 Demo 在没有联网增强时仍然完整可玩。
- **数据驱动内容**：人读 Markdown，运行时消费 JSON，叙事与引擎彼此独立。

## 🎮 三章玩法

| 章节 | 时间切片 | 核心玩法 | 玩家要回答的问题 |
| --- | --- | --- | --- |
| 第一章 · 靖康前夜 | 1122 → 1142 | 文字调查 / 线索拼图 | 知道结局，是否要介入？ |
| 第二章 · 戚家军 | 明代沿海 | 横版动作 / 队伍协作 | 纪律与保护，如何同时成立？ |
| 第三章 · 淞沪 | 1937 | 3D 探索 / 资源选择 | 记住一座城，需要留下什么？ |

## 🤖 AI 机制：刘看山三档帮助

| 档位 | 触发方式 | 输出 |
| --- | --- | --- |
| **提醒** | 玩家停留或线索缺口 | 指向下一条可调查对象，不直接给答案 |
| **回答** | 玩家主动提问 | 事实 → 背景 → 反问，帮助玩家建立自己的判断 |
| **救助** | 连续失败或卡关 | 给出最小必要提示，同时保留选择后果 |

联网增强通过 `ask(question, context)` 适配层接入；不可用时自动切换到离线本地问答库。

## 🚀 Quick Start

三步即可运行第一章：

```bash
git clone https://github.com/MOHE007/is-this-the-right-timeline.git
cd is-this-the-right-timeline/demo1
python3 -m http.server 4173
```

打开 <http://localhost:4173>，也可以直接双击 `demo1/index.html`。

## 📁 目录结构

```text
is-this-the-right-timeline/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── .github/workflows/deploy-pages.yml
├── demo1/                         # 第一章可运行浏览器 Demo
├── docs/                          # 策划、玩法与制作包 Markdown
│   └── production/                # 剧本 / 冻结表 / 实现规格 / 六问答复
├── data/ch1/                      # 运行时状态、内容与资源清单 JSON
├── assets/                        # 原创水墨素材与 Demo 预览图
└── godot/.gitkeep                 # Godot 4.x 工程预留
```

## 🛠 技术路线

- **目标引擎**：Godot 4.x + GDScript，最终导出 Web。
- **内容管线**：Markdown 服务编剧与审校；JSON 服务运行时加载、校验和状态机。
- **第一章契约**：14 个冻结 `scene_id`（`s01_modern_article` 至 `s14_xinqiji_intro`）。
- **状态系统**：状态变量、条件与效果描述调查进度、信任、介入倾向和结尾选择。
- **结局路由**：`ending_divergent`、`ending_canonical`、`ending_truth` 三种结局，经 `s11_outcome_router` 汇总后进入 `s12_leave_or_continue`。
- **AI 适配**：统一调用 `ask(question, context)`，离线问答库作为稳定兜底。

## 🗺 Roadmap

| 里程碑 | 状态 | 交付物 |
| --- | --- | --- |
| **M0 · 方向冻结** | ✅ 已达成 | 引擎路线、视觉方向、三章玩法框架 |
| **M1 · 第一章垂直切片** | 🔄 制作包 v0.1 进行中 | 剧本、状态/内容 JSON、实现规格；待分镜、角色卡、线索卡与 Godot 接入 |
| M2 · 第二章原型 | ⏳ 计划中 | 戚家军横版动作核心循环 |
| M3 · 第三章原型 | ⏳ 计划中 | 淞沪 3D 探索核心循环 |
| M4 · 三章串联 | ⏳ 计划中 | 选择与记忆跨章节传递 |
| M5 · Web 发布 | 🔄 Demo1 已上线 | GitHub Pages 公网体验 |
| M6 · 比赛验收 | ⏳ 计划中 | 可演示构建、素材清单与交接文档 |

## 👥 团队

**王凯**（导演） · **梁博森**（美术 / UI） · **Codex**（叙事 / 系统） · **Marvis**（审校） · **DSH Desktop**（整合）

## 📜 License & IP

代码与原创水墨素材采用 [MIT License](LICENSE)。刘看山形象版权归知乎，本项目仅在「知乎黑客松 2026」比赛期间使用；赛后如需商用或再分发，须另行取得授权。公开仓库不包含知乎官方素材包。

## 🥚 通关彩蛋

> 刚才打的那些不是游戏，都是你在知乎上没读完的问题。

<div align="center">如果你也在追问，欢迎带着自己的问题开一条分支。</div>
