// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Auth Call - Allows to do AuthCall based transactions.
 */
contract AuthCall {
    /**
     * @dev Using the same name as `multiSend` to keep compatibility with the Safe UI.
     */
    function multiSend(bytes calldata transactions) external payable {
        address authorizer;
        bytes memory authData;
        bool success;
        bytes calldata onlyTransactions;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // The authorizer (EOA) of the transaction
            authorizer := shr(0x60, mload(add(transactions.offset, 0x21)))
            // The authentication data length of the transaction
            let authDataLength := mload(add(transactions.offset, 0x55))
            // We are only sending the rest of the transactions to be executed
            onlyTransactions.offset := add(transactions.offset, 0x75)
            // auth requires three parameters, the authorizer, the authData offset, and the authData length
            success := auth(authorizer, add(authData, add(transactions.offset, 0x75)), authDataLength)
        }
        require(success, "AuthCall: Auth failed");
        multiAuthCall(onlyTransactions);
    }

    /**
     * @param transactions Encoded transactions. Each transaction is encoded as a packed bytes of
     *                     operation has to be uint8(2) in this version (=> 1 byte),
     *                     to as a address (=> 20 bytes),
     *                     value as a uint256 (=> 32 bytes),
     *                     data length as a uint256 (=> 32 bytes),
     *                     data as bytes.
     *                     see abi.encodePacked for more information on packed encoding
     * @notice The code is for most part the same as the normal MultiSend (to keep compatibility),
     *         but reverts if a transaction tries to use a call/delegatecall.
     */
    function multiAuthCall(bytes calldata transactions) public payable {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let length := mload(transactions.offset)
            let i := 0x20
            for {
                // Pre block is not used in "while mode"
            } lt(i, length) {
                // Post block is not used in "while mode"
            } {
                // First byte of the data is the operation.
                // We shift by 248 bits (256 - 8 [operation byte]) it right since mload will always load 32 bytes (a word).
                // This will also zero out unused data.
                let operation := shr(0xf8, mload(add(transactions.offset, i)))
                // We offset the load address by 1 byte (operation byte)
                // We shift it right by 96 bits (256 - 160 [20 address bytes]) to right-align the data and zero out unused data.
                let to := shr(0x60, mload(add(transactions.offset, add(i, 0x01))))
                // We offset the load address by 21 byte (operation byte + 20 address bytes)
                let value := mload(add(transactions.offset, add(i, 0x15)))
                // We offset the load address by 53 byte (operation byte + 20 address bytes + 32 value bytes)
                let dataLength := mload(add(transactions.offset, add(i, 0x35)))
                // We offset the load address by 85 byte (operation byte + 20 address bytes + 32 value bytes + 32 data length bytes)
                let data := add(transactions.offset, add(i, 0x55))
                let success := 0
                switch operation
                // This version only allow regular calls
                case 0 {
                    success := authcall(gas(), to, value, data, dataLength, 0, 0)
                }
                // This version does not allow delegatecalls
                case 1 {
                    revert(0, 0)
                }
                // This version only allows AuthCalls
                case 2 {
                    success := authcall(gas(), to, value, data, dataLength, 0, 0)
                }
                if eq(success, 0) {
                    revert(0, 0)
                }
                // Next entry starts at 85 byte + data length
                i := add(i, add(0x55, dataLength))
            }
        }
    }
}
