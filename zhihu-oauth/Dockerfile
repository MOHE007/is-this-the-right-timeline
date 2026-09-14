# 知乎 Hackathon OAuth 服务容器镜像
# 纯 Node 内置模块，无 npm 依赖；PORT 触发 0.0.0.0 绑定。
FROM node:22-alpine

WORKDIR /app

COPY package.json hackathon.config.json server.mjs ./
COPY lib ./lib
COPY public ./public
COPY tests ./tests

ENV PORT=4173
EXPOSE 4173

CMD ["npm", "start"]
