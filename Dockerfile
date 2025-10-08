# syntax=docker/dockerfile:1
# Build and run CoreDNS in a distroless container
ARG BUILDER_IMAGE=golang:1.24-bookworm
ARG BASE_IMAGE=gcr.io/distroless/static-debian12:nonroot

FROM ${BUILDER_IMAGE} AS builder

ARG COREDNS_VERSION

WORKDIR /build

COPY plugin.cfg* /build/

RUN \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt/archives,sharing=locked \
    apt update && apt install -y --no-install-recommends \
    ca-certificates

RUN \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    git clone -b ${COREDNS_VERSION} --depth=1 https://github.com/coredns/coredns.git && \
    cd coredns && \
    if [ -f "/build/plugin.cfg" ]; then cp /build/plugin.cfg ./plugin.cfg ; fi && \
    GOFLAGS="-buildvcs=false" make

FROM ${BASE_IMAGE}

ARG COREDNS_VERSION
ARG BUILD_REVISION

USER nonroot:nonroot

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder --chown=nonroot:nonroot /build/coredns/coredns /opt/coredns

WORKDIR /opt
VOLUME ["/etc/coredns"]
EXPOSE 53/udp 53/tcp

ENTRYPOINT ["/opt/coredns"]
CMD ["-conf", "/etc/coredns/Corefile"]

LABEL org.opencontainers.image.version=${COREDNS_VERSION}-${BUILD_REVISION} \
    org.opencontainers.image.revision=${BUILD_REVISION} \
    org.opencontainers.image.source=https://github.com/carme-264pp/coredns-docker \
    org.opencontainers.image.description="coredns-docker" \
    org.opencontainers.image.licenses=MIT
