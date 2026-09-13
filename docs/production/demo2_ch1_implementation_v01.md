---
tags:
  - project
  - production
  - implementation
  - demo2
  - dsh-desktop
  - godot
type: implementation-handoff
status: ready-for-integration
created: 2026-09-13
updated: 2026-09-13
---

# Demo2 第一章实现交接规格 v0.1.1

**接收方：DSH Desktop**  
**内容负责人：Codex**  
**接口修订：** v0.1.1，已与状态/内容 JSON 的 14 个场景 ID 对齐  
**目标运行时：Godot 4.x + GDScript，Web 导出优先**  
**范围：第一章《南宋意难平》20 至 30 分钟垂直切片**

## 1. 接入边界

Demo2 必须使用独立目录或独立 Godot 场景，不能覆盖 `/Users/mac/Downloads/比赛用/第一章Demo/` 中的 Demo1。Demo1 只作为参考和稳定样片保留。

运行时采用“内容数据驱动、状态与渲染分离”的结构：

- `ChapterState` 持有可保存的剧情状态；
- `ContentRepository` 读取 `data/ch1/*.json`；
- `SceneRouter` 根据 `scene_id` 切换场景；
- `DialogueController`、`ChoiceController`、`ClueController` 只消费内容和状态；
- 水墨背景、角色立绘、UI 由资源清单中的稳定 `resource_id` 装载；
- 文本较多的面板优先使用 Godot Control 节点，世界画面使用 Node2D/CanvasLayer。

不要把节点路径、图片文件名或 UI 文案硬编码为跨模块 API。跨 Agent 交接只认 `scene_id`、`node_id`、`resource_id`、`ui_slot`。

## 2. 场景图与流程

建议主场景：`res://scenes/ch1_demo2_root.tscn`

```text
Ch1Demo2Root (Node)
├── ChapterState (Node)
├── ContentRepository (Node)
├── SceneRouter (Node)
├── WorldLayer (Node2D)
│   ├── Background (Sprite2D/TextureRect)
│   ├── Midground (Node2D)
│   └── CharacterLayer (Node2D)
├── UILayer (CanvasLayer)
│   ├── TopBar [ui_slot: top_bar]
│   ├── SceneTitle [ui_slot: scene_title]
│   ├── DialoguePanel [ui_slot: dialogue_panel]
│   ├── CluePanel [ui_slot: clue_panel]
│   ├── ShanPanel [ui_slot: shan_panel]
│   ├── ChoicePanel [ui_slot: choice_panel]
│   ├── TimelineRibbon [ui_slot: timeline_ribbon]
│   └── Toast [ui_slot: toast]
└── DebugOverlay (Control, hidden by default)
```

流程场景固定如下。实现可以将多个场景合并为一个场景，但 `scene_id` 不得改名：

| 顺序 | `scene_id` | 年份 | 作用 | 必须出口 |
|---:|---|---:|---|---|
| 1 | `s01_modern_article` | 现代 | 未读完的知乎文章入口 | `s02_baby_home` |
| 2 | `s02_baby_home` | 1122 | 玩家穿越成两岁婴儿；感官互动 | `s03_baby_liushanshan` |
| 3 | `s03_baby_liushanshan` | 1122 | 刘看山回答年份与岳飞结局 | `s04_growth_1127` |
| 4 | `s04_growth_1127` | 1127 | 靖康之变后南宋建立；确立章主题 | `s05_station` |
| 5 | `s05_station` | 1127 | 驿站调查：家书与路线起点 | `s06_ferry` |
| 6 | `s06_ferry` | 1132 | 渡口调查：迁徙者证言与征发文书 | `s07_military_town` |
| 7 | `s07_military_town` | 1138 | 军镇调查：军书与岳飞名号 | `s08_yuefei_countdown` |
| 8 | `s08_yuefei_countdown` | 1140 | 二十年倒计时与三类提问达成 | `s09_recall_chain` |
| 9 | `s09_recall_chain` | 1141 | 完成“来源→路线→接收者→执行能力”信息链 | `s10_intervention` |
| 10 | `s10_intervention` | 1141 | 选择行动并写入时间线结果 | `s11_outcome_router` |
| 11 | `s11_outcome_router` | 1142 | 进入岳飞未被召回、历史轨迹或真相结尾 | `s12_leave_or_continue` |
| 12 | `s12_leave_or_continue` | 1142 | 双选项：进入下一章或继续游戏 | `s13_exit_chapter` 或 `s14_xinqiji_intro` |
| 13 | `s13_exit_chapter` | 1142 | 记录离开选择并结束本章 | `chapter_complete` |
| 14 | `s14_xinqiji_intro` | 1161 | 辛弃疾相遇、一次具体帮助、一个新问题 | `chapter_complete` |

