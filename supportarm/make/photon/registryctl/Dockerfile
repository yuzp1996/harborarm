FROM golang:1.12.12 as builder
ENV CGO_ENABLED 0
ENV GOOS linux
ENV GOARCH arm64
ADD . /go/src/github.com/goharbor/harbor
WORKDIR /go/src/github.com/goharbor/harbor/src/registryctl
RUN go build -o harbor_registryctl

ENV DISTRIBUTION_DIR /go/src/github.com/docker
ENV BUILDTAGS include_oss include_gcs

WORKDIR $DISTRIBUTION_DIR
COPY . $DISTRIBUTION_DIR

RUN git clone -b v2.7.1 https://github.com/docker/distribution.git
WORKDIR /go/src/github.com/docker/distribution

RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 make PREFIX=/go clean binaries


FROM photon:3.0

MAINTAINER wangyan@vmware.com

RUN tdnf install sudo -y >> /dev/null \
    && tdnf clean all \
    && groupadd -r -g 10000 harbor && useradd --no-log-init -r -g 10000 -u 10000 harbor \
    && mkdir -p /etc/registry \
    && mkdir /harbor/

COPY ./make/photon/common/install_cert.sh /harbor
COPY --from=builder /go/src/github.com/docker/distribution/bin/registry /usr/bin
COPY ./make/photon/registryctl/start.sh /harbor/
COPY --from=builder /go/src/github.com/goharbor/harbor/src/registryctl/harbor_registryctl /harbor/

RUN chmod u+x /harbor/harbor_registryctl \
    && chmod u+x /usr/bin/registry \
    && chmod u+x /harbor/start.sh

HEALTHCHECK CMD curl --fail -s http://127.0.0.1:8080/api/health || exit 1

VOLUME ["/var/lib/registry"]
WORKDIR /harbor/

ENTRYPOINT ["/harbor/start.sh"]