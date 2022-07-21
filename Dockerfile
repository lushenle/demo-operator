FROM golang:1.18 as builder
WORKDIR /app
ADD . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -installsuffix cgo -o ingress-manager main.go

# Based from alpine-glibc
FROM frolvlad/alpine-glibc:glibc-2.35
# Labels
LABEL "maintainer"="Shenle Lu <lushenle@gmail.com>" \
    "org.opencontainers.image.authors"="Shenle Lu <lushenle@gmail.com>" \
    "org.opencontainers.image.vendor"="Shenle Lu <lushenle@gmail.com>" \
    "org.opencontainers.image.ref.name"="ingress-manager" \
    "org.opencontainers.image.title"="ingress-manager v0.1" \
    "org.opencontainers.image.description"="k8s ingress manager tool"
# Working dir
WORKDIR /app
# Copy app from builder
COPY --from=builder /app/ingress-manager .

# Create user
RUN addgroup -g 65535 ishenle && \
    adduser --shell /sbin/nologin --disabled-password \
    --no-create-home --uid 65535 --ingroup ishenle ishenle

# Run the process as ishenle
USER ishenle

# Start app
CMD ["/app/ingress-manager"]