1142 的结点不直接表现残酷场面。`ending_divergent`（偏离但未改写）不是无代价好结局，必须出现军政压力、补给或命令冲突中的至少一项。

## 3. JSON 加载契约

### 3.1 文件位置

```text
res://data/ch1/demo2_ch1_state_v01.json
res://data/ch1/demo2_ch1_content_v01.json
res://data/ch1/demo2_ch1_manifest_v01.json
```

若文件尚未生成，DSH Desktop 可先建立同名空壳并在启动时显示缺失文件错误；不要把临时文本写入脚本。

### 3.2 内容 JSON 最小结构

```json
{
  "schema": "zhihu-hackathon.ch1.content",
  "version": "0.1.0",
  "chapter_id": "ch1_southern_song_unresolved",
  "start_scene": "s01_modern_article",
  "scenes": [
    {
      "scene_id": "s02_baby_home",
      "year": 1122,
      "background_resource_id": "BG_INK_BABY_HOME_1122",
      "nodes": [
        {
          "node_id": "n01_shan_year_answer",
          "type": "dialogue",
          "speaker_id": "shan",
          "text": "你所在的起点是1122年，北宋末年。岳飞约在1142年离世。",
          "next": "n01_after_shan"
        }
      ]
    }
  ]
}
```

节点 `type` 至少支持：`dialogue`、`inspect`、`ask_shan`、`choice`、`timeline`、`ending`、`scene_transition`。

选择节点格式：

```json
{
  "node_id": "n06_branch_choice",
  "type": "choice",
  "choices": [
    {
      "choice_id": "choice_warn_yuefei",
      "label": "把预警交给传令者",
      "conditions": {"all": ["evidence.source", "evidence.route", "evidence.recipient", "evidence.executor"]},
      "effects": ["set:branch=intervene", "set:message_delivered=true"],
      "next": "s11_outcome_router"
    },
    {
      "choice_id": "choice_keep_witness",
      "label": "保存证言，承认自己没有做到",
      "effects": ["set:branch=witness"],
      "next": "s11_outcome_router"
    }
  ]
}
```

### 3.3 状态 JSON 契约

状态文件描述默认值、条件表达式和调试标签，不保存渲染节点：

```json
{
  "schema": "zhihu-hackathon.ch1.state",
  "version": "0.1.0",
  "defaults": {
    "current_scene": "s01_modern_article",
    "current_node": "n00_article_prompt",
    "year": 2026,
    "player_age": 20,
    "evidence": [],
    "trust_commoners": 0,
    "shan_asked_count": 0,
    "message_chain": {"source": false, "route": false, "recipient": false, "executor": false},
    "branch": null,
    "ending_choice": null,
    "xinqiji_entry_seen": false
  },
  "flags": [
    "article_read", "shan_year_answered", "letter_checked", "order_checked", "map_checked",
    "commoner_trust_gained", "message_delivered", "branch_intervene", "branch_witness", "next_chapter_selected",
    "xinqiji_helped"
  ]
}
```

条件解析至少支持：布尔 flag、点号路径、`all`、`any`、`not`、数值比较（`gte`/`lt`）。效果至少支持：`set:path=value`、`add:path=value`、`push:evidence=id`、`advance_year=value`、`goto:scene_id`。

状态保存点放在：开始文章后、三条核心线索集齐后、1141 分支选择后、`s12_leave_or_continue` 选择后。保存格式为 JSON，默认写入浏览器 `user://ch1_demo2_save.json`；Web 导出若不可写，继续使用内存状态完成流程。

## 4. UI 槽位与交互约定

