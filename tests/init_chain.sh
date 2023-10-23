#!/bin/bash
set -eux

if [ $# == 0 ]; then
    echo "validator: init_chain.sh <node-name> <seed-file>"
    echo "fullnode: init_chain.sh <node-name>"
    exit
fi

CHAIN_ID=oyster-0
BINARY=oysterd
NODE_MONIKER=$1
NODE_HOME=$HOME/.$NODE_MONIKER
KEY=$NODE_MONIKER

if [ $# == 2 ]; then
    MNEMONIC_FILE=$2
    echo "create and add new keys"
    cat $MNEMONIC_FILE | $BINARY keys add $KEY --home $NODE_HOME --no-backup --recover --keyring-backend test
fi

echo "init chain with moniker=$NODE_MONIKER and chain-id=$CHAIN_ID"
$BINARY init $NODE_MONIKER --home $NODE_HOME --chain-id $CHAIN_ID