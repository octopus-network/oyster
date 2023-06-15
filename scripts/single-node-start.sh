#!/bin/bash

KEY="dev0"
CHAINID="oyster_9000-1"
MONIKER="mymoniker"
DENOM="aoct"
DATA_DIR=/oyster
GENESIS=$DATA_DIR/config/genesis.json
TEMP_GENESIS=$DATA_DIR/config/tmp_genesis.json

echo "create and add new keys"
./oysterd keys add $KEY --home $DATA_DIR --no-backup --chain-id $CHAINID --algo "eth_secp256k1" --keyring-backend test
echo "init Oyster with moniker=$MONIKER and chain-id=$CHAINID"
./oysterd init $MONIKER --chain-id $CHAINID --home $DATA_DIR
echo "prepare genesis: Allocate genesis accounts"
./oysterd add-genesis-account \
"$(./oysterd keys show $KEY -a --home $DATA_DIR --keyring-backend test)" 1000000000000000000aoct,1000000000000000000stake \
--home $DATA_DIR --keyring-backend test

# Set gas limit in genesis
cat $GENESIS | jq '.consensus_params["block"]["max_gas"]="10000000"' > $TEMP_GENESIS && mv $TEMP_GENESIS $GENESIS

echo "- Set $DENOM as denom"
sed -i "s/aphoton/$DENOM/g" $GENESIS

echo "prepare genesis: Sign genesis transaction"
./oysterd gentx $KEY 1000000000000000000stake --keyring-backend test --home $DATA_DIR --keyring-backend test --chain-id $CHAINID
echo "prepare genesis: Collect genesis tx"
./oysterd collect-gentxs --home $DATA_DIR
echo "prepare genesis: Run validate-genesis to ensure everything worked and that the genesis file is setup correctly"
./oysterd validate-genesis --home $DATA_DIR

echo "starting oyster node ..."
./oysterd start --pruning=nothing --rpc.unsafe --keyring-backend test --home $DATA_DIR