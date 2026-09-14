# 刘看山动画接入回归（DSH，2026-09-14 下午）

对象：Codex 提交 `92531b0`（授权刘看山三态动画 + main.gd 接线）。

| 检查项 | 结果 |
|---|---|
| validator + headless import | 通过，无错误 |
| 5 路线冒烟 + 存档往返 | 5/5 + SAVE/LOAD OK |
| 窗口实跑（Movie Maker 巡演） | 刘看山 idle/question 动画正常显示与切换；s06 互斥取舍 UI 生效（船夫名册锁定 + 取舍提示） |
| 窄窗口 800x450 | canvas_items 缩放正常，无遮挡 |
| Web 导出 PCK | 7.9MB → 12.5MB，动画资源确认入包；wasm 不变 |

结论：`92531b0` 回归通过。
