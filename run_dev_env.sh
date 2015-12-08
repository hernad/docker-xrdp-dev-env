docker rm -f dev-env
docker run -d \
      --name dev-env \
      -v ${PWD}/.atom:/root/.atom \
      -v ${PWD}/.f18:/root/.f18 \
      -v ${PWD}/build:/build \
      -v /dev/shm:/dev/shm \
       -p 3389:3389 \
      dev-env

