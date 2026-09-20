# Stage 1: Builder - Install dependencies
FROM node:25-alpine AS builder

# Install git (required for npm to install dependencies from GitHub)
RUN apk add --no-cache git

WORKDIR /app

# Copy package files to leverage Docker layer caching
COPY package.json package-lock.json* ./

# Install production dependencies
RUN npm install

# Stage 2: Runner - Copy application code and execute
FROM node:25-alpine

# Install git in runtime stage so NodeLink can perform runtime git checks
RUN apk add --no-cache git

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy application source code
COPY src/ ./src/
COPY config.default.ts ./config.default.ts
COPY package.json ./package.json

# Create required directories and grant ownership to default non-root node user (UID 1000)
RUN mkdir -p /app/plugins /app/dist && \
    chown -R node:node /app

# Run as non-root user
USER node

# Expose port
EXPOSE 3000

# Set environment variables for runtime configuration
ENV NODELINK_SERVER_PORT=3000 \
    NODELINK_SERVER_HOST=0.0.0.0 \
    NODELINK_CLUSTER_ENABLED=true

# Start application
CMD ["npm", "start"]
