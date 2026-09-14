---
tags:
  - project
  - production
  - audio
  - logic-pro
  - demo2
  - zhihu-hackathon
type: audio-asset-brief
status: ready-for-production
version: v0.1
created: 2026-09-14
updated: 2026-09-14
---

# Demo2 第一章音频交付单 v0.1

这份清单给 Logic Pro 制作使用。目标是让《南宋意难平》有完整的水墨氛围和交互反馈，同时控制两天工期。对白暂不配音，玩家看到文字、听环境和反馈音即可。

## 先做这些：P0 最小音频包

| # | resource_id | 建议文件名 | 类型 | 用途/场景 | Logic Pro 交付要求 |
|---:|---|---|---|---|---|
| 1 | `AUD_BGM_INK_MAIN_01` | `demo2_ch1_audio_AUD_BGM_INK_MAIN_01_v01.wav` | BGM 循环 | s04 成长蒙太奇、s05 驿站、s06 渡口、s07 军镇的主探索音乐 | 60—90 秒无缝循环；68—76 BPM；稀疏古琴/箫/弦音；不要持续鼓点 |
| 2 | `AUD_BGM_RECALL_TENSION_01` | `demo2_ch1_audio_AUD_BGM_RECALL_TENSION_01_v01.wav` | BGM 循环 | s08 倒计时、s09 召回链、s10 介入选择 | 45—60 秒无缝循环；低频持续音加极少打击；紧张但克制，不能做成战斗音乐 |
| 3 | `AUD_BGM_ENDING_QUIET_01` | `demo2_ch1_audio_AUD_BGM_ENDING_QUIET_01_v01.wav` | BGM 循环 | s11 结局、s12 离开/继续、s13 收束 | 45—60 秒无缝循环；留白、低密度；适合空营和未寄家书 |
| 4 | `AUD_AMB_INDOOR_PAPER_01` | `demo2_ch1_audio_AUD_AMB_INDOOR_PAPER_01_v01.wav` | 环境循环 | s02 婴儿屋、s05 驿站 | 20—30 秒无缝循环；屋内呼吸、窗纸风、远处极轻马蹄、纸张摩擦；不要明显旋律 |
| 5 | `AUD_AMB_FERRY_MIST_01` | `demo2_ch1_audio_AUD_AMB_FERRY_MIST_01_v01.wav` | 环境循环 | s06 渡口 | 20—30 秒无缝循环；水流、船木轻响、绳索受力、薄雾风；水声不能盖对白 |
| 6 | `AUD_AMB_MILITARY_TOWN_01` | `demo2_ch1_audio_AUD_AMB_MILITARY_TOWN_01_v01.wav` | 环境循环 | s07 军镇、s08 倒计时 | 20—30 秒无缝循环；旗面、木栅、粮车、远处马匹呼吸和人声模糊层；不出现可辨台词 |
| 7 | `AUD_SFX_PAPER_TURN_01` | `demo2_ch1_audio_AUD_SFX_PAPER_TURN_01_v01.wav` | 一次性 SFX | s01 文章进入、s03 年份出现、s13 纸页合拢 | 0.8—1.2 秒；纸张翻页与宣纸摩擦，尾部干净 |
| 8 | `AUD_SFX_INK_STAMP_01` | `demo2_ch1_audio_AUD_SFX_INK_STAMP_01_v01.wav` | 一次性 SFX | s03 时间线节点、s06 文书印记、s08/s09 关键确认 | 1—2 秒；木/石印落纸与墨水扩散；提供一个正常版即可 |
| 9 | `AUD_SFX_UI_CLICK_INK` | `demo2_ch1_audio_AUD_SFX_UI_CLICK_INK_v01.wav` | UI SFX | 所有按钮、调查对象、刘看山提问 | 0.15—0.3 秒；同一音色做轻/中/重 3 个变体；保留现有 resource_id 兼容名 |
| 10 | `AUD_SFX_CLUE_PICKUP_01` | `demo2_ch1_audio_AUD_SFX_CLUE_PICKUP_01_v01.wav` | 一次性 SFX | 拾取家书、军书、路线图、证言 | 0.5—0.9 秒；纸张展开加一颗很轻的木/玉质点音；不能像奖励箱 |
| 11 | `AUD_SFX_CLUE_VERIFY_01` | `demo2_ch1_audio_AUD_SFX_CLUE_VERIFY_01_v01.wav` | 一次性 SFX | 刘看山验证成功、线索从“待验证”变“已验证” | 0.8—1.3 秒；轻印记、短泛音、低调确认感 |
| 12 | `AUD_SFX_TIMELINE_TICK_01` | `demo2_ch1_audio_AUD_SFX_TIMELINE_TICK_01_v01.wav` | 一次性 SFX | 1122、1127、1141、1142、1161 节点聚焦 | 0.4—0.7 秒；木签/玉片轻敲，五个年份共用 |
| 13 | `AUD_SFX_TIMELINE_JUMP_01` | `demo2_ch1_audio_AUD_SFX_TIMELINE_JUMP_01_v01.wav` | 一次性 SFX | 婴儿手到少年手、1127 成长蒙太奇转场 | 1—1.5 秒；纸卷掠过加一层低风，不做科幻传送声 |
| 14 | `AUD_SFX_INK_SPREAD_01` | `demo2_ch1_audio_AUD_SFX_INK_SPREAD_01_v01.wav` | 一次性 SFX | s10 介入/见证分叉、朱砂扩散 | 1.2—2 秒；墨水在纸上扩散的湿声，结尾带轻微分叉感 |
| 15 | `AUD_SFX_ROUTE_CONNECT_01` | `demo2_ch1_audio_AUD_SFX_ROUTE_CONNECT_01_v01.wav` | 一次性 SFX | s09 来源、路线、接收者、执行能力槽位连通 | 0.5—0.8 秒；细线拉紧、纸面点亮；四次播放不能刺耳 |
| 16 | `AUD_SFX_UI_LOCKED_01` | `demo2_ch1_audio_AUD_SFX_UI_LOCKED_01_v01.wav` | 一次性 SFX | 缺线索/缺验证时点击锁定选项 | 0.25—0.45 秒；闷纸声或木片轻碰；不要用警报声 |

