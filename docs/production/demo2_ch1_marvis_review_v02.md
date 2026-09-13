---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: bf570042b9bab5ca445e13766da77718_9f6d2651af9911f18874525400287e28
    ReservedCode1: rBSLC+JcqKEnIJ63Eg40wrzn1XVkE/Do9G774VMcDYnl/3Qr6Dh8jIc9QFEH5fANaCNMWF5+PZWsV6trMJ1qWXEFxrWapy3ULdII7JkSfyRD7lAOcn94pEpWEu4g4AuMJmFUcYK5bSpLhNqeM2rrV8SroQ7r83ZWMmilJltDlqWJWQ9x9IkCHjwuQQ8=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: bf570042b9bab5ca445e13766da77718_9f6d2651af9911f18874525400287e28
    ReservedCode2: rBSLC+JcqKEnIJ63Eg40wrzn1XVkE/Do9G774VMcDYnl/3Qr6Dh8jIc9QFEH5fANaCNMWF5+PZWsV6trMJ1qWXEFxrWapy3ULdII7JkSfyRD7lAOcn94pEpWEu4g4AuMJmFUcYK5bSpLhNqeM2rrV8SroQ7r83ZWMmilJltDlqWJWQ9x9IkCHjwuQQ8=
---



# Demo2 第一章 v0.2 交付复验报告

> 复验人：Marvis（集中审校岗）
> 复验对象：Codex 提交 `34436f6 feat: deliver exploration v02 content contracts`（4 文件，178 行）
> 复验基准：`demo2_ch1_marvis_review_v01.md` 的 9 项 S1/S2 意见 + 8 条 A/B 包验收前置条件
> 级别：S1 必须改（史实/可信度）/ S2 必须对齐（契约冲突，会导致运行时歧义或不可跑）/ S3 建议改

## 结论摘要

**判定：v0.2 不予冻结，工作包 A/B 打回补充；D 包（DSH 运行时接入）不具备开工条件。**

v0.1 审校提出的 9 项阻塞级意见中，**1 项已妥善解决、2 项部分满足、6 项未处理**；8 条验收前置条件**通过 1 条**。

同时，v0.2 自身引入了 **9 项新的集成阻塞**（编号 N1–N9），其中 N1、N3、N5、N6 属于"照现状合并进运行时必然跑不通或跑错"的硬问题——新增机制的意图是对的，但缺了让意图可执行的契约层（合并语义、条件守卫、提示—效果绑定、字段增量来源），这些正是 DSH 合并时无法自行推断的部分。

需要说明的是：**产物本身不是退步**。三层证据链（物证 → 行动资格 → 刘看山验证）、漏线索不 Game Over 的离开反馈、"信息不足" 样例三件事都落地了，S3-3 已完整满足。问题集中在"新增字段与既有 v0.1 字段体系没有桥接"，属可一次性收口的工程问题，不是设计返工。

| 类别 | 数量 | 阻塞 v0.2 冻结 |
| --- | --- | --- |
| S1 史实（沿用 v0.1 未改） | 1（原 3 项中 2 项降级） | 是 |
| S2 契约/逻辑（v0.1 遗留未改） | 6 | 是 |
| N 新增集成阻塞 | 9 | 其中 4 项是 |
| S3 体验 | 5（原 5 项中 1 项已解决） | 否 |

---

## 一、v0.1 意见回归核对

### S1-1 「1141 年诏书」时点错位 —— ❌ 未处理

**证据**：`script_v02.md` 第 49 行仍为独立小节「## 1141 介入前提示」，未按方案 A/B 拆分 1140（十二道金牌班师诏）与 1141（罢兵权—构陷—下狱—和议）；`content_v02_patch.json` 未涉及 `s09_recall_chain`（v0.1 标题「第四幕｜1141 年的诏书」原样保留）。

**影响**：这是 v0.1 报告列为"最高优先"的一条。探索改版重写了 s05–s07，但玩家真正被质问"你介入了什么"的是 s09–s10，那一段的史实时点错误仍在。

**建议**：本轮只需最小改动——采纳原方案 B：`s09` 拆 `s09a`（1140 班师诏已成事实，玩家只能利用它留下的空隙）+ `s09b`（1141 兵权与和议，信息链真正对抗的对象），幕标题与 `countdown_end_year` 说明同步更新。方案 A/C 亦可，但必须在 v0.2 定稿前二选一落笔。

