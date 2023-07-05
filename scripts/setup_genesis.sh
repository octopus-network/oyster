#!/bin/bash

CHAIN="otto"
# set denom
DENOM="aoct"
CHAINID="$CHAIN"_9100-1
MONIKER="orchestrator"

# Orchestrator account
KEY="orchestrator"
MNEMONIC="stumble tilt business detect father ticket major inner awake jeans name vibrant tribe pause crunch sad wine muscle hidden pumpkin inject segment rocket silver"

BUILD_DIR=$(pwd)/build
CHAIND=$BUILD_DIR/ottod
DATA_DIR=$BUILD_DIR/node3/ottod
CONF_DIR=$DATA_DIR/config
GENESIS=$CONF_DIR/genesis.json
TEMP_GENESIS=$CONF_DIR/tmp_genesis.json
CONFIG=$CONF_DIR/config.toml

# create necessary directory for orchestrator node
mkdir -p "$DATA_DIR"

echo "Create and add Orchestrator keys"
echo "$MNEMONIC" | $CHAIND keys add "$KEY" --home "$DATA_DIR" --no-backup --chain-id "$CHAINID" --keyring-backend test --recover
echo "Init $CHAIN with moniker=$MONIKER and chain-id=$CHAINID"
$CHAIND init "$MONIKER" --chain-id "$CHAINID" --home "$DATA_DIR"

echo "Prepare genesis..."
echo "- Set gas limit in genesis"
jq '.consensus_params["block"]["max_gas"]="10000000"' "$GENESIS" > "$TEMP_GENESIS" && mv "$TEMP_GENESIS" "$GENESIS"

echo "- Set $DENOM as denom"
sed -i.bak "s/aphoton/$DENOM/g" $GENESIS
sed -i.bak "s/stake/$DENOM/g" $GENESIS

echo "- Set no_base_fee"
sed -i.bak 's/"no_base_fee": false/"no_base_fee": true/g' "$GENESIS"

# # Change proposal periods to pass within a reasonable time for local testing
# sed -i.bak 's/"max_deposit_period": "172800s"/"max_deposit_period": "30s"/g' "$GENESIS"
# sed -i.bak 's/"voting_period": "172800s"/"voting_period": "30s"/g' "$GENESIS"
# # Change proposal required quorum to 15%, so with the orchestrator vote the proposals pass 
# sed -i.bak 's/"quorum": "0.334000000000000000"/"quorum": "0.150000000000000000"/g' "$GENESIS"

echo "- Allocate genesis accounts"
$CHAIND add-genesis-account \
"$($CHAIND keys show $KEY -a --home $DATA_DIR --keyring-backend test)" 100000000000000000000000000000000$DENOM \
--home $DATA_DIR --keyring-backend test

echo "- Sign genesis transaction"
$CHAIND gentx $KEY 100000000000000000000$DENOM --keyring-backend test --home $DATA_DIR --chain-id $CHAINID

echo "- Add all other validators genesis accounts"
for i in $(find $BUILD_DIR/gentxs -name "*.json");do
    address=$(cat "$i" | jq '.body.messages[0].delegator_address'|tr -d '"')
    $CHAIND add-genesis-account "$address" 100000000000000000000000000$DENOM --home $DATA_DIR --keyring-backend test
    [ $? -eq 0 ] && echo "$address added" || echo "$address failed"
done

# add gentx to gentxs dir
cp $CONF_DIR/gentx/*.json $BUILD_DIR/gentxs/node3.json

echo "- Collect genesis tx"
$CHAIND collect-gentxs --gentx-dir $BUILD_DIR/gentxs --home $DATA_DIR

echo "- Run validate-genesis to ensure everything worked and that the genesis file is setup correctly"
$CHAIND validate-genesis --home $DATA_DIR

echo "- Distribute final genesis.json to all validators"
for i in $(ls $BUILD_DIR | grep 'node');do
    cp $GENESIS $BUILD_DIR/$i/ottod/config/genesis.json
    [ $? -eq 0 ] && echo "$i: genesis updated successfully" || echo "$i: genesis update failed"
    cp $CONF_DIR/client.toml $BUILD_DIR/$i/ottod/config/client.toml
done

echo "copy config.toml to get the seeds"
cp $BUILD_DIR/node0/ottod/config/config.toml $CONFIG
sed -i.bak 's/moniker = \"node0\"/moniker = \"orchestrator\"/g' $CONFIG

echo "copy app.toml to have same config on all nodes"
cp $BUILD_DIR/node0/ottod/config/app.toml $CONF_DIR/app.toml