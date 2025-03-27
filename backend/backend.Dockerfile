# Use official Node.js LTS image with Alpine (smaller size)
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files first for better layer caching
COPY package.json package-lock.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy the rest of the application
COPY . .

# Ensure proper file permissions
RUN chown -R node:node /app
USER node

# Expose the port (informational only)
EXPOSE 5000

# Health check (optional but recommended)
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:5000/api/health || exit 1

# Start command (using exec form)
CMD ["node", "server.js"]

