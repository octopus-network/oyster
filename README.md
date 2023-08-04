# OttoChain

**OttoChain** is a scalable PoS blockchain that is fully compatible and interoperable with the EVM. It is built using the Cosmos SDK which runs on top of the CometBFT consensus engine, to accomplish fast finality, high transaction throughput and short block times (~2 seconds).

## OttoChain Testnet

* Chain Name: OttoChain
* Cosmos Chain ID: `otto_9100-1`
* EVM Chain ID (EIP155 Number): `9100`
* JSON RPC: `https://gateway.testnet.octopus.network/ottochain/m4k5urt9h33dpbhgsp4lqxemo6naeihz`
* [Explorer](http://34.69.4.240:4000/)
* [Faucet](http://34.69.4.240:8088/)
* Genesis File: [genesis.json](https://raw.githubusercontent.com/octopus-network/oyster/ocb-otto/genesis.json)
* Persistent Peers:
    ```json
    persistent_peers = "58ca8716508f50d51d2918c9b70758c1c25bb498@34.81.140.131:26656, 834bbc8f2738313679c414df63136eb3197048a7@35.201.135.223:26656"
    ```

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

You can also watch logs via Docker with the `-f` flag, for example:

```bash
docker logs -f ottonode0
```

### Interact with the Localnet

You can send some curl commands such as:

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_newBlockFilter","params":[],"id":1}' -H "Content-Type: application/json" http://127.0.0.1:8545
```

```json
{"jsonrpc":"2.0","id":1,"result":"0x47fbaaa9287f72dbe2465469b4e71d5a"}
```

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getFilterChanges","params":["0x47fbaaa9287f72dbe2465469b4e71d5a"],"id":1}' -H "Content-Type: application/json" http://127.0.0.1:8545
```

```json
{"jsonrpc":"2.0","id":1,"result":["0x5c7be43735b901f41c9aa0c7340c99462f490104cfb8dc14d7fb0a33e15e46c2","0x7bb4eacdf8de04a86ec127b1a4417a38199094754a6e4560610ca2c11b1bfd57","0x1269fd687598334ae734bc24559b8e71dfc1525fdae86ceb3c439d2f4c2a7532","0x434b5ac65b607c8a910fc4f4d589818f4144bc64de638a82ceb24509ddfeac59","0xb26ef28098aa5cdaec6f58b267a8d2806770e46282131ff00b9f52d901c343e5","0xec87d067ea62730db4b0a2b3edcb462bad041c358971de3e5fd11c69761a2f9e","0x9c6f443ee54811d28cc1b903564f7fdbfd3372613cfbd55eddfc23a3205784df","0x83fe4eb6af26523f5675474053ae99d8369afed28bff7de6be727c8062ce53a3","0xdcc146c9d21a10b119397d98658c3d2bc4231c79cc3892d0070c0377308e9fdd","0x4a20b02aaa26846eecf646e606f39641acae52e4d66926dbc8585e406af50452","0x749ac740da8ea608eb293620a8a90b4c30a1fa7036975f07421c41b3cf0f48ca","0xdabcd4e8c672c3536e8cba7b480710a113de246ef679016033109bb1ca2bf405","0xd91373c0eea02653479c02e13d309441c0ff884a5e9b7a6ea0711a3e08c9ed59","0x7ac9e220458c3e7d273583505069385d8f0caf68763adb54744ea1ce449d0d24","0xad9de6812c8fcf292e14c0e4fe7099fdcb39677a9ff0df24862bf8a44b3812d5","0x3c491a7946d6b87e3bc69a7643e195795320e5bab3568bbfea444b93847081db","0x58d49ef24729a20f78047a6d230860ea427b58d300517368ab555db40b2c9309","0xbb24017c97487d554e82b876529c3fbf9e801eaf8105fe57b9414cb24b03fbb8"]}
```

## Tutorial

[Hardhat Tutorial](./tutorial/README.md)