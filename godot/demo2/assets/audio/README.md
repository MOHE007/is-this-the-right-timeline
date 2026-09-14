# Demo2 第一章音频接入区

音频制作清单见 `docs/production/demo2_ch1_audio_brief_v01.md`。Logic Pro 交付时请使用清单中的 `resource_id` 命名，不要直接覆盖旧版本。

目录约定：

- `bgm/`：可循环背景音乐，48 kHz / 24-bit WAV 母版。
- `ambience/`：环境循环，保留无缝循环点。
- `sfx/`：短一次性反馈音效。
- `source_logic/`：Logic Pro 工程、分轨和可编辑源文件。

DSH Desktop 负责将 WAV 转为 Web 运行时 OGG、登记 manifest、挂接场景事件并做浏览器音量检查。对白暂不配音。
