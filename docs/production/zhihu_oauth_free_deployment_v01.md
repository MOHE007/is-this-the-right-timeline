# 知乎 OAuth 接入与免费部署方案 v0.1

**项目**：这真的是对的时间线吗？  
**日期**：2026-09-14  
**状态**：本地初始化完成；等待公网部署与 Access Secret

## 已完成

- 按 `zhihu-hackathon-skill_v2026s2.zip` 安装并校验知乎 Hackathon Skill。
- 初始化独立 OAuth 服务目录：`zhihu-oauth/`。
- `oauth.enabled=true`，App ID 已写入 `hackathon.config.json`。
- OAuth App Key 已通过 Skill 的 `set_app_key.mjs` 写入 macOS 钥匙串，不进入代码、日志或 Git。
- 官方 `zhihu` Skill 已安装到 `zhihu-oauth/.codex/skills/zhihu/`。
- 官方 CLI 0.6.0 已安装到用户目录并通过兼容性检查。
- `npm test`、`npm run check`、`/api/health`、`/api/oauth/status` 全部通过。

## 免费部署组合

采用双服务：

1. **OAuth 后端：Render Free（优先）**。`render.yaml` 已提供 Node 22、`npm ci`、`npm start` 和两个 Secret 占位。Render 免费实例会休眠，进程重启后 OAuth 内存会话清空，用户需要重新授权。
2. **游戏静态包：GitHub Pages**。继续使用现有 Godot Web 构建/发布流程；OAuth Node 服务不能直接放 Pages。Cloudflare Pages 可作为静态包备选，但当前 Godot wasm 文件可能触及单文件限制。
3. **国内备选：Sealos**。用同一 Node 22 服务部署，注入相同两个 Secret；具体免费额度以账号页面为准。

## Render 操作步骤

在 Render 新建 Web Service，连接此 GitHub 仓库：

- Root Directory：`zhihu-oauth`
- Runtime：Node
- Node：22
- Build Command：`npm ci`
- Start Command：`npm start`
- Plan：Free

添加 Secret 环境变量：

- `ZHIHU_OAUTH_APP_KEY`：OAuth App Key（不是 App ID）
- `ZHIHU_ACCESS_SECRET`：知乎开放平台 Access Secret（不是 OAuth App Key）

部署后得到 `https://<service>.onrender.com`，再执行：

```bash
node /Users/mac/.codex/skills/zhihu-hackathon/scripts/configure_callback.mjs \
  --project-dir /Users/mac/Downloads/比赛用/is-this-the-right-timeline/zhihu-oauth \
  --redirect-uri https://<service>.onrender.com/auth/callback
```

把完全相同的 HTTPS 地址登记到知乎开放平台，然后重新部署。回调地址不能使用 `localhost` 或 `127.0.0.1`。

## 尚待队长操作

- 在 Render 或 Sealos 登录并创建免费服务。
- 从知乎开放平台获取 Access Secret，并通过平台 Secret 注入；不要发到聊天或写入文件。
- 将部署后的公网 `/auth/callback` 地址登记到知乎开放平台。
- 用户本人在部署后的页面点击最终授权确认。

## 安全边界

App ID `496` 属于公开配置；OAuth App Key 只存钥匙串/平台 Secret。Access Secret 由官方 `zhihu` Skill 管理或存平台 Secret。OAuth Token 只在 Node 进程内存中保存。服务重启会丢失会话，这是当前 Hackathon 模板的已知限制。
