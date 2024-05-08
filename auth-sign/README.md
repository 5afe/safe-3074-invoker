# Auth Sign

A simple HTML page for generating an EIP-3074 `AUTH` signature for the Safe
invoker using the injected EIP-1193 Ethereum provider.

## Running

This is just a static HTML page, and can be hosted however you like. A
`Makefile` with a `host` rule is provided to host using the builtin Python HTTP
server.

```sh
make host
```
