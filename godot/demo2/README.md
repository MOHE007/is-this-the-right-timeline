# Demo2 Godot 占位运行时

这是《第一章 南宋意难平》的最小 Godot 4.x 接入工程，当前使用占位画面，目的是先验证 JSON 内容管线、14 个 `scene_id`、对话推进、条件选择和结局跳转。

## 运行

用 Godot 4.x 打开本目录并运行 `main.tscn`。运行前可先执行：

```bash
python3 tools/validate_content.py
```

当前开发环境未检测到 Godot CLI，因此已完成静态契约验证；待 DSH Desktop 使用 Godot 编辑器实际运行并回填截图、版本和导出日志。

## 美术接入位置

- `assets/art/`：梁博森最终资源（目录已用 `.gitkeep` 保留）。
- `assets/placeholders/`：占位说明。
- 运行时由 `resource_id` 绑定资源，不改剧情 JSON 和场景 ID。
- JSON：`data/ch1/`。

## 当前限制

当前已支持：

- 14 个场景加载与推进；
- `condition` / `conditions` 条件按钮锁定；
- 线索、提问类型、军中信任、分支、三种结局和离开/继续状态；
- 每个场景的 `visual` / `ui_slot` 作为美术接入锚点。

仍待 DSH Desktop 完成：Godot 编辑器实跑、完整刘看山本地问答适配、保存点、窄窗口检查和 Web 导出。
