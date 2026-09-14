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

## 部署结果（2026-09-14 完成）

- **公网地址**：`https://ifesrjkdxats.cloud.sealos.io`（Sealos 新加坡区，Free 套餐）。
- **镜像**：`ghcr.io/mohe007/zhihu-oauth:latest`（GitHub Actions 自动构建，public）。
- **回调**：`https://ifesrjkdxats.cloud.sealos.io/auth/callback`，经 `ZHIHU_REDIRECT_URI` 环境变量注入（`lib/oauth.mjs` 支持 env 覆盖，改 URL 不用重打镜像）。
- **密钥**：`ZHIHU_OAUTH_APP_KEY` / `ZHIHU_ACCESS_SECRET` 以 Sealos 环境变量注入，值在 macOS 钥匙串，不入库。
- **实测**：`/api/health` `{ok:true,oauthEnabled:true}`；`/api/oauth/status` `configured:true, callbackConfigured:true`。

## 尚待队长操作

- **从知乎开放平台登记回调地址** `https://ifesrjkdxats.cloud.sealos.io/auth/callback`（DSH 无知乎账号，无法代办）。
- **用户本人在部署后的页面点击最终授权确认**（`/` 页面点「连接知乎」）。

## Sealos 操作步骤（队长已定：改用 Sealos）

> 2026-09-14 更新：Render 需 Stripe 卡片验证，已弃用；改走 Sealos。DSH 已用 GitHub 授权进入 Sealos 工作台（新加坡区，余额 ¥5），但被「绑定手机号」合规门槛拦下——此步必须队长本人收短信完成。绑好后按下面走，或通知 DSH 继续。

1. 队长在 Sealos 完成「绑定手机号」（手机号 + 短信验证码）。新加坡区不强制实名。
2. 进入「应用管理 → 新建应用」；来源选「镜像构建 / 从 Dockerfile」，指向本仓库 `zhihu-oauth/`（已提供 `Dockerfile`，Node 22、EXPOSE 4173、`npm start`）。
3. 配置端口：容器端口 `4173`，开启公网访问，记下分配的 HTTPS 域名（形如 `https://xxx.cloud.sealos.io`）。
4. 添加 Secret 环境变量（值在 macOS 钥匙串，不要写进文件/聊天）：
   - `ZHIHU_OAUTH_APP_KEY` ← 钥匙串 `security find-generic-password -s "zhihu-hackathon:这真的是对的时间线吗:ca830503c8" -a oauth-app-key -w`
   - `ZHIHU_ACCESS_SECRET` ← 钥匙串 `security find-generic-password -s zhihu-cli -a access-secret -w`
5. 部署后得到公网地址，执行回调配置（把 `<公网域名>` 换成实际值）：

```bash
node /Users/mac/.codex/skills/zhihu-hackathon/scripts/configure_callback.mjs \
  --project-dir /Users/mac/Downloads/比赛用/is-this-the-right-timeline/zhihu-oauth \
  --redirect-uri https://<公网域名>/auth/callback
```

6. 把完全相同的 HTTPS 地址登记到知乎开放平台，重新部署。
7. 公网 `/api/health` 返回 `{ok:true, oauthEnabled:true}` 即成功。

## 安全边界

App ID `496` 属于公开配置；OAuth App Key 只存钥匙串/平台 Secret。Access Secret 由官方 `zhihu` Skill 管理或存平台 Secret。OAuth Token 只在 Node 进程内存中保存。服务重启会丢失会话，这是当前 Hackathon 模板的已知限制。
