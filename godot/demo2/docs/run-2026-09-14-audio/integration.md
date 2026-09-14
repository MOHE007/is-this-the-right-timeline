# 音频接入记录（demo2_ch1_audio_v01，2026-09-14）

来源：`/Users/mac/Downloads/比赛用/demo2_ch1_audio_v01.zip`（29 个 WAV，48 kHz / 24-bit 立体声，P0 16 + P1 10 + 3 变体）。

## 处理

- 全部转 OGG Vorbis 入库 `assets/audio/{bgm,ambience,sfx}/<RESOURCE_ID>_v01.ogg`：**51.9MB WAV → 1.8MB OGG**。
- manifest 注册 29 个音频绑定 + `audio_scene_map`（逐场景 BGM/环境）+ `audio_sfx_map`（10 个交互音效）。

## 接入结果（tools/probe_audio.gd 实测）

- 逐场景 BGM：s02–s03 仅环境；s04–s07 `AUD_BGM_INK_MAIN_01`；s08–s10 `AUD_BGM_RECALL_TENSION_01`；s11–s13 `AUD_BGM_ENDING_QUIET_01`；s14 `AUD_BGM_XINQiji_ACTION_01`。
- 环境：屋内 s02–s05、渡口 s06、军镇 s07–s10。
- SFX 10/10 加载：点击、拾取、验证、锁定、存档、读档、分支确认、时间跳跃、钤印、翻页。
- BGM/环境为无缝循环（`AudioStreamOggVorbis.loop = true`）；SFX 用 4 路播放池避免互相打断。

## 体积

- Web 包 `index.pck` 12.1MB → **14.2MB**（+1.8MB 音频）。
- 冒烟 5/5 + 存档往返全绿。
