// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract IntentSwap {
    using ECDSA for bytes32;

    struct Intent {
        address user;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 expiry;
        uint256 nonce;
    }

    mapping(address => uint256) public nonces;

    event IntentFulfilled(
        address indexed user,
        address indexed solver,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    function fulfillIntent(
        Intent calldata intent,
        bytes calldata signature
    ) external {
        require(block.timestamp <= intent.expiry, "Intent expired");
        require(intent.nonce == nonces[intent.user], "Invalid nonce");

        // Recreate signed message hash
        bytes32 hash = getIntentHash(intent);
        bytes32 messageHash = MessageHashUtils.toEthSignedMessageHash(
            abi.encodePacked(getIntentHash(intent))
        );
        address signer = messageHash.recover(signature);

        require(signer == intent.user, "Invalid signature");

        // Transfer tokenIn from user to this contract
        require(
            IERC20(intent.tokenIn).transferFrom(
                intent.user,
                address(this),
                intent.amountIn
            ),
            "Token in transfer failed"
        );

        // Solver must send at least minAmountOut of tokenOut to user
        uint256 balanceBefore = IERC20(intent.tokenOut).balanceOf(intent.user);
        require(
            IERC20(intent.tokenOut).transferFrom(
                msg.sender,
                intent.user,
                intent.minAmountOut
            ),
            "Token out transfer failed"
        );

        // Update nonce to prevent replay
        nonces[intent.user]++;

        emit IntentFulfilled(
            intent.user,
            msg.sender,
            intent.tokenIn,
            intent.tokenOut,
            intent.amountIn,
            intent.minAmountOut
        );
    }

    function getIntentHash(
        Intent calldata intent
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    intent.user,
                    intent.tokenIn,
                    intent.tokenOut,
                    intent.amountIn,
                    intent.minAmountOut,
                    intent.expiry,
                    intent.nonce
                )
            );
    }
}
