# Demo2 第一章｜刘看山形象接入记录 v0.1

**日期**：2026-09-14  
**资源 ID**：`CHAR_LIUSHAN_WHITE`  
**状态**：已接入候选版，待 DSH Godot/Web 回归

## 授权与来源

项目队长王凯于 2026-09-14 明确允许将刘看山形象接入 Demo2 第一章。素材来自队长提供的 `刘看山动态.zip` 与 `看山三视图.zip`；仓库内 `godot/demo2/assets/art/characters/liushan/SOURCE.md` 记录原始包校验值、状态映射和处理规格。

## 接入内容

| 运行状态 | 原始动作 | 规格 | 触发 |
|---|---|---|---|
| `idle` | 待机 | 100 帧，20fps，循环 | s03 起默认显示 |
| `question` | 电脑 | 120 帧，20fps，单次 | 玩家成功向刘看山提问或验证线索 |
| `reminder` | 打招呼 | 80 帧，20fps，单次 | 信息不足或四次预算耗尽 |

三态动画均为 160×160 透明 PNG 序列，底部中心对齐。`question` 与 `reminder` 播放完自动回到 `idle`。角色位于画面中部留白区，不占左侧调查列表、右侧刘看山问题列表或底部对白区；s01 现代文章和 s02 婴儿初醒阶段保持隐藏，s03 正式登场。

## 工程改动

- `godot/demo2/scripts/main.gd`：建立 `AnimatedSprite2D`、加载三态序列、绑定提问结果。
- `godot/demo2/data/ch1/demo2_ch1_manifest_v01.json`：manifest 升至 v01.1，登记动画绑定、帧率、尺寸与来源记录。
- `godot/demo2/assets/art/characters/liushan/`：运行帧、三态预览、机器可读 asset manifest 与授权来源记录。
- `godot/demo2/assets/art/README.md`：将 `CHAR_LIUSHAN_WHITE` 标记为已接入。

## 已完成校验

- 300 张运行帧均为 160×160 RGBA PNG。
- 三态帧数分别为 100 / 120 / 80，透明边角有效。
- 内容静态校验通过：14 scenes / 33 effects / 7 conditions；9 investigation objects / 5 shan prompts。
- 预览图：`godot/demo2/assets/art/characters/liushan/preview_states.jpg`。
- Godot 4.3 headless import、桌面运行和 Web release export 通过；导出日志确认三态帧资源进入 PCK。
- Godot Movie Maker 115 帧视觉巡检通过：s03 起角色可见，进入 s05 后仍不遮挡调查/问答/对白区域；提问时出现电脑动作帧。
- 运行截图：`godot/demo2/docs/run-2026-09-14-liushan/01_s03_liushan_idle.png`、`02_s05_liushan_question.png`。

## DSH 回归项

1. Godot 4.3 启动后确认 s03 起角色可见，s01/s02 隐藏。
2. 成功提问播放 `question`；信息不足与次数耗尽播放 `reminder`；播放完回待机。
3. 1280×720 与窄窗口下确认角色不遮挡调查、提问和对白控件。
4. 重新导出 Web，确认动态路径资源全部进入 PCK，首次加载时间可接受。
5. 复跑五路线冒烟与保存/读档，确认纯视觉接入不改变状态机。