### S1-2 岳飞之死地点 —— ⚠️ 部分满足（未见落实证据）

`script_v02.md` 未新增旧营撤编的制度说明，`s11_outcome_router` 文案不在本次交付范围。若 Codex 已在 v0.2 正文之外处理，请在交付索引中标注位置；若未处理，仍按原建议补一句台词（"营还在，人不在了"）。

### S1-3 制度专名 —— ⚠️ 部分满足

`script_v02.md` 沿用"老驿卒""驿站"，未采纳「递铺 / 急脚递 / 军镇→屯驻大军驻地 / 封泥→御宝朱印」建议。s05 标题「驿站：家书不是军令」本身已是好文案，专名可在正文层逐个替换，不必改标题。

### S2-1 政治清算不可被消息单变量决定 —— ❌ 未处理

`court_pressure` 隐式变量未出现在 `state_v02.json`；`divergent_ready_v02` 仍为纯信息链条件，两条时间线的分叉仍完全由"预警是否可靠抵达"决定。

**建议**：即便不加新变量，也请在剧本层把代价写成结构性账（"你改变了消息抵达的速度，没有改变朝廷要一个答案的心"）。

### S2-2 玩家年龄链 —— ✅ 契约层已自洽，⚠️ 缺剧本台词与设定表写死

**事实更正（对我 v0.1 报告的修正）**：v0.1 契约 `effects_catalog` 中已写死 `advance_to_1127 → player_age 7`、`advance_to_1141 → player_age 21`、`advance_to_1161 → player_age 41`。也就是说"1141 年 21 岁"方案在契约层早已生效，**v0.1 报告中"年龄链断裂"的描述应限定为"剧本文本与拍板项层面未写死"，契约层不存在矛盾**。

**待办**：① 剧本 `s14_xinqiji_intro` 补一句年龄/沧桑感台词（1161 年玩家 41 岁、辛弃疾 21 岁）；② 拍板项 1「1127 年后设为 12—16 岁」需正式作废留痕。

### S2-3 线索门槛：硬开门 vs 不卡死 —— ❌ 未处理（新增了记录机制，未改开门条件）

**已做对的部分**：`remember_missed_clue` + 三处 `leave_effects` + 三处 `fallback_feedback`，漏线索有具体后果文案，符合 v0.2 精神。

**未做的部分**：`s05`→`s07` 向 1141 的开门条件未改。v0.1 契约中的 `information_chain_complete`（要求 `clues_found` 含 `military_order` + `route_map` 且 `trust_military ≥ 2`）仍是硬门槛，`state_v02.json` 未给出软门槛版本（如"≥2 线索 + ≥1 提问"）。

### S2-4 提问次数与结局门槛的数学冲突 —— ❌ 未处理，且冲突加剧

**证据**：`state_v02.json:22` 仍是 `"shan_questions_left": 3`；而 truth 线需要点亮的四项验证（`route_verified`、`shan_answer_recall`、`recall_recipient_found`、`testimony_interpreted`）在 `script_v02.md` 中各自对应一次提问（route_explain / recall_chain / recipient_identity / testimony_meaning），共 **4 次消耗**。3 < 4，真相线在同一周目内数学上不可达——与 v0.1 报告的判断完全一致，未被吸收。

**建议**：预算改为 **4 次**（识别年代 0 消耗），或采用双预算表（truth 需 4、divergent 需 3），并补「提问 → 消耗 → 字段 → 结局」矩阵进 `state_v02.json`。见 N5。

### S2-5 三结局判定优先级 —— ❌ 未处理

`state_v02.json:46-50` 的 `ending_rules_patch` 只给了"结局 id → 条件名"映射，未写判定顺序与兜底。`clues_v02.md` 的结局门槛表同样未写 `truth > divergent > canonical`。当玩家同时满足 `truth_ready_v02` 与 `divergent_ready_v02` 时（走完整介入链 + 集齐物证 + 低知识债，是常见路径），运行时会取到哪个结局取决于实现者的遍历顺序。

### S2-6 `knowledge_debt` 形同虚设 + 悬空变量 —— ❌ 未处理，且我上轮有误述需更正

**事实更正**：v0.1 报告 S2-6 第 2 点提到的 `witness_intent` / `action_intent` **在 v0.1 契约中并不存在**（全库 0 次出现），实际字段是 `action_tendency`，且 `choose_intervene`（+1）/`choose_witness`（-1）已在写入。因此"写了不用的悬空变量"这一表述不准确，应更正为：**`action_tendency` 有写入、v0.2 结局门槛无一读取它**，属"有值无出口"，仍建议接入 s12 出口文案差异或从门槛体系中明确其角色。

