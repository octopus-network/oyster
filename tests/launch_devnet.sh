#!/bin/bash
set -eux

CHAIN_BIN=oysterd
CHAINID=oyster-0
MONIKER=dev
HOME_DIR=~/.$MONIKER-node
KEY=$MONIKER
VALIDATOR_DIR=$(pwd)/tests/validatornode01
CCV_SECTION=$(pwd)/tests/devnet_ccv_consumer.json
DENOM_METADAT_SECTION=$(pwd)/tests/denom_metadata.json
GENESIS=$HOME_DIR/config/genesis.json
TEMP_GENESIS=$HOME_DIR/config/tmp_genesis.json

# clean
rm -rf $HOME_DIR

echo "Create and add $KEY keys"
cat $VALIDATOR_DIR/seed.txt | $CHAIN_BIN keys add $KEY --home $HOME_DIR --no-backup --keyring-backend test --recover
echo "Init chain with chain-id=$CHAINID under $HOME_DIR"
$CHAIN_BIN init $MONIKER --chain-id $CHAINID --home $HOME_DIR

echo "Prepare genesis..."
echo "- Set CCV Consumer section"
jq -s '.[0].app_state.ccvconsumer = .[1] | .[0]' $GENESIS $CCV_SECTION > $TEMP_GENESIS && mv $TEMP_GENESIS $GENESIS

echo "- Set bank.denom_metadata with the content of $DENOM_METADAT_SECTION"
jq -s '.[0].app_state.bank.denom_metadata = .[1] | .[0]' $GENESIS $DENOM_METADAT_SECTION > $HOME_DIR/config/genesis_denom_metadata.json
mv $HOME_DIR/config/genesis_denom_metadata.json $GENESIS

# Change proposal periods to pass within a reasonable time for local testing
sed -i 's/"max_deposit_period": "172800s"/"max_deposit_period": "60s"/g' "$GENESIS"
sed -i 's/"voting_period": "172800s"/"voting_period": "60s"/g' "$GENESIS"

echo "- Allocate genesis accounts"
$CHAIN_BIN genesis add-genesis-account \
"$($CHAIN_BIN keys show $KEY -a --home $HOME_DIR --keyring-backend test)" 100000000000000stake \
--home $HOME_DIR --keyring-backend test

echo "- Run validate-genesis correctly"
$CHAIN_BIN genesis validate-genesis --home $HOME_DIR

echo "Set Validator Key File"
cp $VALIDATOR_DIR/priv_validator_key.json $HOME_DIR/config/priv_validator_key.json

echo "Set Node Key File"
cp $VALIDATOR_DIR/node_key.json $HOME_DIR/config/node_key.json

echo "Start the chain"
$CHAIN_BIN start --home $HOME_DIR