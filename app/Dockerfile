# Multi-stage lightweight Dockerfile
FROM node:20-alpine AS base

WORKDIR /usr/src/app

# Copy package definition and install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application source
COPY . .

# Set environment
ENV PORT=3000
ENV NODE_ENV=production

# Run with non-privileged user for security best practice
USER node

EXPOSE 3000

CMD ["node", "server.js"]
