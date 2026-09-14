---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: bf570042b9bab5ca445e13766da77718_4826eb34afa511f18f50525400aeaaa3
    ReservedCode1: Pdy9SOtWmN+YtYo6uKSQ9WQwg+iKrbV4Bxs2k0HTrqQzwTXRUZBFlLdBpQTqCDQkhQ3g4NgcJDjCRumHaua0a5oUg0DI1Q/Ua8RkjE8tvF4yA7jtL6sjPv+Wh9oTe9PfGTkkGxoS1mRxse85q44rlnxxIuNRFfgUnFeif0+E0gn70vS/H3JP4czEoVY=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: bf570042b9bab5ca445e13766da77718_4826eb34afa511f18f50525400aeaaa3
    ReservedCode2: Pdy9SOtWmN+YtYo6uKSQ9WQwg+iKrbV4Bxs2k0HTrqQzwTXRUZBFlLdBpQTqCDQkhQ3g4NgcJDjCRumHaua0a5oUg0DI1Q/Ua8RkjE8tvF4yA7jtL6sjPv+Wh9oTe9PfGTkkGxoS1mRxse85q44rlnxxIuNRFfgUnFeif0+E0gn70vS/H3JP4czEoVY=
---

# Marvis 增量复验报告 — v0.2.1 契约固化与 E 包文案

**日期**：2026-09-14
**审校**：Marvis（集中审校岗）
**对象**：Codex 提交 `b5c7f3a`（state_v02 / content_v02_patch v0.2.1）、DSH 运行时 `916b72c` / `2ba8187`、E 包 `godot/demo2/data/ch1/demo2_ch1_shan_answers_v02.json`
**基准**：`demo2_ch1_marvis_review_v02.md`（v0.1 审校）、`demo2_ch1_team_announcement_v02.md` 10 条清单、`demo2_runtime_response_marvis_v02.md`

## 一、结论

1. **N1–N9 中 8 项已在契约层固化到位**；N4（s06 互斥载体）已定义 `exclusive_group`，待 DSH 接入。
2. **增量发现 6 项契约级不一致（M1–M6，其中 1 项 P0、5 项 P1），另 3 项 P2 建议。判定：v0.2.1 暂不冻结**，建议以 v0.2.2 处置 M1–M6 后再冻结。
3. **E 包文案**：史实表述基本成立（1141 链条顺序正确），但发现 1 处硬错字、1 处语感穿越、1 处 effects 缺失、1 处文件未纳入提交。
4. **需队长拍板 3 项**：M3 提问资源真源与预算取值、s09 提示语口径（M8）、v0.1 遗留五项。

## 二、N1–N9 固化核对（b5c7f3a）

| # | v0.1 判定 | 契约层现状 | 复核 |
|---|---|---|---|
| N1 合并语义 | 阻塞 | `merge_rule` 已补（deep_merge_by_key / preserve_unspecified / nodes·variables·endings 各自策略） | 通过 |
| N2 双字段无桥接 | 阻塞 | `field_mapping` 已写入，`clues_found` 标注 v01 唯一真源 canonical，`verified_clues` 为验证层 | 通过 |
| N3 leave_effects 误记 | 阻塞 | `remember_missed_clue_if_absent` 已补，含 `guard.not_contains` | 通过（旧效果见 M7） |
| N4 s06 取舍无载体 | 冻结 | `exclusive_group: ferry_action` 已在 s06 两个调查对象上定义 | 载体已定义，待 DSH 接入 |
| N5 提问→效果无绑定 | 阻塞 | `prompt_effects` 五组已补（requires/ask_effect/verify_effect/consume）；E 包同步交付 | 通过（一致性见 M1/M2/M4） |
| N6 truth 字段增量源 | 阻塞 | 由 N1 继承语义 + `field_mapping.inquiry_count` 说明解决 | 通过（语义漂移见 M9） |
| N7 提示三项 vs 门槛四项 | 建议 | content patch 提示语已改为四项并列 | 通过（口径见 M8） |
| N8 evidence 绝对值污染 | 阻塞 | `evidence_completeness` 改为 derived formula（unique_count 交集） | 通过 |
| N9 old_station 牌命名 | 细节 | 已改 `old_station_plate` | 通过 |

## 三、增量发现（M1–M9）

