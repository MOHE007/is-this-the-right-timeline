# Demo2 第一章线索与结局矩阵 v0.2

| clue_id | 地点/动作 | 拾取结果 | 刘看山验证 | 验证后解锁 | 漏掉/未验证后果 |
|---|---|---|---|---|---|
| `family_letter` | 驿站查看家书 | 物证 | 可选：解释普通人消息链 | 真相线物证 +1 | 真相线物证不足 |
| `route_map_fragment` | 驿站查看旧驿牌或渡口湿图 | 碎片 | 需要提问“路线如何抵达” | `route_verified` | 只能知道方向，不能可靠介入 |
| `route_map` | 驿站追问老驿卒 | 完整路线 | 仍需刘看山确认 | `route_verified` | 1141 介入链缺路线 |
| `civilian_testimony` | 渡口保存迁徙者证言 | 物证 | 需提问证言意味着什么 | `testimony_interpreted` | 真相线关闭 |
| `military_order` | 军镇查看军书 | 物证 | 需提问召回链 | `shan_answer_recall` | 可见命令但无法理解链条 |
| `recall_recipient_token` | 军镇拾取传令牌 | 行动凭证 | 需提问谁能执行 | `recall_recipient_found` | 预警没有可靠接收者 |

## 结局门槛

| 结局 | 必须满足 | 不满足时 |
|---|---|---|
| `ending_divergent` | `military_order` + `route_verified` + `recall_recipient_found` + `shan_answer_recall` + 介入 | 进入“预警未可靠抵达”普通收束 |
| `ending_canonical` | 选择见证历史 | 始终可达 |
| `ending_truth` | 四类物证 + `testimony_interpreted` + 三类提问 + `knowledge_debt <= 2` | 真相按钮锁定，仍可走历史线 |

## 设计规则

- 拿到道具不等于验证道具。
- 刘看山没有对应道具时回答 `insufficient`，不产生解锁 effect。
- 漏掉关键道具不 Game Over，反馈必须说明失去的具体路线。
- 每个调查地点至少三个调查对象，至少一个选择存在收益与代价。

## v0.2.1 字段与提问真源

- `clues_found` 是已拾取物证的唯一真源；所有 `find_*` 使用去重追加，`evidence_completeness` 由四类物证去重数量派生，不再使用绝对 set。
- `clue_fragments` 记录调查碎片，拾取物证时同步写入；`verified_clues` 只记录刘看山确认后的证据。
- 四次提问预算初值为 4。每个 prompt 必须绑定 `ask_*`、验证 effect 和 `consume_shan_question`；消耗同时使 `inquiry_count +1`。
- 结局优先级：`ending_truth > ending_divergent > ending_canonical`；无特殊条件时回退 `ending_canonical`。
- `knowledge_debt` 的风险来源包括未验证介入、使用不可靠送达、介入并改变信息链；真相线要求 `knowledge_debt <= 2`。
- `s06` 的 `ferry_action` 互斥组保证保存证言与查看船夫名册必须取舍。
