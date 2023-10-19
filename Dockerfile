FROM golang:1.20-bullseye as builder

# Install minimum necessary dependencies
ENV PACKAGES curl make git libc-dev bash gcc
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y $PACKAGES

# Download and compile the oysterd binaries
WORKDIR /root
RUN git clone --depth 1 -b v1 https://github.com/octopus-network/oyster.git oyster-v1 && \
    cd oyster-v1 && CGO_ENABLED=0 make build

WORKDIR /root
RUN git clone --depth 1 -b v2 https://github.com/octopus-network/oyster.git oyster-v2 && \
    cd oyster-v2 && CGO_ENABLED=0 make build

WORKDIR /root
RUN git clone --depth 1 -b v3 https://github.com/octopus-network/oyster.git oyster-v3 && \
    cd oyster-v3 && CGO_ENABLED=0 make build

# Install the cosmovisor binary
WORKDIR /root
ENV COSMOS_VERSION=v0.47.5
RUN git clone --depth 1 -b ${COSMOS_VERSION} https://github.com/cosmos/cosmos-sdk.git && \
    cd cosmos-sdk/tools/cosmovisor && make cosmovisor

# Final image
FROM golang:1.20-bullseye as final

# Setting the environmental variables
ENV DAEMON_HOME=/data
ENV DAEMON_NAME=oysterd

COPY --from=builder /root/cosmos-sdk/tools/cosmovisor/cosmovisor /usr/local/bin/cosmovisor
COPY --from=builder /root/oyster-v1/build/$DAEMON_NAME /usr/local/bin/$DAEMON_NAME

# Initialization creates the folder structure required for using cosmovisor
RUN cosmovisor init /usr/local/bin/$DAEMON_NAME

COPY --from=builder /root/oyster-v2/build/$DAEMON_NAME $DAEMON_HOME/cosmovisor/upgrades/v2/bin/$DAEMON_NAME
COPY --from=builder /root/oyster-v3/build/$DAEMON_NAME $DAEMON_HOME/cosmovisor/upgrades/v3/bin/$DAEMON_NAME

ENTRYPOINT ["/bin/bash", "-c"]