#!/bin/bash
# Roll the first key: move old rsa1 to rsa2, generate new rsa1
# Parameterized for algorithm and key size

ALG=${1:-RS256}
KEY_SIZE=${2:-2048}

TMPDIR="$(dirname "$0")/tmp"
REPOROOT="$(dirname "$0")/.."
mkdir -p "$TMPDIR"

# Extract the old first key (rsa1) from jwks_public.json to become rsa2
jq '.keys[0]' "$REPOROOT/jwks_public.json" > "$TMPDIR/rsa2_pub.json"

# Generate new key 1
KID=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jose jwk gen -i "{\"alg\":\"$ALG\",\"use\":\"sig\",\"kid\":\"$KID\"}" -s $KEY_SIZE | jq '.keys[0]' > "$TMPDIR/rsa1.json"
jose jwk pub -i "$TMPDIR/rsa1.json" > "$TMPDIR/rsa1_pub.json"

echo "Rolled rsa1.json (alg: $ALG, size: $KEY_SIZE, kid: $KID) in $TMPDIR"

# Combine private keys into a JWKS at repo root (only new key has private, old key public only)
cat "$TMPDIR/rsa1.json" "$TMPDIR/rsa2_pub.json" | jq -s '{"keys": .}' > "$REPOROOT/jwks_private.json"

# Combine public keys into a JWKS at repo root
cat "$TMPDIR"/rsa1_pub.json "$TMPDIR"/rsa2_pub.json | jq -s '{"keys": .}' > "$REPOROOT/jwks_public.json"

echo "Key rollover complete. JWKS files updated."
