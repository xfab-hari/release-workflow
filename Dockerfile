# Arguments for easy customization
ARG GO_VERSION=1.23.4
ARG DEBIAN_VERSION=bullseye-slim

# Stage 1: Build stage
FROM golang:${GO_VERSION} AS backend-builder

# Set working directory
WORKDIR /app

# Copy and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy application source and build
COPY . .
WORKDIR /app/backend
RUN go build -o release-workflow main.go

# Stage 2: Final stage (Distroless or Slim image)
FROM debian:${DEBIAN_VERSION}

# Add a non-root user
RUN useradd -m appuser
USER appuser

# Set working directory
WORKDIR /app

# Copy the built binary from the previous stage
COPY --from=backend-builder /app/backend/release-workflow /app/release-workflow

# Add metadata
LABEL maintainer="Your Name <your.email@example.com>"
LABEL version="1.0"
LABEL description="Release workflow application."

# Set the entrypoint
ENTRYPOINT ["/app/release-workflow"]


# -------






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
