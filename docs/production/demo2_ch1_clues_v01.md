---
tags:
  - project
  - production
  - clues
  - demo2
  - zhihu-hackathon
type: clue-bible
status: ready-for-integration
version: v0.1
created: 2026-09-13
updated: 2026-09-13
---

# Demo2 第一章线索卡与证言卡 v0.1

## 线索设计原则

每张线索卡只回答一个问题，并保留一个未解决的缺口。玩家需要把四类线索拼成“来源 → 路线 → 接收者 → 执行能力”信息链，不能靠单张卡直接得到最优答案。

| clue_id | resource_id | 名称 | 首次出现 | 玩家看到什么 | 能证明什么 | 仍缺什么 | 状态效果 |
|---|---|---|---|---|---|---|---|
| `family_letter` | `PROP_LETTER_UNSENT` | 未寄出的家书 | `s05_station` | 三日延误、折痕、重新封存 | 消息会在驿路节点停摆 | 谁在中途读过或扣下它 | `evidence_completeness +1` |
| `route_map` | `PROP_WET_ROUTE_MAP` | 湿掉的路线图 | `s05_station` | 驿站、渡口、军镇三类节点 | 送达依赖连续路线 | 哪条路线仍可通行 | `evidence_completeness +1` |
| `requisition` | `PROP_MILITARY_ORDER` | 征发文书 | `s06_ferry` | 转运印、模糊发令者 | 发令者与执行者可能不同 | 谁拥有实际调度权 | `evidence_completeness +1` |
| `civilian_testimony` | `CHAR_MIGRANT_WITNESS` | 迁徙者证言 | `s06_ferry` | “只相信能让孩子今晚睡下的人” | 普通人承担消息成本 | 证言能否被保存和传递 | `testimony_saved = true` |
| `military_order` | `PROP_MILITARY_ORDER` | 军书缺页 | `s07_military_town` | “调回”“待命”、缺失页角 | 召回是命令链动作 | 谁能执行或延缓它 | `evidence_completeness +1` |
| `yuefei_name` | `CHAR_YUEFEI_BACK` | 岳飞名号与背影 | `s07_military_town` | 军中谈论与远处背影 | 玩家确认目标人物处境 | 不能证明他会相信未来预言 | `trust_military +1` |

## 证言卡

| testimony_id | 提供者 | 原话/摘要 | 结局作用 |
|---|---|---|---|
| `testimony_postman` | 老驿卒 | “不是路断，是没人敢在夜里点灯。” | 说明延误可能来自风险判断，而非单一反派 |
| `testimony_migrant` | 迁徙者 | “我只相信能让我孩子今晚睡下的人。” | 保存后提高普通人信任，并进入真相线 |
| `testimony_soldier` | 军中同伴 | “你要是只带一句我知道未来，没人会替你开门。” | 说明预言必须转化为可核验的证据链 |

## 线索卡视觉要求

- 卡面尺寸建议 640×820 PNG 9-slice 框，缩略图由 DSH Desktop 统一生成 320×320。
- 线索卡正文由运行时排版，图片只保留标题、图形、纸张质感和印记。
- 四类关键线索用不同小图标区分：家书、路线、命令、证言；颜色保持灰青体系，只有召回诏书封泥使用朱砂。
- 线索卡显示“已确认 / 待核实”，不直接显示“正确答案”。

## 交互验收

- 收到四类线索后，证据完整度达到 4，开放 1141 信息链。
- 重复调查不重复增加证据，但可以增加信任、提问类型或知识债。
- 保存证言会影响结局语气；它不能单独阻止岳飞被召回。
- 线索缺失时，刘看山只能指出缺口类别，不能自动替玩家填槽。

## 关联

- [[10-projects/知乎黑客松游戏项目/制作包/demo2_ch1_storyboard_v01]]
- [[10-projects/知乎黑客松游戏项目/制作包/demo2_ch1_asset_brief_v01]]
- [[10-projects/知乎黑客松游戏项目/制作包/demo2_ch1_state_v01]]
- [[10-projects/知乎黑客松游戏项目/制作包/demo2_ch1_content_v01]]
