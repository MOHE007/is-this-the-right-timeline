# DSH 运行时对 Marvis v0.2 复验报告的回应（2026-09-14）

> 回应人：DSH Desktop（工作包 D/E 实现方）
> 对象：`demo2_ch1_marvis_review_v02.md`（复验基准为 Codex 裸契约 `34436f6`）
> 事实前提：复验报告落盘时，运行时接入提交 `916b72c feat: wire exploration v02 into demo2 runtime` 已完成——本文逐条说明 N1–N9 与 S2 项在**运行时层**的现状，区分「运行时已桥接」与「仍需契约修订」。

## 结论

- 复验判定「D 包不具备开工条件」所依据的 5 项开工前置（N1/N2/N3/N5+S2-4/N6+N8），在 `916b72c` 运行时中**已全部桥接**，并有 5/5 冒烟证据（`godot/demo2/docs/run-2026-09-14-exploration/smoke_test_5routes.log`）。
- 桥接≠契约修好：**契约层修订清单仍然成立**，v03 应把运行时的临时桥固化为契约语义（见文末移交表）。
- 真正开放且运行时无法代劳的项：N4（互斥取舍载体）、S2-3（软门槛拍板）、S2-6（knowledge_debt 增量）、S1 全部史实项、S3-2/3-4/3-5 文案项。

## 逐条对照（N1–N9）

| # | Marvis 判定 | 运行时现状 | 剩余动作（归属） |
|---|---|---|---|
| N1 合并语义缺失 | 阻塞 | ✅ 运行时按**键级合并、未提及项保留 v01** 实现（`variables`/`nodes`/`endings` 不丢）；静态校验器同口径 | Codex：在 `state_v02.json` 顶部补 `merge_rule` 与 `variables_patch` 类型表 |
| N2 双字段无桥接 | 阻塞 | ✅ v01 `find_*`/`ask_*` 效果整体继承；`clues_found` 为拾取唯一真源，`verified_clues` 为验证层；truth/divergent 门槛读数经冒烟实证 | Codex：映射表写入 v03（含 `clues_v02.md` 注明入哪个字段） |
| N3 leave_effects 误记 | 阻塞（必错） | ✅ 运行时实现内建守卫：`remember_missed_clue:X` 仅在 X 确实未取得时触发；`canonical_missed` 路线实测 missed=2、已拾取项不误记 | Codex：契约层补 `if_not` 语法或 `remember_missed_clue_if_absent`，替换运行时内建约定 |
| N4 s06 取舍无载体 | 阻塞冻结 | ❌ 未实现（契约无 `exclusive_group`，运行时拒绝私造语义） | Codex 定义载体后运行时接入（预计 <20 行） |
| N5 提问→效果无绑定 | 阻塞 | ✅ 绑定表已交付：`data/ch1/demo2_ch1_shan_answers_v02.json`（prompt → requires_any → effects → 消耗 → 三段回答 → insufficient 文案），即复验要求的那张表 | Marvis：审校问答文案；Codex：把绑定表纳入 v03 契约族 |
| N6 truth 字段无增量源 | 阻塞 | ✅ 由 N1 的继承语义解决；`truth_verified` 冒烟 ending_truth 达成（inquiry=5、物证=4） | 同 N1 |
| N7 提示三项 vs 门槛四项 | 建议 | ✅ 已实现**动态缺项反馈**（推荐方案）：锁定按钮 tooltip + 面板提示逐项显示缺失（例：『查看偏离但未改写』还缺：理解召回链、选择介入路线、交付预警），见截图 `03_s11_outcome_router_gate_hint.png` | Codex：s09 提示语文案仍建议改为四项并列 |
| N8 evidence 绝对值污染 | 阻塞 | ✅ 运行时忽略 `set` 绝对值，按 `clues_found` 去重长度重算，任意拾取顺序安全 | Codex：v03 把 `find_*` 改计数语义 |
| N9 `old_station牌` | 细节 | ✅ 已改 `old_station_plate`（docs/production 与工程内同步，提交 `916b72c`）；如偏好 `old_station_plaque` 请在 v03 统一 | 无 |

## 对 S2-4「3 < 4 不可达」的更正性实证

复验断言「truth 线需要四项验证共 4 次消耗」与契约不符：`truth_ready_v02` 只要求 `testimony_interpreted`（1 次提问）+ 物证/提问/知识债三个 v01 字段；`divergent_ready_v02` 的四项中 `recall_recipient_found` 可由调查对象「询问军中同伴」免费获得（`find_recall_recipient`，不消耗提问）。

冒烟实测（预算 3 不变）：

- `divergent_verified`：消耗 2 次（route_explain + recall_chain），达成 `ending_divergent`，剩 1；
- `truth_verified`：消耗 1 次（testimony_meaning），达成 `ending_truth`，剩 2；
- 两线所需验证若同周目做满（route + recall + testimony = 3 次）恰好用尽预算。

**结论：预算 3 在当前契约下数学成立。**是否放宽到 4（给 letter_chain/试错留余量）属体验决策，请 Marvis/王凯按「玩家应有几次浪费机会」拍板，运行时读 `question_budget` 字段即可切换。

## 对 S2-5「判定顺序」的运行时现状

s11 三个结局是**玩家显式选择**而非自动判定：同时满足多个门槛时按钮并列可用、玩家自选，不存在遍历歧义；三门全锁时运行时提供「普通收束」兜底按钮（`fail_delivery + set_ending_canonical`，`divergent_unverified` 路线实证无死锁）。建议 v03 仍写明 `truth > divergent > canonical` 供自动判定场景（如成就/结算页）使用，并把兜底收束固化为正式 content 节点。

## 请各方拍板/跟进

- **Codex（v03 契约）**：上表 8 项固化 + `resolve_intervention_branch` 守卫语义 + s09 软门槛方案（S2-3）+ `knowledge_debt` 增量来源（S2-6）+ S1-1 方案 B 拆分。
- **Marvis**：审校 `demo2_ch1_shan_answers_v02.json` 五组三段式文案与史实表述；确认 S2-4 更正；给出提问预算 3/4 的体验建议。
- **王凯**：五项拍板事项（年龄作废留痕、时间线措辞、岳飞呈现、辛弃疾入口、专名浓度）仍待批注。
- **梁博森**：新增 UI 槽位（调查按钮、拾取 toast、验证印章、刘看山面板）可按占位布局开工，resource_id 不变。

## 证据

- 运行时提交：`916b72c`（引擎+UI+问答）、本文随后的 N7 反馈提交。
- 冒烟日志：`godot/demo2/docs/run-2026-09-14-exploration/smoke_test_5routes.log`（5/5）。
- 截图：同目录 01–04（调查+问答、调查面板、s11 动态缺项提示、truth 结局）。
- Godot：`4.3.stable.official.77dcf97d8`。
