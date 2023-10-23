FROM golang:1.20-bullseye as builder

# Install minimum necessary dependencies
ENV PACKAGES curl make git libc-dev bash gcc
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y $PACKAGES

WORKDIR /root

# Download and compile the oysterd binaries
RUN git clone --depth 1 -b release-v1 https://github.com/octopus-network/oyster.git oyster-v1 \
    && cd oyster-v1 \
    && make build

# Install the cosmovisor binary
ENV COSMOS_VERSION=v0.47.5
RUN git clone --depth 1 -b ${COSMOS_VERSION} https://github.com/cosmos/cosmos-sdk.git \
    && cd cosmos-sdk/tools/cosmovisor \
    && make cosmovisor

# Final image
FROM ubuntu:22.04

# Set the environmental variables
ENV DAEMON_HOME=/oyster
ENV DAEMON_NAME=oysterd

# Create the folder structure required for using cosmovisor
RUN mkdir -p $DAEMON_HOME/cosmovisor/genesis/bin \
    && mkdir -p $DAEMON_HOME/data

# Copy the cosmovisor binary
COPY --from=builder /root/cosmos-sdk/tools/cosmovisor/cosmovisor /usr/local/bin/cosmovisor

# Copy the oysterd binaries to the appropriate directories
COPY --from=builder /root/oyster-v1/build/$DAEMON_NAME $DAEMON_HOME/cosmovisor/genesis/bin/$DAEMON_NAME

# Create a symbolic link for the current version
RUN ln -s $DAEMON_HOME/cosmovisor/genesis $DAEMON_HOME/cosmovisor/current

WORKDIR /root

ENTRYPOINT ["/bin/bash", "-c"]