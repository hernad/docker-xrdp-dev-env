#!/bin/bash

CT=xrdp-dev-env
IMG=xrdp-dev-env

docker rm -f $CT
docker run -d \
      --name $CT \
      -v ${PWD}/.atom:/root/.atom \
      -v ${PWD}/.f18:/root/.f18 \
      -v ${PWD}/build:/build \
       -p 3389:3389 \
      $IMG

