# syntax=docker/dockerfile:1
# Build and run CoreDNS in a distroless container
FROM golang:1.24-bookworm AS builder

ARG COREDNS_VERSION=v1.12.1

RUN \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt/archives,sharing=locked \
    apt update && apt install -y --no-install-recommends \
    ca-certificates libcap2-bin

WORKDIR /build
RUN \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    git clone -b ${COREDNS_VERSION} --depth=1 https://github.com/coredns/coredns.git && \
    cd coredns && \
    GOFLAGS="-buildvcs=false" make && ls

FROM gcr.io/distroless/static-debian12:nonroot

USER nonroot:nonroot

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder --chown=nonroot:nonroot /build/coredns/coredns /opt/coredns

WORKDIR /opt
VOLUME ["/etc/coredns"]
EXPOSE 53/udp 53/tcp

ENTRYPOINT ["/opt/coredns"]
CMD ["-conf", "/etc/coredns/Corefile"]

LABEL org.opencontainers.image.version="v1.12.1"
LABEL org.opencontainers.image.revision="20250501-01"
LABEL org.opencontainers.image.source=https://github.com/carme-264pp/coredns-docker
LABEL org.opencontainers.image.description="coredns-docker"
LABEL org.opencontainers.image.licenses=MIT
