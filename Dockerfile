# =============================================
# Dockerfile — Frontend Innovatech Chile
# React + Vite → Nginx
# Multi-stage build | Usuario no-root
# =============================================

# ── Stage 1: BUILD ───────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY . .

ARG VITE_API_VENTAS
ARG VITE_API_DESPACHOS
ENV VITE_API_VENTAS=$VITE_API_VENTAS
ENV VITE_API_DESPACHOS=$VITE_API_DESPACHOS

RUN npm run build

# ── Stage 2: PRODUCCIÓN ──────────────────────
FROM nginx:1.25-alpine AS production

RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/dist /usr/share/nginx/html

RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown appuser:appgroup /var/run/nginx.pid

USER appuser

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]