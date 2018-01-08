# chatbot-trt-docker
testing repo for tensor-rt chatbot in docker

# Build

* If you want to use the `--squash` option in the below command, enable Docker experimental features (**CAUTION**: the shell redirection below will overwrite an existing `daemon.json` config file)

      echo '{ "experimental": true }' > /etc/docker/daemon.json && systemctl restart docker

* Build docker container

      docker build -t tensorrt-chatbot --squash --no-cache --compress .

* Run docker instance w/ access to the nvidia device (tested with an "NVIDIA Corporation GM204GL [Tesla M60] (rev a1)" GPU card in SoftLayer)

      docker run --rm --privileged -it tensorrt-chatbot:latest
