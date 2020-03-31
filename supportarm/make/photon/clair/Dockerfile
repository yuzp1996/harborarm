FROM golang:1.12.12 as builder

ADD .   /go/src/github.com/coreos/
WORKDIR /go/src/github.com/coreos/
RUN git clone https://github.com/coreos/clair.git
WORKDIR /go/src/github.com/coreos/clair/

RUN git checkout v2.1.0 && export CLAIR_VERSION=$(git describe --tag --always --dirty) && \
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags "-X github.com/coreos/clair/pkg/version.Version=$CLAIR_VERSION" github.com/coreos/clair/cmd/clair

FROM photon:3.0

RUN tdnf install -y git shadow sudo rpm xz python-xml >>/dev/null\
    && tdnf clean all \
    && mkdir /clair/ \
    && mkdir /harbor \
    && groupadd -r -g 10000 clair \
    && useradd --no-log-init -m -r -g 10000 -u 10000 clair
COPY --from=builder /go/src/github.com/coreos/clair/clair /clair/
COPY ./make/photon/clair/docker-entrypoint.sh /docker-entrypoint.sh
COPY ./supportarm/make/photon/clair/dumb-init /dumb-init
COPY ./make/photon/common/install_cert.sh /harbor

VOLUME /config

EXPOSE 6060 6061

RUN chown -R 10000:10000 /clair \
    && chmod u+x /clair/clair \
    && chmod u+x /docker-entrypoint.sh \
    && chmod +x /dumb-init

HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1:6061/health || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]