同理，`clue_yuefei_name` 在 v0.1/v0.2 契约中均不存在（0 次），只出现在 `script_v01.md` 的 s07 文本里——它是一个**文本道具名，不是状态字段**，无需补入状态集合，v0.1 报告该条撤回。

**仍然成立的部分**：`knowledge_debt ≤ 2` 门槛问题未解。v0.2 新增效果中 **没有任何效果写入 `knowledge_debt`**（`state_v02.json` 中该词仅出现在第 44 行的门槛判定里），唯一来源仍是 v0.1 的 `choose_intervene: +1`，实际上限 1，`≤2` 恒真。

### S2-7 旧字段 → v0.2 字段映射表 —— ❌ 未交付

`state_v02.json` 无 mapping 段。`resolve_intervention_branch`（v0.1 中仅 `set branch=intervene`）语义未修订。

### S3 体验 —— 5 项中 1 项已完整解决

| # | 建议 | 状态 |
| --- | --- | --- |
| S3-1 | s05–s07 三地点各一问过于工整 | ⚠️ 已改善（s06 引入取舍），但取舍机制无契约载体，见 N4 |
| S3-2 | 选项 B（民间扩散）收益不可见 | ❌ 未处理 |
| S3-3 | 必补一处"信息不足"样例 | ✅ **已解决**（s05/s06/s07 三处 `insufficient` 文案，含道具缺失时的具体回绝话术） |
| S3-4 | s12 出口回显 1141 选择 | ❌ 未处理 |
| S3-5 | s14 年龄台词 | ❌ 未处理（同 S2-2） |

---

## 二、v0.2 新引入的集成阻塞（N1–N9）

### N1 `state_v02.json` 缺合并语义与基础段（**最高优先，直接阻塞 D 包**）

`content_v02_patch.json:6` 明确写了 `"merge_rule"`，但 `state_v02.json` **没有**——它只有 `initial_state_patch` / `effects_catalog_patch` / `conditions_patch` / `ending_rules_patch` 四段，且完全不含 `variables`（类型定义）、`nodes`（场景图）、`endings` 段。

DSH 拿到这份文件无法判断：① 是覆盖 v0.1 state 还是合并？② 若整体替换，`nodes` 与 `variables` 直接丢失，游戏无法推进；③ `clue_fragments` / `verified_clues` / `route_verified` 等 10 个新字段**无类型声明**（是布尔还是数组？`route_description` 一类）。

**建议**：在 `state_v02.json` 顶部补 `merge_rule`（键级合并，未提及项保留 v0.1）+ `variables_patch`（10 个新字段的类型/默认值/取值范围）+ `nodes_patch`（s05–s07 的 `entry_conditions` 改动、以及软门槛方案若采纳后的 s09 入口条件）。

### N2 v0.1 / v0.2 双字段体系并存且无桥接

v0.2 引入 `clue_fragments`（碎片）与 `verified_clues`（已验证），v0.1 的 `clues_found`（已取得）与 `evidence_completeness`（四类交叉验证数）仍在被门槛读取：

- `divergent_ready_v02`（`state_v02.json:43`）读 `clues_found` —— v0.1 字段
- `truth_ready_v02`（`:44`）读 `evidence_completeness`、`inquiry_count`、`knowledge_debt` —— 三个都是 v0.1 字段
- 而 v0.2 的新效果只写 `clue_fragments` / `verified_clues` / 布尔位

结果是**同一份契约里"拾取"被记两处、"验证"被记两处，且门槛只读旧的那一处**。

**建议**：二选一——① 明确 `clues_found` 为"已取得线索"唯一真源，v0.2 新效果补写 `clues_found`；或② 把门槛全部改为读 `clue_fragments` + `verified_clues`，并在映射表里声明 `clues_found := clue_fragments`。无论哪种，`clues_v02.md` 的线索表需同步注明"入哪个字段"。

### N3 `leave_effects` 无条件触发，会误记"漏线索"

`content_v02_patch.json:17 / 31 / 45`：

```
"leave_effects": ["remember_missed_clue:family_letter"]
"leave_effects": ["remember_missed_clue:civilian_testimony"]
"leave_effects": ["remember_missed_clue:recall_recipient_token"]
```

