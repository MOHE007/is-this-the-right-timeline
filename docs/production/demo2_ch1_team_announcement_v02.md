# 团队公告 — Demo2 第一章 v0.2 交付复验结论

**日期**：2026-09-14
**发件人**：Marvis（集中审校岗）
**收件人**：Codex（叙事系统设计）、DSH Desktop（桌面端整合）
**抄送**：王凯（队长）

---

## 一、结论

**v0.2 不予冻结。A 包（state_v02）与 B 包（script_v02 / content_v02_patch）打回补充。D 包（DSH 运行时合并接入）不具备开工条件。**

v0.1 审校 9 项阻塞意见，6 项未处理；验收前置条件通过率 **1.5 / 8**。v0.2 自身新增 9 项集成阻塞，其中 N1、N3、N5、N6 为硬阻塞。

---

## 二、给 Codex 的最小修订清单（10 条，按优先级）

1. **N1 — state_v02 补 `merge_rule` + `variables_patch` + `nodes_patch`**
   目前只有 patch 四段，缺合并语义、10 个新字段类型声明、场景图入口条件。DSH 无法推断合并策略。

2. **N2 — 统一字段真源，补旧→新映射表**
   `clue_fragments` / `verified_clues`（v0.2）与 `clues_found` / `evidence_completeness`（v0.1）并存，门槛只读旧源。二选一：要么新效果补写 `clues_found`，要么全量门槛改为读新源。

3. **N3 — `leave_effects` 加条件守卫**
   目前无条件触发 `remember_missed_clue`。已取得家书再离开也会被记成"漏了家书"。

4. **S2-4 + N5 — 提问预算改 4 + 绑定 prompt → effects → 消耗**
   初值仍为 3，四项验证需 4 次；且 `consume_shan_question` 不减 `inquiry_count`，真相线锁死。

5. **N8 — `find_*` 改计数语义**
   `evidence_completeness` 用绝对值 `set`，拾取顺序会倒退（先取 route_map=3 再取 family_letter=1 → 退回 1）。

6. **S2-6 — `knowledge_debt` 增量来源补齐或门槛收紧**
   目前没有任何 v0.2 效果写入 `knowledge_debt`，`≤2` 恒真。

7. **S2-5 — 结局判定顺序 + 兜底**
   写明 `truth > divergent > canonical`，补同时满足兜底。

8. **N4 — s06 取舍加互斥载体**
   "保存证言"与"查看船夫名册"不可兼得，契约层无互斥声明。

9. **N7 — 1141 提示语与门槛对齐**
   提示语说三项（物证、路线、能行动的人），门槛要求四项（另加"看得懂召回链"）。

10. **细节项**：`old_station牌` 改名（N9）、年龄台词补 s14、专名替换（S1-3）、出口回显（S3-4）、S1-1 方案 B 拆分。

第 1–5 项为 **D 包开工前置**，第 6–9 项为 **冻结前置**，第 10 项冻结后批处理。

---

## 三、给 DSH Desktop

**D 包暂停。待 Codex 完成上述第 1–5 项并重新交付 `state_v02.json` 后，再评估开工。**

当前 `state_v02.json` 最大的问题是：它告诉 DSH 要加 10 个新字段（布尔值与数组），但没告诉 DSH 怎么跟 v0.1 的 `nodes`、`variables`、`endings` 拼在一起。照现状合并，`nodes` 图会直接丢失，游戏走到 1141 会断线。

---

## 四、五项拍板待队长

五项拍板（年龄链、措辞、岳飞背影、辛弃疾入口、语感）仍无留痕。队长确认后我再按拍板意见做最终收口。

---

**完整报告**：`demo2_ch1_marvis_review_v02.md`（仓库 + 知识库同步）
