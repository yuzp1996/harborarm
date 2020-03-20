FROM golang:1.12.12 as builder
ENV CGO_ENABLED 0
ENV GOOS linux
ENV GOARCH arm64
ADD . /go/src/github.com/goharbor/harbor
WORKDIR /go/src/github.com/goharbor/harbor/src/jobservice
RUN go build -o harbor_jobservice

FROM photon:3.0

RUN mkdir /harbor/ \
    && tdnf install sudo -y >> /dev/null\
    && tdnf clean all \
    && groupadd -r -g 10000 harbor && useradd --no-log-init -r -g 10000 -u 10000 harbor 

COPY ./make/photon/jobservice/start.sh /harbor/
COPY  --from=builder /go/src/github.com/goharbor/harbor/src/jobservice/harbor_jobservice  /harbor/

RUN chmod u+x /harbor/harbor_jobservice /harbor/start.sh
WORKDIR /harbor/
ENTRYPOINT ["/harbor/start.sh"]
