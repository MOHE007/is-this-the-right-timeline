# Demo2 第一章探索改版 v0.2：开工框架

这次改版的目标是把第一章从“阅读节点串联”升级为“玩家主动调查、拾取、提问、验证，再决定是否介入”。所有任务都围绕同一份状态契约推进，避免剧本、代码和美术各自发散。

## 先冻结的共同规则

1. 三个调查地点：驿站、渡口、军镇。
2. 四类物证：家书、军书、路线图、普通人证言。
3. 三层证据：物证 → 行动资格 → 刘看山验证。
4. 漏线索不 Game Over；玩家仍能走历史轨迹或普通收束。
5. 特殊结局依赖玩家实际行为，不能由默认点击直接获得。
6. Demo1 保持不动；所有新改动只进入 Demo2 v0.2。

## 工作包总表

| 工作包 | 主要改动 | 交付物 | 前置依赖 | 验收人 |
| --- | --- | --- | --- | --- |
| A. 规则与状态 | 增加物证、碎片、验证、行动资格和失败原因字段 | `state_v02.json`、状态字段表 | 本文规则 | Codex + Marvis |
| B. 剧本与对白 | 把 s05/s06/s07 改成可调查节点；补刘看山“信息不足”和验证回答 | `script_v02.md`、`content_v02.json` | A 的字段名 | Codex + Marvis |
| C. 线索与分支 | 定义每件道具的拾取、验证、丢失后果和结局门槛 | `clues_v02.md`、结局矩阵 | A、B | Codex |
| D. Godot 运行时 | 调查对象按钮、拾取反馈、线索栏、刘看山能力消耗、条件路由 | `main.gd`、UI 场景、测试工具 | A、B、C | DSH Desktop |
| E. 刘看山问答 | 本地问答库、上下文匹配、无道具时信息不足、次数消耗 | `shan_answers_v02.json`、适配脚本 | A、B | DSH Desktop + Codex |
| F. 美术/UI | 调查对象高亮、拾取提示、已验证标记、线索卡状态 | 资源与 manifest 更新 | B、C 的 resource_id | 梁博森 |
| G. QA 与平衡 | 完整路线、漏道具路线、拿到未提问路线、窄窗口 | smoke test、QA 日志、时长记录 | A-F | DSH Desktop + Marvis |
| H. 发布与归档 | Web 导出、中文字体、README、Obsidian、Git 提交 | 构建包、截图、日志、版本记录 | G | 王凯最终验收 |

## 每个工作包要改什么

### A. 规则与状态

新增字段建议：

- `clues_found`：已拾取物证。
- `clue_fragments`：碎片线索，例如 `route_map_fragment`。
- `verified_clues`：经过刘看山验证的线索。
- `route_verified`：路线是否被解释为可执行路线。
- `recall_recipient_token`：是否拿到传令牌。
- `recall_recipient_found`：是否确认可靠接收者。
- `shan_answer_recall`：是否理解召回信息链。
- `testimony_interpreted`：是否理解普通人证言的结构性意义。
- `missed_critical_clues`：漏掉的关键物品，用于反馈和结局说明。
- `shan_questions_left`：刘看山剩余验证次数。

规则：每个字段只由明确 effect 改写；UI 不直接修改状态；结局只读状态。

### B. 剧本与对白

现有 s05、s06、s07 不能只保留一个二选一按钮。每个调查地点至少拆成：

1. 进入场景。
2. 查看三个调查对象。
3. 拾取或记录一个对象。
4. 向刘看山提问或暂时离开。
5. 显示已获得、未验证、错过的状态。

每个地点至少提供一个“有收益但有代价”的选择，避免所有选项都等价。

### C. 线索与分支

每件线索必须有五列：

| 字段 | 说明 |
| --- | --- |
| `clue_id` | 运行时稳定 ID |
| `pickup_action` | 玩家如何发现或拾取 |
| `shan_requirement` | 刘看山验证所需条件 |
| `unlock_effect` | 验证后解锁什么 |
| `miss_consequence` | 没拿或没验证会失去什么 |

结局不要只判断“线索数量”。要判断具体的证据组合，例如 `military_order + route_verified + recall_recipient_found + shan_answer_recall`。

### D. Godot 运行时

运行时需要新增四个 UI 状态：

- 调查对象列表：每个对象显示“未查看 / 已查看 / 已拾取”。
- 线索栏：显示“已拾取 / 待验证 / 已验证”。
- 刘看山能力栏：显示剩余提问次数和可验证对象。
- 失败反馈：说明缺少什么，以及因此关闭哪条结局。

代码边界：

- `content_v02.json` 只描述剧情节点、调查对象和 effects。
- `state_v02.json` 只描述字段、条件和 effects 目录。
- `main.gd` 只负责加载、状态机、条件判断和 UI 事件。
- 美术资源通过 `resource_id` 和 manifest 接入，不改 scene_id。

### E. 刘看山问答

本地问答至少覆盖：年代识别、路线解析、召回链、执行者、普通人证言五类。

统一返回：

```json
{
  "status": "answered | insufficient | exhausted",
  "fact": "事实段",
  "context": "背景段",
  "counter_question": "反问段",
  "effects": ["verify_route"]
}
```

没有对应道具时返回 `insufficient`，提问机会仍然消耗，但不产生验证 effect。

### F. 美术/UI

不阻塞逻辑开工。先使用占位资源完成 UI 状态，再逐个替换：

- 调查对象按钮和 hover 状态。
- 道具拾取 toast。
- 线索卡“待验证 / 已验证”印章。
- 刘看山能力面板。
- 结局反馈印章。

梁博森只需遵循既有 `resource_id`、尺寸和 16:9 安全区，不需要等待全部剧本完成才开始。

### G. QA 与平衡

至少测试五条路径：

1. 完整验证 → `ending_truth`。
2. 军书与路线齐全但缺刘看山验证 → 不得进入 `ending_divergent`。
3. 漏掉传令牌 → 介入失败反馈，历史轨迹仍可达。
4. 不保存普通人证言 → 真相线关闭，canonical 仍可达。
5. 提问次数耗尽 → 刘看山返回 exhausted，游戏不死锁。

记录：总操作数、阅读时长、调查次数、提问次数、结局、漏掉的线索和玩家是否理解失败原因。

### H. 发布与归档

每次合并都同步四处：

- 仓库对应代码或 JSON。
- `docs/production/` 制作说明。
- Obsidian 制作包和项目进度。
- 开发日志与 Git commit。

Web 发布前必须确认 CJK 字体、资源缺失 fallback、窄窗口和离线问答。

## 推荐开工顺序

第一批并行：A 规则与状态、B 剧本节点、C 线索矩阵。三者完成后再冻结字段名。

第二批并行：D Godot UI、E 刘看山问答、F 占位 UI。它们共同消费第一批的字段和 effect。

第三批：G 五条 QA 路线和时长平衡。发现不可达或过短时，优先改内容数据，不直接在代码里写特例。

最后：H Web 导出、公开仓库、Obsidian 留痕和王凯验收。

## 当前可以马上动工的任务

- Codex：制作 `state_v02` 字段草案、`content_v02` 的 s05-s07 调查节点和线索矩阵。
- DSH Desktop：先实现调查按钮、拾取状态、线索栏和 effect 调试面板，使用占位资源。
- Marvis：审校五类刘看山回答与 1141 信息链的历史因果。
- 梁博森：按现有 manifest 继续制作三个风格锚点和调查对象 UI 状态。
- 王凯：只需确认“特殊结局必须依赖主动调查”这一总规则，其他字段可按本文推进。
