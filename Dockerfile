FROM tensorflow/serving:2.11.1 AS build_image
FROM ubuntu:20.04
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
# tensorflow/serving:2.11.1
ARG TF_SERVING_VERSION_GIT_BRANCH=master
ARG TF_SERVING_VERSION_GIT_COMMIT=head
LABEL tensorflow_serving_github_branchtag=2.11.1
LABEL tensorflow_serving_github_commit=c38a1f63b9686ea35198cb97ddcdb9a15dfedc53
COPY --from=build_image /usr/bin/tensorflow_model_server /usr/bin/tensorflow_model_server
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
