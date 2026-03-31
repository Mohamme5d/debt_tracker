# ── Stage 1: Build Angular ────────────────────────────────────────────────────
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --silent
COPY . .
ARG BUILD_CONFIGURATION=production
RUN npm run build -- --configuration ${BUILD_CONFIGURATION}

# ── Stage 2: Serve with nginx ─────────────────────────────────────────────────
FROM nginx:alpine
COPY --from=build /app/dist/ijari-web/browser /usr/share/nginx/html
COPY nginx-spa.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