| # | 级别 | 问题 | 证据 | 影响 | 归属 |
|---|---|---|---|---|---|
| M1 | P1 | `route_explain` 的 requires 三处字段名与语义不一致：state 用 `requires_any`（OR），content_v02_patch 的 s05/s06 用 `requires`（未标语义，易读作 AND），E 包用 `requires_any`（OR） | state_v02.json `prompt_effects.route_explain`；content_v02_patch.json s05/s06 `shan_prompts[]`；E 包 `route_explain.requires_any` | 运行时判定分支若取 AND，玩家只握其一（仅 route_map 或仅 route_map_fragment）时该提问被错误锁死 | Codex |
| M2 | P1 | E 包 `letter_chain.effects` 仅含 `consume_shan_question`，缺 `ask_fact` 与 `verify_route`；契约 `prompt_effects.letter_chain` 与 content patch s05 均为三项 | E 包 letter_chain.effects vs state/content | 玩家提问后无任何状态变化（不产生 route_verified、不加 inquiry_count），只扣次数 | Codex |
| M3 | **P0** | 提问资源双真源且取值冲突：E 包 `question_budget = 3`，state `initial_state_patch.shan_questions_left = 4` 且 `variables_patch.shan_questions_left.default = 4 / max = 4` | E 包；state_v02.json | S2-4「预算 3 在当前契约下数学成立」的结论**取决于取哪个真源**：若以 state 的 4 初始化，则"3<4 不可达"的原判成立，truth/divergent 两线不可兼得 | 队长拍板 + Codex 收敛 |
| M4 | P1 | E 包每个 prompt 同时声明 `consume: 1` 与 effects 内 `consume_shan_question`，消耗被声明两次 | E 包 5 组 prompt 全部 | 运行时若两者都执行将双扣提问次数（当前冒烟为单扣，属实现取一，契约二义须消除） | Codex |
| M5 | P1 | `gain_military_trust`（s07 `military_companion`）未出现在 state 的 `effects_catalog_patch`；`ask_context` / `ask_fact` / `ask_counterfactual` / `fail_delivery` / `set_ending_canonical` 亦未见定义 | content_v02_patch.json s07；state_v02.json effects_catalog_patch；DSH 回应文档第三节 | `trust_military >= 2` 是 divergent 门槛项，效果若无契约定义即属运行时私造语义 | Codex |
| M6 | P1 | E 包未被 `b5c7f3a` 纳入提交（文件时间 01:36:47 早于提交），状态仍为 `draft-for-marvis-review`，不在 v0.2.1 契约族内 | git show --stat b5c7f3a（6 文件，不含 E 包）；E 包 status 字段 | E 包与契约将各自演进，回归风险持续存在 | Codex |
| M7 | P2 | 旧效果 `remember_missed_clue`（无守卫）与 `remember_missed_clue_if_absent` 并存，旧者未标 deprecated | state_v02.json effects_catalog_patch | 后续内容误用旧效果将复现 v0.1 N3 缺陷 | Codex |
| M8 | P2 | s09 入口门槛为 `evidence_completeness >= 2 且 inquiry_count >= 1`，而提示语标称「物证、路线、看得懂召回链、能行动的人」四项——两者口径不同（四项实为 s11 结局门槛） | state_v02.json nodes_patch.s09_1141_gate；content_v02_patch.json 提示语门槛 | 玩家在 s09 依据提示语判断"打不开"可能误判为 bug | 队长拍板 |
| M9 | P2 | `truth_ready_v02` 的 `inquiry_count >= 3` 可被零成本 `ask_*`（s05 老驿卒、s07 军中同伴等调查对象自带）刷满，与"消耗 3 次刘看山提问"不等价 | state_v02.json conditions_patch / field_mapping.inquiry_count | 该门槛不再等价于验证深度，语义漂移；影响 S2-4 的体验论证 | Codex |

## 四、E 包文案审校（逐条）

| # | 位置 | 原文 | 判定 | 处理建议 |
|---|---|---|---|---|
| T1 | `testimony_meaning.answer.context` | 「历史记录常常只剩军书与与和议」 | **硬错字**（"与与"重复） | 必改为「军书与和议」 |
| T2 | `testimony_meaning.answer.fact` | 「我们不是谁的数字」 | 语感穿越：现代语汇，与南宋语境不协 | 建议改古典化表达，如「我们不是纸上的一个名字」；属体验项，需队长确认 |
| T3 | `route_explain.answer.fact` | 「家书只能走步递」 | 绝对化：宋代平民私信多依托递铺/便人，非必然步递 | 建议改为「家书多走步递」或「家书只能跟着慢一步的传法走」 |
| T4 | `recall_chain.answer.fact` | 「1140 年班师诏已成事实；1141 年真正的链条是罢兵权、构陷、下狱与和议」 | 史实成立：绍兴十年（1140）七月金字牌召还；绍兴十一年（1141）四月罢三大将兵权、九月构陷、十月下狱、十一月和议成，顺序无误 | 通过 |
| T5 | `route_explain.answer.fact` | 「军情走急脚递」 | 成立：宋递铺体系含步递、马递、急脚递，金字牌为急脚递 | 通过 |
| T6 | 全组 `insufficient_text` / `exhausted_text` | —— | 语气一致，均守住"不凭转述作证"的设定边界 | 通过 |

**E 包总体判定**：文案质量可接受，修 T1（必改）+ T2/T3（建议）后可交付；交付前须先解决 M2（effects 缺失）与 M6（纳入契约族）。

## 五、待队长拍板

1. **提问预算**：**已决策：4 次**。`state_v02.initial_state_patch.shan_questions_left` 为唯一真源，问答包 `question_budget: 4` 仅作镜像校验；取 4 为玩家保留 1 次试错余量（M3 已处置）。
2. **s09 提示语口径**：保留四项并列（引导性优先）还是改为与入口门槛一致的两项（准确性优先）（M8）。
3. **v0.1 遗留五项**：年龄作废留痕、时间线措辞、岳飞呈现方式、辛弃疾入口、专名浓度。
4. **T2 文案**：「我们不是谁的数字」是否替换。

## 六、证据清单

| 项 | 位置 |
|---|---|
| 契约 v0.2.1 | `docs/production/demo2_ch1_state_v02.json`（9181 B）、`demo2_ch1_content_v02_patch.json`（5318 B） |
| E 包 | `godot/demo2/data/ch1/demo2_ch1_shan_answers_v02.json`（4304 B） |
| DSH 逐条回应 | `docs/production/demo2_runtime_response_marvis_v02.md` |
| 提交 | `b5c7f3a`（6 文件）、`916b72c`、`2ba8187` |
| 协作接口 | 知识库 `协作接口/inbox.md`、`task_board.md` |

---
*本报告仓库与知识库同步存档。*
*（内容由AI生成，仅供参考）*
