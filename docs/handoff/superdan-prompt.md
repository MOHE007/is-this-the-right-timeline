# 超级真蛋执行提示词：读取仓库并完成第一章美术 / UI 接入

请先把本仓库完整拉取到本地，再开始任何创作或代码修改。仓库地址：

<https://github.com/MOHE007/is-this-the-right-timeline>

## 目标

在保持第一章叙事契约、公开仓库安全和现有 Demo 可运行的前提下，完成第一章的美术、UI、分镜和必要的运行时接入。优先交付一个可审阅、可运行、可回滚的垂直切片，不要重写项目方向。

## 读取顺序

```bash
git clone https://github.com/MOHE007/is-this-the-right-timeline.git
cd is-this-the-right-timeline
git checkout main
git pull --ff-only origin main
```

依次读取：

1. `README.md`：项目定位、三章玩法、技术路线和 IP 边界。
2. `docs/ch1-jingkang.md`：第一章叙事、镜头、视觉和团队分工。
3. `docs/production/00_ch1_vertical_slice_freeze.md`：冻结范围、交付物和 `scene_id` 契约。
4. `docs/production/demo2_ch1_script_v01.md`：逐幕对白、线索、UI 文案和结局。
5. `docs/production/demo2_ch1_implementation_v01.md`：节点、槽位、状态条件、资源 ID 和验收约束。
6. `docs/production/marvis-qa-and-ch1-kickoff.md`：协作、审校和提交规范。
7. `data/ch1/demo2_ch1_state_v01.json`、`demo2_ch1_content_v01.json`、`demo2_ch1_manifest_v01.json`：运行时真实数据。
8. `demo1/`：现有可运行 Demo 的结构和交互，改动前先本地运行确认。

## 必须保持的契约

- 14 个 `scene_id` 只能使用：
  `s01_modern_article`、`s02_baby_home`、`s03_baby_liushanshan`、`s04_growth_1127`、`s05_station`、`s06_ferry`、`s07_military_town`、`s08_yuefei_countdown`、`s09_recall_chain`、`s10_intervention`、`s11_outcome_router`、`s12_leave_or_continue`、`s13_exit_chapter`、`s14_xinqiji_intro`。
- 选择分支先进入 `s11_outcome_router`，再依据 branch 路由到结局和 `s12_leave_or_continue`。
- 结局 ID 只有 `ending_divergent`、`ending_canonical`、`ending_truth`。
- 资源交接只认 `scene_id`、`node_id`、`resource_id`、`ui_slot`；不要把文件名或节点路径当跨模块 API。
- 不得出现 `s07_unrecalled` 或 `s08_history_continues`。
- 不得提交 app_key、access_secret、token、API key、个人账号信息或任何真实凭证。
- 不得复制或提交知乎官方刘看山素材包、官方 Logo 或未获授权的第三方素材。

## 美术 / UI 任务

按 `scene_id` 制作一套可运行的第一章资源包：

1. 为 `s01` 至 `s14` 给出镜头草案或分镜表，标明景别、构图、转场、情绪、旁白 / 对白承载方式和 `ui_slot`。
2. 建立水墨风格板：宣纸底、墨黑层次、低饱和青灰、朱砂只用于诏书 / 选择确认 / 关键时间线节点；现代宿舍使用冷白屏幕光，穿越使用墨迹扩散和纸面折叠。
3. 制作角色 / 场景 / 道具的原创占位或最终素材，优先覆盖：现代宿舍、婴儿之家、驿站、渡口、军镇、岳飞倒计时、时间线面板、三类线索卡、刘看山问答面板。
4. 设计并实现 `dialogue_panel`、`choice_panel`、`shan_panel`、`evidence_panel`、`timeline_panel`、`toast` 六类 UI 状态；窄屏仍可读，按钮触控区域至少 44×44 px。
5. 为缺失资源准备低对比度灰宣纸占位，不得让资源缺失阻塞流程。
6. 把资源元数据写入或补充 `data/ch1/demo2_ch1_manifest_v01.json`，并保持 JSON 可解析；需要新增文件时使用清晰的 `assets/` 子目录和稳定 `resource_id`。
7. 若修改 `demo1/`，必须保留离线可玩和三结局路线；先截图前后对比，再提交。

## 实现与验证

```bash
python3 -m http.server 4173 --directory demo1
```

验证首页、开始、调查、线索收集、提问、选择和三结局；检查浏览器控制台无错误；检查手机宽度布局；验证 JSON 解析和路径大小写。提交前运行：

```bash
rg -n 's07_unrecalled|s08_history_continues' .
rg -n -i 'app[_-]?key|access[_-]?secret|api[_-]?key|access token|secret|token' .
git diff --check
```

第二条命令命中时逐条确认只是说明性文字；严禁出现凭证值。不要提交 `.docx`、`.pdf`、`.zip`、QA 截图、`node_modules` 或官方 IP 素材。

## 提交要求

- 从 `main` 创建短分支，例如 `feat/ch1-art-ui-superdan`。
- 每个提交只做一类事情，提交信息使用中文或 Conventional Commits。
- PR 描述写清：完成的 `scene_id` / `ui_slot`、资源来源与授权、运行步骤、截图、已知缺口。
- 不要强推 `main`、不要删除已有文件、不要覆盖 `promo-ink-timeline.png`，除非明确说明并保留回滚方案。
- 完成后回报：分支、提交、PR 链接、改动文件、测试结果、未决美术选择，以及需要王凯 / 梁博森 / Marvis / DSH Desktop 决定的事项。

## 立即执行

先拉取并阅读上述文件，给出一页“现状 → 美术 / UI 任务拆解 → 依赖和风险”清单；随后直接完成不依赖外部决定的资源整理、分镜草案和 UI 接入。遇到历史事实或角色版权问题，暂停该单项并标记给审校，不要擅自编造或引入外部素材。
