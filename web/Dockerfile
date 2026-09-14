# 静态站镜像：把 Godot Web 导出产物放进 nginx，部署到 Sealos。
# 构建上下文是仓库根目录（需要 demo2-web/）。
FROM nginx:alpine

# 覆盖默认站点配置：正确的 wasm MIME、gzip、缓存策略。
COPY web/nginx.conf /etc/nginx/conf.d/default.conf

# 游戏产物（相对路径引用，可放在站点根）。
COPY demo2-web/ /usr/share/nginx/html/

EXPOSE 80
