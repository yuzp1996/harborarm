FROM golang:1.12.12 as builder

ARG NOTARY_VERSION
ARG MIGRATE_VERSION
RUN test -n "$NOTARY_VERSION"
RUN test -n "$MIGRATE_VERSION"
ENV NOTARYPKG github.com/theupdateframework/notary
ENV MIGRATEPKG github.com/golang-migrate/migrate
ENV CGO_ENABLED 0
ENV GOOS linux
ENV GOARCH arm64

RUN git clone -b $NOTARY_VERSION https://github.com/theupdateframework/notary.git /go/src/${NOTARYPKG}
WORKDIR /go/src/${NOTARYPKG}

RUN go install -tags pkcs11 \
    -ldflags "-w -X ${NOTARYPKG}/version.GitCommit=`git rev-parse --short HEAD` -X ${NOTARYPKG}/version.NotaryVersion=`cat NOTARY_VERSION`" ${NOTARYPKG}/cmd/notary-server

RUN go install -tags pkcs11 \
    -ldflags "-w -X ${NOTARYPKG}/version.GitCommit=`git rev-parse --short HEAD` -X ${NOTARYPKG}/version.NotaryVersion=`cat NOTARY_VERSION`" ${NOTARYPKG}/cmd/notary-signer
RUN cp -r /go/src/${NOTARYPKG}/migrations/ /

RUN git clone -b $MIGRATE_VERSION https://github.com/golang-migrate/migrate /go/src/${MIGRATEPKG}
WORKDIR /go/src/${MIGRATEPKG}

RUN GOPROXY=https://athens.acp.alauda.cn GO111MODULE=on go mod vendor


ENV DATABASES="postgres mysql redshift cassandra spanner cockroachdb clickhouse"
ENV SOURCES="file go_bindata github aws_s3 google_cloud_storage"

RUN go install -tags "$DATABASES $SOURCES" -ldflags="-X main.Version=${MIGRATE_VERSION}" ${MIGRATEPKG}/cli && ls /go/bin && mv /go/bin/cli /go/bin/migrate



FROM photon:3.0
   
RUN tdnf install -y shadow sudo \
    && tdnf clean all \
    && groupadd -r -g 10000 notary \
    && useradd --no-log-init -r -g 10000 -u 10000 notary

COPY ./make/photon/notary/migrate-patch /bin/migrate-patch
COPY --from=builder /go/bin/notary-server /bin/notary-server
COPY --from=builder /go/bin/migrate /bin/migrate
COPY --from=builder /migrations /migrations/
COPY ./make/photon/notary/server-start.sh /bin/server-start.sh
RUN chmod +x /bin/notary-server /migrations/migrate.sh /bin/migrate /bin/migrate-patch /bin/server-start.sh
ENV SERVICE_NAME=notary_server
ENTRYPOINT [ "/bin/server-start.sh" ]