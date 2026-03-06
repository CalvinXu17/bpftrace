#!/bin/bash
#
# This script is the entrypoint for the static build.
#
# To make CI errors easier to reproduce locally, please limit
# this script to using only git, docker, and coreutils.

set -eux

IMAGE=bpftrace-static
cd $(git rev-parse --show-toplevel)

# Build the base image
docker build -t "$IMAGE" -f docker/Dockerfile.static docker/

# Perform bpftrace static build
docker run -v $(pwd):$(pwd) -w $(pwd) -i "$IMAGE" <<'EOF'
set -eux
BUILD_DIR=build-static
cmake -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=ON -DBUILD_TESTING=OFF -DCMAKE_EXE_LINKER_FLAGS="-static" -DSTATIC_LINKING=ON -DENABLE_SKB_OUTPUT=OFF
make -C "$BUILD_DIR" -j$(nproc)

# Basic smoke test
./"$BUILD_DIR"/src/bpftrace --help

EOF
