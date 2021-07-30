FROM intel/intel-optimized-tensorflow-serving:2.2.0 AS build_image
FROM ubuntu:20.04
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends curl wget bzip2 ca-certificates && \
    apt-get install -y --no-install-recommends tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get install -y --no-install-recommends python3 python3-pip python3-dev gcc g++ && \
    apt-get install -y --no-install-recommends supervisor memcached && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# intel/intel-optimized-tensorflow-serving:2.2.0
# https://github.com/Intel-tensorflow/serving/blob/master/tensorflow_serving/tools/docker/Dockerfile.mkl
ARG TF_SERVING_VERSION_GIT_BRANCH=master
ARG TF_SERVING_VERSION_GIT_COMMIT=head
LABEL tensorflow_serving_github_branchtag=2.2.0
LABEL tensorflow_serving_github_commit=d22fc192c7ad7b48d9a81346224aff637b8988f1
COPY --from=build_image /usr/bin/tensorflow_model_server /usr/bin/tensorflow_model_server
COPY --from=build_image /usr/local/lib/libiomp5.so /usr/local/lib
COPY --from=build_image /usr/local/lib/libmklml_gnu.so /usr/local/lib
COPY --from=build_image /usr/local/lib/libmklml_intel.so /usr/local/lib
ENV LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV OMP_NUM_THREADS=1
ENV KMP_BLOCKTIME=1
ENV KMP_SETTINGS=1
ENV KMP_AFFINITY=granularity=fine,verbose,compact,1,0
ENV MKLDNN_VERBOSE=0
