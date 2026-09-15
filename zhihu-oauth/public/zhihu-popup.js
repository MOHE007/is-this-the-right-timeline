// Popup landing logic for the in-game Zhihu connection.
//
// Kept in an external file (not inline) because the service sends
// `Content-Security-Policy: script-src 'self'`, which blocks inline scripts.
//
// This page is same-origin with the API, so it reads the session here and
// relays the result to the game window — the game never calls the API
// cross-origin, so there are no CORS or third-party cookie problems.
//
// The summary walks five account interfaces and each upstream call can take
// many seconds, so the connection result is relayed immediately and the counts
// follow as a second message.
(async () => {
  const params = new URLSearchParams(location.search);
  const failed = params.get('oauth') === 'error';

  let relayOrigin = '*';
  try {
    const relay = await fetch('/api/oauth/relay').then((r) => r.json());
    if (relay && relay.origin) relayOrigin = relay.origin;
  } catch (error) { /* fall back to '*' */ }

  const send = (payload) => {
    try {
      if (window.opener && !window.opener.closed) window.opener.postMessage(payload, relayOrigin);
    } catch (error) { /* the player can retry */ }
  };

  const stamp = document.getElementById('stamp');
  const title = document.getElementById('title');
  const detail = document.getElementById('detail');
  const closeButton = document.getElementById('close');

  let status = null;
  try {
    status = await fetch('/api/oauth/status', { headers: { accept: 'application/json' } }).then((r) => r.json());
  } catch (error) { /* treated as failure below */ }

  const ok = !failed && status && status.authorized;
  const profile = (status && status.profile) || {};

  // 1. Relay the connection result right away so the game can update.
  send({
    type: 'ithrtt-zhihu',
    status: ok ? 'ok' : 'error',
    name: profile.name || null,
    avatar: profile.avatarUrl || null,
    headline: profile.headline || null,
    url: profile.url || null,
    counts: null,
    message: (status && status.error && status.error.message) || null,
  });

  stamp.textContent = ok ? '✓' : '×';
  title.textContent = ok ? '已连接知乎' : '授权未完成';
  if (ok) {
    detail.innerHTML = profile.name
      ? '账号：<span class="name">' + profile.name + '</span><br />正在读取你的创作 / 关注 / 收藏…'
      : '正在读取你的创作 / 关注 / 收藏…';
  } else {
    detail.textContent = (status && status.error && status.error.message) || '请回到游戏重试，或检查知乎开放平台的回调登记。';
  }
  closeButton.hidden = false;
  closeButton.addEventListener('click', () => window.close());

  if (!ok) return;

  // 2. Counts arrive separately; give up quietly if the interfaces are slow.
  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 25000);
    const summary = await fetch('/api/oauth/summary', { signal: controller.signal }).then((r) => r.json());
    clearTimeout(timer);
    const counts = (summary && summary.counts) || {};
    send({ type: 'ithrtt-zhihu', status: 'ok', name: profile.name || null, counts, update: true });
    detail.innerHTML = '账号：<span class="name">' + (profile.name || '已连接') + '</span><br />创作 '
      + (counts.contents || 0) + ' · 关注 ' + (counts.followees || 0) + ' · 收藏夹 ' + (counts.favlists || 0);
  } catch (error) {
    detail.innerHTML = '<span class="name">' + (profile.name || '已连接') + '</span><br />账号数据读取较慢，可以直接开始游戏。';
  }

  setTimeout(() => window.close(), 2500);
})();
