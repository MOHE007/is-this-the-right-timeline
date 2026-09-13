---
title: 第一章时间线分支卡 v0.1
status: draft-for-review
---

# 第一章时间线分支卡 v0.1

## `ending_canonical`｜历史继续

触发：证据链不完整、预警未可靠抵达，或玩家选择保存证言。

画面：空营、封存的信、没有寄出的家书。后果：普通人的声音被保存，但消息链仍有断点；`knowledge_debt` 低。

## `ending_divergent`｜偏离但未改写

触发：四类线索齐全，`warning_delivered = true`，且 `trust_military >= 1`。

画面：命令延迟、粮道重新分配、军镇出现争执。后果：岳飞未被召回或召回被延迟，但军政压力上升；玩家明确看到代价。

## `ending_truth`｜见证者真相

触发：事实、背景、反事实三类提问齐全，且 `testimony_saved = true`。

画面：玩家无法保证改变命运，却把迁徙者、驿卒和士卒的证言带出时间线。后果：历史叙述多出一条来自现场的声音。

三张卡均经 `s11_outcome_router` 进入 `s12_leave_or_continue`；`continue` 继续到 `s14_xinqiji_intro`，`leave` 进入 `s13_exit_chapter`。
