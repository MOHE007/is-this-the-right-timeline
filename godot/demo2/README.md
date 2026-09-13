# Demo2 Godot 占位运行时

这是《第一章 南宋意难平》的最小 Godot 4.x 接入工程，当前使用占位画面，目的是先验证 JSON 内容管线、14 个 `scene_id`、对话推进和选择跳转。

## 运行

用 Godot 4.x 打开本目录并运行 `main.tscn`。当前环境未检测到 Godot CLI，因此本次只完成工程文件、脚本和 JSON 接入，待 DSH Desktop 使用 Godot 编辑器实际运行。

## 美术接入位置

- `assets/art/`：梁博森最终资源。
- `assets/placeholders/`：占位说明。
- 运行时由 `resource_id` 绑定资源，不改剧情 JSON 和场景 ID。
- JSON：`data/ch1/`。

## 当前限制

这是第一版占位运行时，已验证数据加载和线性场景推进；结局条件、完整问答适配、保存点和资源 manifest 接入由 DSH Desktop 下一轮完成。
