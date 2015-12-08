#!/bin/bash

CT=xrdp-dev-env
IMG=xrdp-dev-env

HOME_DIR=/home/dockerx

docker rm -f $CT
docker run -d \
      --name $CT \
      -v $(pwd)/dockerx/.config/google-chrome:$HOME_DIR/.config/google-chrome \
      -v $(pwd)/syncthing/config:/syncthing/config \
      -v $(pwd)/data:/syncthing/data \
      -v ${PWD}/go:/$HOME_DIR/go \
      -v ${PWD}/.atom:/$HOME_DIR/.atom \
      -v ${PWD}/.f18:/$HOME_DIR/.f18 \
      -v ${PWD}/build:/build \
       -p 3389:3389 \
       -p 8080:8080 \
      $IMG

docker exec -ti $CT /bin/bash