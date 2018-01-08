FROM ubuntu:xenial-20171201

MAINTAINER nuculur@gmail.com

# N.B. The downloads are arch-dependent, they use dpkg at runtime on the build box to determine the appropriate arch. If a download fails, it might be because the arch isn't supported

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update && apt-get install -y wget curl git build-essential libboost-all-dev python python-pip python-dev libboost-python-dev libboost-thread-dev

# install python, related
RUN apt-get update && apt-get install -y python
RUN curl https://bootstrap.pypa.io/get-pip.py | python

# install nvidia repo for tensorrt, others; TODO: ensure this is ok w/ nvidia for us to mirror, this is a file that developers only have permission to download from nvidia after registration
RUN bash -c 'wget -O /tmp/nv-tensorrt-repo.deb http://1dd40.http.tor01.cdn.softlayer.net/nvidia-media/nv-tensorrt-repo-ubuntu1604-ga-cuda9.0-trt3.0-20171128_1-1_$(dpkg --print-architecture).deb && dpkg -i /tmp/nv-tensorrt-repo.deb'

RUN bash -c 'wget -O /tmp/nv-cuda-repo.deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.1.85-1_$(dpkg --print-architecture).deb && dpkg -i /tmp/nv-cuda-repo.deb'

RUN apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub

RUN apt-get update && apt-get install -y --no-install-recommends cuda tensorrt

# install nvidia packages
RUN apt-get update && apt-get install -y libnvinfer4 libnvinfer-dev python-libnvinfer-doc uff-converter-tf tensorrt cuda-cublas-dev-9-0

ENV CUDA_INC_DIR=/usr/local/cuda-9.1
ENV PATH=/usr/local/cuda-9.1/bin:$PATH

# install old cudart libs
RUN apt-get update && apt-get install -y cuda-cudart-9-0 cuda-cudart-dev-9-0

# add old cuda libs to library path with some silly business
RUN mkdir -p /usr/local/cuda-compat && echo "/usr/local/cuda-compat" > /etc/ld.so.conf.d/cuda-compat.conf
RUN ln -s /usr/local/cuda-9.0/targets/x86_64-linux/lib/libcublas.so.9.0 /usr/local/cuda-compat/
RUN ln -s /usr/local/cuda-9.0/targets/x86_64-linux/lib/libcudart.so.9.0 /usr/local/cuda-compat/

RUN ldconfig

# important to not get protobuf 3.5.1 depended-on by tensorflow
RUN pip install --no-cache-dir tensorflow numpy protobuf==3.4.0

RUN cd /tmp; curl https://pypi.python.org/packages/b3/30/9e1c0a4c10e90b4c59ca7aa3c518e96f37aabcac73ffe6b5d9658f6ef843/pycuda-2017.1.1.tar.gz | tar xzvf - && cd pycuda-2017.1.1 && \
	./configure.py --cuda-root=/usr/local/cuda-9.1 --cudadrv-lib-dir=/usr/lib --boost-inc-dir=/usr/include --boost-lib-dir=/usr/lib --boost-python-libname=boost_python-py27 --boost-thread-libname=boost_thread && \
	python setup.py install && \
	pip install .

## Clone repo
RUN git clone https://github.com/AastaNV/ChatBot.git /root/ChatBot
WORKDIR /root/ChatBot

## Cleanup for squashed image (N.B. there are a *lot* of packages installed that aren't necessary but they're non-optional dependencies of cuda, xorg, gnome, etc. are examples. If it's desirable to slim this image down we'll need to use dpkg -P with particular installed packages' names to remove them, or set up apt policies to prevent installing them in the first place)
RUN rm -Rf /tmp/* /var/cache/apt/archives/*

CMD ["python","src/tf_to_uff/tf_to_trt.py","model/ID210_649999","model/ID210_649999.uff"]
