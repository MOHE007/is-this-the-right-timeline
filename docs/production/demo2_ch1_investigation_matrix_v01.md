---
title: 第一章调查矩阵 v0.1
status: draft-for-integration
---

# 第一章调查矩阵 v0.1

| 场景 | 动作 | 线索 | 状态效果 | 刘看山档位 | 玩家可见反馈 |
|---|---|---|---|---|---|
| `s05_station` | 查封泥 | `family_letter` | `evidence_completeness += 1` | 回答 | 家书延误可能来自节点停摆 |
| `s05_station` | 问送信路线 | `route_map` | `inquiry_types += context` | 回答 | 驿站、渡口、军镇串成路线 |
| `s05_station` | 翻家书折痕 | `family_letter` | `trust_public += 1` | 提醒 | 家书有人读过又重新封存 |
| `s06_ferry` | 核对转运印 | `requisition` | `evidence_completeness += 1` | 回答 | 发令者与执行者可能不同 |
| `s06_ferry` | 保存迁徙者原话 | `testimony_migrant` | `testimony_saved = true` | 救助 | 一句证言进入结局卡 |
| `s06_ferry` | 询问水位路线 | `route_map` | `trust_public += 1` | 提醒 | 水位改变送达时机 |
| `s07_military_town` | 比对军书措辞 | `military_dispatch` | `evidence_completeness += 1` | 回答 | “调回”是命令链动作 |
| `s07_military_town` | 问谁有权限 | `military_recipient` | `trust_military += 1` | 回答 | 接收者不等于执行者 |
| `s07_military_town` | 查看缺页 | `military_dispatch` | `knowledge_debt += 1` | 救助 | 缺页带来新疑点 |
| `s08_yuefei_countdown` | 事实提问 | — | `inquiry_types += fact` | 回答 | 岳飞 1142 年离世为已知事实 |
| `s08_yuefei_countdown` | 背景提问 | — | `inquiry_types += context` | 回答 | 召回依赖政令、路线和权限 |
| `s08_yuefei_countdown` | 反事实提问 | — | `inquiry_types += counterfactual` | 回答 | 改变一个节点会新增代价 |

实现时将动作映射到现有 state/content 契约；如某动作不适合当前 JSON 字段，应先在实现规格中登记，不直接发明第二套状态名。
