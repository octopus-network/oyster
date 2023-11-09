#!/bin/bash
set -eux

COMMAND=oysterd
MONIKER=cosmovisor
CHAINID=oyster-0
DATA_DIR=/data
PEERS="29aa7bef50c930284202c89cfb9f4452e160bebb@35.234.3.39:26656,f33dfacf06344222bbd92b377de5d17e0c37ee02@104.199.233.115:26656"

if [ ! -f "$DATA_DIR/config/config.toml" ]; then
	# Initialize node's configuration files.
	$COMMAND init $MONIKER --chain-id $CHAINID --home $DATA_DIR

	# Modify the persistent_peers field of config.toml
	sed -i.bak "s/persistent_peers = \"\"/persistent_peers = \"${PEERS}\"/" $DATA_DIR/config/config.toml

	# Download genesis file
	curl -L -o $DATA_DIR/config/genesis.json https://raw.githubusercontent.com/octopus-network/oyster/ocb-oyster/tests/testnet_genesis.json

	# Copy cosmovisor folder to data directory
	cp -R /root/cosmovisor $DATA_DIR/

	# Create a symbolic link for the current version
	ln -s $DATA_DIR/cosmovisor/genesis $DATA_DIR/cosmovisor/current
fi

# Copy cosmovisor folder to data directory
cp -R /root/cosmovisor $DATA_DIR/

cosmovisor run start --home $DATA_DIR --rpc.laddr="tcp://0.0.0.0:26657"