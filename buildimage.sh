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
sed -i 's/BUILDBIN=false/BUILDBIN=true/' "Makefile"

docker login --username yugougou --password dochub_123456
#读取第一个参数
change_base_image "make/photon"

##wget  https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_arm64
#
#echo "compile and build amd64 image"
#
#
#
#make  ui_version compile_core compile_jobservice compile_registryctl compile_notary_migrate_patch build
#
#echo "compile and build amd64 image end..."
#


echo "should clean the binary "

mv ./dumb-init_1.2.2_arm64 ./make/photon/clair/dumb-init
sed -i 's/build --pull/buildx build --allow network.host --platform linux\/arm64 --progress plain --push/' "make/photon/Makefile"

sed -i 's/--rm/--rm --env CGO_ENABLED=0 --env GOOS=linux --env GOARCH=arm64/g' "Makefile"

#make  ui_version compile_core compile_jobservice compile_registryctl compile_notary_migrate_patch build
make build

echo "build image for arm64"





