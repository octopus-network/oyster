FROM golang:1.20-bullseye as builder

# Install minimum necessary dependencies
ENV PACKAGES curl make git libc-dev bash gcc
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y $PACKAGES

# Set working directory for the build
WORKDIR /src/app/

# Add source files
COPY . .

# build
RUN make install

# Final image
FROM golang:1.20-bullseye as final

WORKDIR /

RUN apt-get update && apt-get install -y jq

# Copy over binaries from the build-env
COPY --from=builder /go/bin/ottod /

EXPOSE 26656 26657 1317 9090 8545 8546

ENTRYPOINT ["/bin/bash", "-c"]