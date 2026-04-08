# Build stage
FROM golang:1.25-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# Build the cloud server (no CGO, no GUI deps).
RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/shape-server ./cmd/shape-server

# Build the propagation Lambda handler.
RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/propagate ./cmd/propagate

# Runtime stage - minimal image.
FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=build /bin/shape-server /bin/shape-server
COPY --from=build /bin/propagate /bin/propagate
EXPOSE 8080
ENTRYPOINT ["/bin/shape-server"]
