FROM golang:1.24

# Download Go modules
COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./
COPY ./internal ./internal

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o /docker-todo
EXPOSE 8080

# Run
CMD ["/docker-todo"]
