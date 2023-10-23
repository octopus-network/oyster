#!/bin/bash
set -eux

CHAIN_BIN=oysterd
CHAINID=oyster-0
MONIKER=dev
HOME_DIR=~/.$MONIKER-node
KEY=$MONIKER
TEST_ADDR=cosmos1ev0l8q3z2pya33ckwnrapgqzcx0yz73ccyeu02
TEST_AMOUNT=2000000stake

# Before: Get balance
$CHAIN_BIN query bank balances $TEST_ADDR --chain-id $CHAINID

# Test transfer
$CHAIN_BIN tx bank send \
$($CHAIN_BIN keys show $KEY -a --home $HOME_DIR --keyring-backend test) \
$TEST_ADDR \
$TEST_AMOUNT \
--chain-id $CHAINID \
--home $HOME_DIR \
--keyring-backend test \
--trace -y

# After: Get balance
$CHAIN_BIN query bank balances $TEST_ADDR --chain-id $CHAINID