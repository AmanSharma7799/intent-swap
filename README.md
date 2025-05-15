# 🧠 IntentSwap – Intent-Based Token Swap Protocol (Inspired by CoW Swap)

IntentSwap is a simplified proof-of-concept implementation of an **intent-based token swapping protocol** in Solidity. Instead of placing rigid on-chain orders, users sign **flexible off-chain intents**, which are later fulfilled by solvers through optimal routing or coincidence of wants (CoW) .

## ✨ Features

- 📝 **Intent Definition**: Users define what they want, not how.
- 🔐 **Signature-Based Execution**: Intents are signed off-chain using ECDSA(Elliptic Curve Digital Signature Algorithm) and executed by solvers.
- ⚙️ **Flexible Routing**: Solvers decide how to fulfill intents (DEX aggregation, arbitrage, etc.).
- 🚫 **Replay Protection**: Nonce-based intent tracking.
- 📦 **ERC-20 Compatible**: Supports all standard ERC-20 tokens.

### `IntentSwap.sol`

The main contract allows:
- Users to define and sign off-chain intents.
- Solvers to fulfill those intents by:
  - Pulling tokens from the user.
  - Sending target tokens to the user.
  - Executing swaps on-chain.