| `ui_slot` | 责任 | 必须显示 | 交互事件 |
|---|---|---|---|
| `top_bar` | 章节与年份 | 章节名、当前年份、进度 `01/12` | 无 |
| `scene_title` | 场景标题 | 标题、地点或时间副标题 | 无 |
| `dialogue_panel` | 叙事与对白 | speaker 名、正文、继续按钮 | `dialogue_advance` |
| `clue_panel` | 调查反馈 | 已收集线索、未确认信息 | `clue_inspect` |
| `shan_panel` | 刘看山问答 | 输入框、历史消息、离线状态提示 | `shan_ask`、`shan_close` |
| `choice_panel` | 关键选择 | 选项标签、后果提示 | `choice_select` |
| `timeline_ribbon` | 时间线认知 | 1122、1127、1141、1142、1161 节点 | `timeline_focus` |
| `toast` | 短反馈 | 调查成功、状态变化、错误 | 自动消失 |

梁博森的美术资源按槽位填充；缺失资源时使用低对比度灰宣纸占位，不得阻塞流程。移动端和窄窗口下，`dialogue_panel`、`choice_panel`、`shan_panel` 必须保持可读，按钮最小点击区域 44×44 px。

## 5. 资源 ID 约定

资源文件名可以变化，运行时只读取 manifest 中的 `resource_id`：

| 前缀 | 示例 `resource_id` | 用途 |
|---|---|---|
| `BG_` | `BG_INK_BABY_HOME_1122` | 水墨背景、时间节点画面 |
| `CHAR_` | `CHAR_YUEFEI_BACK` | 角色背影或立绘 |
| `PROP_` | `PROP_LETTER_UNSENT` | 家书、军书、路线图等线索 |
| `UI_` | `UI_SEAL_TIMELINE` | 印章、时间线、按钮、面板装饰 |
| `FX_` | `FX_RED_INK_SPREAD` | 朱砂扩散、转场、纸张纹理 |
| `AUD_` | `AUD_PAPER_WIND_01` | 环境声、古琴/箫、提示音 |

manifest 条目至少包含：`resource_id`、`kind`、`path`、`fallback_path`、`owner`、`status`。推荐首批资源 ID：

```text
BG_MODERN_ROOM_ARTICLE
BG_INK_BABY_HOME_1122
BG_INK_MIGRATION_MONTAGE
BG_INK_SOUTHERN_SONG_1127
BG_INK_POST_STATION
BG_INK_RECALL_1141
BG_INK_EMPTY_CAMP_1142
BG_INK_XINQiji_1161
CHAR_LIUSHAN_WHITE
CHAR_CAREGIVER_SILHOUETTE
CHAR_OLD_POSTMAN
CHAR_MIGRANT_WITNESS
CHAR_YUEFEI_BACK
CHAR_XINQiji_YOUNG
PROP_LETTER_UNSENT
PROP_MILITARY_ORDER
PROP_WET_ROUTE_MAP
PROP_RECALL_EDICT
UI_SEAL_TIMELINE
UI_INK_DIALOGUE_FRAME
FX_RED_INK_SPREAD
AUD_PAPER_WIND_01
AUD_INK_STAMP_01
```

## 6. 状态钩子与事件名

所有系统通过事件总线或信号通信。最低实现集合：

```text
chapter_loaded(chapter_id)
scene_entered(scene_id, year)
node_entered(scene_id, node_id)
dialogue_advanced(node_id)
shan_asked(question, answer_source)
clue_inspected(clue_id)
trust_changed(amount, reason)
message_chain_updated(part)
choice_presented(node_id, choice_ids)
choice_selected(choice_id)
branch_resolved(branch_id)

路由优先级：当 `truth_ready` 与 `divergent_ready` 同时满足时，先按玩家在 `s10_intervention` 写入的 `branch` 判定：`witness` 优先进入 `ending_truth`，`intervene` 优先进入 `ending_divergent`；没有明确分支时回退 `ending_canonical`。不要依赖 JSON 数组顺序决定结局。
save_requested(slot_id)
chapter_completed(result_id)
```

