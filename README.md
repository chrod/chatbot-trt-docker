# chatbot-trt-docker
testing repo for tensor-rt chatbot in docker

# Build

* If you want to use the `--squash` option in the below command, enable Docker experimental features (**CAUTION**: the shell redirection below will overwrite an existing `daemon.json` config file)

      echo '{ "experimental": true }' > /etc/docker/daemon.json && systemctl restart docker

* Build docker container (this took 14 min to complete on a SoftLayer Baremetal 32-core Xeon E5-2620 system)

      docker build -t tensorrt-chatbot --squash --no-cache --compress .

# Execute

* Run docker instance w/ access to the nvidia device (tested with an "NVIDIA Corporation GM204GL [Tesla M60] (rev a1)" GPU card in SoftLayer)

      docker run --rm --privileged -it tensorrt-chatbot:latest
      
For example:

      root@tesla1:~/chatbot-trt-docker# docker run --rm --privileged -it tensorrt-chatbot:latest
      [ChatBot] Covert model/ID210_649999 to model/ID210_649999.uff
      2018-01-08 05:27:32.576523: I tensorflow/core/platform/cpu_feature_guard.cc:137] Your CPU supports instructions that this TensorFlow binary was not compiled to use: SSE4.1 SSE4.2 AVX AVX2 FMA
      Converted 29 variables to const ops.
      Using output node h0_out
      Using output node c0_out
      Using output node h1_out
      Using output node c1_out
      Using output node final_output
      Converting to UFF graph
      No. nodes: 101
      UFF Output written to model/ID210_649999.uff
      [ChatBot] Successfully transfer to UFF model
