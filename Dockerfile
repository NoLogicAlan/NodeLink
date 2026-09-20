# Stage 1: Build TypeScript source
FROM oven/bun:alpine AS builder

WORKDIR /app

COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile || bun install

COPY . .
RUN bun run build || true

# Stage 2: Runtime
FROM oven/bun:alpine AS runner

WORKDIR /app

ENV NODE_ENV=production \
    NODELINK_SERVER_PORT=2333 \
    NODELINK_SERVER_HOST=0.0.0.0

COPY package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

RUN chown -R 1000:1000 /app
USER 1000

EXPOSE 2333

CMD ["bun", "run", "dist/index.js"]
