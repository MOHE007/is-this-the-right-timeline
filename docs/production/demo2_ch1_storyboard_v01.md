---
tags:
  - project
  - production
  - storyboard
  - demo2
  - zhihu-hackathon
type: storyboard
status: ready-for-art
version: v0.1
created: 2026-09-13
updated: 2026-09-13
---

# Demo2 第一章分镜表 v0.1

## 使用规则

- 目标画幅 1920×1080，水墨长卷感，镜头以静止构图、横向平移和纸面转场为主。
- 对话框默认占底部 25%，重要角色脸部、道具和时间线节点不得放入该区域。
- `scene_id`、`shot_id` 是运行时与美术交接的稳定编号；改文案不改编号。
- 朱砂只用于 1141 诏书封泥、时间线分叉和确认反馈。

## 分镜总表

| scene_id | shot_id | 时长 | 景别/运动 | 画面与动作 | UI/声音 | 美术交付 |
|---|---|---:|---|---|---|---|
| `s01_modern_article` | `sh01_01` | 8s | 近景，静止 | 宿舍桌面、屏幕文章停在 72%，光从屏幕溢出 | 文章标题、阅读进度；键盘与室内底噪 | `BG_MODERN_ROOM_ARTICLE` |
| `s01_modern_article` | `sh01_02` | 10s | 特写，慢推 | 问题文字浮起：“你会回去改变它吗？” | 文字浮现音；选择按钮出现 | `UI_CHOICE_BUTTON` |
| `s01_modern_article` | `sh01_03` | 6s | 叠化 | 屏幕白光转宣纸纹理，进入历史 | 纸张翻页声 | `FX_PAPER_GRAIN_OVERLAY` |
| `s02_baby_home` | `sh02_01` | 12s | 低机位，静止 | 屋梁压低，衣料和手指掠过前景 | 抚养者对白；屋内呼吸声 | `BG_INK_BABY_HOME_1122`、`CHAR_CAREGIVER_SILHOUETTE` |
| `s02_baby_home` | `sh02_02` | 8s | 特写，轻移 | 木盆、旧铜钱、门缝的光依次出现 | 点击热点；铜钱轻响 | `PROP_LETTER_UNSENT`（可替换为铜钱占位） |
| `s02_baby_home` | `sh02_03` | 10s | 远景，声先画后 | 远方马蹄，窗纸微动，画面留白 | 马蹄声渐近；刘看山低声提示 | `AUD_PAPER_WIND_01` |
| `s03_baby_liushanshan` | `sh03_01` | 8s | 中近景，纸面显现 | 刘看山从纸面墨痕中浮出 | 问答面板开启 | `CHAR_LIUSHAN_WHITE` |
| `s03_baby_liushanshan` | `sh03_02` | 12s | 特写，定格 | “1122”“1142”两个年份落在纸上，间隔拉开 | 时间线初次显示；印章轻响 | `UI_SEAL_TIMELINE`、`AUD_INK_STAMP_01` |
| `s03_baby_liushanshan` | `sh03_03` | 6s | 横向拉卷 | 婴儿手指叠化为少年手掌 | 年份跳转音 | `FX_RED_INK_SPREAD`（低强度） |
| `s04_growth_1127` | `sh04_01` | 15s | 横向长卷 | 山路、队伍、渡口、行囊按远中近三层移动 | 蒙太奇 BGM；年份字幕 | `BG_INK_MIGRATION_MONTAGE` |
| `s04_growth_1127` | `sh04_02` | 10s | 中景，平移 | 少年读字、搬运、看向南方 | 旁白；时间线推进至 1127 | `BG_INK_SOUTHERN_SONG_1127` |
| `s05_station` | `sh05_01` | 10s | 中景，静止 | 驿桌中央家书，老驿卒从右侧入画 | 驿灯与纸张声 | `BG_INK_POST_STATION`、`CHAR_OLD_POSTMAN` |
| `s05_station` | `sh05_02` | 8s | 道具特写 | 家书折痕、封泥和三日延误信息 | 线索卡弹出 | `PROP_LETTER_UNSENT`、`UI_CLUE_CARD_FRAME` |
| `s05_station` | `sh05_03` | 8s | 侧面双人 | 玩家询问路线，老驿卒递出旧图 | 刘看山回答档按钮；轻提示音 | `PROP_WET_ROUTE_MAP` |
| `s06_ferry` | `sh06_01` | 12s | 远中景，慢移 | 雾中渡船、迁徙者和行囊，绳索在前景 | 水声、风声；对白框 | `BG_INK_FERRY_MIST`、`CHAR_MIGRANT_WITNESS` |
| `s06_ferry` | `sh06_02` | 8s | 特写 | 征发文书背面转运印，墨迹被水晕开 | 线索卡；印章音 | `PROP_MILITARY_ORDER` |
| `s06_ferry` | `sh06_03` | 8s | 中近景 | 迁徙者回望抱着孩子，玩家选择保存证言 | “证言已保存”短 toast | `UI_TOAST_STAMP` |
| `s07_military_town` | `sh07_01` | 12s | 中景，横移 | 军旗、粮车、木栅栏，军中同伴在桌旁 | 军营环境声 | `BG_INK_MILITARY_TOWN` |
| `s07_military_town` | `sh07_02` | 8s | 道具特写 | 军书出现“调回”“待命”字样，缺页露出 | 线索卡；纸页声 | `PROP_MILITARY_ORDER` |
| `s07_military_town` | `sh07_03` | 8s | 背影中景 | 岳飞只以背影停在远处军帐前，不做正面英雄特写 | BGM 降低；马匹呼吸 | `CHAR_YUEFEI_BACK` |
| `s08_yuefei_countdown` | `sh08_01` | 10s | 俯视，定格 | 四类线索摊在桌上，线条连成消息链 | 证据计数、提问计数 | `UI_CLUE_CARD_FRAME` |
| `s08_yuefei_countdown` | `sh08_02` | 8s | 特写，慢推 | “1141”朱砂节点亮起，倒计时剩 1 年 | 时间线聚焦 | `UI_SEAL_TIMELINE` |
| `s09_recall_chain` | `sh09_01` | 12s | 中景，静止 | 文书房与驿路叠化，诏书置于中央 | 任务提示四步链 | `BG_INK_RECALL_1141`、`PROP_RECALL_EDICT` |
| `s09_recall_chain` | `sh09_02` | 15s | 俯视，拖拽 | 来源、路线、接收者、执行能力四槽位依次点亮 | 拖拽音；缺口提示 | `UI_INK_DIALOGUE_FRAME` |
| `s10_intervention` | `sh10_01` | 10s | 双人中景 | 玩家与军中同伴对话，决定消息交给谁 | 选项按钮两到三项 | `UI_CHOICE_BUTTON` |
| `s10_intervention` | `sh10_02` | 8s | 特写 | 诏书封泥朱砂扩散，按选择向不同方向流动 | 分叉音效；`FX_RED_INK_SPREAD` | `FX_RED_INK_SPREAD` |
| `s11_outcome_router` | `sh11_01` | 15s | 远景，静止 | 时间线分叉：一侧军旗未落，另一侧空营 | 分支标题和后果摘要 | `BG_INK_EMPTY_CAMP_1142` |
| `s11_outcome_router` | `sh11_02` | 12s | 道具特写 | 封存的信、未寄家书、粮道标记或冲突批注 | 结局卡；低频钟声 | `PROP_LETTER_UNSENT` |
| `s12_leave_or_continue` | `sh12_01` | 10s | 正面中景 | 刘看山回到纸面边缘，提出“离开还是继续” | 两个大按钮 | `CHAR_LIUSHAN_WHITE`、`UI_CHOICE_BUTTON` |
| `s13_exit_chapter` | `sh13_01` | 12s | 空镜，慢拉远 | 纸页合拢，保留玩家留下的证言印记 | 下一章提示；收尾句 | `FX_PAPER_GRAIN_OVERLAY` |
| `s14_xinqiji_intro` | `sh14_01` | 12s | 中景，快速推近 | 1161，年轻辛弃疾在土红墨线中转身 | 节奏变快；马蹄与脚步 | `BG_INK_XINQiji_1161`、`CHAR_XINQiji_YOUNG` |
| `s14_xinqiji_intro` | `sh14_02` | 12s | 侧面双人 | 玩家帮他确认芦苇湾路线，名单写入纸上 | 帮助完成 toast；新问题出现 | `PROP_WET_ROUTE_MAP`、`UI_TOAST_STAMP` |

## 镜头与 UI 交接规则

- 所有背景图底部 25% 保持低信息密度，供 `dialogue_panel` 和 `choice_panel` 使用。
- 角色默认站位：玩家/叙事主体左中，NPC 右中；刘看山可在左上或纸面边缘浮现。
- 线索道具必须提供单独透明图层，方便点击热点和线索卡缩略图复用。
- 关键转场统一使用纸张翻页、墨迹扩散、横向长卷三类动效，避免额外制作复杂粒子。
- 移动端或窄窗口裁切时，优先保留角色动作和道具中心，允许牺牲两侧远景。

## P0 镜头交付

若时间不足，先交 `sh01_01`、`sh02_01`、`sh03_01`、`sh05_01`、`sh07_01`、`sh09_01`、`sh11_01`、`sh14_01` 八个关键镜头对应背景/角色素材，其余镜头用平移、淡入淡出和占位图完成。

## 关联

- [[10-projects/知乎黑客松游戏项目/制作包/demo2_ch1_script_v01]]
- [[10-projects/知乎黑客松游戏项目/制作包/demo2_ch1_asset_brief_v01]]
- [[10-projects/知乎黑客松游戏项目/制作包/demo2_ch1_implementation_v01]]
