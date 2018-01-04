FROM ubuntu:16.04

MAINTAINER nuculur@gmail.com


# update system
RUN apt-get update && apt-get -y upgrade && apt-get -y install python python-pip curl git wget swig

# Copy local libs over
RUN mkdir -p /root/src
#COPY *.deb /tmp/

ARG URL91=https://developer.nvidia.com/compute/cuda/9.1/Prod/local_installers/
ARG URL90=https://developer.nvidia.com/compute/cuda/9.0/Prod/local_installers/

# Install CUDA 9.1 libs (with latest nvidia-387)
#wget $URL_90/cuda-repo-ubuntu1604-9-0-local_9.0.176-1_amd64
#wget $URL_91/cuda-repo-ubuntu1604-9-1-local_9.1.85-1_amd64
RUN curl -sL $URL90/cuda-repo-ubuntu1604-9-0-local_9.0.176-1_amd64-deb -so /tmp/cuda-repo-ubuntu1604-9-0_amd64.deb
RUN curl -sL $URL91/cuda-repo-ubuntu1604-9-1-local_9.1.85-1_amd64 -so /tmp/cuda-repo-ubuntu1604-9-1_amd64.deb
RUN dpkg -i /tmp/cuda-repo-ubuntu1604-9-0_amd64.deb
RUN apt-key add /var/cuda-repo-9-0-local/7fa2af80.pub
RUN DEBIAN_FRONTEND=noninteractive apt-get install lightdm -y
RUN apt-get update && apt-get -y install cuda cuda-cublas-9-0

# Install CUDA 9.0 to deal with lib compatibility issues
RUN dpkg -i /tmp/cuda-repo-ubuntu1604-9-1_amd64.deb
RUN apt-get update && apt-get -y install cuda cuda-cublas-9-1

#RUN ln -s /usr/local/cuda-9.0/lib64/libcublas.so.9.0 /usr/local/cuda/lib64/libcublas.so.9.0
RUN ln -s /usr/local/cuda-9.0/lib64/libcu*.so.9.0 /usr/local/cuda/lib64/
RUN export PATH=$PATH:/usr/local/cuda-9.0/bin

# Install TensorRT
#wget https://developer.nvidia.com/compute/machine-learning/tensorrt/3.0/ga/nv-tensorrt-repo-ubuntu1604-ga-cuda9.0-trt3.0-20171128_1-1_amd64-deb
RUN dpkg -i /tmp/nv-tensorrt-repo-ubuntu1604-ga-cuda9.0-trt3.0-20171128_1-1_amd64.deb
RUN apt-get update && apt-get install -y libnvinfer4 libnvinfer-dev libnvinfer-samples tensorrt
RUN apt-get update && apt-get install tensorrt
RUN apt-get install -y python-libnvinfer-doc python3-libnvinfer-doc uff-converter-tf
# Check for TensorRT installed
RUN dpkg -l | grep TensorRT

# Install tensorflow, numpy
RUN pip install --no-cache-dir tensorflow numpy

# Install protobuf 3.4.0 (must be this version)
RUN apt-get remove python-protobuf libprotobuf-dev
RUN apt-get install -y unzip
RUN wget https://github.com/google/protobuf/releases/download/v3.4.0/protobuf-python-3.4.0.zip
RUN unzip protobuf-python-3.4.0.zip -d /tmp/
WORKDIR /tmp/protobuf-3.4.0
RUN /bin/bash -c "./configure"
RUN make -j7
RUN make install
RUN ldconfig

# Install PyCUDA      from: https://wiki.tiker.net/PyCuda/Installation/Linux/Ubuntu
ENV CUDA_ROOT=/usr/local/cuda-9.1
RUN apt-get install -y build-essential gcc g++ libboost-all-dev python-dev python-setuptools libboost-python-dev libboost-thread-dev
WORKDIR /tmp
RUN curl https://pypi.python.org/packages/b3/30/9e1c0a4c10e90b4c59ca7aa3c518e96f37aabcac73ffe6b5d9658f6ef843/pycuda-2017.1.1.tar.gz | tar xzvf -
WORKDIR /tmp/pycuda-2017.1.1
RUN ./configure.py --cuda-root=/usr/local/cuda-9.1 --cudadrv-lib-dir=/usr/lib --boost-inc-dir=/usr/include --boost-lib-dir=/usr/lib --boost-python-libname=boost_python-py27 --boost-thread-libname=boost_thread
RUN make -j4
RUN python setup.py install
RUN ldconfig
RUN pip install .

# Clone repo
RUN git clone https://github.com/AastaNV/ChatBot.git /root/src/ChatBot
RUN cd /root/src/ChatBot
WORKDIR /root/src/ChatBot

# run command, translate model (if it works... success!!)
#RUN python src/tf_to_uff/tf_to_trt.py model/ID210_649999 model/ID210_649999.uff

# Dev stuff
RUN apt-get install -y vim
