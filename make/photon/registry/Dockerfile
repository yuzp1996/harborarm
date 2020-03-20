FROM golang:1.12.12 as builder

ENV DISTRIBUTION_DIR /go/src/github.com/docker
ENV BUILDTAGS include_oss include_gcs

WORKDIR $DISTRIBUTION_DIR
COPY . $DISTRIBUTION_DIR

RUN git clone -b v2.7.1 https://github.com/docker/distribution.git
WORKDIR /go/src/github.com/docker/distribution

RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 make PREFIX=/go clean binaries


FROM photon:3.0

MAINTAINER wangyan@vmware.com

# The original script in the docker offical registry image.
RUN tdnf install sudo -y >> /dev/null\
    && tdnf clean all \
    && mkdir /harbor/ \
    && mkdir -p /etc/registry \
    && groupadd -r -g 10000 harbor && useradd --no-log-init -r -g 10000 -u 10000 harbor  

COPY ./make/photon/common/install_cert.sh /harbor
COPY ./make/photon/registry/entrypoint.sh /
COPY --from=builder /go/src/github.com/docker/distribution/bin/registry /usr/bin
COPY --from=builder /go/src/github.com/docker/distribution/cmd/registry/config-example.yml /etc/registry/config.yml

RUN chmod u+x /entrypoint.sh \
    && chmod u+x /usr/bin/registry

HEALTHCHECK CMD curl 127.0.0.1:5000/

VOLUME ["/var/lib/registry"]
EXPOSE 5000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/etc/registry/config.yml"]
