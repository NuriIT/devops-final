# Use official Node.js image
FROM node:18

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy backend source code
COPY . .

# Expose the port
EXPOSE 5000

# Start the backend
CMD ["node", "index.js"]
