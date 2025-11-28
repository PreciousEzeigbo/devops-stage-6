FROM node:20-alpine

WORKDIR /app

COPY todos-api/package*.json ./

RUN npm install

COPY todos-api/ .

EXPOSE 8082

CMD ["node", "server.js"]