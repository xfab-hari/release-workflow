# Stage 1: Build stage
FROM golang:1.23-alpine AS backend-builder

# Set the working directory
WORKDIR /workspace

# Copy Go modules and download dependencies
COPY go.mod go.sum ./
RUN go mod tidy

# Copy the source code
COPY . .

# Build the Go binary for different platforms
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o xfab ./backend
RUN CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -o xfab.exe ./backend
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o xfab-arm64 ./backend
RUN CGO_ENABLED=0 GOOS=windows GOARCH=arm64 go build -o xfab-arm64.exe ./backend

# Stage 2: Final image (multi-platform compatible)
FROM debian:bullseye-slim AS final

# Ensure platform compatibility
COPY --from=backend-builder /workspace/xfab /usr/local/bin/xfab
COPY --from=backend-builder /workspace/xfab.exe /usr/local/bin/xfab.exe
COPY --from=backend-builder /workspace/xfab-arm64 /usr/local/bin/xfab-arm64
COPY --from=backend-builder /workspace/xfab-arm64.exe /usr/local/bin/xfab-arm64.exe

ENTRYPOINT ["/usr/local/bin/xfab"]


# ### WORKING VERSION
# # Stage 1: Build stage
# FROM golang:1.23 AS backend-builder

# # Set the working directory
# WORKDIR /app

# # Copy Go modules manifests
# COPY go.mod go.sum ./

# # Download dependencies
# RUN go mod download

# # Copy the rest of the application source code
# COPY backend/ ./backend

# COPY cmd/ ./cmd

# # Build the Go application
# WORKDIR /app/backend
# RUN go build -o release-workflow main.go

# # Stage 2: Final stage
# FROM debian:bullseye-slim

# # Set the working directory
# WORKDIR /app

# # Copy the built binary from the previous stage
# COPY --from=backend-builder /app/backend/release-workflow /app/release-workflow

# # Set the entrypoint
# ENTRYPOINT ["/app/release-workflow"]







# # Use the official Golang image as the build stage
# FROM golang:1.23.4 as builder

# # Set environment variables
# ENV GO111MODULE=on \
#     CGO_ENABLED=0 \
#     GOOS=linux \
#     GOARCH=amd64

# # Create and set the working directory
# WORKDIR /app

# # Copy go.mod and go.sum files for dependency resolution
# COPY backend/go.mod backend/go.sum ./
# RUN go mod download

# # Copy the entire backend source directory
# COPY backend/ ./backend/

# # Build the Go application
# WORKDIR /app/backend
# RUN go build -o /app/backend-app main.go

# # Use a minimal image for the runtime
# FROM alpine:latest

# # Install essential dependencies (optional if needed for runtime)
# RUN apk --no-cache add ca-certificates

# # Set the working directory
# WORKDIR /root/

# # Copy the binary from the build stage
# COPY --from=builder /app/backend-app .

# # Expose the port your app listens on
# EXPOSE 8080

# # Run the binary
# CMD ["./backend-app"]
