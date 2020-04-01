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
        fi
    done
}

change_base_image "make/photon"

sed -i 's/BUILDBIN=false/BUILDBIN=true/g' "Makefile"
sed -i 's/CLAIRFLAG=false/CLAIRFLAG=true/g' "Makefile"
sed -i 's/-v $(BUILDPATH):/-v $(COMPILEBUILDPATH):/g' "Makefile"
sed '1i\COMPILEBUILDPATH=/go/src' Makefile
sed -i 's/-e NPM_REGISTRY=$(NPM_REGISTRY)/-e NPM_REGISTRY=$(NPM_REGISTRY) -e NOTARYFLAG=true -e CHARTFLAG=true -e CLAIRFLAG=true/g' "Makefile"
sed '1i\COMPILEBUILDPATH=/go/src' Makefile
sed -i 's/=goharbor/=yugougou'"make/photon/Makefile"

docker login --username yugougou --password dochub_123456



mv ./dumb-init_1.2.2_arm64 ./make/photon/clair/dumb-init
sed -i 's/build --pull/buildx build --allow network.host --platform linux\/arm64 --progress plain --push/' "make/photon/Makefile"

sed -i 's/--rm/--rm --env CGO_ENABLED=0 --env GOOS=linux --env GOARCH=arm64/g' "Makefile"
sed -i 's/go build -a/GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -a/g' "make/photon/chartserver/compile.sh"
sed -i 's/go build/CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build/g' "make/photon/clair/Dockerfile.binary"
sed -i 's/\/go\/bin\/notary-server/\/go\/bin\/linux_arm64\/notary-server/g' "make/photon/registry/Dockerfile.binary"
sed -i 's/\/go\/bin\/notary-signer/\/go\/bin\/linux_arm64\/notary-signer/g' "make/photon/registry/Dockerfile.binary"
sed -i 's/CGO_ENABLED=0/GOOS=linux GOARCH=arm64 CGO_ENABLED=0/g' "make/photon/notary/builder"



#make  ui_version compile_core compile_jobservice compile_registryctl compile_notary_migrate_patch build
make build

echo "build image for arm64"





