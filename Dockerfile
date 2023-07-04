FROM golang:1.20-bullseye as builder

# Set working directory for the build
WORKDIR /src/app/
COPY go.mod go.sum* ./
RUN go mod download
COPY . .

# Install minimum necessary dependencies
ENV PACKAGES curl make git libc-dev bash gcc
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y $PACKAGES

# Compile the oysterd binary
RUN CGO_ENABLED=0 make install

# Final image
FROM golang:1.20-bullseye as final

COPY --from=builder /go/bin/oysterd /usr/local/bin/

EXPOSE 26656 26657 1317 9090
USER 0

ENTRYPOINT ["oysterd", "start"]