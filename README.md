```
 ___ ___  __  _   ____  __    __  __  _  _____
|   T   T|  l/ ] |    ||  T__T  T|  l/ ]/ ___/
| _   _ ||  ' /  l__  ||  |  |  ||  ' /(   \_ 
|  \_/  ||    \  __j  ||  |  |  ||    \ \__  T
|   |   ||     Y/  |  |l  `  '  !|     Y/  \ |
|   |   ||  .  |\  `  | \      / |  .  |\    |
l___j___jl__j\_j \____j  \_/\_/  l__j\_j \___j
```

> **🤖 Built entirely by GitHub Copilot** - This complete JWKS key management system was designed, implemented, and documented by AI!

# mkjwks

This repository provides scripts and automation for generating and rolling JSON Web Key Sets (JWKS) for signing (RS256, RSA 2048-bit by default). Each key includes a unique `kid` (Key ID) based on ISO 8601 creation timestamp for easy identification and tracking.

## Scripts

- `scripts/generate_jwks.sh`: Generates N RSA key pairs (default 2), builds JWKS files for public and private keys. Accepts parameters for number of keys, algorithm, and key size. Uses `scripts/tmp/` for intermediate files. Each key gets a unique `kid` with ISO 8601 timestamp format (e.g., `2025-06-14T05:29:40Z`).
- `scripts/roll_jwks_key.sh`: Rolls the primary key by extracting the current first key from `jwks_public.json` to become the second key, generates a new first key with ISO timestamp-based `kid`, and updates JWKS files. Accepts parameters for algorithm and key size. Uses `scripts/tmp/` for intermediate files and reads from existing JWKS for persistence across GitHub Actions runs.

## Key Files

- `scripts/tmp/rsa*.json`: Temporary private RSA keys (ignored by git).
- `scripts/tmp/rsa*_pub.json`: Temporary public RSA keys (ignored by git).
- `jwks_private.json`: JWKS containing both private keys (ignored by git).
- `jwks_public.json`: JWKS containing both public keys (tracked in git).

## GitHub Actions

A workflow in `.github/workflows/roll-jwks-key.yml` automatically:
- Checks if `jwks_public.json` exists
- If not found, runs `generate_jwks.sh` to create initial keys
- If found, runs `roll_jwks_key.sh` to roll the primary key
- Commits changes to `jwks_public.json` every 48 hours

## .gitignore

Private and working key files are ignored by git for security:

```
scripts/tmp/
jwks_private.json
```

## Requirements

- [jose](https://github.com/latchset/jose)
- [jq](https://stedolan.github.io/jq/)

## Usage

To generate new keys (defaults: 2 keys, RS256, 2048 bits):

```sh
bash scripts/generate_jwks.sh
```

Or specify parameters:

```sh
bash scripts/generate_jwks.sh [NUM_KEYS] [ALG] [KEY_SIZE]
# Example: bash scripts/generate_jwks.sh 3 RS256 3072
```

To roll the primary key (defaults: RS256, 2048 bits):

```sh
bash scripts/roll_jwks_key.sh
```

Or specify parameters:

```sh
bash scripts/roll_jwks_key.sh [ALG] [KEY_SIZE]
# Example: bash scripts/roll_jwks_key.sh RS256 3072
```

## Key Management

The roll script is designed to work across GitHub Actions runs:
- Reads existing keys from the persistent `jwks_public.json` file
- Does not depend on temporary files being available between runs
- Only the public JWKS file is committed to the repository
- Private keys are regenerated as needed and stored only temporarily
- Each key includes a unique `kid` (Key ID) with ISO 8601 timestamp (e.g., `2025-06-14T05:29:40Z`) for easy identification and tracking during rotation