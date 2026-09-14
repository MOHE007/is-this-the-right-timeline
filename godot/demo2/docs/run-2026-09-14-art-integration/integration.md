# 美术接入记录（超级真蛋交付 v01，2026-09-14）

来源：`/Users/mac/Downloads/比赛用/项目图片(1).zip`（PNG 原图，背景 1920×1080 / 角色 1024×1536 / 道具 1024×1024 / UI 1600×360…）

## 处理

- 转 WebP q90 入库 `godot/demo2/assets/art/{bg,characters,props,ui,fx}/`，命名 `<RESOURCE_ID>_v01.webp`。
- Godot 导入改为有损（`compress/mode=1`, `lossy_quality=0.9`）压缩纹理，PCK 44MB → 27.5MB。
- 字体子集化：Noto Sans SC 8.3MB → 173KB（按内容/脚本实际用字 702 字符，校验覆盖 100%）。
- UI 符号替换：`◻`/`✕` 字体不含，改为 `·`/`—`（`✓ ● ◆ · —` 均可用）。
- 清理被 `apk`… 无关；`tools/probe_art.gd` 新增，用于逐场景/逐说话人核对素材。

## 接入结果（`tools/probe_art.gd` 实测）

- 14 个场景背景 **全部加载**（`scene_visuals` → `assets.bindings`）。
- 说话人立绘按 `character_by_speaker` 切换：抚养者 / 老驿卒 / 迁徙者 / 岳飞 / 辛弃疾 → 立绘；刘看山 → 三态动画；旁白、系统、玩家 → 无立绘。
- 对话框套用 `UI_INK_DIALOGUE_FRAME`（9-slice 110/80）。

## 仍缺（归超级真蛋 P1）

- `CHAR_PLAYER_HAND`、`CHAR_MILITARY_COMPANION`（军中同伴目前无立绘）、`FX_RED_INK_SPREAD`。

## 体积

- Web 包：`index.pck` 20.0MB + `index.wasm` 35.4MB；五条 QA 冒烟 5/5 + 存档往返仍全绿。
