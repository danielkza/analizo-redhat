#!/bin/bash

set -e

docker build --rm=true --tag analizo-build-centos7 -f Dockerfile-centos7 .
mkdir -p $PWD/rpms/centos-7
docker run -i -t --volume=$PWD/rpms/centos-7:/root/analizo/rpms --volume=$PWD/.gnupg:/root/.gnupg analizo-build-centos7 

docker build --rm=true --tag analizo-build-f22 -f Dockerfile-f22 .
mkdir -p $PWD/rpms/fedora-22
docker run -i -t --volume=$PWD/rpms/fedora-22:/root/analizo/rpms --volume=$PWD/.gnupg:/root/.gnupg analizo-build-f22 
