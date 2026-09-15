import http from 'node:http';
import { existsSync } from 'node:fs';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createOAuth } from './lib/oauth.mjs';

const root = path.dirname(fileURLToPath(import.meta.url));
const config = JSON.parse(await readFile(path.join(root, 'hackathon.config.json'), 'utf8'));
const publicDir = path.join(root, 'public');
const oauth = createOAuth(config);
const runtimeHost = process.env.HOST || (process.env.PORT ? '0.0.0.0' : config.host);
const runtimePort = Number(process.env.PORT || config.port);
const types = new Map([['.html', 'text/html; charset=utf-8'], ['.css', 'text/css; charset=utf-8'], ['.js', 'text/javascript; charset=utf-8']]);

function headers(type = 'application/json; charset=utf-8') {
  return {
    'Content-Type': type, 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff',
    'Referrer-Policy': 'no-referrer',
    'Content-Security-Policy': "default-src 'self'; img-src 'self' https: data:; style-src 'self'; script-src 'self'; connect-src 'self'; base-uri 'none'; frame-ancestors 'none'",
  };
}
function json(response, status, payload) { response.writeHead(status, headers()); response.end(JSON.stringify(payload)); }
function redirect(response, location) { response.writeHead(302, { Location: location, 'Cache-Control': 'no-store', 'Referrer-Policy': 'no-referrer' }); response.end(); }

// Only these origins may receive the postMessage relay, so the flow cannot be
// turned into an open redirect or used to leak a session to another site.
const ALLOWED_RELAY_HOSTS = new Set(['mohe007.github.io']);
function safeRelayOrigin(raw) {
  if (!raw) return null;
  try {
    const parsed = new URL(raw);
    if (parsed.protocol !== 'https:' && parsed.protocol !== 'http:') return null;
    const host = parsed.hostname;
    if (ALLOWED_RELAY_HOSTS.has(host) || host === '127.0.0.1' || host === 'localhost') return parsed.origin;
    return null;
  } catch { return null; }
}

const server = http.createServer(async (request, response) => {
  const url = new URL(request.url, `http://${config.host}:${config.port}`);
  try {
    if (request.method === 'GET' && url.pathname === '/api/health') return json(response, 200, { ok: true, project: config.projectName, oauthEnabled: true });
    if (request.method === 'GET' && url.pathname === '/api/oauth/status') return json(response, 200, { ok: true, ...(await oauth.status(request, response)) });
    if (request.method === 'GET' && url.pathname === '/api/oauth/summary') return json(response, 200, { ok: true, ...(await oauth.summary(request, response)) });
    if (request.method === 'GET' && url.pathname === '/api/oauth/relay') return json(response, 200, { ok: true, ...oauth.relay(request, response) });
    if (request.method === 'GET' && url.pathname === '/api/oauth/start') {
      const mode = url.searchParams.get('mode') === 'popup' ? 'popup' : null;
      const origin = safeRelayOrigin(url.searchParams.get('origin'));
      if (mode) oauth.setRelay(request, response, { origin, mode });
      try { return redirect(response, await oauth.start(request, response)); }
      catch (error) { oauth.record(request, response, error); return redirect(response, '/?oauth=error'); }
    }
    if (request.method === 'GET' && url.pathname === '/auth/callback') {
      const relay = oauth.relay(request, response);
      const popupLanding = relay.mode === 'popup' ? '/zhihu-popup.html' : '/?oauth=success';
      try { await oauth.callback(request, response, url); return redirect(response, popupLanding); }
      catch (error) { oauth.record(request, response, error); return redirect(response, relay.mode === 'popup' ? '/zhihu-popup.html?oauth=error' : '/?oauth=error'); }
    }
    if (request.method === 'POST' && url.pathname === '/api/oauth/run-all') return json(response, 200, { ok: true, results: await oauth.runAll(request, response) });
    if (request.method === 'POST' && url.pathname === '/api/oauth/logout') { oauth.logout(request, response); return json(response, 200, { ok: true }); }
    if (request.method !== 'GET') return json(response, 405, { ok: false, error: { message: '不支持的请求方法' } });
    const requested = url.pathname === '/' ? '/index.html' : url.pathname;
    const filePath = path.join(publicDir, path.normalize(requested));
    if (!filePath.startsWith(publicDir) || !existsSync(filePath)) return json(response, 404, { ok: false, error: { message: '页面不存在' } });
    response.writeHead(200, headers(types.get(path.extname(filePath)) || 'application/octet-stream'));
    response.end(await readFile(filePath));
  } catch (error) { json(response, 401, { ok: false, error: { code: error.code || 'REQUEST_FAILED', message: error.message } }); }
});

server.listen(runtimePort, runtimeHost, () => process.stdout.write(`${config.projectName}: http://${runtimeHost}:${runtimePort}/\n`));
for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => server.close(() => process.exit(0)));
