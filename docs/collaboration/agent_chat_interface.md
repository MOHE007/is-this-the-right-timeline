# Agent Chat Interface — Demo2 第一章

> 文件型协作接口。所有 agent 通过 Obsidian 中的消息页异步沟通；完成任务后必须写回状态、证据和下一步。

## 规则

1. `inbox.md` 是统一消息流：一条消息一个区块，使用唯一 `message_id`。
2. 新消息追加到文件末尾，不改写历史消息；回复用 `in_reply_to` 关联。
3. agent 完成工作后，更新 `task_board.md`，并在 `inbox.md` 发一条 `done` 或 `blocked` 消息。
4. 需要王凯拍板的事项标记 `needs_owner_decision: true`，否则自主推进。
5. 文件内容是公开协作记录，不写入 API key、隐私或未核验凭据。
6. 仓库与 Obsidian 双写：仓库保存协议与可公开记录，Obsidian 保存实时消息。

## 角色地址

| address | 角色 | 主要职责 |
|---|---|---|
| `codex` | 叙事/系统 | 剧本、状态契约、线索、分支 |
| `dsh` | 桌面整合 | Godot、导入、构建、运行验证 |
| `marvis` | 审校 | 阻塞项、史实、体验验收 |
| `super-zhendan` | 美术/UI | 水墨资产、UI、素材清单 |
| `owner` | 王凯 | 范围、最终取舍、发布 |

## 消息格式

```md
### MSG-YYYYMMDD-001
- from: codex
- to: dsh
- timestamp: 2026-09-14T00:00:00+08:00
- type: handoff | question | status | done | blocked | decision-request
- priority: P0 | P1 | P2
- in_reply_to: null
- needs_owner_decision: false
- subject: 简短主题

正文：事实、动作、验收标准或问题。

- evidence: 文件路径、commit、测试结果
- next_action: 接收方下一步
- status: open | acknowledged | done | blocked
```

## 当前同步口径

- DSH 已完成运行时接入并通过五条 QA 路径；保留运行时，不回滚。
- Codex 已将临时桥接固化到 `state_v02` / `content_v02_patch`，提交 `b5c7f3a`。
- DSH 在契约外继续做 H 向工作：保存点、窄窗口、Web 导出 CJK 字体。
- Marvis 负责对 `b5c7f3a` 与 DSH 回应做增量复验。
