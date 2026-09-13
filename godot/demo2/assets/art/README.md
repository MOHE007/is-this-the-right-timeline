# 梁博森美术接入区

把最终水墨资源放在本目录，文件名优先使用 manifest 中的 `resource_id`，例如：

```text
BG_INK_BABY_HOME_1122.png
UI_INK_DIALOGUE_FRAME.png
CHAR_LIUSHAN_WHITE.png
```

建议格式：PNG（透明角色/UI）、JPG 或 WebP（大背景），长边 2048px 以内；保持 16:9 构图安全区，重要主体避开右侧选择区和底部对白区。

首批风格锚点：

- `BG_INK_BABY_HOME_1122`
- `UI_INK_DIALOGUE_FRAME`
- `CHAR_LIUSHAN_WHITE`

接入时只替换资源文件或 manifest 映射，不修改 `scene_id`、`ui_slot` 和剧情 JSON。
