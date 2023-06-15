#!/bin/bash

DENOM="aoct"
DATA_DIR=/oyster
GENESIS=$DATA_DIR/config/genesis.json
TEMP_GENESIS=$DATA_DIR/config/tmp_genesis.json

echo "- Set gas limit in genesis"
cat $GENESIS | jq '.consensus_params["block"]["max_gas"]="10000000"' > $TEMP_GENESIS && mv $TEMP_GENESIS $GENESIS

echo "- Set $DENOM as denom"
sed -i "s/aphoton/$DENOM/g" $GENESIS

echo "starting oyster node ..."
./oysterd start --pruning=nothing --rpc.unsafe --keyring-backend test --home $DATA_DIR