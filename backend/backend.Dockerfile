# Use official Node.js image as base
FROM node:18

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (for caching npm install)
COPY package.json package-lock.json ./

# Install app dependencies
RUN npm install

# Copy the rest of the application code into the container
COPY . .

# Expose port 5000 (make sure this is the port your app is using)
EXPOSE 5000

# Set environment variables (optional, can be done in Kubernetes or as docker run params)
# ENV NODE_ENV=production

# Start the backend application
CMD ["node", "index.js"]

