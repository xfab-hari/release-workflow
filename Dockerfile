# Use the official Golang image as the build stage
FROM golang:1.23.4 as builder

# Set environment variables
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Create and set the working directory
WORKDIR /app

# Copy go.mod and go.sum files for dependency resolution
COPY backend/go.mod backend/go.sum ./
RUN go mod download

# Copy the entire backend source directory
COPY backend/ ./backend/

# Build the Go application
WORKDIR /app/backend
RUN go build -o /app/backend-app main.go

# Use a minimal image for the runtime
FROM alpine:latest

# Install essential dependencies (optional if needed for runtime)
RUN apk --no-cache add ca-certificates

# Set the working directory
WORKDIR /root/

# Copy the binary from the build stage
COPY --from=builder /app/backend-app .

# Expose the port your app listens on
EXPOSE 8080

# Run the binary
CMD ["./backend-app"]
