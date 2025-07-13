FROM node:14  # Base image for the app
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000   # Assuming the app runs on port 3000
CMD ["npm", "start"]