这 16 项完成后，游戏已经具备完整的听觉反馈：玩家知道自己在调查、拿到线索、验证成功、错过条件，并能感到 1141 分叉和 1142 留白。

## 有时间再做：P1 增强包

| resource_id | 建议文件名 | 用途 | 规格 |
|---|---|---|---|
| `AUD_BGM_XINQiji_ACTION_01` | `demo2_ch1_audio_AUD_BGM_XINQiji_ACTION_01_v01.wav` | s14 辛弃疾入口 | 45—60 秒循环；84—96 BPM；节奏更快，加入土红色“行动感”，不要变成热血战斗曲 |
| `AUD_SFX_HOOF_DISTANT_01` | `demo2_ch1_audio_AUD_SFX_HOOF_DISTANT_01_v01.wav` | s02 远马蹄、s14 入口 | 3—5 秒；远景、稀疏、带空间感；另留一个无混响干声版本更好 |
| `AUD_SFX_WATER_ROPE_01` | `demo2_ch1_audio_AUD_SFX_WATER_ROPE_01_v01.wav` | s06 渡口调查 | 3—5 秒；水拍船板、绳索摩擦、木船轻响，可随机播放 |
| `AUD_SFX_HORSE_BREATH_01` | `demo2_ch1_audio_AUD_SFX_HORSE_BREATH_01_v01.wav` | s07 岳飞背影、军镇 | 2—4 秒；近景但克制，不能盖对白 |
| `AUD_SFX_FLAG_WIND_01` | `demo2_ch1_audio_AUD_SFX_FLAG_WIND_01_v01.wav` | s07 军镇、s11 结局画面 | 3—5 秒；旗面抖动与空风，低存在感 |
| `AUD_SFX_DISTANT_BELL_01` | `demo2_ch1_audio_AUD_SFX_DISTANT_BELL_01_v01.wav` | s11 1142 空营 | 3—5 秒；远钟单响，长尾但不悲情煽情 |
| `AUD_SFX_PAPER_RUSTLE_01` | `demo2_ch1_audio_AUD_SFX_PAPER_RUSTLE_01_v01.wav` | 家书、军书、诏书特写 | 2—4 秒；多层纸张摩擦，供道具特写循环或随机播放 |
| `AUD_SFX_BRANCH_CONFIRM_01` | `demo2_ch1_audio_AUD_SFX_BRANCH_CONFIRM_01_v01.wav` | 结局分支确认 | 0.8—1.2 秒；比普通验证更深一层，但和墨扩散音色统一 |
| `AUD_SFX_SAVE_01` | `demo2_ch1_audio_AUD_SFX_SAVE_01_v01.wav` | 存档成功 | 0.5—0.8 秒；轻印章/纸面收束 |
| `AUD_SFX_LOAD_01` | `demo2_ch1_audio_AUD_SFX_LOAD_01_v01.wav` | 读档成功 | 0.5—0.8 秒；与存档区分，偏纸页展开 |

## Logic Pro 导出规范

