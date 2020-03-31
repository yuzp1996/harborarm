FROM golang:1.12.12 as builder
ENV CGO_ENABLED 0
ENV GOOS linux
ENV GOARCH arm64
ADD . /go/src/github.com/goharbor/harbor
WORKDIR /go/src/github.com/goharbor/harbor/src/core
RUN go build -o harbor_core

FROM photon:3.0

RUN tdnf install sudo -y >> /dev/null\
    && tdnf clean all \
    && groupadd -r -g 10000 harbor && useradd --no-log-init -r -g 10000 -u 10000 harbor \
    && mkdir /harbor/

HEALTHCHECK CMD curl --fail -s http://127.0.0.1:8080/api/ping || exit 1
COPY --from=builder /go/src/github.com/goharbor/harbor/src/core/harbor_core /harbor
COPY ./make/photon/core/start.sh ./supportarm/make/photon/core/UIVERSION /harbor/
COPY ./src/core/views /harbor/views
COPY ./make/migrations /harbor/migrations

RUN chmod u+x /harbor/start.sh /harbor/harbor_core
WORKDIR /harbor/

ENTRYPOINT ["/harbor/start.sh"]