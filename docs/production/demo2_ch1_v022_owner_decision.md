# Demo2 第一章 v0.2.2 队长决策记录

**日期**：2026-09-14  
**决策人**：王凯（队长）  
**议题**：刘看山提问预算与真源

## 决策

提问预算确定为 **4 次**。`state_v02.json` 的 `initial_state_patch.shan_questions_left` 是唯一运行时真源，`variables_patch.shan_questions_left.default/max` 与之保持一致；问答包中的 `question_budget: 4` 只作镜像校验，不单独驱动状态。

## 体验理由

四次预算覆盖路线、家书/证言、召回链和执行者验证，并保留一次试错空间。缺少前置线索的提问仍会消耗一次预算；预算耗尽后返回 `exhausted`，不阻塞普通收束。

## 接入约束

- prompt 的 `requires_any` 统一按 OR 语义解释。
- prompt 的 effects 由内容对象绑定；问答库只提供同 ID 的文案和镜像校验，不再重复声明 `consume` 字段。
- 每个有效提问必须触发对应 `ask_*`、验证 effect 和 `consume_shan_question`。

## 证据

- `docs/production/demo2_ch1_state_v02.json`（revision `v0.2.2`）
- `godot/demo2/data/ch1/demo2_ch1_shan_answers_v02.json`（revision `v0.2.2`）
- Marvis `demo2_ch1_marvis_review_v021.md` M3