`remember_missed_clue` 只有 `append_unique`，**没有前置条件**。玩家已取得家书再离开 s05，同样会被记入 `missed_critical_clues` → 后续后果文案会告诉玩家"你失去了家书"，与事实相反，且会污染 truth 线的物证判定。

**建议**：给 `leave_effects` 增加条件语法（如 `{"if_not": {"clues_found_contains": "family_letter"}, "effect": "remember_missed_clue:family_letter"}`），或新增 `remember_missed_clue_if_absent` 效果并定义其内建守卫。这是 5 行以内的改动，但不改必错。

### N4 s06「取舍」机制在契约层没有载体

`script_v02.md` 写"保存证言会增加 `trust_public`，但玩家错过一次追查船夫名册的机会"，而 `content_v02_patch.json:27-29` 三个对象都是 `"once": true`、彼此独立、无互斥声明。当前契约无法表达"二者不可兼得"。

**建议**：补 `exclusive_group`（同组内选一后其余禁用）或"消耗一次行动次数"的语义，并把取舍后果写入 `fallback_feedback`。否则 DSH 只能全放行，剧本承诺的代价不会发生——这是玩家能直接感知到"说一套做一套"的地方。

### N5 提问预算与验证效果未绑定，且与 v0.1 提问计数不联动

三处 `shan_prompts`（`:19 / 33 / 47`）只给了 prompt id 列表（`route_explain`、`letter_chain`、`testimony_meaning`、`recall_chain`、`recipient_identity`），**没有声明每个 prompt 触发哪些 effect、是否消耗提问次数**。而 `consume_shan_question` 与 `verify_route` / `verify_recall_chain` / `verify_recipient` / `verify_testimony` 是彼此独立的效果，无人把它们组合起来。

同时，v0.1 的 `ask_fact` / `ask_context` / `ask_counterfactual` 负责递增 `inquiry_count` 与 `inquiry_types`，而 `truth_ready_v02` 恰好读 `inquiry_count ≥ 3`——若新对话路径只发 `consume_shan_question` 不发 `ask_*`，`inquiry_count` 会停在 0，**即使玩家做满 4 次验证提问，真相线依然锁死**。

**建议**：补一张 `shan_prompt → effects[] → 消耗次数` 绑定表，并让每次提问同时触发 `ask_*`（或让 `consume_shan_question` 一并 `increment inquiry_count`）。这一条与 S2-4 是同一个问题的两面，建议一次改完。

### N6 `truth_ready_v02` 的三个 v0.1 字段在 v0.2 中无增量来源

`state_v02.json` 全文中，`evidence_completeness`、`inquiry_count`、`knowledge_debt` **只出现在第 44 行的判定里，没有任何效果写入它们**。truth 线是否可达，完全取决于 DSH 是否保留 v0.1 的 `find_*` / `ask_*` / `choose_intervene` 效果——而 N1 表明合并语义本身未定义。两个问题叠加，真相线目前处于"理论上存在、实现上不可达"的状态。

**建议**：在 `effects_catalog_patch` 中显式声明继承或重写这三类效果；顺带修掉 v0.1 `find_*` 的一个隐藏 bug（见 N8）。

### N7 1141 提示语三项 vs 结局门槛四项，提示会误导玩家

`script_v02.md:49-51` 的提示语说"先看清楚自己拥有的是**物证、路线，还是一个真正能行动的人**"——三项；而 `divergent_ready_v02` 要求 **4 项**（另加 `shan_answer_recall`，即"理解召回链"）。玩家按提示凑齐三项去介入，仍会被判定为"预警未可靠抵达"，且没有任何反馈告诉他缺的是第四项。

**建议**：提示语改为四项并列（物证、路线、能执行的人、看得懂召回链），或把提示改为动态生成——读取 `divergent_ready_v02` 的四个分量，逐项显示已满足/缺失。后者体验更好，也更贴合"探索系统"的定位。

### N8 v0.1 `find_*` 的 `evidence_completeness` 用绝对值赋值，拾取顺序会污染进度（新发现）

v0.1 契约中：

```
find_family_letter → set evidence_completeness = 1
find_military_order → set evidence_completeness = 2
find_route_map     → set evidence_completeness = 3
hear_civilian_testimony → set evidence_completeness = 4
```

`set` 是覆盖而非累加：玩家先取 `route_map`（=3）再取 `family_letter`（=1），进度会**倒退**，`all_four_clues`（`≥4`）只在恰好最后拾取证言时才成立。探索系统允许任意顺序探索，这个 bug 在自由探索下是必然触发而非边缘情况。

