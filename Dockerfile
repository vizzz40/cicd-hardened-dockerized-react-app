# syntax=docker/dockerfile:1.7

FROM node:24-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm npm ci

COPY . .
RUN npm run build

FROM cgr.dev/chainguard/nginx:latest AS runtime

LABEL org.opencontainers.image.title="Hardened React task board" \
      org.opencontainers.image.description="Non-root production image for the DevBoard React application" \
      org.opencontainers.image.source="https://github.com/vizzz40/cicd-hardened-dockerized-react-app"

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build --chown=65532:65532 /app/dist /usr/share/nginx/html

USER 65532
EXPOSE 8080
