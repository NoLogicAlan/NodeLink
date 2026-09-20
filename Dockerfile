# Stage 1: Build & Dependencies
FROM oven/bun:alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json bun.lock* ./

# Install production dependencies using Bun
RUN bun install --production --frozen-lockfile || bun install --production

# Stage 2: Runtime
FROM oven/bun:alpine AS runner

WORKDIR /app

# Set production environment
ENV NODE_ENV=production \
    NODELINK_SERVER_PORT=2333 \
    NODELINK_SERVER_HOST=0.0.0.0

# Copy node_modules from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy application source code
COPY package.json ./
COPY src/ ./src/
COPY config.default.js* config.default.ts* ./

# Set standard non-root user permissions (UID 1000)
RUN chown -R 1000:1000 /app
USER 1000

# Expose NodeLink port
EXPOSE 2333

# Start NodeLink using Bun
CMD ["bun", "run", "src/index.js"]
