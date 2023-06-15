# oyster

**oyster** is a EVM chain based on Ethermint, it's built using the Cosmos SDK which runs on top of the Tendermint Core consensus engine.

## Run Multi Node

To build start a 4 node testnet using docker, run:

```bash
make localnet-start
```

### Watch Logs

You can watch logs, run:

```bash
make localnet-show-logstream
```

### Interact with the Localnet

You can send a curl command such as:

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' -H "Content-Type: application/json" 192.162.10.1:8545
```
