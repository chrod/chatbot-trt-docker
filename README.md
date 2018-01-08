# chatbot-trt-docker
testing repo for tensor-rt chatbot in docker

# Build

* Enable docker experimental features

      echo '{ "experimental": true }' > /etc/docker/daemon.json && systemctl restart docker

* Build docker container

      docker build -t tensorrt-chatbot --squash --no-cache --compress .

* Run docker instance w/ access to the nvidia device (tested on "NVIDIA Corporation GM204GL [Tesla M60] (rev a1)" in SoftLayer)

      docker run --rm --privileged -it tensorrt-chatbot:latest