1. Logic Pro 工程统一使用 **48 kHz / 24-bit**。每个资源导出一个干净的立体声 WAV 主文件；不要把整套 BGM 和环境声烙成一个长音轨。
2. BGM 和环境循环必须在头尾可无缝拼接，循环点不要带长混响尾。若需要尾音，另导出 `*_tail_v01.wav`，由 DSH 在转场时播放。
3. 一次性 SFX 保留 100—300 ms 的自然尾巴；不要把静音留到 2 秒以上。
4. 混音峰值建议不超过 **-1 dBTP**。BGM/环境比对白低一层，先按 BGM 约 -18 LUFS、环境约 -24 LUFS、UI/SFX 约 -14 至 -10 LUFS 作为起点，DSH 接入后再统一调音。
5. 运行时版本由 DSH 转为 OGG Vorbis；Logic Pro 只需交 WAV。若要自己预览，可额外导出 OGG，但不要用 MP3 作为母版。
6. 文件名必须包含 `resource_id` 和版本号；不要交“渡口音效最终版.wav”这种无法登记的名称。

## 场景使用映射

| 场景 | 背景音乐/环境 | 关键一次性音效 |
|---|---|---|
| s01 现代文章 | 暂用无 BGM；可用极轻室内底噪 | `AUD_SFX_PAPER_TURN_01`、`AUD_SFX_UI_CLICK_INK` |
| s02 婴儿屋 | `AUD_AMB_INDOOR_PAPER_01` | `AUD_SFX_TIMELINE_TICK_01`、P1 `AUD_SFX_HOOF_DISTANT_01` |
| s03 刘看山 | `AUD_AMB_INDOOR_PAPER_01` | `AUD_SFX_PAPER_TURN_01`、`AUD_SFX_INK_STAMP_01` |
| s04 成长蒙太奇 | `AUD_BGM_INK_MAIN_01` | `AUD_SFX_TIMELINE_JUMP_01` |
| s05 驿站 | `AUD_BGM_INK_MAIN_01` + `AUD_AMB_INDOOR_PAPER_01` | `AUD_SFX_CLUE_PICKUP_01`、`AUD_SFX_ROUTE_CONNECT_01` |
| s06 渡口 | `AUD_BGM_INK_MAIN_01` + `AUD_AMB_FERRY_MIST_01` | `AUD_SFX_CLUE_PICKUP_01`、`AUD_SFX_INK_STAMP_01` |
| s07 军镇 | `AUD_BGM_INK_MAIN_01` + `AUD_AMB_MILITARY_TOWN_01` | `AUD_SFX_CLUE_PICKUP_01`、P1 `AUD_SFX_HORSE_BREATH_01` |
| s08 倒计时 | `AUD_BGM_RECALL_TENSION_01` + `AUD_AMB_MILITARY_TOWN_01` | `AUD_SFX_TIMELINE_TICK_01`、`AUD_SFX_ROUTE_CONNECT_01` |
| s09 召回链 | `AUD_BGM_RECALL_TENSION_01` | `AUD_SFX_ROUTE_CONNECT_01`、`AUD_SFX_INK_STAMP_01` |
| s10 介入 | `AUD_BGM_RECALL_TENSION_01` | `AUD_SFX_INK_SPREAD_01`、P1 `AUD_SFX_BRANCH_CONFIRM_01` |
| s11 结局 | `AUD_BGM_ENDING_QUIET_01` + `AUD_AMB_MILITARY_TOWN_01` | P1 `AUD_SFX_DISTANT_BELL_01` |
| s12—s13 收束 | `AUD_BGM_ENDING_QUIET_01` | `AUD_SFX_PAPER_TURN_01`、`AUD_SFX_INK_STAMP_01` |
| s14 辛弃疾 | P1 `AUD_BGM_XINQiji_ACTION_01` | P1 `AUD_SFX_HOOF_DISTANT_01`、`AUD_SFX_WATER_ROPE_01` |

## 不需要制作的东西

- 不需要给每句对白配音。
- 不需要为四类线索各做一套完全不同的拾取声；同一套音色配合音量/音高轻微变化即可。
- 不需要做复杂战斗音效，第一章没有战斗玩法。
- 不需要做长篇影视化配乐；短循环、可淡入淡出、能服务调查反馈更重要。

## 交付目录

```text
godot/demo2/assets/audio/
├── bgm/
├── ambience/
├── sfx/
└── source_logic/
```

Logic Pro 工程和可编辑源文件放 `source_logic/`；运行时 WAV 母版暂放对应分类目录，DSH 接收后转 OGG 并登记 manifest。