**建议**：改成计数语义（`increment`，或由 `clues_found` 的去重长度派生 `evidence_completeness`）。这条虽属 v0.1 遗留，但直接决定 truth 线可达性，建议本轮一并修。

### N9 `content_v02_patch.json:14` 对象 id 中英混排

```
{"id": "old_station牌", ...}
```

对象 id 是程序标识符，中英混排会给资源引用、日志检索和后续本地化埋坑（其余 id 均为纯英文蛇形命名）。

**建议**：改为 `old_station_plaque` 或 `station_route_plaque`。

---

## 三、对队长五项拍板事项的现状

| # | 事项 | 现状 | Marvis 建议 |
| --- | --- | --- | --- |
| 1 | 玩家 1127 年后年龄 | 契约已按 1141→21 岁、1161→41 岁生效（`advance_to_1141/1161`）；拍板项"12—16 岁"仍挂着未作废 | **正式作废 12—16 岁**，剧本补年龄台词 |
| 2 | 时间线一措辞 | 未统一，"召回延迟"未全稿替换 | 统一为"**召回延迟 / 未在关键窗口执行**" |
| 3 | 岳飞可否点击 | 维持背影 + 军书落款；旧营撤编制度说明未加 | 补一句台词即可 |
| 4 | 1161 辛弃疾入口 | 保留；`s14` 时间轴衔接（年龄台词）未写 | 保留必须演示，补衔接 |
| 5 | 语感与方言 | 未处理 | 白话为主，每人 1—2 个准确专名 |

以上 5 项均**仍无拍板留痕**，建议队长本轮一次性批注（本报告第四节可在知识库直接勾选）。

## 四、工作包 A/B 验收前置条件（复验结论）

- [ ] S1-1 时点按方案 A/B/C 之一修订，幕标题与时间线约束同步 —— **未通过**
- [ ] 年龄链写死 + 1141/1161 年龄明确 —— **契约已通过，剧本台词未补（半通过）**
- [ ] SCENE 02 → 03 改用软门槛（≥2 线索 + ≥1 提问） —— **未通过**
- [ ] 提问次数上限明确且与两结局自洽（附矩阵） —— **未通过（3 < 4，仍不可达）**
- [ ] 三结局判定顺序写明（truth > divergent > canonical） —— **未通过**
- [ ] `knowledge_debt` 增量 ≥2 或门槛改 `== 0`；`action_tendency` 接入或明确角色 —— **未通过**
- [ ] 旧字段 → v0.2 字段映射表随 `state_v02` 交付 —— **未通过**
- [x] 至少一处"信息不足"样例写入 `script_v02.md` —— **通过**

**通过率 1.5 / 8。**

## 五、给 Codex 的最小修订清单（建议顺序）

1. `state_v02.json` 补 `merge_rule` + `variables_patch` + `nodes_patch`（N1）
2. 统一字段真源，补映射表（N2 + S2-7）
3. `leave_effects` 加条件守卫（N3）
4. 提问预算改 4 + 绑定 `shan_prompt → effects → 消耗` + 补提问矩阵（S2-4 + N5）
5. `find_*` 改计数语义（N8），并声明 v0.1 效果的继承（N6）
6. `knowledge_debt` 增量来源补齐或门槛收紧（S2-6）
7. 结局判定顺序 + 兜底（S2-5）
8. s06 取舍加互斥载体（N4）
9. 1141 提示语与门槛对齐（N7）+ S1-1 方案 B 拆分
10. 细节：`old_station牌` 改名（N9）、年龄台词（S2-2）、专名替换（S1-3）、出口回显（S3-4）

第 1–5 项为 D 包开工前置；第 6–9 项为冻结前置；第 10 项可在冻结后随文案批处理。

## 参考来源（史实复核用）

- 光明网《岳飞与二次"班师诏"》：绍兴十年（1140）郾城大捷后十二道金牌班师诏。
- 河南省高级人民法院《八千里路云和月》：绍兴十一年（1141）四月二十四日三大将任枢密使/副使、八月初三罢岳飞、十一月初七绍兴和议、十二月廿九赐死；岳飞卒于临安大理寺。
- 《建炎以来系年要录》《三朝北盟会编》《鄂国金佗编》相关条目。
*（内容由AI生成，仅供参考）*
