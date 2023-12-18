# Use a base Node.js image
FROM node:18-slim

# Set the working directory to /app
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port that the server listens on (backend_b)
EXPOSE 3000

# Start the server
CMD ["npm", "start"]