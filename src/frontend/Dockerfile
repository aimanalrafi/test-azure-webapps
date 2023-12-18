# Use a base Node.js image
FROM node:alpine

# Set the working directory to /app
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port that the server listens on (backend_a)
EXPOSE 3001

# Start the server
CMD ["npm", "start"]