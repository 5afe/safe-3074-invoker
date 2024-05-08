# Setup Safe infrastructure

1. Install [docker](https://docs.docker.com/) and make sure docker daemon is running.

2. Start services
```bash
sh setup.sh
```

3. Create admin user

After services start, create a admin user as asked in the terminal.

4. Add config for chain

https://github.com/safe-global/safe-infrastructure/blob/main/docs/running_locally.md#step-3-add-your-chaininfo

Chain Id: 41144114
Chain name: Otim testnet

RPC URI: http://devnet.otim.xyz
Public RPC Uri: http://devnet.otim.xyz

TX Service URI: http://nginx:8000/txs
Vpc tx service uri: http://nginx:8000/txs

Master copy: 0x80369c324367a86B7704d0307b225275783A735c

http://localhost:8000/txs/admin/

Add Safe master copy address: 0x80369c324367a86B7704d0307b225275783A735c
Tx Block number: 40800
Version: 1.4.1
Leaver Deployer field as it is
L2: Yes