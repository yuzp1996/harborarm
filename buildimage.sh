#!/bin/bash









function change_base_image(){
    for file in `ls $1`
    do
        if [ -d $1"/"$file ]
        then
            change_base_image $1"/"$file
        elif [[ $file == "*Dockerfile*" ]]
        then
            sed -i 's/photon:2.0/photon:3.0/' $1"/"$file
            echo $1"/"$file
            cat $1"/"$file
        fi
    done
}

change_base_image "make/photon"

sed -i 's/BUILDBIN=false/BUILDBIN=true/g' "Makefile"
sed -i 's/CLAIRFLAG=false/CLAIRFLAG=true/g' "Makefile"
sed -i 's/-v $(BUILDPATH):/-v $(COMPILEBUILDPATH):/g' "Makefile"
sed -i 's/-e NPM_REGISTRY=$(NPM_REGISTRY)/-e NPM_REGISTRY=$(NPM_REGISTRY) -e NOTARYFLAG=true -e CHARTFLAG=true -e CLAIRFLAG=true/g' "Makefile"
sed -i '1 a COMPILEBUILDPATH=/go/src' "Makefile"
cat Makefile

sed -i 's/=goharbor/=yugougou/g' "make/photon/Makefile"

cat make/photon/Makefile

docker login armharbor.alauda.cn --username alaudak8s --password t4YSpvPrrFOsjAapawc5


#mv ./dumb-init_1.2.2_arm64 ./make/photon/clair/dumb-init
sed -i 's/build --pull/buildx build --allow network.host --platform linux\/arm64 --progress plain --push/' "make/photon/Makefile"

sed -i 's/--rm/--rm --env CGO_ENABLED=0 --env GOOS=linux --env GOARCH=arm64/g' "Makefile"

sed -i 's/go build -a/GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -a/g' "make/photon/chartserver/compile.sh"

sed -i 's/go build/CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build/g' "make/photon/clair/Dockerfile.binary"

sed -i 's/notary-server/linux_arm64\/notary-server/g' make/photon/notary/builder
sed -i 's/notary-signer/linux_arm64\/notary-signer/g' make/photon/notary/builder

sed -i 's/CGO_ENABLED=0/GOOS=linux GOARCH=arm64 CGO_ENABLED=0/g' "make/photon/registry/Dockerfile.binary"

sed -i 's/bin\/cli/bin\/linux_arm64\/cli/g' "make/photon/notary/binary.Dockerfile"
sed -i '26,27d' make/photon/notary/binary.Dockerfile
sed -i '5 a ENV CGO_ENABLED 0\ENV GOOS linux\ENV GOARCH arm64' "make/photon/notary/binary.Dockerfile"

sed -i '26 a RUN GOPROXY=https://athens.acp.alauda.cn GO111MODULE=on go mod tidy vendor' "make/photon/notary/binary.Dockerfile"
cat make/photon/notary/binary.Dockerfile




#make  ui_version compile_core compile_jobservice compile_registryctl compile_notary_migrate_patch build
make build

echo "build image for arm64"