调试模式（URL `?debug=1` 或 Godot `--debug-ch1`）显示当前 `scene_id`、`node_id`、`branch`、线索集合和信任值，并允许跳转到任意场景。调试入口不得出现在默认演示 UI。

## 7. 刘看山适配层

第一章必须离线可通关。`ShanAnswerProvider` 接口建议为：

```text
ask(question: String, context: Dictionary) -> {text, source, confidence}
```

默认 `LocalAnswerProvider` 读取本地问答库；联网适配器可选，失败时回落本地。回答保持“事实 → 背景 → 反问”结构，不直接替玩家选择。回答首次必须明确：1122 为北宋末年、南宋 1127 年建立、岳飞约 1142 年离世。

## 8. 构建与运行步骤

1. DSH Desktop 新建或复制 Demo2 独立 Godot 4.x 工程，保留 Demo1 原目录不动。
2. 建立 `scenes/`、`scripts/`、`data/ch1/`、`assets/`、`build/` 目录。
3. 将三份 JSON 放入 `res://data/ch1/`，在启动场景加载前做 schema/version 校验。
4. 设置主场景为 `res://scenes/ch1_demo2_root.tscn`，运行项目，默认进入 `s01_modern_article`。
5. 编辑器运行：`godot --path <demo2-project> --editor`。
6. 本地桌面运行：`godot --path <demo2-project> --path .`（或使用编辑器 F6/F5；以实际 Godot CLI 为准）。
7. Web 导出：配置名为 `Web` 的导出预设后执行：

   ```bash
   godot --headless --path <demo2-project> --export-release "Web" build/web/index.html
   python3 -m http.server 4173 --directory build/web
   ```

8. 每次构建记录 commit/日期、引擎版本、JSON 版本和资源缺失项；输出包与 Demo1 分目录保存。

## 9. 验收清单

- [ ] Demo1 `/Users/mac/Downloads/比赛用/第一章Demo/` 文件未被修改。
- [ ] 可以从现代知乎文章入口开始并进入 1122 年两岁婴儿视角。
- [ ] 刘看山明确说出“岳飞约在 1142 年离世”，玩家能理解二十年倒计时。
- [ ] 1122、1127、1141、1142、1161 五个时间点在 UI 或叙事中可识别。
- [ ] 至少收集家书、军书、路线图 3 条核心线索，并完成至少 1 次普通人信任变化。
- [ ] 玩家至少可以有效提问 3 次；联网失败时仍能离线继续。
- [ ] 1141 信息链必须检查来源、路线、接收者、执行能力四部分。
- [ ] “岳飞未被召回/召回延迟”分支可达，且显示新的军政压力。
- [ ] “玩家没有做到，历史轨迹继续”分支可达，显示证言和未完成问题。
- [ ] 1142 结点使用空营、封存信或未寄家书等间接表现，不出现残酷画面。
- [ ] `s12_leave_or_continue` 的“直接进入下一章”和“继续游戏”都可点击并记录状态。
- [ ] 继续游戏进入 1161 年辛弃疾入口，完成相遇、一次帮助和一个新问题。
- [ ] 刷新或重新运行后，若浏览器支持 `user://`，可恢复至少四个保存点之一。
- [ ] 窄窗口下对白、选项、刘看山面板可读且按钮可点击。
- [ ] 调试信息默认隐藏，打开 debug 开关后能看到状态与场景 ID。

## 10. 交接输出

DSH Desktop 完成接入后回填以下信息到开发日志和本文件末尾：

```text
构建目录：
Godot 版本：
内容 JSON 版本：
可运行入口：
已接入资源 ID：
缺失资源 ID：
未通过的验收项：
需要王凯决定的事项：
```

本规格只约束实现接口和验收行为。水墨画面、角色造型和 UI 视觉由梁博森主导；剧情文本与分支由 Codex 维护，Marvis 审校后再冻结。

## 关联

- [[10-projects/知乎黑客松游戏项目/制作包/00_第一章垂直切片冻结表]]
- [[10-projects/知乎黑客松游戏项目/协作启动说明_给所有Agent]]
- [[10-projects/知乎黑客松游戏项目/产出物/第一章南宋意难平Demo2设定方案]]
- [[10-projects/知乎黑客松游戏项目/制作包/README]]
