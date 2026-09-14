# Demo2 第一章音频接入区

音频制作清单见 `docs/production/demo2_ch1_audio_brief_v01.md`。Logic Pro 交付时请使用清单中的 `resource_id` 命名，不要直接覆盖旧版本。

目录约定：

- `bgm/`：可循环背景音乐，48 kHz / 24-bit WAV 母版。
- `ambience/`：环境循环，保留无缝循环点。
- `sfx/`：短一次性反馈音效。
- `source_logic/`：Logic Pro 工程、分轨和可编辑源文件。

DSH Desktop 负责将 WAV 转为 Web 运行时 OGG、登记 manifest、挂接场景事件并做浏览器音量检查。对白暂不配音。

当前 manifest 已预登记音频 resource_id；文件到位后按 ID 放入对应目录即可。P0 清单共 16 项，P1 为辛弃疾入口和细节增强音效。

P0 的 16 项是：`AUD_BGM_INK_MAIN_01`、`AUD_BGM_RECALL_TENSION_01`、`AUD_BGM_ENDING_QUIET_01`；`AUD_AMB_INDOOR_PAPER_01`、`AUD_AMB_FERRY_MIST_01`、`AUD_AMB_MILITARY_TOWN_01`；以及纸张翻页、印章、按钮、拾取、验证、时间线、转场、墨扩散、路线连通、锁定反馈 10 个 SFX。完整时长、场景和 Logic Pro 参数见制作包音频交付单。
