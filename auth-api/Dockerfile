FROM golang:1.21.1-alpine

WORKDIR /app

COPY auth-api/go.mod auth-api/go.sum ./
RUN go mod download

COPY auth-api/ .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o auth-api .

EXPOSE 8081

CMD ["./auth-api"]