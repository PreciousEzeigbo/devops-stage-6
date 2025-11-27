FROM node:12-alpine AS builder

WORKDIR /app
RUN apk add --no-cache python2 make g++

COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY . .
RUN npm run build

FROM node:20-alpine

WORKDIR /app

RUN npm install -g http-server
COPY --from=builder /app/dist /app/dist

EXPOSE 8080

CMD ["http-server", "dist", "-p", "8080", "--proxy", "http://localhost:8080?"]