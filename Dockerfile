# debian:10-slim
ARG BASE_IMAGE=debian@sha256:7f5c2603ccccb7fa4fc934bad5494ee9f47a5708ed0233f5cd9200fe616002ad
FROM $BASE_IMAGE

# See the 'docker' directory for arm32v7/arm64v8

# Build settings
ARG INSTALL=bitcoind,bwt,btc-rpc-explorer,specter,tor,nginx,letsencrypt,dropbear

ARG BWT_VERSION=0.2.2
ARG BWT_ARCH=x86_64-linux
ARG BWT_SHA256=4c8a1147a617dd87a732e8f6fcca18d07cca26c6dbd8d012e8813328d8c624e8

ARG BITCOIND_VERSION=0.21.0
ARG BITCOIND_ARCH=x86_64-linux-gnu
ARG BITCOIND_SHA256=da7766775e3f9c98d7a9145429f2be8297c2672fe5b118fd3dc2411fb48e0032

#ARG BTCEXP_VERSION=2.2.0
#ARG BTCEXP_SHA256=6f3dc1ea1c5d5256f3d5c4cdbb4042de37527d5abc17f9833e9c78c0164cef31

ARG SPECTER_VERSION=1.1.0
ARG SPECTER_SHA256=3e6cf4b7be66cfcee3043048e19bc1b418fcfcdda7220cce55f439a93dacca68

ARG S6_OVERLAY_VERSION=2.2.0.1
ARG S6_OVERLAY_ARCH=amd64
ARG S6_OVERLAY_SHA256=2dcb59b63d1d0f5f056d4e10d6cbae21a9c216e130080d3b5aaa8e7325ac571b

ARG NODEJS_VERSION=14.15.5
ARG NODEJS_ARCH=linux-x64
ARG NODEJS_SHA256=fa198afa9a2872cde991c3aa71796894bf7b5310d6eb178c3eafcf66e3ae79a7

COPY . /tmp/setup
RUN (cd /tmp/setup && ./install.sh) && rm -r /tmp/*

# Runtime settings
ENV NETWORK=bitcoin
ENV BWT=1
ENV EXPLORER=1
ENV TOR=0
ENV SSL=0
ENV SSHD=0
ENV BWT_LOGS=1

ENV PATH=/ez/bin:$PATH
# FIXME VOLUME /data
ENTRYPOINT ["/ez/entrypoint.sh"]
